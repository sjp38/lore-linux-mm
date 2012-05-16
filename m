Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 94CC46B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 22:04:58 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
Date: Wed, 16 May 2012 11:05:17 +0900
Message-Id: <1337133919-4182-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chen Liqin <liqin.chen@sunplusct.com>

zsmalloc uses set_pte and __flush_tlb_one for performance but
many architecture don't support it. so this patch removes
set_pte and __flush_tlb_one which are x86 dependency.
Instead of it, use local_flush_tlb_kernel_range which are available
by more architectures. It would be better than supporting only x86
and last patch in series will enable again with supporting
local_flush_tlb_kernel_range in x86.

About local_flush_tlb_kernel_range,
If architecture is very smart, it could flush only tlb entries related to vaddr.
If architecture is smart, it could flush only tlb entries related to a CPU.
If architecture is _NOT_ smart, it could flush all entries of all CPUs.
So, it would be best to support both portability and performance.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---

Need double check about supporting local_flush_tlb_kernel_range
in ARM, MIPS, SUPERH maintainers. And I will Ccing unicore32 and
score maintainers because arch directory in those arch have
local_flush_tlb_kernel_range, too but I'm very unfamiliar with those
architecture so pass it to maintainers.
I didn't coded up dumb local_flush_tlb_kernel_range which flush
all cpus. I expect someone need ZSMALLOC will implement it easily in future.
Seth might support it in PowerPC. :)


 drivers/staging/zsmalloc/Kconfig         |    6 ++---
 drivers/staging/zsmalloc/zsmalloc-main.c |   36 +++++++++++++++++++++---------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    1 -
 3 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index a5ab720..def2483 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -1,9 +1,9 @@
 config ZSMALLOC
 	tristate "Memory allocator for compressed pages"
-	# X86 dependency is because of the use of __flush_tlb_one and set_pte
+	# arch dependency is because of the use of local_unmap_kernel_range
 	# in zsmalloc-main.c.
-	# TODO: convert these to portable functions
-	depends on X86
+	# TODO: implement local_unmap_kernel_range in all architecture.
+	depends on (ARM || MIPS || SUPERH)
 	default n
 	help
 	  zsmalloc is a slab-based memory allocator designed to store
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 4496737..8a8b08f 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -442,7 +442,7 @@ static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
 		area = &per_cpu(zs_map_area, cpu);
 		if (area->vm)
 			break;
-		area->vm = alloc_vm_area(2 * PAGE_SIZE, area->vm_ptes);
+		area->vm = alloc_vm_area(2 * PAGE_SIZE, NULL);
 		if (!area->vm)
 			return notifier_from_errno(-ENOMEM);
 		break;
@@ -696,13 +696,22 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
 	} else {
 		/* this object spans two pages */
 		struct page *nextp;
+		struct page *pages[2];
+		struct page **page_array = &pages[0];
+		int err;
 
 		nextp = get_next_page(page);
 		BUG_ON(!nextp);
 
+		page_array[0] = page;
+		page_array[1] = nextp;
 
-		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
-		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
+		/*
+		 * map_vm_area never fail because we already allocated
+		 * pages for page table in alloc_vm_area.
+		 */
+		err = map_vm_area(area->vm, PAGE_KERNEL, &page_array);
+		BUG_ON(err);
 
 		/* We pre-allocated VM area so mapping can never fail */
 		area->vm_addr = area->vm->addr;
@@ -712,6 +721,15 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
+static void local_unmap_kernel_range(unsigned long addr, unsigned long size)
+{
+	unsigned long end = addr + size;
+
+	flush_cache_vunmap(addr, end);
+	unmap_kernel_range_noflush(addr, size);
+	local_flush_tlb_kernel_range(addr, end);
+}
+
 void zs_unmap_object(struct zs_pool *pool, void *handle)
 {
 	struct page *page;
@@ -730,14 +748,12 @@ void zs_unmap_object(struct zs_pool *pool, void *handle)
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = &__get_cpu_var(zs_map_area);
-	if (off + class->size <= PAGE_SIZE) {
+	if (off + class->size <= PAGE_SIZE)
 		kunmap_atomic(area->vm_addr);
-	} else {
-		set_pte(area->vm_ptes[0], __pte(0));
-		set_pte(area->vm_ptes[1], __pte(0));
-		__flush_tlb_one((unsigned long)area->vm_addr);
-		__flush_tlb_one((unsigned long)area->vm_addr + PAGE_SIZE);
-	}
+	else
+		local_unmap_kernel_range((unsigned long)area->vm->addr,
+					PAGE_SIZE * 2);
+
 	put_cpu_var(zs_map_area);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 6fd32a9..eaec845 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -111,7 +111,6 @@ static const int fullness_threshold_frac = 4;
 
 struct mapping_area {
 	struct vm_struct *vm;
-	pte_t *vm_ptes[2];
 	char *vm_addr;
 };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
