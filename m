Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCFC36B0010
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 13:01:45 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o68-v6so13628956qte.0
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:01:45 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0114.outbound.protection.outlook.com. [104.47.0.114])
        by mx.google.com with ESMTPS id b17-v6si336579qkc.57.2018.06.25.10.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 10:01:44 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kernel/memremap, kasan: Make ZONE_DEVICE with work with KASAN
Date: Mon, 25 Jun 2018 20:02:59 +0300
Message-Id: <20180625170259.30393-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

KASAN learns about hot added memory via the memory hotplug notifier.
The devm_memremap_pages() intentionally skips calling memory hotplug
notifiers. So KASAN doesn't know anything about new memory added
by devm_memremap_pages(). This causes to crash when KASAN tries to
access non-existent shadow memory:

 BUG: unable to handle kernel paging request at ffffed0078000000
 RIP: 0010:check_memory_region+0x82/0x1e0
 Call Trace:
  memcpy+0x1f/0x50
  pmem_do_bvec+0x163/0x720
  pmem_make_request+0x305/0xac0
  generic_make_request+0x54f/0xcf0
  submit_bio+0x9c/0x370
  submit_bh_wbc+0x4c7/0x700
  block_read_full_page+0x5ef/0x870
  do_read_cache_page+0x2b8/0xb30
  read_dev_sector+0xbd/0x3f0
  read_lba.isra.0+0x277/0x670
  efi_partition+0x41a/0x18f0
  check_partition+0x30d/0x5e9
  rescan_partitions+0x18c/0x840
  __blkdev_get+0x859/0x1060
  blkdev_get+0x23f/0x810
  __device_add_disk+0x9c8/0xde0
  pmem_attach_disk+0x9a8/0xf50
  nvdimm_bus_probe+0xf3/0x3c0
  driver_probe_device+0x493/0xbd0
  bus_for_each_drv+0x118/0x1b0
  __device_attach+0x1cd/0x2b0
  bus_probe_device+0x1ac/0x260
  device_add+0x90d/0x1380
  nd_async_device_register+0xe/0x50
  async_run_entry_fn+0xc3/0x5d0
  process_one_work+0xa0a/0x1810
  worker_thread+0x87/0xe80
  kthread+0x2d7/0x390
  ret_from_fork+0x3a/0x50

Add kasan_add_zero_shadow()/kasan_remove_zero_shadow() - post mm_init()
interface to map/unmap kasan_zero_page at requested virtual addresses.
And use it to add/remove the shadow memory for hotpluged/unpluged
device memory.

Reported-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
---
 include/linux/kasan.h |  13 ++-
 kernel/memremap.c     |  10 ++
 mm/kasan/kasan_init.c | 316 +++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 325 insertions(+), 14 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index de784fd11d12..46aae129917c 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -20,7 +20,7 @@ extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
 extern p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D];
 
-void kasan_populate_zero_shadow(const void *shadow_start,
+int kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
 
 static inline void *kasan_mem_to_shadow(const void *addr)
@@ -71,6 +71,9 @@ struct kasan_cache {
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
 
+int kasan_add_zero_shadow(void *start, unsigned long size);
+void kasan_remove_zero_shadow(void *start, unsigned long size);
+
 size_t ksize(const void *);
 static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
 size_t kasan_metadata_size(struct kmem_cache *cache);
@@ -124,6 +127,14 @@ static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
 static inline void kasan_free_shadow(const struct vm_struct *vm) {}
 
+static inline int kasan_add_zero_shadow(void *start, unsigned long size)
+{
+	return 0;
+}
+static inline void kasan_remove_zero_shadow(void *start,
+					unsigned long size)
+{}
+
 static inline void kasan_unpoison_slab(const void *ptr) { }
 static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5857267a4af5..172264bf5812 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -5,6 +5,7 @@
 #include <linux/types.h>
 #include <linux/pfn_t.h>
 #include <linux/io.h>
+#include <linux/kasan.h>
 #include <linux/mm.h>
 #include <linux/memory_hotplug.h>
 #include <linux/swap.h>
@@ -137,6 +138,7 @@ static void devm_memremap_pages_release(void *data)
 	mem_hotplug_begin();
 	arch_remove_memory(align_start, align_size, pgmap->altmap_valid ?
 			&pgmap->altmap : NULL);
+	kasan_remove_zero_shadow(__va(align_start), align_size);
 	mem_hotplug_done();
 
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
@@ -223,6 +225,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_pfn_remap;
 
 	mem_hotplug_begin();
+	error = kasan_add_zero_shadow(__va(align_start), align_size);
+	if (error) {
+		mem_hotplug_done();
+		goto err_kasan;
+	}
+
 	error = arch_add_memory(nid, align_start, align_size, altmap, false);
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
@@ -251,6 +259,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	return __va(res->start);
 
  err_add_memory:
+	kasan_remove_zero_shadow(__va(align_start), align_size);
+ err_kasan:
 	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
  err_pfn_remap:
  err_radix:
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index f436246ccc79..3ae77df8f414 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -21,6 +21,8 @@
 #include <asm/page.h>
 #include <asm/pgalloc.h>
 
+#include "kasan.h"
+
 /*
  * This page serves two purposes:
  *   - It used as early shadow memory. The entire shadow region populated
@@ -32,22 +34,59 @@ unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
 #if CONFIG_PGTABLE_LEVELS > 4
 p4d_t kasan_zero_p4d[MAX_PTRS_PER_P4D] __page_aligned_bss;
+static inline bool kasan_p4d_table(pgd_t pgd)
+{
+	return __pa(pgd_page_vaddr(pgd)) == __pa_symbol(kasan_zero_p4d);
+}
+#else
+static inline bool kasan_p4d_table(pgd_t pgd)
+{
+	return 0;
+}
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
 pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+static inline bool kasan_pud_table(p4d_t p4d)
+{
+	return __pa(p4d_page_vaddr(p4d)) == __pa_symbol(kasan_zero_pud);
+}
+#else
+static inline bool kasan_pud_table(p4d_t p4d)
+{
+	return 0;
+}
 #endif
 #if CONFIG_PGTABLE_LEVELS > 2
 pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+static inline bool kasan_pmd_table(pud_t pud)
+{
+	return __pa(pud_page_vaddr(pud)) == __pa_symbol(kasan_zero_pmd);
+}
+#else
+static inline bool kasan_pmd_table(pud_t pud)
+{
+	return 0;
+}
 #endif
 pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
 
+static inline bool kasan_pte_table(pmd_t pmd)
+{
+	return __pa(pmd_page_vaddr(pmd)) == __pa_symbol(kasan_zero_pte);
+}
+
+static inline bool kasan_zero_page_entry(pte_t pte)
+{
+	return pte_pfn(pte) == PHYS_PFN(__pa_symbol(kasan_zero_page));
+}
+
 static __init void *early_alloc(size_t size, int node)
 {
 	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
 					BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
-static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
+static void __ref zero_pte_populate(pmd_t *pmd, unsigned long addr,
 				unsigned long end)
 {
 	pte_t *pte = pte_offset_kernel(pmd, addr);
@@ -63,7 +102,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 	}
 }
 
-static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
+static int __ref zero_pmd_populate(pud_t *pud, unsigned long addr,
 				unsigned long end)
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
@@ -78,14 +117,24 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 		}
 
 		if (pmd_none(*pmd)) {
-			pmd_populate_kernel(&init_mm, pmd,
-					early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+			pte_t *p;
+
+			if (slab_is_available())
+				p = pte_alloc_one_kernel(&init_mm, addr);
+			else
+				p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+
+			pmd_populate_kernel(&init_mm, pmd, p);
 		}
 		zero_pte_populate(pmd, addr, next);
 	} while (pmd++, addr = next, addr != end);
+
+	return 0;
 }
 
-static void __init zero_pud_populate(p4d_t *p4d, unsigned long addr,
+static int __ref zero_pud_populate(p4d_t *p4d, unsigned long addr,
 				unsigned long end)
 {
 	pud_t *pud = pud_offset(p4d, addr);
@@ -103,14 +152,25 @@ static void __init zero_pud_populate(p4d_t *p4d, unsigned long addr,
 		}
 
 		if (pud_none(*pud)) {
-			pud_populate(&init_mm, pud,
-				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+			pmd_t *p;
+
+			if (slab_is_available())
+				p = pmd_alloc_one(&init_mm, addr);
+			else
+				p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+
+			if (!p)
+				return -ENOMEM;
+
+			pud_populate(&init_mm, pud, p);
 		}
 		zero_pmd_populate(pud, addr, next);
 	} while (pud++, addr = next, addr != end);
+
+	return 0;
 }
 
-static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
+static int __ref zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 				unsigned long end)
 {
 	p4d_t *p4d = p4d_offset(pgd, addr);
@@ -132,11 +192,21 @@ static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 		}
 
 		if (p4d_none(*p4d)) {
-			p4d_populate(&init_mm, p4d,
-				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+			pud_t *p;
+
+			if (slab_is_available())
+				p = pud_alloc_one(&init_mm, addr);
+			else
+				p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+
+			p4d_populate(&init_mm, p4d, p);
 		}
 		zero_pud_populate(p4d, addr, next);
 	} while (p4d++, addr = next, addr != end);
+
+	return 0;
 }
 
 /**
@@ -145,7 +215,7 @@ static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
  * @shadow_start - start of the memory range to populate
  * @shadow_end   - end of the memory range to populate
  */
-void __init kasan_populate_zero_shadow(const void *shadow_start,
+int __ref kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end)
 {
 	unsigned long addr = (unsigned long)shadow_start;
@@ -191,9 +261,229 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 		}
 
 		if (pgd_none(*pgd)) {
-			pgd_populate(&init_mm, pgd,
-				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+			p4d_t *p;
+
+			if (slab_is_available())
+				p = p4d_alloc_one(&init_mm, addr);
+			else
+				p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+
+			pgd_populate(&init_mm, pgd, p);
 		}
 		zero_p4d_populate(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
+
+	return 0;
+}
+
+static void kasan_free_pte(pte_t *pte_start, pmd_t *pmd)
+{
+	pte_t *pte;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		pte = pte_start + i;
+		if (!pte_none(*pte))
+			return;
+	}
+
+	pte_free_kernel(&init_mm, (pte_t *)pmd_page_vaddr(*pmd));
+	pmd_clear(pmd);
+}
+
+static void kasan_free_pmd(pmd_t *pmd_start, pud_t *pud)
+{
+	pmd_t *pmd;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		pmd = pmd_start + i;
+		if (!pmd_none(*pmd))
+			return;
+	}
+
+	pmd_free(&init_mm, (pmd_t *)pud_page_vaddr(*pud));
+	pud_clear(pud);
+}
+
+static void kasan_free_pud(pud_t *pud_start, p4d_t *p4d)
+{
+	pud_t *pud;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		pud = pud_start + i;
+		if (!pud_none(*pud))
+			return;
+	}
+
+	pud_free(&init_mm, (pud_t *)p4d_page_vaddr(*p4d));
+	p4d_clear(p4d);
+}
+
+static void kasan_free_p4d(p4d_t *p4d_start, pgd_t *pgd)
+{
+	p4d_t *p4d;
+	int i;
+
+	for (i = 0; i < PTRS_PER_P4D; i++) {
+		p4d = p4d_start + i;
+		if (!p4d_none(*p4d))
+			return;
+	}
+
+	p4d_free(&init_mm, (p4d_t *)pgd_page_vaddr(*pgd));
+	pgd_clear(pgd);
+}
+
+static void kasan_remove_pte_table(pte_t *pte, unsigned long addr,
+				unsigned long end)
+{
+	unsigned long next;
+
+	for (; addr < end; addr = next, pte++) {
+		next = (addr + PAGE_SIZE) & PAGE_MASK;
+		if (next > end)
+			next = end;
+
+		if (!pte_present(*pte))
+			continue;
+
+		if (WARN_ON(!kasan_zero_page_entry(*pte)))
+			continue;
+		pte_clear(&init_mm, addr, pte);
+	}
+}
+
+static void kasan_remove_pmd_table(pmd_t *pmd, unsigned long addr,
+				unsigned long end)
+{
+	unsigned long next;
+
+	for (; addr < end; addr = next, pmd++) {
+		pte_t *pte;
+
+		next = pmd_addr_end(addr, end);
+
+		if (!pmd_present(*pmd))
+			continue;
+
+		if (kasan_pte_table(*pmd)) {
+			if (IS_ALIGNED(addr, PMD_SIZE) &&
+			    IS_ALIGNED(next, PMD_SIZE))
+				pmd_clear(pmd);
+			continue;
+		}
+		pte = pte_offset_kernel(pmd, addr);
+		kasan_remove_pte_table(pte, addr, next);
+		kasan_free_pte(pte_offset_kernel(pmd, 0), pmd);
+	}
+}
+
+static void kasan_remove_pud_table(pud_t *pud, unsigned long addr,
+				unsigned long end)
+{
+	unsigned long next;
+
+	for (; addr < end; addr = next, pud++) {
+		pmd_t *pmd, *pmd_base;
+
+		next = pud_addr_end(addr, end);
+
+		if (!pud_present(*pud))
+			continue;
+
+		if (kasan_pmd_table(*pud)) {
+			if (IS_ALIGNED(addr, PUD_SIZE) &&
+			    IS_ALIGNED(next, PUD_SIZE))
+				pud_clear(pud);
+			continue;
+		}
+		pmd = pmd_offset(pud, addr);
+		pmd_base = pmd_offset(pud, 0);
+		kasan_remove_pmd_table(pmd, addr, next);
+		kasan_free_pmd(pmd_base, pud);
+	}
+}
+
+static void kasan_remove_p4d_table(p4d_t *p4d, unsigned long addr,
+				unsigned long end)
+{
+	unsigned long next;
+
+	for (; addr < end; addr = next, p4d++) {
+		pud_t *pud;
+
+		next = p4d_addr_end(addr, end);
+
+		if (!p4d_present(*p4d))
+			continue;
+
+		if (kasan_pud_table(*p4d)) {
+			if (IS_ALIGNED(addr, P4D_SIZE) &&
+			    IS_ALIGNED(next, P4D_SIZE))
+				p4d_clear(p4d);
+			continue;
+		}
+		pud = pud_offset(p4d, addr);
+		kasan_remove_pud_table(pud, addr, next);
+		kasan_free_pud(pud_offset(p4d, 0), p4d);
+	}
+}
+
+void kasan_remove_zero_shadow(void *start, unsigned long size)
+{
+	unsigned long addr, end, next;
+	pgd_t *pgd;
+
+	addr = (unsigned long)kasan_mem_to_shadow(start);
+	end = addr + (size >> KASAN_SHADOW_SCALE_SHIFT);
+
+	if (WARN_ON((unsigned long)start %
+			(KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE)) ||
+	    WARN_ON(size % (KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE)))
+		return;
+
+	for (; addr < end; addr = next) {
+		p4d_t *p4d;
+
+		next = pgd_addr_end(addr, end);
+
+		pgd = pgd_offset_k(addr);
+		if (!pgd_present(*pgd))
+			continue;
+
+		if (kasan_p4d_table(*pgd)) {
+			if (IS_ALIGNED(addr, PGDIR_SIZE) &&
+			    IS_ALIGNED(next, PGDIR_SIZE))
+				pgd_clear(pgd);
+			continue;
+		}
+
+		p4d = p4d_offset(pgd, addr);
+		kasan_remove_p4d_table(p4d, addr, next);
+		kasan_free_p4d(p4d_offset(pgd, 0), pgd);
+	}
+}
+
+int kasan_add_zero_shadow(void *start, unsigned long size)
+{
+	int ret;
+	void *shadow_start, *shadow_end;
+
+	shadow_start = kasan_mem_to_shadow(start);
+	shadow_end = shadow_start + (size >> KASAN_SHADOW_SCALE_SHIFT);
+
+	if (WARN_ON((unsigned long)start %
+			(KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE)) ||
+	    WARN_ON(size % (KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE)))
+		return -EINVAL;
+
+	ret = kasan_populate_zero_shadow(shadow_start, shadow_end);
+	if (ret)
+		kasan_remove_zero_shadow(shadow_start,
+					size >> KASAN_SHADOW_SCALE_SHIFT);
+	return ret;
 }
-- 
2.16.4
