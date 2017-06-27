Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 452766B03C1
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:09:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u36so29665023pgn.5
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:09:42 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0048.outbound.protection.outlook.com. [104.47.32.48])
        by mx.google.com with ESMTPS id b15si2340662plk.613.2017.06.27.08.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:09:41 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 12/38] x86/mm: Extend early_memremap() support
 with additional attrs
Date: Tue, 27 Jun 2017 10:09:29 -0500
Message-ID: <20170627150929.17428.31589.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add early_memremap() support to be able to specify encrypted and
decrypted mappings with and without write-protection. The use of
write-protection is necessary when encrypting data "in place". The
write-protect attribute is considered cacheable for loads, but not
stores. This implies that the hardware will never give the core a
dirty line with this memtype.

Reviewed-by: Borislav Petkov <bp@suse.de>
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
index 3a59e9c..a04081ce 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1434,6 +1434,10 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
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
index de32ca3..32095af 100644
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
index bfc3e2d..26db273 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -414,6 +414,50 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
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
