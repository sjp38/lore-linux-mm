Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id C88866B026A
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:37:06 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id l124so212814841ywb.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:37:06 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0077.outbound.protection.outlook.com. [104.47.34.77])
        by mx.google.com with ESMTPS id w135si982851oia.219.2016.11.09.16.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:37:06 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 11/20] x86: Add support for changing memory
 encryption attribute
Date: Wed, 9 Nov 2016 18:36:55 -0600
Message-ID: <20161110003655.3280.57333.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch adds support to be change the memory encryption attribute for
one or more memory pages.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cacheflush.h  |    3 +
 arch/x86/include/asm/mem_encrypt.h |   13 ++++++
 arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
 arch/x86/mm/pageattr.c             |   73 ++++++++++++++++++++++++++++++++++++
 4 files changed, 132 insertions(+)

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
index 0b40f79..d544481 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -21,6 +21,9 @@
 
 extern unsigned long sme_me_mask;
 
+int sme_set_mem_enc(void *vaddr, unsigned long size);
+int sme_set_mem_unenc(void *vaddr, unsigned long size);
+
 void __init sme_early_mem_enc(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_mem_dec(resource_size_t paddr,
@@ -39,6 +42,16 @@ void __init sme_early_init(void);
 
 #define sme_me_mask	0UL
 
+static inline int sme_set_mem_enc(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
+static inline int sme_set_mem_unenc(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
 static inline void __init sme_early_mem_enc(resource_size_t paddr,
 					    unsigned long size)
 {
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 411210d..41cfdf9 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -18,6 +18,7 @@
 #include <asm/fixmap.h>
 #include <asm/setup.h>
 #include <asm/bootparam.h>
+#include <asm/cacheflush.h>
 
 extern pmdval_t early_pmd_flags;
 int __init __early_make_pgtable(unsigned long, pmdval_t);
@@ -33,6 +34,48 @@ EXPORT_SYMBOL_GPL(sme_me_mask);
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
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
+int sme_set_mem_unenc(void *vaddr, unsigned long size)
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
+EXPORT_SYMBOL_GPL(sme_set_mem_unenc);
+
 /*
  * This routine does not change the underlying encryption setting of the
  * page(s) that map this memory. It assumes that eventually the memory is
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index b8e6bb5..babf3a6 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1729,6 +1729,79 @@ int set_memory_4k(unsigned long addr, int numpages)
 					__pgprot(0), 1, 0, NULL);
 }
 
+static int __set_memory_enc_dec(struct cpa_data *cpa)
+{
+	unsigned long addr;
+	int numpages;
+	int ret;
+
+	/* People should not be passing in unaligned addresses */
+	if (WARN_ONCE(*cpa->vaddr & ~PAGE_MASK,
+		      "misaligned address: %#lx\n", *cpa->vaddr))
+		*cpa->vaddr &= PAGE_MASK;
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
