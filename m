Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBEE6B0265
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:37:54 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id h3so270431170ybi.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:37:54 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0045.outbound.protection.outlook.com. [104.47.38.45])
        by mx.google.com with ESMTPS id r24si263381qkh.31.2016.08.22.15.37.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:37:53 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 12/20] x86: Add support for changing memory
 encryption attribute
Date: Mon, 22 Aug 2016 17:37:49 -0500
Message-ID: <20160822223749.29880.10183.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch adds support to be change the memory encryption attribute for
one or more memory pages.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cacheflush.h  |    3 +
 arch/x86/include/asm/mem_encrypt.h |   13 ++++++
 arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
 arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
 4 files changed, 134 insertions(+)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 61518cf..bfb08e5 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -13,6 +13,7 @@
  * Executability : eXeutable, NoteXecutable
  * Read/Write    : ReadOnly, ReadWrite
  * Presence      : NotPresent
+ * Encryption    : ENCrypted, DECrypted
  *
  * Within a category, the attributes are mutually exclusive.
  *
@@ -48,6 +49,8 @@ int set_memory_ro(unsigned long addr, int numpages);
 int set_memory_rw(unsigned long addr, int numpages);
 int set_memory_np(unsigned long addr, int numpages);
 int set_memory_4k(unsigned long addr, int numpages);
+int set_memory_enc(unsigned long addr, int numpages);
+int set_memory_dec(unsigned long addr, int numpages);
 
 int set_memory_array_uc(unsigned long *addr, int addrinarray);
 int set_memory_array_wc(unsigned long *addr, int addrinarray);
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 2785493..5616ed1 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -23,6 +23,9 @@ extern unsigned long sme_me_mask;
 
 u8 sme_get_me_loss(void);
 
+int sme_set_mem_enc(void *vaddr, unsigned long size);
+int sme_set_mem_dec(void *vaddr, unsigned long size);
+
 void __init sme_early_mem_enc(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_mem_dec(resource_size_t paddr,
@@ -44,6 +47,16 @@ static inline u8 sme_get_me_loss(void)
 	return 0;
 }
 
+static inline int sme_set_mem_enc(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
+static inline int sme_set_mem_dec(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
 static inline void __init sme_early_mem_enc(resource_size_t paddr,
 					    unsigned long size)
 {
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index f35a646..b0f39c5 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,12 +14,55 @@
 #include <linux/mm.h>
 
 #include <asm/mem_encrypt.h>
+#include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char me_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
+int sme_set_mem_enc(void *vaddr, unsigned long size)
+{
+	unsigned long addr, numpages;
+
+	if (!sme_me_mask)
+		return 0;
+
+	addr = (unsigned long)vaddr & PAGE_MASK;
+	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	/*
+	 * The set_memory_xxx functions take an integer for numpages, make
+	 * sure it doesn't exceed that.
+	 */
+	if (numpages > INT_MAX)
+		return -EINVAL;
+
+	return set_memory_enc(addr, numpages);
+}
+EXPORT_SYMBOL_GPL(sme_set_mem_enc);
+
+int sme_set_mem_dec(void *vaddr, unsigned long size)
+{
+	unsigned long addr, numpages;
+
+	if (!sme_me_mask)
+		return 0;
+
+	addr = (unsigned long)vaddr & PAGE_MASK;
+	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	/*
+	 * The set_memory_xxx functions take an integer for numpages, make
+	 * sure it doesn't exceed that.
+	 */
+	if (numpages > INT_MAX)
+		return -EINVAL;
+
+	return set_memory_dec(addr, numpages);
+}
+EXPORT_SYMBOL_GPL(sme_set_mem_dec);
+
 /*
  * This routine does not change the underlying encryption setting of the
  * page(s) that map this memory. It assumes that eventually the memory is
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 72c292d..0ba9382 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1728,6 +1728,81 @@ int set_memory_4k(unsigned long addr, int numpages)
 					__pgprot(0), 1, 0, NULL);
 }
 
+static int __set_memory_enc_dec(struct cpa_data *cpa)
+{
+	unsigned long addr;
+	int numpages;
+	int ret;
+
+	if (*cpa->vaddr & ~PAGE_MASK) {
+		*cpa->vaddr &= PAGE_MASK;
+
+		/* People should not be passing in unaligned addresses */
+		WARN_ON_ONCE(1);
+	}
+
+	addr = *cpa->vaddr;
+	numpages = cpa->numpages;
+
+	/* Must avoid aliasing mappings in the highmem code */
+	kmap_flush_unused();
+	vm_unmap_aliases();
+
+	ret = __change_page_attr_set_clr(cpa, 1);
+
+	/* Check whether we really changed something */
+	if (!(cpa->flags & CPA_FLUSHTLB))
+		goto out;
+
+	/*
+	 * On success we use CLFLUSH, when the CPU supports it to
+	 * avoid the WBINVD.
+	 */
+	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
+		cpa_flush_range(addr, numpages, 1);
+	else
+		cpa_flush_all(1);
+
+out:
+	return ret;
+}
+
+int set_memory_enc(unsigned long addr, int numpages)
+{
+	struct cpa_data cpa;
+
+	if (!sme_me_mask)
+		return 0;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = __pgprot(_PAGE_ENC);
+	cpa.mask_clr = __pgprot(0);
+	cpa.pgd = init_mm.pgd;
+
+	return __set_memory_enc_dec(&cpa);
+}
+EXPORT_SYMBOL(set_memory_enc);
+
+int set_memory_dec(unsigned long addr, int numpages)
+{
+	struct cpa_data cpa;
+
+	if (!sme_me_mask)
+		return 0;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = __pgprot(0);
+	cpa.mask_clr = __pgprot(_PAGE_ENC);
+	cpa.pgd = init_mm.pgd;
+
+	return __set_memory_enc_dec(&cpa);
+}
+EXPORT_SYMBOL(set_memory_dec);
+
 int set_pages_uc(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
