Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 60DD9829BA
	for <linux-mm@kvack.org>; Fri, 22 May 2015 12:14:32 -0400 (EDT)
Received: by wibt6 with SMTP id t6so52349316wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:14:31 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id d5si4448354wjb.200.2015.05.22.09.14.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 09:14:30 -0700 (PDT)
Received: by wibt6 with SMTP id t6so52348398wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:14:29 -0700 (PDT)
From: Leon Romanovsky <leon@leon.nu>
Subject: [PATCH v2] mm: nommu: refactor debug and warning prints
Date: Fri, 22 May 2015 19:14:15 +0300
Message-Id: <1432311255-22443-1-git-send-email-leon@leon.nu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dhowells@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leon Romanovsky <leon@leon.nu>

kenter/kleave/kdebug are wrapper macros to print functions flow and debug
information. This set was written before pr_devel() was introduced, so
it was controlled by "#if 0" construction. It is questionable if anyone
is using them [1] now.

This patch removes these macros, converts numerous
printk(KERN_WARNING, ...) to use general pr_warn(...) and
removes debug print line from validate_mmap_request() function.

--
Changelog since v1
* Remove kenter/kleave/kdebug macros as was suggested by Andrew Morton [2]
* Convert warning prints to be pr_warn(..)
* Fix checkpatch warnings in legacy prints code
* Change title to reflect new changes. It was "[PATCH] mm: nommu: convert
  kenter/kleave/kdebug macros to use pr_devel()" [3].

[1] https://lkml.org/lkml/2015/5/16/279
[2] https://lkml.org/lkml/2015/5/18/903
[3] https://lkml.org/lkml/2015/5/18/682

Signed-off-by: Leon Romanovsky <leon@leon.nu>
---
 mm/nommu.c |  112 +++++++++++-------------------------------------------------
 1 file changed, 20 insertions(+), 92 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index e544508..05e7447 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -42,22 +42,6 @@
 #include <asm/mmu_context.h>
 #include "internal.h"
 
-#if 0
-#define kenter(FMT, ...) \
-	printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
-#define kleave(FMT, ...) \
-	printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
-#define kdebug(FMT, ...) \
-	printk(KERN_DEBUG "xxx" FMT"yyy\n", ##__VA_ARGS__)
-#else
-#define kenter(FMT, ...) \
-	no_printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
-#define kleave(FMT, ...) \
-	no_printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
-#define kdebug(FMT, ...) \
-	no_printk(KERN_DEBUG FMT"\n", ##__VA_ARGS__)
-#endif
-
 void *high_memory;
 EXPORT_SYMBOL(high_memory);
 struct page *mem_map;
@@ -665,11 +649,7 @@ static void free_page_series(unsigned long from, unsigned long to)
 	for (; from < to; from += PAGE_SIZE) {
 		struct page *page = virt_to_page(from);
 
-		kdebug("- free %lx", from);
 		atomic_long_dec(&mmap_pages_allocated);
-		if (page_count(page) != 1)
-			kdebug("free page %p: refcount not one: %d",
-			       page, page_count(page));
 		put_page(page);
 	}
 }
@@ -683,8 +663,6 @@ static void free_page_series(unsigned long from, unsigned long to)
 static void __put_nommu_region(struct vm_region *region)
 	__releases(nommu_region_sem)
 {
-	kenter("%p{%d}", region, region->vm_usage);
-
 	BUG_ON(!nommu_region_tree.rb_node);
 
 	if (--region->vm_usage == 0) {
@@ -697,10 +675,8 @@ static void __put_nommu_region(struct vm_region *region)
 
 		/* IO memory and memory shared directly out of the pagecache
 		 * from ramfs/tmpfs mustn't be released here */
-		if (region->vm_flags & VM_MAPPED_COPY) {
-			kdebug("free series");
+		if (region->vm_flags & VM_MAPPED_COPY)
 			free_page_series(region->vm_start, region->vm_top);
-		}
 		kmem_cache_free(vm_region_jar, region);
 	} else {
 		up_write(&nommu_region_sem);
@@ -744,8 +720,6 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	struct address_space *mapping;
 	struct rb_node **p, *parent, *rb_prev;
 
-	kenter(",%p", vma);
-
 	BUG_ON(!vma->vm_region);
 
 	mm->map_count++;
@@ -813,8 +787,6 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	struct mm_struct *mm = vma->vm_mm;
 	struct task_struct *curr = current;
 
-	kenter("%p", vma);
-
 	protect_vma(vma, 0);
 
 	mm->map_count--;
@@ -854,7 +826,6 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
  */
 static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	kenter("%p", vma);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
@@ -957,12 +928,8 @@ static int validate_mmap_request(struct file *file,
 	int ret;
 
 	/* do the simple checks first */
-	if (flags & MAP_FIXED) {
-		printk(KERN_DEBUG
-		       "%d: Can't do fixed-address/overlay mmap of RAM\n",
-		       current->pid);
+	if (flags & MAP_FIXED)
 		return -EINVAL;
-	}
 
 	if ((flags & MAP_TYPE) != MAP_PRIVATE &&
 	    (flags & MAP_TYPE) != MAP_SHARED)
@@ -1060,8 +1027,7 @@ static int validate_mmap_request(struct file *file,
 			    ) {
 				capabilities &= ~NOMMU_MAP_DIRECT;
 				if (flags & MAP_SHARED) {
-					printk(KERN_WARNING
-					       "MAP_SHARED not completely supported on !MMU\n");
+					pr_warn("MAP_SHARED not completely supported on !MMU\n");
 					return -EINVAL;
 				}
 			}
@@ -1205,16 +1171,12 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	 *   we're allocating is smaller than a page
 	 */
 	order = get_order(len);
-	kdebug("alloc order %d for %lx", order, len);
-
 	total = 1 << order;
 	point = len >> PAGE_SHIFT;
 
 	/* we don't want to allocate a power-of-2 sized page set */
-	if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages) {
+	if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages)
 		total = point;
-		kdebug("try to alloc exact %lu pages", total);
-	}
 
 	base = alloc_pages_exact(total << PAGE_SHIFT, GFP_KERNEL);
 	if (!base)
@@ -1285,18 +1247,14 @@ unsigned long do_mmap_pgoff(struct file *file,
 	unsigned long capabilities, vm_flags, result;
 	int ret;
 
-	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
-
 	*populate = 0;
 
 	/* decide whether we should attempt the mapping, and if so what sort of
 	 * mapping */
 	ret = validate_mmap_request(file, addr, len, prot, flags, pgoff,
 				    &capabilities);
-	if (ret < 0) {
-		kleave(" = %d [val]", ret);
+	if (ret < 0)
 		return ret;
-	}
 
 	/* we ignore the address hint */
 	addr = 0;
@@ -1383,11 +1341,9 @@ unsigned long do_mmap_pgoff(struct file *file,
 			vma->vm_start = start;
 			vma->vm_end = start + len;
 
-			if (pregion->vm_flags & VM_MAPPED_COPY) {
-				kdebug("share copy");
+			if (pregion->vm_flags & VM_MAPPED_COPY)
 				vma->vm_flags |= VM_MAPPED_COPY;
-			} else {
-				kdebug("share mmap");
+			else {
 				ret = do_mmap_shared_file(vma);
 				if (ret < 0) {
 					vma->vm_region = NULL;
@@ -1467,7 +1423,6 @@ share:
 
 	up_write(&nommu_region_sem);
 
-	kleave(" = %lx", result);
 	return result;
 
 error_just_free:
@@ -1479,27 +1434,24 @@ error:
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	kmem_cache_free(vm_area_cachep, vma);
-	kleave(" = %d", ret);
 	return ret;
 
 sharing_violation:
 	up_write(&nommu_region_sem);
-	printk(KERN_WARNING "Attempt to share mismatched mappings\n");
+	pr_warn("Attempt to share mismatched mappings\n");
 	ret = -EINVAL;
 	goto error;
 
 error_getting_vma:
 	kmem_cache_free(vm_region_jar, region);
-	printk(KERN_WARNING "Allocation of vma for %lu byte allocation"
-	       " from process %d failed\n",
-	       len, current->pid);
+	pr_warn("Allocation of vma for %lu byte allocation from process %d failed\n",
+			len, current->pid);
 	show_free_areas(0);
 	return -ENOMEM;
 
 error_getting_region:
-	printk(KERN_WARNING "Allocation of vm region for %lu byte allocation"
-	       " from process %d failed\n",
-	       len, current->pid);
+	pr_warn("Allocation of vm region for %lu byte allocation from process %d failed\n",
+			len, current->pid);
 	show_free_areas(0);
 	return -ENOMEM;
 }
@@ -1563,8 +1515,6 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_region *region;
 	unsigned long npages;
 
-	kenter("");
-
 	/* we're only permitted to split anonymous regions (these should have
 	 * only a single usage on the region) */
 	if (vma->vm_file)
@@ -1628,8 +1578,6 @@ static int shrink_vma(struct mm_struct *mm,
 {
 	struct vm_region *region;
 
-	kenter("");
-
 	/* adjust the VMA's pointers, which may reposition it in the MM's tree
 	 * and list */
 	delete_vma_from_mm(vma);
@@ -1669,8 +1617,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	unsigned long end;
 	int ret;
 
-	kenter(",%lx,%zx", start, len);
-
 	len = PAGE_ALIGN(len);
 	if (len == 0)
 		return -EINVAL;
@@ -1682,11 +1628,9 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	if (!vma) {
 		static int limit;
 		if (limit < 5) {
-			printk(KERN_WARNING
-			       "munmap of memory not mmapped by process %d"
-			       " (%s): 0x%lx-0x%lx\n",
-			       current->pid, current->comm,
-			       start, start + len - 1);
+			pr_warn("munmap of memory not mmapped by process %d (%s): 0x%lx-0x%lx\n",
+					current->pid, current->comm,
+					start, start + len - 1);
 			limit++;
 		}
 		return -EINVAL;
@@ -1695,38 +1639,27 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	/* we're allowed to split an anonymous VMA but not a file-backed one */
 	if (vma->vm_file) {
 		do {
-			if (start > vma->vm_start) {
-				kleave(" = -EINVAL [miss]");
+			if (start > vma->vm_start)
 				return -EINVAL;
-			}
 			if (end == vma->vm_end)
 				goto erase_whole_vma;
 			vma = vma->vm_next;
 		} while (vma);
-		kleave(" = -EINVAL [split file]");
 		return -EINVAL;
 	} else {
 		/* the chunk must be a subset of the VMA found */
 		if (start == vma->vm_start && end == vma->vm_end)
 			goto erase_whole_vma;
-		if (start < vma->vm_start || end > vma->vm_end) {
-			kleave(" = -EINVAL [superset]");
+		if (start < vma->vm_start || end > vma->vm_end)
 			return -EINVAL;
-		}
-		if (start & ~PAGE_MASK) {
-			kleave(" = -EINVAL [unaligned start]");
+		if (start & ~PAGE_MASK)
 			return -EINVAL;
-		}
-		if (end != vma->vm_end && end & ~PAGE_MASK) {
-			kleave(" = -EINVAL [unaligned split]");
+		if (end != vma->vm_end && end & ~PAGE_MASK)
 			return -EINVAL;
-		}
 		if (start != vma->vm_start && end != vma->vm_end) {
 			ret = split_vma(mm, vma, start, 1);
-			if (ret < 0) {
-				kleave(" = %d [split]", ret);
+			if (ret < 0)
 				return ret;
-			}
 		}
 		return shrink_vma(mm, vma, start, end);
 	}
@@ -1734,7 +1667,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 erase_whole_vma:
 	delete_vma_from_mm(vma);
 	delete_vma(mm, vma);
-	kleave(" = 0");
 	return 0;
 }
 EXPORT_SYMBOL(do_munmap);
@@ -1766,8 +1698,6 @@ void exit_mmap(struct mm_struct *mm)
 	if (!mm)
 		return;
 
-	kenter("");
-
 	mm->total_vm = 0;
 
 	while ((vma = mm->mmap)) {
@@ -1776,8 +1706,6 @@ void exit_mmap(struct mm_struct *mm)
 		delete_vma(mm, vma);
 		cond_resched();
 	}
-
-	kleave("");
 }
 
 unsigned long vm_brk(unsigned long addr, unsigned long len)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
