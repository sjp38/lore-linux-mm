Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 308D62806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:18:16 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a3so4032088oii.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:18:16 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0051.outbound.protection.outlook.com. [104.47.34.51])
        by mx.google.com with ESMTPS id 88si129250oty.337.2017.04.18.14.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:18:15 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 10/32] x86/mm: Extend early_memremap() support with
 additional attrs
Date: Tue, 18 Apr 2017 16:18:04 -0500
Message-ID: <20170418211804.10190.34358.stgit@tlendack-t1.amdoffice.net>
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

Add early_memremap() support to be able to specify encrypted and
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
index cf0cbe8..6bc52d3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1429,6 +1429,10 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
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
index d9ff226..dcd9fb5 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -164,6 +164,19 @@ static inline void __set_fixmap(enum fixed_addresses idx,
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
index d3ae99c..ce8cb1c 100644
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
index e4f7b25..9bfcb1f 100644
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
