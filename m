Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D27D2680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:45:46 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id j49so21805495otb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:45:46 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0089.outbound.protection.outlook.com. [104.47.36.89])
        by mx.google.com with ESMTPS id 89si3457365ots.304.2017.02.16.07.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:45:46 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 16/28] x86: Add support for changing memory
 encryption attribute
Date: Thu, 16 Feb 2017 09:45:35 -0600
Message-ID: <20170216154535.19244.6294.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Add support for changing the memory encryption attribute for one or more
memory pages.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cacheflush.h |    3 ++
 arch/x86/mm/pageattr.c            |   66 +++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 872877d..33ae60a 100644
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
index 91c5c63..9710f5c 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1742,6 +1742,72 @@ int set_memory_4k(unsigned long addr, int numpages)
 					__pgprot(0), 1, 0, NULL);
 }
 
+static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
+{
+	struct cpa_data cpa;
+	unsigned long start;
+	int ret;
+
+	/* Nothing to do if the _PAGE_ENC attribute is zero */
+	if (_PAGE_ENC == 0)
+		return 0;
+
+	/* Save original start address since it will be modified */
+	start = addr;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = enc ? __pgprot(_PAGE_ENC) : __pgprot(0);
+	cpa.mask_clr = enc ? __pgprot(0) : __pgprot(_PAGE_ENC);
+	cpa.pgd = init_mm.pgd;
+
+	/* Should not be working on unaligned addresses */
+	if (WARN_ONCE(*cpa.vaddr & ~PAGE_MASK,
+		      "misaligned address: %#lx\n", *cpa.vaddr))
+		*cpa.vaddr &= PAGE_MASK;
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
+EXPORT_SYMBOL(set_memory_encrypted);
+
+int set_memory_decrypted(unsigned long addr, int numpages)
+{
+	return __set_memory_enc_dec(addr, numpages, false);
+}
+EXPORT_SYMBOL(set_memory_decrypted);
+
 int set_pages_uc(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
