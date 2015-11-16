Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4506B0257
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:32:57 -0500 (EST)
Received: by wmec201 with SMTP id c201so191324239wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:56 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id f6si27386354wma.122.2015.11.16.10.32.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:32:55 -0800 (PST)
Received: by wmvv187 with SMTP id v187so191188757wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:55 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 04/12] arm64/efi: split off EFI init and runtime code for reuse by 32-bit ARM
Date: Mon, 16 Nov 2015 19:32:29 +0100
Message-Id: <1447698757-8762-5-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, linux@arm.linux.org.uk, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org
Cc: msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This splits off the early EFI init and runtime code that
- discovers the EFI params and the memory map from the FDT, and installs
  the memblocks and config tables.
- prepares and installs the EFI page tables so that UEFI Runtime Services
  can be invoked at the virtual address installed by the stub.

This will allow it to be reused for 32-bit ARM.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/efi.c            | 323 +-------------------
 drivers/firmware/efi/Makefile      |   3 +
 drivers/firmware/efi/arm-init.c    | 196 ++++++++++++
 drivers/firmware/efi/arm-runtime.c | 160 ++++++++++
 4 files changed, 360 insertions(+), 322 deletions(-)

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index c7c7fb417110..bd3b2f5adf0c 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -11,308 +11,11 @@
  *
  */
 
-#include <linux/atomic.h>
 #include <linux/dmi.h>
 #include <linux/efi.h>
-#include <linux/export.h>
-#include <linux/memblock.h>
-#include <linux/mm_types.h>
-#include <linux/bootmem.h>
-#include <linux/of.h>
-#include <linux/of_fdt.h>
-#include <linux/preempt.h>
-#include <linux/rbtree.h>
-#include <linux/rwsem.h>
-#include <linux/sched.h>
-#include <linux/slab.h>
-#include <linux/spinlock.h>
+#include <linux/init.h>
 
-#include <asm/cacheflush.h>
 #include <asm/efi.h>
-#include <asm/tlbflush.h>
-#include <asm/mmu_context.h>
-#include <asm/mmu.h>
-#include <asm/pgtable.h>
-
-struct efi_memory_map memmap;
-
-static u64 efi_system_table;
-
-static pgd_t efi_pgd[PTRS_PER_PGD] __page_aligned_bss;
-
-static struct mm_struct efi_mm = {
-	.mm_rb			= RB_ROOT,
-	.pgd			= efi_pgd,
-	.mm_users		= ATOMIC_INIT(2),
-	.mm_count		= ATOMIC_INIT(1),
-	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
-	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
-	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
-};
-
-static int __init is_normal_ram(efi_memory_desc_t *md)
-{
-	if (md->attribute & EFI_MEMORY_WB)
-		return 1;
-	return 0;
-}
-
-/*
- * Translate a EFI virtual address into a physical address: this is necessary,
- * as some data members of the EFI system table are virtually remapped after
- * SetVirtualAddressMap() has been called.
- */
-static phys_addr_t efi_to_phys(unsigned long addr)
-{
-	efi_memory_desc_t *md;
-
-	for_each_efi_memory_desc(&memmap, md) {
-		if (!(md->attribute & EFI_MEMORY_RUNTIME))
-			continue;
-		if (md->virt_addr == 0)
-			/* no virtual mapping has been installed by the stub */
-			break;
-		if (md->virt_addr <= addr &&
-		    (addr - md->virt_addr) < (md->num_pages << EFI_PAGE_SHIFT))
-			return md->phys_addr + addr - md->virt_addr;
-	}
-	return addr;
-}
-
-static int __init uefi_init(void)
-{
-	efi_char16_t *c16;
-	void *config_tables;
-	u64 table_size;
-	char vendor[100] = "unknown";
-	int i, retval;
-
-	efi.systab = early_memremap(efi_system_table,
-				    sizeof(efi_system_table_t));
-	if (efi.systab == NULL) {
-		pr_warn("Unable to map EFI system table.\n");
-		return -ENOMEM;
-	}
-
-	set_bit(EFI_BOOT, &efi.flags);
-	set_bit(EFI_64BIT, &efi.flags);
-
-	/*
-	 * Verify the EFI Table
-	 */
-	if (efi.systab->hdr.signature != EFI_SYSTEM_TABLE_SIGNATURE) {
-		pr_err("System table signature incorrect\n");
-		retval = -EINVAL;
-		goto out;
-	}
-	if ((efi.systab->hdr.revision >> 16) < 2)
-		pr_warn("Warning: EFI system table version %d.%02d, expected 2.00 or greater\n",
-			efi.systab->hdr.revision >> 16,
-			efi.systab->hdr.revision & 0xffff);
-
-	/* Show what we know for posterity */
-	c16 = early_memremap(efi_to_phys(efi.systab->fw_vendor),
-			     sizeof(vendor) * sizeof(efi_char16_t));
-	if (c16) {
-		for (i = 0; i < (int) sizeof(vendor) - 1 && *c16; ++i)
-			vendor[i] = c16[i];
-		vendor[i] = '\0';
-		early_memunmap(c16, sizeof(vendor) * sizeof(efi_char16_t));
-	}
-
-	pr_info("EFI v%u.%.02u by %s\n",
-		efi.systab->hdr.revision >> 16,
-		efi.systab->hdr.revision & 0xffff, vendor);
-
-	table_size = sizeof(efi_config_table_64_t) * efi.systab->nr_tables;
-	config_tables = early_memremap(efi_to_phys(efi.systab->tables),
-				       table_size);
-
-	retval = efi_config_parse_tables(config_tables, efi.systab->nr_tables,
-					 sizeof(efi_config_table_64_t), NULL);
-
-	early_memunmap(config_tables, table_size);
-out:
-	early_memunmap(efi.systab,  sizeof(efi_system_table_t));
-	return retval;
-}
-
-/*
- * Return true for RAM regions we want to permanently reserve.
- */
-static __init int is_reserve_region(efi_memory_desc_t *md)
-{
-	switch (md->type) {
-	case EFI_LOADER_CODE:
-	case EFI_LOADER_DATA:
-	case EFI_BOOT_SERVICES_CODE:
-	case EFI_BOOT_SERVICES_DATA:
-	case EFI_CONVENTIONAL_MEMORY:
-	case EFI_PERSISTENT_MEMORY:
-		return 0;
-	default:
-		break;
-	}
-	return is_normal_ram(md);
-}
-
-static __init void reserve_regions(void)
-{
-	efi_memory_desc_t *md;
-	u64 paddr, npages, size;
-
-	if (efi_enabled(EFI_DBG))
-		pr_info("Processing EFI memory map:\n");
-
-	for_each_efi_memory_desc(&memmap, md) {
-		paddr = md->phys_addr;
-		npages = md->num_pages;
-
-		if (efi_enabled(EFI_DBG)) {
-			char buf[64];
-
-			pr_info("  0x%012llx-0x%012llx %s",
-				paddr, paddr + (npages << EFI_PAGE_SHIFT) - 1,
-				efi_md_typeattr_format(buf, sizeof(buf), md));
-		}
-
-		memrange_efi_to_native(&paddr, &npages);
-		size = npages << PAGE_SHIFT;
-
-		if (is_normal_ram(md))
-			early_init_dt_add_memory_arch(paddr, size);
-
-		if (is_reserve_region(md)) {
-			memblock_mark_nomap(paddr, size);
-			if (efi_enabled(EFI_DBG))
-				pr_cont("*");
-		}
-
-		if (efi_enabled(EFI_DBG))
-			pr_cont("\n");
-	}
-
-	set_bit(EFI_MEMMAP, &efi.flags);
-}
-
-void __init efi_init(void)
-{
-	struct efi_fdt_params params;
-
-	/* Grab UEFI information placed in FDT by stub */
-	if (!efi_get_fdt_params(&params))
-		return;
-
-	efi_system_table = params.system_table;
-
-	memmap.phys_map = params.mmap;
-	memmap.map = early_memremap(params.mmap, params.mmap_size);
-	memmap.map_end = memmap.map + params.mmap_size;
-	memmap.desc_size = params.desc_size;
-	memmap.desc_version = params.desc_ver;
-
-	if (uefi_init() < 0)
-		return;
-
-	reserve_regions();
-	early_memunmap(memmap.map, params.mmap_size);
-	memblock_mark_nomap(params.mmap & PAGE_MASK,
-			    PAGE_ALIGN(params.mmap_size +
-				       (params.mmap & ~PAGE_MASK)));
-}
-
-static bool __init efi_virtmap_init(void)
-{
-	efi_memory_desc_t *md;
-
-	for_each_efi_memory_desc(&memmap, md) {
-		u64 paddr, npages, size;
-		pgprot_t prot;
-
-		if (!(md->attribute & EFI_MEMORY_RUNTIME))
-			continue;
-		if (md->virt_addr == 0)
-			return false;
-
-		paddr = md->phys_addr;
-		npages = md->num_pages;
-		memrange_efi_to_native(&paddr, &npages);
-		size = npages << PAGE_SHIFT;
-
-		pr_info("  EFI remap 0x%016llx => %p\n",
-			md->phys_addr, (void *)md->virt_addr);
-
-		/*
-		 * Only regions of type EFI_RUNTIME_SERVICES_CODE need to be
-		 * executable, everything else can be mapped with the XN bits
-		 * set.
-		 */
-		if (!is_normal_ram(md))
-			prot = __pgprot(PROT_DEVICE_nGnRE);
-		else if (md->type == EFI_RUNTIME_SERVICES_CODE ||
-			 !PAGE_ALIGNED(md->phys_addr))
-			prot = PAGE_KERNEL_EXEC;
-		else
-			prot = PAGE_KERNEL;
-
-		create_pgd_mapping(&efi_mm, paddr, md->virt_addr, size, prot);
-	}
-	return true;
-}
-
-/*
- * Enable the UEFI Runtime Services if all prerequisites are in place, i.e.,
- * non-early mapping of the UEFI system table and virtual mappings for all
- * EFI_MEMORY_RUNTIME regions.
- */
-static int __init arm64_enable_runtime_services(void)
-{
-	u64 mapsize;
-
-	if (!efi_enabled(EFI_BOOT)) {
-		pr_info("EFI services will not be available.\n");
-		return -1;
-	}
-
-	if (efi_runtime_disabled()) {
-		pr_info("EFI runtime services will be disabled.\n");
-		return -1;
-	}
-
-	pr_info("Remapping and enabling EFI services.\n");
-
-	mapsize = memmap.map_end - memmap.map;
-	memmap.map = (__force void *)ioremap_cache(memmap.phys_map,
-						   mapsize);
-	if (!memmap.map) {
-		pr_err("Failed to remap EFI memory map\n");
-		return -1;
-	}
-	memmap.map_end = memmap.map + mapsize;
-	efi.memmap = &memmap;
-
-	efi.systab = (__force void *)ioremap_cache(efi_system_table,
-						   sizeof(efi_system_table_t));
-	if (!efi.systab) {
-		pr_err("Failed to remap EFI System Table\n");
-		return -1;
-	}
-	set_bit(EFI_SYSTEM_TABLES, &efi.flags);
-
-	if (!efi_virtmap_init()) {
-		pr_err("No UEFI virtual mapping was installed -- runtime services will not be available\n");
-		return -1;
-	}
-
-	/* Set up runtime services function pointers */
-	efi_native_runtime_setup();
-	set_bit(EFI_RUNTIME_SERVICES, &efi.flags);
-
-	efi.runtime_version = efi.systab->hdr.revision;
-
-	return 0;
-}
-early_initcall(arm64_enable_runtime_services);
 
 static int __init arm64_dmi_init(void)
 {
@@ -328,30 +31,6 @@ static int __init arm64_dmi_init(void)
 }
 core_initcall(arm64_dmi_init);
 
-static void efi_set_pgd(struct mm_struct *mm)
-{
-	if (mm == &init_mm)
-		cpu_set_reserved_ttbr0();
-	else
-		cpu_switch_mm(mm->pgd, mm);
-
-	local_flush_tlb_all();
-	if (icache_is_aivivt())
-		__local_flush_icache_all();
-}
-
-void efi_virtmap_load(void)
-{
-	preempt_disable();
-	efi_set_pgd(&efi_mm);
-}
-
-void efi_virtmap_unload(void)
-{
-	efi_set_pgd(current->active_mm);
-	preempt_enable();
-}
-
 /*
  * UpdateCapsule() depends on the system being shutdown via
  * ResetSystem().
diff --git a/drivers/firmware/efi/Makefile b/drivers/firmware/efi/Makefile
index ec379a4164cc..f292917b00e7 100644
--- a/drivers/firmware/efi/Makefile
+++ b/drivers/firmware/efi/Makefile
@@ -18,3 +18,6 @@ obj-$(CONFIG_EFI_RUNTIME_MAP)		+= runtime-map.o
 obj-$(CONFIG_EFI_RUNTIME_WRAPPERS)	+= runtime-wrappers.o
 obj-$(CONFIG_EFI_STUB)			+= libstub/
 obj-$(CONFIG_EFI_FAKE_MEMMAP)		+= fake_mem.o
+
+arm-obj-$(CONFIG_EFI)			:= arm-init.o arm-runtime.o
+obj-$(CONFIG_ARM64)			+= $(arm-obj-y)
diff --git a/drivers/firmware/efi/arm-init.c b/drivers/firmware/efi/arm-init.c
new file mode 100644
index 000000000000..4653d789f10d
--- /dev/null
+++ b/drivers/firmware/efi/arm-init.c
@@ -0,0 +1,196 @@
+/*
+ * Extensible Firmware Interface
+ *
+ * Based on Extensible Firmware Interface Specification version 2.4
+ *
+ * Copyright (C) 2013 - 2015 Linaro Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/efi.h>
+#include <linux/init.h>
+#include <linux/memblock.h>
+#include <linux/mm_types.h>
+#include <linux/of.h>
+#include <linux/of_fdt.h>
+
+#include <asm/efi.h>
+
+struct efi_memory_map memmap;
+
+u64 efi_system_table;
+
+static int __init is_normal_ram(efi_memory_desc_t *md)
+{
+	if (md->attribute & EFI_MEMORY_WB)
+		return 1;
+	return 0;
+}
+
+/*
+ * Translate a EFI virtual address into a physical address: this is necessary,
+ * as some data members of the EFI system table are virtually remapped after
+ * SetVirtualAddressMap() has been called.
+ */
+static phys_addr_t efi_to_phys(unsigned long addr)
+{
+	efi_memory_desc_t *md;
+
+	for_each_efi_memory_desc(&memmap, md) {
+		if (!(md->attribute & EFI_MEMORY_RUNTIME))
+			continue;
+		if (md->virt_addr == 0)
+			/* no virtual mapping has been installed by the stub */
+			break;
+		if (md->virt_addr <= addr &&
+		    (addr - md->virt_addr) < (md->num_pages << EFI_PAGE_SHIFT))
+			return md->phys_addr + addr - md->virt_addr;
+	}
+	return addr;
+}
+
+static int __init uefi_init(void)
+{
+	efi_char16_t *c16;
+	void *config_tables;
+	u64 table_size;
+	char vendor[100] = "unknown";
+	int i, retval;
+
+	efi.systab = early_memremap(efi_system_table,
+				    sizeof(efi_system_table_t));
+	if (efi.systab == NULL) {
+		pr_warn("Unable to map EFI system table.\n");
+		return -ENOMEM;
+	}
+
+	set_bit(EFI_BOOT, &efi.flags);
+	set_bit(EFI_64BIT, &efi.flags);
+
+	/*
+	 * Verify the EFI Table
+	 */
+	if (efi.systab->hdr.signature != EFI_SYSTEM_TABLE_SIGNATURE) {
+		pr_err("System table signature incorrect\n");
+		retval = -EINVAL;
+		goto out;
+	}
+	if ((efi.systab->hdr.revision >> 16) < 2)
+		pr_warn("Warning: EFI system table version %d.%02d, expected 2.00 or greater\n",
+			efi.systab->hdr.revision >> 16,
+			efi.systab->hdr.revision & 0xffff);
+
+	/* Show what we know for posterity */
+	c16 = early_memremap(efi_to_phys(efi.systab->fw_vendor),
+			     sizeof(vendor) * sizeof(efi_char16_t));
+	if (c16) {
+		for (i = 0; i < (int) sizeof(vendor) - 1 && *c16; ++i)
+			vendor[i] = c16[i];
+		vendor[i] = '\0';
+		early_memunmap(c16, sizeof(vendor) * sizeof(efi_char16_t));
+	}
+
+	pr_info("EFI v%u.%.02u by %s\n",
+		efi.systab->hdr.revision >> 16,
+		efi.systab->hdr.revision & 0xffff, vendor);
+
+	table_size = sizeof(efi_config_table_64_t) * efi.systab->nr_tables;
+	config_tables = early_memremap(efi_to_phys(efi.systab->tables),
+				       table_size);
+
+	retval = efi_config_parse_tables(config_tables, efi.systab->nr_tables,
+					 sizeof(efi_config_table_64_t), NULL);
+
+	early_memunmap(config_tables, table_size);
+out:
+	early_memunmap(efi.systab,  sizeof(efi_system_table_t));
+	return retval;
+}
+
+/*
+ * Return true for RAM regions we want to permanently reserve.
+ */
+static __init int is_reserve_region(efi_memory_desc_t *md)
+{
+	switch (md->type) {
+	case EFI_LOADER_CODE:
+	case EFI_LOADER_DATA:
+	case EFI_BOOT_SERVICES_CODE:
+	case EFI_BOOT_SERVICES_DATA:
+	case EFI_CONVENTIONAL_MEMORY:
+	case EFI_PERSISTENT_MEMORY:
+		return 0;
+	default:
+		break;
+	}
+	return is_normal_ram(md);
+}
+
+static __init void reserve_regions(void)
+{
+	efi_memory_desc_t *md;
+	u64 paddr, npages, size;
+
+	if (efi_enabled(EFI_DBG))
+		pr_info("Processing EFI memory map:\n");
+
+	for_each_efi_memory_desc(&memmap, md) {
+		paddr = md->phys_addr;
+		npages = md->num_pages;
+
+		if (efi_enabled(EFI_DBG)) {
+			char buf[64];
+
+			pr_info("  0x%012llx-0x%012llx %s",
+				paddr, paddr + (npages << EFI_PAGE_SHIFT) - 1,
+				efi_md_typeattr_format(buf, sizeof(buf), md));
+		}
+
+		memrange_efi_to_native(&paddr, &npages);
+		size = npages << PAGE_SHIFT;
+
+		if (is_normal_ram(md))
+			early_init_dt_add_memory_arch(paddr, size);
+
+		if (is_reserve_region(md)) {
+			memblock_mark_nomap(paddr, size);
+			if (efi_enabled(EFI_DBG))
+				pr_cont("*");
+		}
+
+		if (efi_enabled(EFI_DBG))
+			pr_cont("\n");
+	}
+
+	set_bit(EFI_MEMMAP, &efi.flags);
+}
+
+void __init efi_init(void)
+{
+	struct efi_fdt_params params;
+
+	/* Grab UEFI information placed in FDT by stub */
+	if (!efi_get_fdt_params(&params))
+		return;
+
+	efi_system_table = params.system_table;
+
+	memmap.phys_map = params.mmap;
+	memmap.map = early_memremap(params.mmap, params.mmap_size);
+	memmap.map_end = memmap.map + params.mmap_size;
+	memmap.desc_size = params.desc_size;
+	memmap.desc_version = params.desc_ver;
+
+	if (uefi_init() < 0)
+		return;
+
+	reserve_regions();
+	early_memunmap(memmap.map, params.mmap_size);
+	memblock_mark_nomap(params.mmap & PAGE_MASK,
+			    PAGE_ALIGN(params.mmap_size +
+				       (params.mmap & ~PAGE_MASK)));
+}
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
new file mode 100644
index 000000000000..e62ee5df96ca
--- /dev/null
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -0,0 +1,160 @@
+/*
+ * Extensible Firmware Interface
+ *
+ * Based on Extensible Firmware Interface Specification version 2.4
+ *
+ * Copyright (C) 2013, 2014 Linaro Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/efi.h>
+#include <linux/memblock.h>
+#include <linux/mm_types.h>
+#include <linux/preempt.h>
+#include <linux/rbtree.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+#include <asm/cacheflush.h>
+#include <asm/efi.h>
+#include <asm/tlbflush.h>
+#include <asm/mmu_context.h>
+#include <asm/mmu.h>
+#include <asm/pgtable.h>
+
+static pgd_t efi_pgd[PTRS_PER_PGD] __page_aligned_bss;
+
+extern u64 efi_system_table;
+
+static struct mm_struct efi_mm = {
+	.mm_rb			= RB_ROOT,
+	.pgd			= efi_pgd,
+	.mm_users		= ATOMIC_INIT(2),
+	.mm_count		= ATOMIC_INIT(1),
+	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
+	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
+	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
+};
+
+static bool __init efi_virtmap_init(void)
+{
+	efi_memory_desc_t *md;
+
+	for_each_efi_memory_desc(&memmap, md) {
+		u64 paddr, npages, size;
+		pgprot_t prot;
+
+		if (!(md->attribute & EFI_MEMORY_RUNTIME))
+			continue;
+		if (md->virt_addr == 0)
+			return false;
+
+		paddr = md->phys_addr;
+		npages = md->num_pages;
+		memrange_efi_to_native(&paddr, &npages);
+		size = npages << PAGE_SHIFT;
+
+		pr_info("  EFI remap 0x%016llx => %p\n",
+			md->phys_addr, (void *)md->virt_addr);
+
+		/*
+		 * Only regions of type EFI_RUNTIME_SERVICES_CODE need to be
+		 * executable, everything else can be mapped with the XN bits
+		 * set.
+		 */
+		if ((md->attribute & EFI_MEMORY_WB) == 0)
+			prot = __pgprot(PROT_DEVICE_nGnRE);
+		else if (md->type == EFI_RUNTIME_SERVICES_CODE ||
+			 !PAGE_ALIGNED(md->phys_addr))
+			prot = PAGE_KERNEL_EXEC;
+		else
+			prot = PAGE_KERNEL;
+
+		create_pgd_mapping(&efi_mm, paddr, md->virt_addr, size, prot);
+	}
+	return true;
+}
+
+/*
+ * Enable the UEFI Runtime Services if all prerequisites are in place, i.e.,
+ * non-early mapping of the UEFI system table and virtual mappings for all
+ * EFI_MEMORY_RUNTIME regions.
+ */
+static int __init arm64_enable_runtime_services(void)
+{
+	u64 mapsize;
+
+	if (!efi_enabled(EFI_BOOT)) {
+		pr_info("EFI services will not be available.\n");
+		return -1;
+	}
+
+	if (efi_runtime_disabled()) {
+		pr_info("EFI runtime services will be disabled.\n");
+		return -1;
+	}
+
+	pr_info("Remapping and enabling EFI services.\n");
+
+	mapsize = memmap.map_end - memmap.map;
+	memmap.map = (__force void *)ioremap_cache(memmap.phys_map,
+						   mapsize);
+	if (!memmap.map) {
+		pr_err("Failed to remap EFI memory map\n");
+		return -1;
+	}
+	memmap.map_end = memmap.map + mapsize;
+	efi.memmap = &memmap;
+
+	efi.systab = (__force void *)ioremap_cache(efi_system_table,
+						   sizeof(efi_system_table_t));
+	if (!efi.systab) {
+		pr_err("Failed to remap EFI System Table\n");
+		return -1;
+	}
+	set_bit(EFI_SYSTEM_TABLES, &efi.flags);
+
+	if (!efi_virtmap_init()) {
+		pr_err("No UEFI virtual mapping was installed -- runtime services will not be available\n");
+		return -1;
+	}
+
+	/* Set up runtime services function pointers */
+	efi_native_runtime_setup();
+	set_bit(EFI_RUNTIME_SERVICES, &efi.flags);
+
+	efi.runtime_version = efi.systab->hdr.revision;
+
+	return 0;
+}
+early_initcall(arm64_enable_runtime_services);
+
+static void efi_set_pgd(struct mm_struct *mm)
+{
+	if (mm == &init_mm)
+		cpu_set_reserved_ttbr0();
+	else
+		cpu_switch_mm(mm->pgd, mm);
+
+	flush_tlb_all();
+	if (icache_is_aivivt())
+		__flush_icache_all();
+}
+
+void efi_virtmap_load(void)
+{
+	preempt_disable();
+	efi_set_pgd(&efi_mm);
+}
+
+void efi_virtmap_unload(void)
+{
+	efi_set_pgd(current->active_mm);
+	preempt_enable();
+}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
