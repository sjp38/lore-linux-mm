Message-Id: <200405222210.i4MMACr13872@mail.osdl.org>
Subject: [patch 35/57] rmap 19: arch prio_tree
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:09:34 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

The previous patches of this prio_tree batch have been to generic only.  Now
the arm and parisc __flush_dcache_page are converted to using
vma_prio_tree_next, and benefit from its selection of relevant vmas.  They're
still accessing the tree without i_shared_lock or any other, that's not
forgotten but still under investigation.  Include pagemap.h for the definition
of PAGE_CACHE_SHIFT.  s390 and x86_64 no longer initialize vma's shared field
(whose type has changed), done later.


---

 25-akpm/arch/arm/mm/fault-armv.c        |   59 +++++++++-----------------------
 25-akpm/arch/parisc/kernel/cache.c      |   43 ++++++++---------------
 25-akpm/arch/parisc/kernel/sys_parisc.c |   14 +------
 25-akpm/arch/s390/kernel/compat_exec.c  |    1 
 25-akpm/arch/x86_64/ia32/ia32_binfmt.c  |    1 
 5 files changed, 36 insertions(+), 82 deletions(-)

diff -puN arch/arm/mm/fault-armv.c~rmap-19-arch-prio_tree arch/arm/mm/fault-armv.c
--- 25/arch/arm/mm/fault-armv.c~rmap-19-arch-prio_tree	2004-05-22 14:56:27.127967448 -0700
+++ 25-akpm/arch/arm/mm/fault-armv.c	2004-05-22 14:59:38.311903072 -0700
@@ -14,6 +14,7 @@
 #include <linux/bitops.h>
 #include <linux/vmalloc.h>
 #include <linux/init.h>
+#include <linux/pagemap.h>
 
 #include <asm/cacheflush.h>
 #include <asm/pgtable.h>
@@ -78,7 +79,10 @@ void __flush_dcache_page(struct page *pa
 {
 	struct address_space *mapping = page_mapping(page);
 	struct mm_struct *mm = current->active_mm;
-	struct list_head *l;
+	struct vm_area_struct *mpnt = NULL;
+	struct prio_tree_iter iter;
+	unsigned long offset;
+	pgoff_t pgoff;
 
 	__cpuc_flush_dcache_page(page_address(page));
 
@@ -89,26 +93,16 @@ void __flush_dcache_page(struct page *pa
 	 * With a VIVT cache, we need to also write back
 	 * and invalidate any user data.
 	 */
-	list_for_each(l, &mapping->i_mmap_shared) {
-		struct vm_area_struct *mpnt;
-		unsigned long off;
-
-		mpnt = list_entry(l, struct vm_area_struct, shared);
-
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
+					&iter, pgoff, pgoff)) != NULL) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 */
 		if (mpnt->vm_mm != mm)
 			continue;
-
-		if (page->index < mpnt->vm_pgoff)
-			continue;
-
-		off = page->index - mpnt->vm_pgoff;
-		if (off >= (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT)
-			continue;
-
-		flush_cache_page(mpnt, mpnt->vm_start + (off << PAGE_SHIFT));
+		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
+		flush_cache_page(mpnt, mpnt->vm_start + offset);
 	}
 }
 
@@ -116,9 +110,11 @@ static void
 make_coherent(struct vm_area_struct *vma, unsigned long addr, struct page *page, int dirty)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct list_head *l;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long pgoff;
+	struct vm_area_struct *mpnt = NULL;
+	struct prio_tree_iter iter;
+	unsigned long offset;
+	pgoff_t pgoff;
 	int aliases = 0;
 
 	if (!mapping)
@@ -131,12 +127,8 @@ make_coherent(struct vm_area_struct *vma
 	 * space, then we need to handle them specially to maintain
 	 * cache coherency.
 	 */
-	list_for_each(l, &mapping->i_mmap_shared) {
-		struct vm_area_struct *mpnt;
-		unsigned long off;
-
-		mpnt = list_entry(l, struct vm_area_struct, shared);
-
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
+					&iter, pgoff, pgoff)) != NULL) {
 		/*
 		 * If this VMA is not in our MM, we can ignore it.
 		 * Note that we intentionally mask out the VMA
@@ -144,23 +136,8 @@ make_coherent(struct vm_area_struct *vma
 		 */
 		if (mpnt->vm_mm != mm || mpnt == vma)
 			continue;
-
-		/*
-		 * If the page isn't in this VMA, we can also ignore it.
-		 */
-		if (pgoff < mpnt->vm_pgoff)
-			continue;
-
-		off = pgoff - mpnt->vm_pgoff;
-		if (off >= (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT)
-			continue;
-
-		off = mpnt->vm_start + (off << PAGE_SHIFT);
-
-		/*
-		 * Ok, it is within mpnt.  Fix it up.
-		 */
-		aliases += adjust_pte(mpnt, off);
+		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
+		aliases += adjust_pte(mpnt, mpnt->vm_start + offset);
 	}
 	if (aliases)
 		adjust_pte(vma, addr);
diff -puN arch/parisc/kernel/cache.c~rmap-19-arch-prio_tree arch/parisc/kernel/cache.c
--- 25/arch/parisc/kernel/cache.c~rmap-19-arch-prio_tree	2004-05-22 14:56:27.128967296 -0700
+++ 25-akpm/arch/parisc/kernel/cache.c	2004-05-22 14:59:38.312902920 -0700
@@ -17,6 +17,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
+#include <linux/pagemap.h>
 
 #include <asm/pdc.h>
 #include <asm/cache.h>
@@ -230,30 +231,27 @@ void disable_sr_hashing(void)
 void __flush_dcache_page(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct list_head *l;
+	struct vm_area_struct *mpnt = NULL;
+	struct prio_tree_iter iter;
+	unsigned long offset;
+	unsigned long addr;
+	pgoff_t pgoff;
 
 	flush_kernel_dcache_page(page_address(page));
 
 	if (!mapping)
 		return;
 
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
 	/* We have ensured in arch_get_unmapped_area() that all shared
 	 * mappings are mapped at equivalent addresses, so we only need
 	 * to flush one for them all to become coherent */
-	list_for_each(l, &mapping->i_mmap_shared) {
-		struct vm_area_struct *mpnt;
-		unsigned long off, addr;
-
-		mpnt = list_entry(l, struct vm_area_struct, shared);
-
-		if (page->index < mpnt->vm_pgoff)
-			continue;
-
-		off = page->index - mpnt->vm_pgoff;
-		if (off >= (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT)
-			continue;
 
-		addr = mpnt->vm_start + (off << PAGE_SHIFT);
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap_shared,
+					&iter, pgoff, pgoff)) != NULL) {
+		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
+		addr = mpnt->vm_start + offset;
 
 		/* flush instructions produce non access tlb misses.
 		 * On PA, we nullify these instructions rather than 
@@ -276,20 +274,11 @@ void __flush_dcache_page(struct page *pa
 	 * *any* mappings of a file are always congruently mapped (whether
 	 * declared as MAP_PRIVATE or MAP_SHARED), so we only need
 	 * to flush one address here too */
-	list_for_each(l, &mapping->i_mmap) {
-		struct vm_area_struct *mpnt;
-		unsigned long off, addr;
-
-		mpnt = list_entry(l, struct vm_area_struct, shared);
-
-		if (page->index < mpnt->vm_pgoff)
-			continue;
-
-		off = page->index - mpnt->vm_pgoff;
-		if (off >= (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT)
-			continue;
 
-		addr = mpnt->vm_start + (off << PAGE_SHIFT);
+	while ((mpnt = vma_prio_tree_next(mpnt, &mapping->i_mmap,
+					&iter, pgoff, pgoff)) != NULL) {
+		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
+		addr = mpnt->vm_start + offset;
 
 		/* This is just for speed.  If the page translation isn't
 		 * there there's no point exciting the nadtlb handler into
diff -puN arch/parisc/kernel/sys_parisc.c~rmap-19-arch-prio_tree arch/parisc/kernel/sys_parisc.c
--- 25/arch/parisc/kernel/sys_parisc.c~rmap-19-arch-prio_tree	2004-05-22 14:56:27.130966992 -0700
+++ 25-akpm/arch/parisc/kernel/sys_parisc.c	2004-05-22 14:56:27.138965776 -0700
@@ -68,17 +68,8 @@ static unsigned long get_unshared_area(u
  * existing mapping and use the same offset.  New scheme is to use the
  * address of the kernel data structure as the seed for the offset.
  * We'll see how that works...
- */
-#if 0
-static int get_offset(struct address_space *mapping)
-{
-	struct vm_area_struct *vma = list_entry(mapping->i_mmap_shared.next,
-			struct vm_area_struct, shared);
-	return (vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT)) &
-		(SHMLBA - 1);
-}
-#else
-/* The mapping is cacheline aligned, so there's no information in the bottom
+ *
+ * The mapping is cacheline aligned, so there's no information in the bottom
  * few bits of the address.  We're looking for 10 bits (4MB / 4k), so let's
  * drop the bottom 8 bits and use bits 8-17.  
  */
@@ -87,7 +78,6 @@ static int get_offset(struct address_spa
 	int offset = (unsigned long) mapping << (PAGE_SHIFT - 8);
 	return offset & 0x3FF000;
 }
-#endif
 
 static unsigned long get_shared_area(struct address_space *mapping,
 		unsigned long addr, unsigned long len, unsigned long pgoff)
diff -puN arch/s390/kernel/compat_exec.c~rmap-19-arch-prio_tree arch/s390/kernel/compat_exec.c
--- 25/arch/s390/kernel/compat_exec.c~rmap-19-arch-prio_tree	2004-05-22 14:56:27.131966840 -0700
+++ 25-akpm/arch/s390/kernel/compat_exec.c	2004-05-22 14:59:36.586165424 -0700
@@ -70,7 +70,6 @@ int setup_arg_pages32(struct linux_binpr
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
 		mpol_set_vma_default(mpnt);
-		INIT_LIST_HEAD(&mpnt->shared);
 		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
 		mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
diff -puN arch/x86_64/ia32/ia32_binfmt.c~rmap-19-arch-prio_tree arch/x86_64/ia32/ia32_binfmt.c
--- 25/arch/x86_64/ia32/ia32_binfmt.c~rmap-19-arch-prio_tree	2004-05-22 14:56:27.133966536 -0700
+++ 25-akpm/arch/x86_64/ia32/ia32_binfmt.c	2004-05-22 14:59:36.587165272 -0700
@@ -367,7 +367,6 @@ int setup_arg_pages(struct linux_binprm 
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
 		mpol_set_vma_default(mpnt);
-		INIT_LIST_HEAD(&mpnt->shared);
 		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
 		mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
