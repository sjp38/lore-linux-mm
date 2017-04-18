Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9D62806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:19:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v1so1316136qtg.0
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:19:56 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0044.outbound.protection.outlook.com. [104.47.33.44])
        by mx.google.com with ESMTPS id e123si298696qkc.327.2017.04.18.14.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:19:55 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 20/32] x86/mm: Add support for changing the memory
 encryption attribute
Date: Tue, 18 Apr 2017 16:19:50 -0500
Message-ID: <20170418211950.10190.99981.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add support for changing the memory encryption attribute for one or more
memory pages. This will be useful when we have to change the AP trampoline
area to not be encrypted. Or when we need to change the SWIOTLB area to
not be encrypted in support of devices that can't support the encryption
mask range.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cacheflush.h |    3 ++
 arch/x86/mm/pageattr.c            |   62 +++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index e7e1942..e064f70 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -12,6 +12,7 @@
  * Executability : eXeutable, NoteXecutable
  * Read/Write    : ReadOnly, ReadWrite
  * Presence      : NotPresent
+ * Encryption    : Encrypted, Decrypted
  *
  * Within a category, the attributes are mutually exclusive.
  *
@@ -47,6 +48,8 @@
 int set_memory_rw(unsigned long addr, int numpages);
 int set_memory_np(unsigned long addr, int numpages);
 int set_memory_4k(unsigned long addr, int numpages);
+int set_memory_encrypted(unsigned long addr, int numpages);
+int set_memory_decrypted(unsigned long addr, int numpages);
 
 int set_memory_array_uc(unsigned long *addr, int addrinarray);
 int set_memory_array_wc(unsigned long *addr, int addrinarray);
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 669fa48..0a850b1 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1768,6 +1768,68 @@ int set_memory_4k(unsigned long addr, int numpages)
 					__pgprot(0), 1, 0, NULL);
 }
 
+static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
+{
+	struct cpa_data cpa;
+	unsigned long start;
+	int ret;
+
+	/* Nothing to do if the SME is not active */
+	if (!sme_active())
+		return 0;
+
+	/* Should not be working on unaligned addresses */
+	if (WARN_ONCE(addr & ~PAGE_MASK, "misaligned address: %#lx\n", addr))
+		addr &= PAGE_MASK;
+
+	start = addr;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = enc ? __pgprot(_PAGE_ENC) : __pgprot(0);
+	cpa.mask_clr = enc ? __pgprot(0) : __pgprot(_PAGE_ENC);
+	cpa.pgd = init_mm.pgd;
+
+	/* Must avoid aliasing mappings in the highmem code */
+	kmap_flush_unused();
+	vm_unmap_aliases();
+
+	/*
+	 * Before changing the encryption attribute, we need to flush caches.
+	 */
+	if (static_cpu_has(X86_FEATURE_CLFLUSH))
+		cpa_flush_range(start, numpages, 1);
+	else
+		cpa_flush_all(1);
+
+	ret = __change_page_attr_set_clr(&cpa, 1);
+
+	/*
+	 * After changing the encryption attribute, we need to flush TLBs
+	 * again in case any speculative TLB caching occurred (but no need
+	 * to flush caches again).  We could just use cpa_flush_all(), but
+	 * in case TLB flushing gets optimized in the cpa_flush_range()
+	 * path use the same logic as above.
+	 */
+	if (static_cpu_has(X86_FEATURE_CLFLUSH))
+		cpa_flush_range(start, numpages, 0);
+	else
+		cpa_flush_all(0);
+
+	return ret;
+}
+
+int set_memory_encrypted(unsigned long addr, int numpages)
+{
+	return __set_memory_enc_dec(addr, numpages, true);
+}
+
+int set_memory_decrypted(unsigned long addr, int numpages)
+{
+	return __set_memory_enc_dec(addr, numpages, false);
+}
+
 int set_pages_uc(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
