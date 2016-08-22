Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0FD76B026E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:37:48 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 65so265162449uay.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:37:48 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0047.outbound.protection.outlook.com. [104.47.38.47])
        by mx.google.com with ESMTPS id 40si180617qkx.312.2016.08.22.15.37.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:37:47 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 11/20] mm: Access BOOT related data in the clear
Date: Mon, 22 Aug 2016 17:37:38 -0500
Message-ID: <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
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

BOOT data (such as EFI related data) is not encyrpted when the system is
booted and needs to be accessed as non-encrypted.  Add support to the
early_memremap API to identify the type of data being accessed so that
the proper encryption attribute can be applied.  Currently, two types
of data are defined, KERNEL_DATA and BOOT_DATA.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/arm64/kernel/acpi.c              |    2 +-
 arch/ia64/include/asm/early_ioremap.h |    2 +-
 arch/x86/kernel/devicetree.c          |    6 ++++--
 arch/x86/kernel/e820.c                |    2 +-
 arch/x86/kernel/setup.c               |    9 +++++---
 arch/x86/mm/ioremap.c                 |   19 +++++++++++++++++
 arch/x86/platform/efi/efi.c           |   15 +++++++-------
 arch/x86/platform/efi/efi_64.c        |   13 +++++++++---
 arch/x86/platform/efi/quirks.c        |    4 ++--
 arch/x86/xen/mmu.c                    |    9 +++++---
 arch/x86/xen/setup.c                  |    6 ++++--
 drivers/acpi/tables.c                 |    2 +-
 drivers/firmware/efi/arm-init.c       |   13 +++++++-----
 drivers/firmware/efi/efi.c            |    7 ++++--
 drivers/firmware/efi/esrt.c           |    4 ++--
 drivers/firmware/efi/fake_mem.c       |    3 ++-
 drivers/firmware/efi/memattr.c        |    2 +-
 include/asm-generic/early_ioremap.h   |   15 +++++++++++---
 mm/early_ioremap.c                    |   36 +++++++++++++++++++++++++--------
 19 files changed, 117 insertions(+), 52 deletions(-)

diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 3e4f1a4..33fdedd 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -98,7 +98,7 @@ char *__init __acpi_map_table(unsigned long phys, unsigned long size)
 	if (!size)
 		return NULL;
 
-	return early_memremap(phys, size);
+	return early_memremap(phys, size, BOOT_DATA);
 }
 
 void __init __acpi_unmap_table(char *map, unsigned long size)
diff --git a/arch/ia64/include/asm/early_ioremap.h b/arch/ia64/include/asm/early_ioremap.h
index eec9e1d..bc8c210 100644
--- a/arch/ia64/include/asm/early_ioremap.h
+++ b/arch/ia64/include/asm/early_ioremap.h
@@ -2,7 +2,7 @@
 #define _ASM_IA64_EARLY_IOREMAP_H
 
 extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
-#define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
+#define early_memremap(phys_addr, size, owner) early_ioremap(phys_addr, size)
 
 extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
 #define early_memunmap(addr, size)             early_iounmap(addr, size)
diff --git a/arch/x86/kernel/devicetree.c b/arch/x86/kernel/devicetree.c
index 3fe45f8..556e986 100644
--- a/arch/x86/kernel/devicetree.c
+++ b/arch/x86/kernel/devicetree.c
@@ -276,11 +276,13 @@ static void __init x86_flattree_get_config(void)
 
 	map_len = max(PAGE_SIZE - (initial_dtb & ~PAGE_MASK), (u64)128);
 
-	initial_boot_params = dt = early_memremap(initial_dtb, map_len);
+	initial_boot_params = dt = early_memremap(initial_dtb, map_len,
+						  BOOT_DATA);
 	size = of_get_flat_dt_size();
 	if (map_len < size) {
 		early_memunmap(dt, map_len);
-		initial_boot_params = dt = early_memremap(initial_dtb, size);
+		initial_boot_params = dt = early_memremap(initial_dtb, size,
+							  BOOT_DATA);
 		map_len = size;
 	}
 
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 621b501..71b237f 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -661,7 +661,7 @@ void __init parse_e820_ext(u64 phys_addr, u32 data_len)
 	struct e820entry *extmap;
 	struct setup_data *sdata;
 
-	sdata = early_memremap(phys_addr, data_len);
+	sdata = early_memremap(phys_addr, data_len, BOOT_DATA);
 	entries = sdata->len / sizeof(struct e820entry);
 	extmap = (struct e820entry *)(sdata->data);
 	__append_e820_map(extmap, entries);
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 1fdaa11..cec8a63 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -344,7 +344,8 @@ static void __init relocate_initrd(void)
 	printk(KERN_INFO "Allocated new RAMDISK: [mem %#010llx-%#010llx]\n",
 	       relocated_ramdisk, relocated_ramdisk + ramdisk_size - 1);
 
-	copy_from_early_mem((void *)initrd_start, ramdisk_image, ramdisk_size);
+	copy_from_early_mem((void *)initrd_start, ramdisk_image, ramdisk_size,
+			    BOOT_DATA);
 
 	printk(KERN_INFO "Move RAMDISK from [mem %#010llx-%#010llx] to"
 		" [mem %#010llx-%#010llx]\n",
@@ -426,7 +427,7 @@ static void __init parse_setup_data(void)
 	while (pa_data) {
 		u32 data_len, data_type;
 
-		data = early_memremap(pa_data, sizeof(*data));
+		data = early_memremap(pa_data, sizeof(*data), BOOT_DATA);
 		data_len = data->len + sizeof(struct setup_data);
 		data_type = data->type;
 		pa_next = data->next;
@@ -459,7 +460,7 @@ static void __init e820_reserve_setup_data(void)
 		return;
 
 	while (pa_data) {
-		data = early_memremap(pa_data, sizeof(*data));
+		data = early_memremap(pa_data, sizeof(*data), BOOT_DATA);
 		e820_update_range(pa_data, sizeof(*data)+data->len,
 			 E820_RAM, E820_RESERVED_KERN);
 		pa_data = data->next;
@@ -479,7 +480,7 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 
 	pa_data = boot_params.hdr.setup_data;
 	while (pa_data) {
-		data = early_memremap(pa_data, sizeof(*data));
+		data = early_memremap(pa_data, sizeof(*data), BOOT_DATA);
 		memblock_reserve(pa_data, sizeof(*data) + data->len);
 		pa_data = data->next;
 		early_memunmap(data, sizeof(*data));
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 031db21..e3bdc5a 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -419,6 +419,25 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
 }
 
+/*
+ * Architecure override of __weak function to adjust the protection attributes
+ * used when remapping memory.
+ */
+pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
+					     unsigned long size,
+					     enum memremap_owner owner,
+					     pgprot_t prot)
+{
+	/*
+	 * If memory encryption is enabled and BOOT_DATA is being mapped
+	 * then remove the encryption bit.
+	 */
+	if (_PAGE_ENC && (owner == BOOT_DATA))
+		prot = __pgprot(pgprot_val(prot) & ~_PAGE_ENC);
+
+	return prot;
+}
+
 /* Remap memory with encryption */
 void __init *early_memremap_enc(resource_size_t phys_addr,
 				unsigned long size)
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 1fbb408..2c7e6b0 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -239,12 +239,13 @@ static int __init efi_systab_init(void *phys)
 		u64 tmp = 0;
 
 		if (efi_setup) {
-			data = early_memremap(efi_setup, sizeof(*data));
+			data = early_memremap(efi_setup, sizeof(*data),
+					      BOOT_DATA);
 			if (!data)
 				return -ENOMEM;
 		}
 		systab64 = early_memremap((unsigned long)phys,
-					 sizeof(*systab64));
+					  sizeof(*systab64), BOOT_DATA);
 		if (systab64 == NULL) {
 			pr_err("Couldn't map the system table!\n");
 			if (data)
@@ -293,7 +294,7 @@ static int __init efi_systab_init(void *phys)
 		efi_system_table_32_t *systab32;
 
 		systab32 = early_memremap((unsigned long)phys,
-					 sizeof(*systab32));
+					  sizeof(*systab32), BOOT_DATA);
 		if (systab32 == NULL) {
 			pr_err("Couldn't map the system table!\n");
 			return -ENOMEM;
@@ -338,7 +339,7 @@ static int __init efi_runtime_init32(void)
 	efi_runtime_services_32_t *runtime;
 
 	runtime = early_memremap((unsigned long)efi.systab->runtime,
-			sizeof(efi_runtime_services_32_t));
+				 sizeof(efi_runtime_services_32_t), BOOT_DATA);
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
 		return -ENOMEM;
@@ -362,7 +363,7 @@ static int __init efi_runtime_init64(void)
 	efi_runtime_services_64_t *runtime;
 
 	runtime = early_memremap((unsigned long)efi.systab->runtime,
-			sizeof(efi_runtime_services_64_t));
+				 sizeof(efi_runtime_services_64_t), BOOT_DATA);
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
 		return -ENOMEM;
@@ -425,7 +426,7 @@ static int __init efi_memmap_init(void)
 	size = efi.memmap.nr_map * efi.memmap.desc_size;
 	addr = (unsigned long)efi.memmap.phys_map;
 
-	efi.memmap.map = early_memremap(addr, size);
+	efi.memmap.map = early_memremap(addr, size, BOOT_DATA);
 	if (efi.memmap.map == NULL) {
 		pr_err("Could not map the memory map!\n");
 		return -ENOMEM;
@@ -471,7 +472,7 @@ void __init efi_init(void)
 	/*
 	 * Show what we know for posterity
 	 */
-	c16 = tmp = early_memremap(efi.systab->fw_vendor, 2);
+	c16 = tmp = early_memremap(efi.systab->fw_vendor, 2, BOOT_DATA);
 	if (c16) {
 		for (i = 0; i < sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = *c16++;
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 677e29e..0871ea4 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -222,7 +222,12 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	if (efi_enabled(EFI_OLD_MEMMAP))
 		return 0;
 
-	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
+	/*
+	 * Since the PGD is encrypted, set the encryption mask so that when
+	 * this value is loaded into cr3 the PGD will be decrypted during
+	 * the pagetable walk.
+	 */
+	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
 	pgd = efi_pgd;
 
 	/*
@@ -261,7 +266,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 		pfn = md->phys_addr >> PAGE_SHIFT;
 		npages = md->num_pages;
 
-		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages, _PAGE_RW)) {
+		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages,
+					    _PAGE_RW | _PAGE_ENC)) {
 			pr_err("Failed to map 1:1 memory\n");
 			return 1;
 		}
@@ -278,7 +284,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	text = __pa(_text);
 	pfn = text >> PAGE_SHIFT;
 
-	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW)) {
+	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages,
+				    _PAGE_RW | _PAGE_ENC)) {
 		pr_err("Failed to map kernel text 1:1\n");
 		return 1;
 	}
diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
index 89d1146..606bf551 100644
--- a/arch/x86/platform/efi/quirks.c
+++ b/arch/x86/platform/efi/quirks.c
@@ -311,7 +311,7 @@ int __init efi_reuse_config(u64 tables, int nr_tables)
 	if (!efi_enabled(EFI_64BIT))
 		return 0;
 
-	data = early_memremap(efi_setup, sizeof(*data));
+	data = early_memremap(efi_setup, sizeof(*data), BOOT_DATA);
 	if (!data) {
 		ret = -ENOMEM;
 		goto out;
@@ -322,7 +322,7 @@ int __init efi_reuse_config(u64 tables, int nr_tables)
 
 	sz = sizeof(efi_config_table_64_t);
 
-	p = tablep = early_memremap(tables, nr_tables * sz);
+	p = tablep = early_memremap(tables, nr_tables * sz, BOOT_DATA);
 	if (!p) {
 		pr_err("Could not map Configuration table!\n");
 		ret = -ENOMEM;
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 7d5afdb..00db54a 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2020,7 +2020,7 @@ static unsigned long __init xen_read_phys_ulong(phys_addr_t addr)
 	unsigned long *vaddr;
 	unsigned long val;
 
-	vaddr = early_memremap_ro(addr, sizeof(val));
+	vaddr = early_memremap_ro(addr, sizeof(val), KERNEL_DATA);
 	val = *vaddr;
 	early_memunmap(vaddr, sizeof(val));
 	return val;
@@ -2114,15 +2114,16 @@ void __init xen_relocate_p2m(void)
 	pgd = __va(read_cr3());
 	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
 	for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
-		pud = early_memremap(pud_phys, PAGE_SIZE);
+		pud = early_memremap(pud_phys, PAGE_SIZE, KERNEL_DATA);
 		clear_page(pud);
 		for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
 		     idx_pmd++) {
-			pmd = early_memremap(pmd_phys, PAGE_SIZE);
+			pmd = early_memremap(pmd_phys, PAGE_SIZE, KERNEL_DATA);
 			clear_page(pmd);
 			for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
 			     idx_pt++) {
-				pt = early_memremap(pt_phys, PAGE_SIZE);
+				pt = early_memremap(pt_phys, PAGE_SIZE,
+						    KERNEL_DATA);
 				clear_page(pt);
 				for (idx_pte = 0;
 				     idx_pte < min(n_pte, PTRS_PER_PTE);
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 1764252..a8e2724 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -686,8 +686,10 @@ static void __init xen_phys_memcpy(phys_addr_t dest, phys_addr_t src,
 		if (src_len > (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off)
 			src_len = (NR_FIX_BTMAPS << PAGE_SHIFT) - src_off;
 		len = min(dest_len, src_len);
-		to = early_memremap(dest - dest_off, dest_len + dest_off);
-		from = early_memremap(src - src_off, src_len + src_off);
+		to = early_memremap(dest - dest_off, dest_len + dest_off,
+				    KERNEL_DATA);
+		from = early_memremap(src - src_off, src_len + src_off,
+				      KERNEL_DATA);
 		memcpy(to, from, len);
 		early_memunmap(to, dest_len + dest_off);
 		early_memunmap(from, src_len + src_off);
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 9f0ad6e..06b75a2 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -583,7 +583,7 @@ void __init acpi_table_upgrade(void)
 			if (clen > MAP_CHUNK_SIZE - slop)
 				clen = MAP_CHUNK_SIZE - slop;
 			dest_p = early_memremap(dest_addr & PAGE_MASK,
-						clen + slop);
+						clen + slop, BOOT_DATA);
 			memcpy(dest_p + slop, src_p, clen);
 			early_memunmap(dest_p, clen + slop);
 			src_p += clen;
diff --git a/drivers/firmware/efi/arm-init.c b/drivers/firmware/efi/arm-init.c
index c49d50e..0a3fd48 100644
--- a/drivers/firmware/efi/arm-init.c
+++ b/drivers/firmware/efi/arm-init.c
@@ -67,7 +67,8 @@ static void __init init_screen_info(void)
 	struct screen_info *si;
 
 	if (screen_info_table != EFI_INVALID_TABLE_ADDR) {
-		si = early_memremap_ro(screen_info_table, sizeof(*si));
+		si = early_memremap_ro(screen_info_table, sizeof(*si),
+				       BOOT_DATA);
 		if (!si) {
 			pr_err("Could not map screen_info config table\n");
 			return;
@@ -94,7 +95,7 @@ static int __init uefi_init(void)
 	int i, retval;
 
 	efi.systab = early_memremap_ro(efi_system_table,
-				       sizeof(efi_system_table_t));
+				       sizeof(efi_system_table_t), BOOT_DATA);
 	if (efi.systab == NULL) {
 		pr_warn("Unable to map EFI system table.\n");
 		return -ENOMEM;
@@ -121,7 +122,8 @@ static int __init uefi_init(void)
 
 	/* Show what we know for posterity */
 	c16 = early_memremap_ro(efi_to_phys(efi.systab->fw_vendor),
-				sizeof(vendor) * sizeof(efi_char16_t));
+				sizeof(vendor) * sizeof(efi_char16_t),
+				BOOT_DATA);
 	if (c16) {
 		for (i = 0; i < (int) sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = c16[i];
@@ -135,7 +137,7 @@ static int __init uefi_init(void)
 
 	table_size = sizeof(efi_config_table_64_t) * efi.systab->nr_tables;
 	config_tables = early_memremap_ro(efi_to_phys(efi.systab->tables),
-					  table_size);
+					  table_size, BOOT_DATA);
 	if (config_tables == NULL) {
 		pr_warn("Unable to map EFI config table array.\n");
 		retval = -ENOMEM;
@@ -226,7 +228,8 @@ void __init efi_init(void)
 	efi_system_table = params.system_table;
 
 	efi.memmap.phys_map = params.mmap;
-	efi.memmap.map = early_memremap_ro(params.mmap, params.mmap_size);
+	efi.memmap.map = early_memremap_ro(params.mmap, params.mmap_size,
+					   BOOT_DATA);
 	if (efi.memmap.map == NULL) {
 		/*
 		* If we are booting via UEFI, the UEFI memory map is the only
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 5a2631a..f9286c6 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -386,7 +386,7 @@ int __init efi_mem_desc_lookup(u64 phys_addr, efi_memory_desc_t *out_md)
 		 * So just always get our own virtual map on the CPU.
 		 *
 		 */
-		md = early_memremap(p, sizeof (*md));
+		md = early_memremap(p, sizeof (*md), BOOT_DATA);
 		if (!md) {
 			pr_err_once("early_memremap(%pa, %zu) failed.\n",
 				    &p, sizeof (*md));
@@ -501,7 +501,8 @@ int __init efi_config_parse_tables(void *config_tables, int count, int sz,
 	if (efi.properties_table != EFI_INVALID_TABLE_ADDR) {
 		efi_properties_table_t *tbl;
 
-		tbl = early_memremap(efi.properties_table, sizeof(*tbl));
+		tbl = early_memremap(efi.properties_table, sizeof(*tbl),
+				     BOOT_DATA);
 		if (tbl == NULL) {
 			pr_err("Could not map Properties table!\n");
 			return -ENOMEM;
@@ -531,7 +532,7 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
 	 * Let's see what config tables the firmware passed to us.
 	 */
 	config_tables = early_memremap(efi.systab->tables,
-				       efi.systab->nr_tables * sz);
+				       efi.systab->nr_tables * sz, BOOT_DATA);
 	if (config_tables == NULL) {
 		pr_err("Could not map Configuration table!\n");
 		return -ENOMEM;
diff --git a/drivers/firmware/efi/esrt.c b/drivers/firmware/efi/esrt.c
index 75feb3f..10ee547 100644
--- a/drivers/firmware/efi/esrt.c
+++ b/drivers/firmware/efi/esrt.c
@@ -273,7 +273,7 @@ void __init efi_esrt_init(void)
 		return;
 	}
 
-	va = early_memremap(efi.esrt, size);
+	va = early_memremap(efi.esrt, size, BOOT_DATA);
 	if (!va) {
 		pr_err("early_memremap(%p, %zu) failed.\n", (void *)efi.esrt,
 		       size);
@@ -323,7 +323,7 @@ void __init efi_esrt_init(void)
 	/* remap it with our (plausible) new pages */
 	early_memunmap(va, size);
 	size += entries_size;
-	va = early_memremap(efi.esrt, size);
+	va = early_memremap(efi.esrt, size, BOOT_DATA);
 	if (!va) {
 		pr_err("early_memremap(%p, %zu) failed.\n", (void *)efi.esrt,
 		       size);
diff --git a/drivers/firmware/efi/fake_mem.c b/drivers/firmware/efi/fake_mem.c
index 48430ab..8e87388 100644
--- a/drivers/firmware/efi/fake_mem.c
+++ b/drivers/firmware/efi/fake_mem.c
@@ -101,7 +101,8 @@ void __init efi_fake_memmap(void)
 
 	/* create new EFI memmap */
 	new_memmap = early_memremap(new_memmap_phy,
-				    efi.memmap.desc_size * new_nr_map);
+				    efi.memmap.desc_size * new_nr_map,
+				    BOOT_DATA);
 	if (!new_memmap) {
 		memblock_free(new_memmap_phy, efi.memmap.desc_size * new_nr_map);
 		return;
diff --git a/drivers/firmware/efi/memattr.c b/drivers/firmware/efi/memattr.c
index 236004b..f351c2a 100644
--- a/drivers/firmware/efi/memattr.c
+++ b/drivers/firmware/efi/memattr.c
@@ -28,7 +28,7 @@ int __init efi_memattr_init(void)
 	if (efi.mem_attr_table == EFI_INVALID_TABLE_ADDR)
 		return 0;
 
-	tbl = early_memremap(efi.mem_attr_table, sizeof(*tbl));
+	tbl = early_memremap(efi.mem_attr_table, sizeof(*tbl), BOOT_DATA);
 	if (!tbl) {
 		pr_err("Failed to map EFI Memory Attributes table @ 0x%lx\n",
 		       efi.mem_attr_table);
diff --git a/include/asm-generic/early_ioremap.h b/include/asm-generic/early_ioremap.h
index 2edef8d..61de27a 100644
--- a/include/asm-generic/early_ioremap.h
+++ b/include/asm-generic/early_ioremap.h
@@ -3,6 +3,11 @@
 
 #include <linux/types.h>
 
+enum memremap_owner {
+	KERNEL_DATA = 0,
+	BOOT_DATA,
+};
+
 /*
  * early_ioremap() and early_iounmap() are for temporary early boot-time
  * mappings, before the real ioremap() is functional.
@@ -10,9 +15,13 @@
 extern void __iomem *early_ioremap(resource_size_t phys_addr,
 				   unsigned long size);
 extern void *early_memremap(resource_size_t phys_addr,
-			    unsigned long size);
+			    unsigned long size, enum memremap_owner);
 extern void *early_memremap_ro(resource_size_t phys_addr,
-			       unsigned long size);
+			       unsigned long size, enum memremap_owner);
+/*
+ * When supplying the protection value assume the caller knows the
+ * situation, so the memremap_owner data is not required.
+ */
 extern void *early_memremap_prot(resource_size_t phys_addr,
 				 unsigned long size, unsigned long prot_val);
 extern void early_iounmap(void __iomem *addr, unsigned long size);
@@ -41,7 +50,7 @@ extern void early_ioremap_reset(void);
  * Early copy from unmapped memory to kernel mapped memory.
  */
 extern void copy_from_early_mem(void *dest, phys_addr_t src,
-				unsigned long size);
+				unsigned long size, enum memremap_owner owner);
 
 #else
 static inline void early_ioremap_init(void) { }
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index d71b98b..ad40720 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -34,6 +34,14 @@ void __init __weak early_ioremap_shutdown(void)
 {
 }
 
+pgprot_t __init __weak early_memremap_pgprot_adjust(resource_size_t phys_addr,
+						    unsigned long size,
+						    enum memremap_owner owner,
+						    pgprot_t prot)
+{
+	return prot;
+}
+
 void __init early_ioremap_reset(void)
 {
 	early_ioremap_shutdown();
@@ -213,16 +221,23 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
 
 /* Remap memory */
 void __init *
-early_memremap(resource_size_t phys_addr, unsigned long size)
+early_memremap(resource_size_t phys_addr, unsigned long size,
+	       enum memremap_owner owner)
 {
-	return (__force void *)__early_ioremap(phys_addr, size,
-					       FIXMAP_PAGE_NORMAL);
+	pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size, owner,
+						     FIXMAP_PAGE_NORMAL);
+
+	return (__force void *)__early_ioremap(phys_addr, size, prot);
 }
 #ifdef FIXMAP_PAGE_RO
 void __init *
-early_memremap_ro(resource_size_t phys_addr, unsigned long size)
+early_memremap_ro(resource_size_t phys_addr, unsigned long size,
+		  enum memremap_owner owner)
 {
-	return (__force void *)__early_ioremap(phys_addr, size, FIXMAP_PAGE_RO);
+	pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size, owner,
+						     FIXMAP_PAGE_RO);
+
+	return (__force void *)__early_ioremap(phys_addr, size, prot);
 }
 #endif
 
@@ -236,7 +251,8 @@ early_memremap_prot(resource_size_t phys_addr, unsigned long size,
 
 #define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
 
-void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
+void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size,
+				enum memremap_owner owner)
 {
 	unsigned long slop, clen;
 	char *p;
@@ -246,7 +262,7 @@ void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
 		clen = size;
 		if (clen > MAX_MAP_CHUNK - slop)
 			clen = MAX_MAP_CHUNK - slop;
-		p = early_memremap(src & PAGE_MASK, clen + slop);
+		p = early_memremap(src & PAGE_MASK, clen + slop, owner);
 		memcpy(dest, p + slop, clen);
 		early_memunmap(p, clen + slop);
 		dest += clen;
@@ -265,12 +281,14 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
 
 /* Remap memory */
 void __init *
-early_memremap(resource_size_t phys_addr, unsigned long size)
+early_memremap(resource_size_t phys_addr, unsigned long size,
+	       enum memremap_owner owner)
 {
 	return (void *)phys_addr;
 }
 void __init *
-early_memremap_ro(resource_size_t phys_addr, unsigned long size)
+early_memremap_ro(resource_size_t phys_addr, unsigned long size,
+		  enum memremap_owner owner)
 {
 	return (void *)phys_addr;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
