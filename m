Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC356B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:08:05 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id r82so134585470ywg.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 04:08:05 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v185si9867059pgd.419.2017.02.13.04.08.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 04:08:04 -0800 (PST)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] mm: free reserved area's memmap if possiable
Date: Mon, 13 Feb 2017 20:02:29 +0800
Message-ID: <1486987349-58711-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, catalin.marinas@arm.com, will.deacon@arm.com, robh+dt@kernel.org, frowand.list@gmail.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, wangkefeng.wang@huawei.com, jszhang@marvell.com, gkulkarni@caviumnetworks.com, steve.capper@arm.com, chengang@emindsoft.com.cn, dennis.chen@arm.com, srikar@linux.vnet.ibm.com, kuleshovmail@gmail.com, zijun_hu@htc.com, tj@kernel.org, joe@perches.com, Mi.Sophia.Wang@huawei.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

From: zhouxianrong <zhouxianrong@huawei.com>

just like freeing no-map area's memmap we could free reserved
area's memmap as well only when user of reserved area indicate
that we can do this in dts or drivers. that is, user of reserved
area know how to use the reserved area who could not memblock_free
or free_reserved_xxx the reserved area and regard the area as raw
pfn usage. the patch supply a way to users who want to utilize the
memmap memory corresponding to raw pfn reserved areas as many as
possible.

Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
---
 arch/arm64/mm/init.c         |   14 +++++++++++++-
 drivers/of/fdt.c             |   31 +++++++++++++++++++++++--------
 drivers/of/of_reserved_mem.c |   21 ++++++++++++++-------
 include/linux/memblock.h     |    3 +++
 include/linux/of_fdt.h       |    2 +-
 mm/memblock.c                |   24 ++++++++++++++++++++++++
 6 files changed, 78 insertions(+), 17 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 380ebe7..7e62ef8 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -358,7 +358,7 @@ static inline void free_memmap(unsigned long start_pfn, unsigned long end_pfn)
  */
 static void __init free_unused_memmap(void)
 {
-	unsigned long start, prev_end = 0;
+	unsigned long start, end, prev_end = 0;
 	struct memblock_region *reg;
 
 	for_each_memblock(memory, reg) {
@@ -391,6 +391,18 @@ static void __init free_unused_memmap(void)
 	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
 		free_memmap(prev_end, ALIGN(prev_end, PAGES_PER_SECTION));
 #endif
+
+	for_each_memblock(reserved, reg) {
+		if (!(reg->flags & MEMBLOCK_RAW_PFN))
+			continue;
+
+		start = memblock_region_memory_base_pfn(reg);
+		end = round_down(memblock_region_memory_end_pfn(reg),
+				 MAX_ORDER_NR_PAGES);
+
+		if (start < end)
+			free_memmap(start, end);
+	}
 }
 #endif	/* !CONFIG_SPARSEMEM_VMEMMAP */
 
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index c9b5cac..39e7474 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -582,7 +582,7 @@ static int __init __reserved_mem_reserve_reg(unsigned long node,
 	phys_addr_t base, size;
 	int len;
 	const __be32 *prop;
-	int nomap, first = 1;
+	int nomap, raw_pfn, first = 1;
 
 	prop = of_get_flat_dt_prop(node, "reg", &len);
 	if (!prop)
@@ -595,13 +595,15 @@ static int __init __reserved_mem_reserve_reg(unsigned long node,
 	}
 
 	nomap = of_get_flat_dt_prop(node, "no-map", NULL) != NULL;
+	raw_pfn = of_get_flat_dt_prop(node, "raw-pfn", NULL) != NULL;
 
 	while (len >= t_len) {
 		base = dt_mem_next_cell(dt_root_addr_cells, &prop);
 		size = dt_mem_next_cell(dt_root_size_cells, &prop);
 
 		if (size &&
-		    early_init_dt_reserve_memory_arch(base, size, nomap) == 0)
+		    early_init_dt_reserve_memory_arch(base, size, nomap,
+				raw_pfn) == 0)
 			pr_debug("Reserved memory: reserved region for node '%s': base %pa, size %ld MiB\n",
 				uname, &base, (unsigned long)size / SZ_1M);
 		else
@@ -699,7 +701,7 @@ void __init early_init_fdt_scan_reserved_mem(void)
 		fdt_get_mem_rsv(initial_boot_params, n, &base, &size);
 		if (!size)
 			break;
-		early_init_dt_reserve_memory_arch(base, size, 0);
+		early_init_dt_reserve_memory_arch(base, size, 0, 0);
 	}
 
 	of_scan_flat_dt(__fdt_scan_reserved_mem, NULL);
@@ -717,6 +719,7 @@ void __init early_init_fdt_reserve_self(void)
 	/* Reserve the dtb region */
 	early_init_dt_reserve_memory_arch(__pa(initial_boot_params),
 					  fdt_totalsize(initial_boot_params),
+					  0,
 					  0);
 }
 
@@ -1161,11 +1164,21 @@ int __init __weak early_init_dt_mark_hotplug_memory_arch(u64 base, u64 size)
 }
 
 int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
-					phys_addr_t size, bool nomap)
+					phys_addr_t size, bool nomap,
+					bool raw_pfn)
 {
+	int err;
+
 	if (nomap)
 		return memblock_remove(base, size);
-	return memblock_reserve(base, size);
+
+	err = memblock_reserve(base, size);
+	if (err == 0) {
+		if (raw_pfn)
+			memblock_mark_raw_pfn(base, size);
+	}
+
+	return err;
 }
 
 /*
@@ -1188,10 +1201,12 @@ int __init __weak early_init_dt_mark_hotplug_memory_arch(u64 base, u64 size)
 }
 
 int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
-					phys_addr_t size, bool nomap)
+					phys_addr_t size, bool nomap,
+					bool raw_pfn)
 {
-	pr_err("Reserved memory not supported, ignoring range %pa - %pa%s\n",
-		  &base, &size, nomap ? " (nomap)" : "");
+	pr_err("Reserved memory not supported, ignoring range %pa - %pa%s - %pa%s\n",
+		  &base, &size, nomap ? " (nomap)" : "",
+		  raw_pfn ? " (raw-pfn)" : "");
 	return -ENOSYS;
 }
 
diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index 366d8c3..d7d9255 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -33,7 +33,7 @@
 #include <linux/memblock.h>
 int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	phys_addr_t align, phys_addr_t start, phys_addr_t end, bool nomap,
-	phys_addr_t *res_base)
+	bool raw_pfn, phys_addr_t *res_base)
 {
 	phys_addr_t base;
 	/*
@@ -56,15 +56,19 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	*res_base = base;
 	if (nomap)
 		return memblock_remove(base, size);
+
+	if (raw_pfn)
+		memblock_mark_raw_pfn(base, size);
+
 	return 0;
 }
 #else
 int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	phys_addr_t align, phys_addr_t start, phys_addr_t end, bool nomap,
-	phys_addr_t *res_base)
+	bool raw_pfn, phys_addr_t *res_base)
 {
-	pr_err("Reserved memory not supported, ignoring region 0x%llx%s\n",
-		  size, nomap ? " (nomap)" : "");
+	pr_err("Reserved memory not supported, ignoring region 0x%llx%s 0x%llx%s\n",
+		  size, nomap ? " (nomap)" : "", raw_pfn ? " (raw-pfn)" : "");
 	return -ENOSYS;
 }
 #endif
@@ -103,7 +107,7 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
 	phys_addr_t base = 0, align = 0, size;
 	int len;
 	const __be32 *prop;
-	int nomap;
+	int nomap, raw_pfn;
 	int ret;
 
 	prop = of_get_flat_dt_prop(node, "size", &len);
@@ -117,6 +121,7 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
 	size = dt_mem_next_cell(dt_root_size_cells, &prop);
 
 	nomap = of_get_flat_dt_prop(node, "no-map", NULL) != NULL;
+	raw_pfn = of_get_flat_dt_prop(node, "raw-pfn", NULL) != NULL;
 
 	prop = of_get_flat_dt_prop(node, "alignment", &len);
 	if (prop) {
@@ -156,7 +161,8 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
 						       &prop);
 
 			ret = early_init_dt_alloc_reserved_memory_arch(size,
-					align, start, end, nomap, &base);
+					align, start, end, nomap,
+					raw_pfn, &base);
 			if (ret == 0) {
 				pr_debug("allocated memory for '%s' node: base %pa, size %ld MiB\n",
 					uname, &base,
@@ -168,7 +174,8 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
 
 	} else {
 		ret = early_init_dt_alloc_reserved_memory_arch(size, align,
-							0, 0, nomap, &base);
+							0, 0, nomap,
+							raw_pfn, &base);
 		if (ret == 0)
 			pr_debug("allocated memory for '%s' node: base %pa, size %ld MiB\n",
 				uname, &base, (unsigned long)size / SZ_1M);
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5b759c9..7266be1 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -26,6 +26,7 @@ enum {
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
 	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
+	MEMBLOCK_RAW_PFN	= 0x8,	/* raw pfn region's memmap never used */
 };
 
 struct memblock_region {
@@ -92,6 +93,8 @@ bool memblock_overlaps_region(struct memblock_type *type,
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size);
+int memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
 
 /* Low level functions */
diff --git a/include/linux/of_fdt.h b/include/linux/of_fdt.h
index 271b3fd..29284d7 100644
--- a/include/linux/of_fdt.h
+++ b/include/linux/of_fdt.h
@@ -73,7 +73,7 @@ extern int early_init_dt_scan_memory(unsigned long node, const char *uname,
 extern void early_init_dt_add_memory_arch(u64 base, u64 size);
 extern int early_init_dt_mark_hotplug_memory_arch(u64 base, u64 size);
 extern int early_init_dt_reserve_memory_arch(phys_addr_t base, phys_addr_t size,
-					     bool no_map);
+					     bool no_map, bool raw_pfn);
 extern void * early_init_dt_alloc_memory_arch(u64 size, u64 align);
 extern u64 dt_mem_next_cell(int s, const __be32 **cellp);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..c103b94 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -814,6 +814,30 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * memblock_mark_raw_pfn - Mark raw pfn memory with flag MEMBLOCK_RAW_PFN.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * Return 0 on succees, -errno on failure.
+ */
+int __init_memblock memblock_mark_raw_pfn(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_RAW_PFN);
+}
+
+/**
+ * memblock_clear_raw_pfn - Clear flag MEMBLOCK_RAW_PFN for a specified region.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * Return 0 on succees, -errno on failure.
+ */
+int __init_memblock memblock_clear_raw_pfn(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 0, MEMBLOCK_RAW_PFN);
+}
+
+/**
  * __next_reserved_mem_region - next function for for_each_reserved_region()
  * @idx: pointer to u64 loop variable
  * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
