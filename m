Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83EED6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:36:17 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id rf5so83861490pab.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:36:17 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0041.outbound.protection.outlook.com. [104.47.32.41])
        by mx.google.com with ESMTPS id a66si1871382pfe.90.2016.11.09.16.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:36:16 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 08/20] x86: Add support for early
 encryption/decryption of memory
Date: Wed, 9 Nov 2016 18:36:10 -0600
Message-ID: <20161110003610.3280.22043.stgit@tlendack-t1.amdoffice.net>
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

Add support to be able to either encrypt or decrypt data in place during
the early stages of booting the kernel. This does not change the memory
encryption attribute - it is used for ensuring that data present in either
an encrypted or un-encrypted memory area is in the proper state (for
example the initrd will have been loaded by the boot loader and will not be
encrypted, but the memory that it resides in is marked as encrypted).

The early_memmap support is enhanced to specify encrypted and un-encrypted
mappings with and without write-protection. The use of write-protection is
necessary when encrypting data "in place". The write-protect attribute is
considered cacheable for loads, but not stores. This implies that the
hardware will never give the core a dirty line with this memtype.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/fixmap.h        |    9 +++
 arch/x86/include/asm/mem_encrypt.h   |   15 +++++
 arch/x86/include/asm/pgtable_types.h |    8 +++
 arch/x86/mm/ioremap.c                |   28 +++++++++
 arch/x86/mm/mem_encrypt.c            |  102 ++++++++++++++++++++++++++++++++++
 include/asm-generic/early_ioremap.h  |    2 +
 mm/early_ioremap.c                   |   15 +++++
 7 files changed, 179 insertions(+)

diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index 83e91f0..4d41878 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -160,6 +160,15 @@ static inline void __set_fixmap(enum fixed_addresses idx,
  */
 #define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
 
+void __init *early_memremap_enc(resource_size_t phys_addr,
+				unsigned long size);
+void __init *early_memremap_enc_wp(resource_size_t phys_addr,
+				   unsigned long size);
+void __init *early_memremap_dec(resource_size_t phys_addr,
+				unsigned long size);
+void __init *early_memremap_dec_wp(resource_size_t phys_addr,
+				   unsigned long size);
+
 #include <asm-generic/fixmap.h>
 
 #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 5f1976d..2a8e186 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -21,6 +21,11 @@
 
 extern unsigned long sme_me_mask;
 
+void __init sme_early_mem_enc(resource_size_t paddr,
+			      unsigned long size);
+void __init sme_early_mem_dec(resource_size_t paddr,
+			      unsigned long size);
+
 void __init sme_early_init(void);
 
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
@@ -30,6 +35,16 @@ void __init sme_early_init(void);
 
 #define sme_me_mask	0UL
 
+static inline void __init sme_early_mem_enc(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
+static inline void __init sme_early_mem_dec(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
 static inline void __init sme_early_init(void)
 {
 }
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index cbfb83e..c456d56 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -161,6 +161,7 @@ enum page_cache_mode {
 
 #define _PAGE_CACHE_MASK	(_PAGE_PAT | _PAGE_PCD | _PAGE_PWT)
 #define _PAGE_NOCACHE		(cachemode2protval(_PAGE_CACHE_MODE_UC))
+#define _PAGE_CACHE_WP		(cachemode2protval(_PAGE_CACHE_MODE_WP))
 
 #define PAGE_NONE	__pgprot(_PAGE_PROTNONE | _PAGE_ACCESSED)
 #define PAGE_SHARED	__pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | \
@@ -189,6 +190,7 @@ enum page_cache_mode {
 #define __PAGE_KERNEL_VVAR		(__PAGE_KERNEL_RO | _PAGE_USER)
 #define __PAGE_KERNEL_LARGE		(__PAGE_KERNEL | _PAGE_PSE)
 #define __PAGE_KERNEL_LARGE_EXEC	(__PAGE_KERNEL_EXEC | _PAGE_PSE)
+#define __PAGE_KERNEL_WP		(__PAGE_KERNEL | _PAGE_CACHE_WP)
 
 #define __PAGE_KERNEL_IO		(__PAGE_KERNEL)
 #define __PAGE_KERNEL_IO_NOCACHE	(__PAGE_KERNEL_NOCACHE)
@@ -202,6 +204,12 @@ enum page_cache_mode {
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
 			 _PAGE_DIRTY | _PAGE_ENC)
 
+#define __PAGE_KERNEL_ENC	(__PAGE_KERNEL | _PAGE_ENC)
+#define __PAGE_KERNEL_ENC_WP	(__PAGE_KERNEL_WP | _PAGE_ENC)
+
+#define __PAGE_KERNEL_DEC	(__PAGE_KERNEL)
+#define __PAGE_KERNEL_DEC_WP	(__PAGE_KERNEL_WP)
+
 #define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
 #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
 #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 7aaa263..ff542cd 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -418,6 +418,34 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
 }
 
+/* Remap memory with encryption */
+void __init *early_memremap_enc(resource_size_t phys_addr,
+				unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_ENC);
+}
+
+/* Remap memory with encryption and write-protected */
+void __init *early_memremap_enc_wp(resource_size_t phys_addr,
+				   unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_ENC_WP);
+}
+
+/* Remap memory without encryption */
+void __init *early_memremap_dec(resource_size_t phys_addr,
+				unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_DEC);
+}
+
+/* Remap memory without encryption and write-protected */
+void __init *early_memremap_dec_wp(resource_size_t phys_addr,
+				   unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_DEC_WP);
+}
+
 static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
 
 static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index d642cc5..06235b4 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,6 +14,9 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 
+#include <asm/tlbflush.h>
+#include <asm/fixmap.h>
+
 extern pmdval_t early_pmd_flags;
 
 /*
@@ -24,6 +27,105 @@ extern pmdval_t early_pmd_flags;
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
 
+/* Buffer used for early in-place encryption by BSP, no locking needed */
+static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
+
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as encrypted but the contents are currently not
+ * encrypted.
+ */
+void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
+{
+	void *src, *dst;
+	size_t len;
+
+	if (!sme_me_mask)
+		return;
+
+	local_flush_tlb();
+	wbinvd();
+
+	/*
+	 * There are limited number of early mapping slots, so map (at most)
+	 * one page at time.
+	 */
+	while (size) {
+		len = min_t(size_t, sizeof(sme_early_buffer), size);
+
+		/* Create a mapping for non-encrypted write-protected memory */
+		src = early_memremap_dec_wp(paddr, len);
+
+		/* Create a mapping for encrypted memory */
+		dst = early_memremap_enc(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the encryption,
+		 * then encrypted access to that area will end up causing
+		 * a crash.
+		 */
+		BUG_ON(!src || !dst);
+
+		memcpy(sme_early_buffer, src, len);
+		memcpy(dst, sme_early_buffer, len);
+
+		early_memunmap(dst, len);
+		early_memunmap(src, len);
+
+		paddr += len;
+		size -= len;
+	}
+}
+
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as not encrypted but the contents are currently
+ * encrypted.
+ */
+void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
+{
+	void *src, *dst;
+	size_t len;
+
+	if (!sme_me_mask)
+		return;
+
+	local_flush_tlb();
+	wbinvd();
+
+	/*
+	 * There are limited number of early mapping slots, so map (at most)
+	 * one page at time.
+	 */
+	while (size) {
+		len = min_t(size_t, sizeof(sme_early_buffer), size);
+
+		/* Create a mapping for encrypted write-protected memory */
+		src = early_memremap_enc_wp(paddr, len);
+
+		/* Create a mapping for non-encrypted memory */
+		dst = early_memremap_dec(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the decryption,
+		 * then un-encrypted access to that area will end up causing
+		 * a crash.
+		 */
+		BUG_ON(!src || !dst);
+
+		memcpy(sme_early_buffer, src, len);
+		memcpy(dst, sme_early_buffer, len);
+
+		early_memunmap(dst, len);
+		early_memunmap(src, len);
+
+		paddr += len;
+		size -= len;
+	}
+}
+
 void __init sme_early_init(void)
 {
 	unsigned int i;
diff --git a/include/asm-generic/early_ioremap.h b/include/asm-generic/early_ioremap.h
index 734ad4d..2edef8d 100644
--- a/include/asm-generic/early_ioremap.h
+++ b/include/asm-generic/early_ioremap.h
@@ -13,6 +13,8 @@ extern void *early_memremap(resource_size_t phys_addr,
 			    unsigned long size);
 extern void *early_memremap_ro(resource_size_t phys_addr,
 			       unsigned long size);
+extern void *early_memremap_prot(resource_size_t phys_addr,
+				 unsigned long size, unsigned long prot_val);
 extern void early_iounmap(void __iomem *addr, unsigned long size);
 extern void early_memunmap(void *addr, unsigned long size);
 
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index 6d5717b..d71b98b 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -226,6 +226,14 @@ early_memremap_ro(resource_size_t phys_addr, unsigned long size)
 }
 #endif
 
+void __init *
+early_memremap_prot(resource_size_t phys_addr, unsigned long size,
+		    unsigned long prot_val)
+{
+	return (__force void *)__early_ioremap(phys_addr, size,
+					       __pgprot(prot_val));
+}
+
 #define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
 
 void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
@@ -267,6 +275,13 @@ early_memremap_ro(resource_size_t phys_addr, unsigned long size)
 	return (void *)phys_addr;
 }
 
+void __init *
+early_memremap_prot(resource_size_t phys_addr, unsigned long size,
+		    unsigned long prot_val)
+{
+	return (void *)phys_addr;
+}
+
 void __init early_iounmap(void __iomem *addr, unsigned long size)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
