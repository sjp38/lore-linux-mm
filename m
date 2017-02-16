Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 849B8680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:43:55 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id j49so21756113otb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:43:55 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0083.outbound.protection.outlook.com. [104.47.38.83])
        by mx.google.com with ESMTPS id v6si7600162ita.104.2017.02.16.07.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:43:54 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 08/28] x86: Extend the early_memremap support with
 additional attrs
Date: Thu, 16 Feb 2017 09:43:48 -0600
Message-ID: <20170216154348.19244.11884.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Add to the early_memremap support to be able to specify encrypted and
decrypted mappings with and without write-protection. The use of
write-protection is necessary when encrypting data "in place". The
write-protect attribute is considered cacheable for loads, but not
stores. This implies that the hardware will never give the core a
dirty line with this memtype.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/Kconfig                     |    4 +++
 arch/x86/include/asm/fixmap.h        |   13 ++++++++++
 arch/x86/include/asm/pgtable_types.h |    8 ++++++
 arch/x86/mm/ioremap.c                |   44 ++++++++++++++++++++++++++++++++++
 include/asm-generic/early_ioremap.h  |    2 ++
 mm/early_ioremap.c                   |   10 ++++++++
 6 files changed, 81 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a3b8c71..581eae4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1417,6 +1417,10 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
 	  If set to N, then the encryption of system memory can be
 	  activated with the mem_encrypt=on command line option.
 
+config ARCH_USE_MEMREMAP_PROT
+	def_bool y
+	depends on AMD_MEM_ENCRYPT
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index 83e91f0..8233373 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -160,6 +160,19 @@ static inline void __set_fixmap(enum fixed_addresses idx,
  */
 #define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
 
+/*
+ * Early memremap routines used for in-place encryption. The mappings created
+ * by these routines are intended to be used as temporary mappings.
+ */
+void __init *early_memremap_encrypted(resource_size_t phys_addr,
+				      unsigned long size);
+void __init *early_memremap_encrypted_wp(resource_size_t phys_addr,
+					 unsigned long size);
+void __init *early_memremap_decrypted(resource_size_t phys_addr,
+				      unsigned long size);
+void __init *early_memremap_decrypted_wp(resource_size_t phys_addr,
+					 unsigned long size);
+
 #include <asm-generic/fixmap.h>
 
 #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 500fc60..f00e70f 100644
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
+#define __PAGE_KERNEL_NOENC	(__PAGE_KERNEL)
+#define __PAGE_KERNEL_NOENC_WP	(__PAGE_KERNEL_WP)
+
 #define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
 #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
 #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index c43b6b3..2385e70 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -419,6 +419,50 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
 }
 
+#ifdef CONFIG_ARCH_USE_MEMREMAP_PROT
+/* Remap memory with encryption */
+void __init *early_memremap_encrypted(resource_size_t phys_addr,
+				      unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_ENC);
+}
+
+/*
+ * Remap memory with encryption and write-protected - cannot be called
+ * before pat_init() is called
+ */
+void __init *early_memremap_encrypted_wp(resource_size_t phys_addr,
+					 unsigned long size)
+{
+	/* Be sure the write-protect PAT entry is set for write-protect */
+	if (__pte2cachemode_tbl[_PAGE_CACHE_MODE_WP] != _PAGE_CACHE_MODE_WP)
+		return NULL;
+
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_ENC_WP);
+}
+
+/* Remap memory without encryption */
+void __init *early_memremap_decrypted(resource_size_t phys_addr,
+				      unsigned long size)
+{
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_NOENC);
+}
+
+/*
+ * Remap memory without encryption and write-protected - cannot be called
+ * before pat_init() is called
+ */
+void __init *early_memremap_decrypted_wp(resource_size_t phys_addr,
+					 unsigned long size)
+{
+	/* Be sure the write-protect PAT entry is set for write-protect */
+	if (__pte2cachemode_tbl[_PAGE_CACHE_MODE_WP] != _PAGE_CACHE_MODE_WP)
+		return NULL;
+
+	return early_memremap_prot(phys_addr, size, __PAGE_KERNEL_NOENC_WP);
+}
+#endif	/* CONFIG_ARCH_USE_MEMREMAP_PROT */
+
 static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
 
 static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
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
index 6d5717b..d7d30da 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -226,6 +226,16 @@ void __init early_iounmap(void __iomem *addr, unsigned long size)
 }
 #endif
 
+#ifdef CONFIG_ARCH_USE_MEMREMAP_PROT
+void __init *
+early_memremap_prot(resource_size_t phys_addr, unsigned long size,
+		    unsigned long prot_val)
+{
+	return (__force void *)__early_ioremap(phys_addr, size,
+					       __pgprot(prot_val));
+}
+#endif
+
 #define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
 
 void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
