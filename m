Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2EA6B0258
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:29:22 -0500 (EST)
Received: by wmec201 with SMTP id c201so153047865wme.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:21 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id n123si28454966wmg.124.2015.11.30.04.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 04:29:21 -0800 (PST)
Received: by wmvv187 with SMTP id v187so154086306wmv.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:20 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v4 05/13] arm64/efi: refactor EFI init and runtime code for reuse by 32-bit ARM
Date: Mon, 30 Nov 2015 13:28:19 +0100
Message-Id: <1448886507-3216-6-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This refactors the EFI init and runtime code that will be shared
between arm64 and ARM so that it can be built for both archs.

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/efi.h       |  9 ++++
 arch/arm64/kernel/efi.c            | 23 ++++++++++
 drivers/firmware/efi/arm-init.c    |  7 +--
 drivers/firmware/efi/arm-runtime.c | 48 +++++++-------------
 drivers/firmware/efi/efi.c         |  2 +
 5 files changed, 54 insertions(+), 35 deletions(-)

diff --git a/arch/arm64/include/asm/efi.h b/arch/arm64/include/asm/efi.h
index ef572206f1c3..8e88a696c9cb 100644
--- a/arch/arm64/include/asm/efi.h
+++ b/arch/arm64/include/asm/efi.h
@@ -2,7 +2,9 @@
 #define _ASM_EFI_H
 
 #include <asm/io.h>
+#include <asm/mmu_context.h>
 #include <asm/neon.h>
+#include <asm/tlbflush.h>
 
 #ifdef CONFIG_EFI
 extern void efi_init(void);
@@ -10,6 +12,8 @@ extern void efi_init(void);
 #define efi_init()
 #endif
 
+int efi_create_mapping(struct mm_struct *mm, efi_memory_desc_t *md);
+
 #define efi_call_virt(f, ...)						\
 ({									\
 	efi_##f##_t *__f;						\
@@ -63,6 +67,11 @@ extern void efi_init(void);
  *   Services are enabled and the EFI_RUNTIME_SERVICES bit set.
  */
 
+static inline void efi_set_pgd(struct mm_struct *mm)
+{
+	switch_mm(NULL, mm, NULL);
+}
+
 void efi_virtmap_load(void);
 void efi_virtmap_unload(void);
 
diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index bd3b2f5adf0c..b6abc852f2a1 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -17,6 +17,29 @@
 
 #include <asm/efi.h>
 
+int __init efi_create_mapping(struct mm_struct *mm, efi_memory_desc_t *md)
+{
+	pteval_t prot_val;
+
+	/*
+	 * Only regions of type EFI_RUNTIME_SERVICES_CODE need to be
+	 * executable, everything else can be mapped with the XN bits
+	 * set.
+	 */
+	if ((md->attribute & EFI_MEMORY_WB) == 0)
+		prot_val = PROT_DEVICE_nGnRE;
+	else if (md->type == EFI_RUNTIME_SERVICES_CODE ||
+		 !PAGE_ALIGNED(md->phys_addr))
+		prot_val = pgprot_val(PAGE_KERNEL_EXEC);
+	else
+		prot_val = pgprot_val(PAGE_KERNEL);
+
+	create_pgd_mapping(mm, md->phys_addr, md->virt_addr,
+			   md->num_pages << EFI_PAGE_SHIFT,
+			   __pgprot(prot_val | PTE_NG));
+	return 0;
+}
+
 static int __init arm64_dmi_init(void)
 {
 	/*
diff --git a/drivers/firmware/efi/arm-init.c b/drivers/firmware/efi/arm-init.c
index ffdd76a51929..9e15d571b53c 100644
--- a/drivers/firmware/efi/arm-init.c
+++ b/drivers/firmware/efi/arm-init.c
@@ -57,7 +57,7 @@ static int __init uefi_init(void)
 {
 	efi_char16_t *c16;
 	void *config_tables;
-	u64 table_size;
+	size_t table_size;
 	char vendor[100] = "unknown";
 	int i, retval;
 
@@ -69,7 +69,8 @@ static int __init uefi_init(void)
 	}
 
 	set_bit(EFI_BOOT, &efi.flags);
-	set_bit(EFI_64BIT, &efi.flags);
+	if (IS_ENABLED(CONFIG_64BIT))
+		set_bit(EFI_64BIT, &efi.flags);
 
 	/*
 	 * Verify the EFI Table
@@ -107,7 +108,7 @@ static int __init uefi_init(void)
 		goto out;
 	}
 	retval = efi_config_parse_tables(config_tables, efi.systab->nr_tables,
-					 sizeof(efi_config_table_64_t), NULL);
+					 sizeof(efi_config_table_t), NULL);
 
 	early_memunmap(config_tables, table_size);
 out:
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index 974743e13a4d..6ae21e41a429 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/efi.h>
+#include <linux/io.h>
 #include <linux/memblock.h>
 #include <linux/mm_types.h>
 #include <linux/preempt.h>
@@ -23,18 +24,14 @@
 
 #include <asm/cacheflush.h>
 #include <asm/efi.h>
-#include <asm/tlbflush.h>
-#include <asm/mmu_context.h>
 #include <asm/mmu.h>
+#include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 
-static pgd_t efi_pgd[PTRS_PER_PGD] __page_aligned_bss;
-
 extern u64 efi_system_table;
 
 static struct mm_struct efi_mm = {
 	.mm_rb			= RB_ROOT,
-	.pgd			= efi_pgd,
 	.mm_users		= ATOMIC_INIT(2),
 	.mm_count		= ATOMIC_INIT(1),
 	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
@@ -46,35 +43,27 @@ static bool __init efi_virtmap_init(void)
 {
 	efi_memory_desc_t *md;
 
+	efi_mm.pgd = pgd_alloc(&efi_mm);
 	init_new_context(NULL, &efi_mm);
 
 	for_each_efi_memory_desc(&memmap, md) {
-		pgprot_t prot;
+		phys_addr_t phys = md->phys_addr;
+		int ret;
 
 		if (!(md->attribute & EFI_MEMORY_RUNTIME))
 			continue;
 		if (md->virt_addr == 0)
 			return false;
 
-		pr_info("  EFI remap 0x%016llx => %p\n",
-			md->phys_addr, (void *)md->virt_addr);
-
-		/*
-		 * Only regions of type EFI_RUNTIME_SERVICES_CODE need to be
-		 * executable, everything else can be mapped with the XN bits
-		 * set.
-		 */
-		if ((md->attribute & EFI_MEMORY_WB) == 0)
-			prot = __pgprot(PROT_DEVICE_nGnRE);
-		else if (md->type == EFI_RUNTIME_SERVICES_CODE ||
-			 !PAGE_ALIGNED(md->phys_addr))
-			prot = PAGE_KERNEL_EXEC;
-		else
-			prot = PAGE_KERNEL;
-
-		create_pgd_mapping(&efi_mm, md->phys_addr, md->virt_addr,
-				   md->num_pages << EFI_PAGE_SHIFT,
-				   __pgprot(pgprot_val(prot) | PTE_NG));
+		ret = efi_create_mapping(&efi_mm, md);
+		if  (!ret) {
+			pr_info("  EFI remap %pa => %p\n",
+				&phys, (void *)(unsigned long)md->virt_addr);
+		} else {
+			pr_warn("  EFI remap %pa: failed to create mapping (%d)\n",
+				&phys, ret);
+			return false;
+		}
 	}
 	return true;
 }
@@ -84,7 +73,7 @@ static bool __init efi_virtmap_init(void)
  * non-early mapping of the UEFI system table and virtual mappings for all
  * EFI_MEMORY_RUNTIME regions.
  */
-static int __init arm64_enable_runtime_services(void)
+static int __init arm_enable_runtime_services(void)
 {
 	u64 mapsize;
 
@@ -131,12 +120,7 @@ static int __init arm64_enable_runtime_services(void)
 
 	return 0;
 }
-early_initcall(arm64_enable_runtime_services);
-
-static void efi_set_pgd(struct mm_struct *mm)
-{
-	switch_mm(NULL, mm, NULL);
-}
+early_initcall(arm_enable_runtime_services);
 
 void efi_virtmap_load(void)
 {
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 027ca212179f..cffa89b3317b 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -25,6 +25,8 @@
 #include <linux/io.h>
 #include <linux/platform_device.h>
 
+#include <asm/efi.h>
+
 struct efi __read_mostly efi = {
 	.mps			= EFI_INVALID_TABLE_ADDR,
 	.acpi			= EFI_INVALID_TABLE_ADDR,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
