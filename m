Message-Id: <200405222211.i4MMBZr14093@mail.osdl.org>
Subject: [patch 40/57] rmap 22 flush_dcache_mmap_lock
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:05 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

arm and parisc __flush_dcache_page have been scanning the i_mmap(_shared) list
without locking or disabling preemption.  That may be even more unsafe now
it's a prio tree instead of a list.

It looks like we cannot use i_shared_lock for this protection: most uses of
flush_dcache_page are okay, and only one would need lock ordering fixed
(get_user_pages holds page_table_lock across flush_dcache_page); but there's a
few (e.g.  in net and ntfs) which look as if they're using it in I/O
completion - and it would be restrictive to disallow it there.

So, on arm and parisc only, define flush_dcache_mmap_lock(mapping) as
spin_lock_irq(&(mapping)->tree_lock); on i386 (and other arches left to the
next patch) define it away to nothing; and use where needed.

While updating locking hierarchy in filemap.c, remove two layers of the fossil
record from add_to_page_cache comment: no longer used for swap.

I believe all the #includes will work out, but have only built i386.  I can
see several things about this patch which might cause revulsion: the name
flush_dcache_mmap_lock?  the reuse of the page radix_tree's tree_lock for this
different purpose?  spin_lock_irqsave instead?  can't we somehow get
i_shared_lock to handle the problem?


---

 25-akpm/arch/arm/mm/fault-armv.c        |    5 +++++
 25-akpm/arch/parisc/kernel/cache.c      |    4 +++-
 25-akpm/include/asm-arm/cacheflush.h    |    5 +++++
 25-akpm/include/asm-i386/cacheflush.h   |    2 ++
 25-akpm/include/asm-parisc/cacheflush.h |    5 +++++
 25-akpm/kernel/fork.c                   |    2 ++
 25-akpm/mm/filemap.c                    |    4 +++-
 25-akpm/mm/fremap.c                     |    2 ++
 25-akpm/mm/mmap.c                       |   10 +++++++++-
 9 files changed, 36 insertions(+), 3 deletions(-)

diff -puN arch/arm/mm/fault-armv.c~rmap-22-flush_dcache_mmap_lock arch/arm/mm/fault-armv.c
--- 25/arch/arm/mm/fault-armv.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.865855272 -0700
+++ 25-akpm/arch/arm/mm/fault-armv.c	2004-05-22 14:56:27.879853144 -0700
@@ -94,6 +94,8 @@ void __flush_dcache_page(struct page *pa
 	 * and invalidate any user data.
 	 */
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+	flush_dcache_mmap_lock(mapping);
 	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		/*
@@ -106,6 +108,7 @@ void __flush_dcache_page(struct page *pa
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		flush_cache_page(mpnt, mpnt->vm_start + offset);
 	}
+	flush_dcache_mmap_unlock(mapping);
 }
 
 static void
@@ -129,6 +132,7 @@ make_coherent(struct vm_area_struct *vma
 	 * space, then we need to handle them specially to maintain
 	 * cache coherency.
 	 */
+	flush_dcache_mmap_lock(mapping);
 	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		/*
@@ -143,6 +147,7 @@ make_coherent(struct vm_area_struct *vma
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
 		aliases += adjust_pte(mpnt, mpnt->vm_start + offset);
 	}
+	flush_dcache_mmap_unlock(mapping);
 	if (aliases)
 		adjust_pte(vma, addr);
 	else
diff -puN arch/parisc/kernel/cache.c~rmap-22-flush_dcache_mmap_lock arch/parisc/kernel/cache.c
--- 25/arch/parisc/kernel/cache.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.866855120 -0700
+++ 25-akpm/arch/parisc/kernel/cache.c	2004-05-22 14:56:27.880852992 -0700
@@ -249,6 +249,7 @@ void __flush_dcache_page(struct page *pa
 	 * declared as MAP_PRIVATE or MAP_SHARED), so we only need
 	 * to flush one address here for them all to become coherent */
 
+	flush_dcache_mmap_lock(mapping);
 	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
 					&iter, pgoff, pgoff)) != NULL) {
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
@@ -266,8 +267,9 @@ void __flush_dcache_page(struct page *pa
 
 		__flush_cache_page(mpnt, addr);
 
-		return;
+		break;
 	}
+	flush_dcache_mmap_unlock(mapping);
 }
 EXPORT_SYMBOL(__flush_dcache_page);
 
diff -puN include/asm-arm/cacheflush.h~rmap-22-flush_dcache_mmap_lock include/asm-arm/cacheflush.h
--- 25/include/asm-arm/cacheflush.h~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.867854968 -0700
+++ 25-akpm/include/asm-arm/cacheflush.h	2004-05-22 14:56:27.880852992 -0700
@@ -303,6 +303,11 @@ static inline void flush_dcache_page(str
 		__flush_dcache_page(page);
 }
 
+#define flush_dcache_mmap_lock(mapping) \
+	spin_lock_irq(&(mapping)->tree_lock)
+#define flush_dcache_mmap_unlock(mapping) \
+	spin_unlock_irq(&(mapping)->tree_lock)
+
 #define flush_icache_user_range(vma,page,addr,len) \
 	flush_dcache_page(page)
 
diff -puN include/asm-i386/cacheflush.h~rmap-22-flush_dcache_mmap_lock include/asm-i386/cacheflush.h
--- 25/include/asm-i386/cacheflush.h~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.869854664 -0700
+++ 25-akpm/include/asm-i386/cacheflush.h	2004-05-22 14:56:27.881852840 -0700
@@ -10,6 +10,8 @@
 #define flush_cache_range(vma, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma,pg)		do { } while (0)
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
diff -puN include/asm-parisc/cacheflush.h~rmap-22-flush_dcache_mmap_lock include/asm-parisc/cacheflush.h
--- 25/include/asm-parisc/cacheflush.h~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.870854512 -0700
+++ 25-akpm/include/asm-parisc/cacheflush.h	2004-05-22 14:56:27.881852840 -0700
@@ -78,6 +78,11 @@ static inline void flush_dcache_page(str
 	}
 }
 
+#define flush_dcache_mmap_lock(mapping) \
+	spin_lock_irq(&(mapping)->tree_lock)
+#define flush_dcache_mmap_unlock(mapping) \
+	spin_unlock_irq(&(mapping)->tree_lock)
+
 #define flush_icache_page(vma,page)	do { flush_kernel_dcache_page(page_address(page)); flush_kernel_icache_page(page_address(page)); } while (0)
 
 #define flush_icache_range(s,e)		do { flush_kernel_dcache_range_asm(s,e); flush_kernel_icache_range_asm(s,e); } while (0)
diff -puN kernel/fork.c~rmap-22-flush_dcache_mmap_lock kernel/fork.c
--- 25/kernel/fork.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.872854208 -0700
+++ 25-akpm/kernel/fork.c	2004-05-22 14:59:35.805284136 -0700
@@ -332,7 +332,9 @@ static inline int dup_mmap(struct mm_str
       
 			/* insert tmp into the share list, just after mpnt */
 			spin_lock(&file->f_mapping->i_mmap_lock);
+			flush_dcache_mmap_lock(mapping);
 			vma_prio_tree_add(tmp, mpnt);
+			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&file->f_mapping->i_mmap_lock);
 		}
 
diff -puN mm/filemap.c~rmap-22-flush_dcache_mmap_lock mm/filemap.c
--- 25/mm/filemap.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.873854056 -0700
+++ 25-akpm/mm/filemap.c	2004-05-22 14:56:27.884852384 -0700
@@ -65,7 +65,9 @@
  *    ->i_mmap_lock		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_lock		(various places)
+ *    ->i_mmap_lock
+ *      ->page_table_lock	(various places, mainly in mmap.c)
+ *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
  *  ->mmap_sem
  *    ->lock_page		(access_process_vm)
diff -puN mm/fremap.c~rmap-22-flush_dcache_mmap_lock mm/fremap.c
--- 25/mm/fremap.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.874853904 -0700
+++ 25-akpm/mm/fremap.c	2004-05-22 14:56:27.884852384 -0700
@@ -202,11 +202,13 @@ asmlinkage long sys_remap_file_pages(uns
 		    !(vma->vm_flags & VM_NONLINEAR)) {
 			mapping = vma->vm_file->f_mapping;
 			spin_lock(&mapping->i_mmap_lock);
+			flush_dcache_mmap_lock(mapping);
 			vma->vm_flags |= VM_NONLINEAR;
 			vma_prio_tree_remove(vma, &mapping->i_mmap);
 			vma_prio_tree_init(vma);
 			list_add_tail(&vma->shared.vm_set.list,
 					&mapping->i_mmap_nonlinear);
+			flush_dcache_mmap_unlock(mapping);
 			spin_unlock(&mapping->i_mmap_lock);
 		}
 
diff -puN mm/mmap.c~rmap-22-flush_dcache_mmap_lock mm/mmap.c
--- 25/mm/mmap.c~rmap-22-flush_dcache_mmap_lock	2004-05-22 14:56:27.876853600 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:37.407040632 -0700
@@ -25,6 +25,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
+#include <asm/cacheflush.h>
 #include <asm/tlb.h>
 
 /*
@@ -74,10 +75,12 @@ static inline void __remove_shared_vm_st
 	if (vma->vm_flags & VM_SHARED)
 		mapping->i_mmap_writable--;
 
+	flush_dcache_mmap_lock(mapping);
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
 		list_del_init(&vma->shared.vm_set.list);
 	else
 		vma_prio_tree_remove(vma, &mapping->i_mmap);
+	flush_dcache_mmap_unlock(mapping);
 }
 
 /*
@@ -266,11 +269,13 @@ static inline void __vma_link_file(struc
 		if (vma->vm_flags & VM_SHARED)
 			mapping->i_mmap_writable++;
 
+		flush_dcache_mmap_lock(mapping);
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			list_add_tail(&vma->shared.vm_set.list,
 					&mapping->i_mmap_nonlinear);
 		else
 			vma_prio_tree_insert(vma, &mapping->i_mmap);
+		flush_dcache_mmap_unlock(mapping);
 	}
 }
 
@@ -350,14 +355,17 @@ void vma_adjust(struct vm_area_struct *v
 	}
 	spin_lock(&mm->page_table_lock);
 
-	if (root)
+	if (root) {
+		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
+	}
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
 	if (root) {
 		vma_prio_tree_init(vma);
 		vma_prio_tree_insert(vma, root);
+		flush_dcache_mmap_unlock(mapping);
 	}
 
 	if (next) {

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
