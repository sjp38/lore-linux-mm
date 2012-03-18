Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 564126B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 15:07:48 -0400 (EDT)
Date: Sun, 18 Mar 2012 19:07:45 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [rfc][patches] fix for munmap/truncate races
Message-ID: <20120318190744.GA6589@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

	Background: truncate() ends up going through the shared mappings
of file being truncated (under ->i_mmap_mutex, to protect them from
getting removed while we do that) and calling unmap_vmas() on them,
with range passed to unmap_vmas() sitting entirely within the vma
being passed to it.  The trouble is, unmap_vmas() expects a chain of
vmas.  It will look into the next vma, see that it's beyond the range
we'd been given and do nothing to it.  Fine, except that there's nothing
to protect that next vma from being removed just as we do that - we do
*not* hold ->i_mmap and ->i_mmap_mutex held on our file won't do anything
to mappings that have nothing to do with the file in question.

	There's an obvious way to deal with that - introducing a variant
of unmap_vmas() that would handle a single vma and switch these callers
of unmap_vmas() to using it.  It requires some preparations; below is
the combined diff, for those who prefer to review the splitup, it is in
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git #vm

 include/linux/mm.h |    4 +-
 mm/memory.c        |  133 +++++++++++++++++++++++++++++++---------------------
 mm/mmap.c          |    5 +-
 3 files changed, 84 insertions(+), 58 deletions(-)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..b5bb54d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -893,9 +893,9 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather *tlb,
+void unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..8ab0918 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1282,10 +1282,10 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
-static unsigned long unmap_page_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				struct zap_details *details)
+static void unmap_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end,
+			     struct zap_details *details)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -1305,8 +1305,47 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
 	mem_cgroup_uncharge_end();
+}
 
-	return addr;
+
+static void unmap_single_vma(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long start_addr,
+		unsigned long end_addr, unsigned long *nr_accounted,
+		struct zap_details *details)
+{
+	unsigned long start = max(vma->vm_start, start_addr);
+	unsigned long end;
+
+	if (start >= vma->vm_end)
+		return;
+	end = min(vma->vm_end, end_addr);
+	if (end <= vma->vm_start)
+		return;
+
+	if (vma->vm_flags & VM_ACCOUNT)
+		*nr_accounted += (end - start) >> PAGE_SHIFT;
+
+	if (unlikely(is_pfn_mapping(vma)))
+		untrack_pfn_vma(vma, 0, 0);
+
+	if (start != end) {
+		if (unlikely(is_vm_hugetlb_page(vma))) {
+			/*
+			 * It is undesirable to test vma->vm_file as it
+			 * should be non-null for valid hugetlb area.
+			 * However, vm_file will be NULL in the error
+			 * cleanup path of do_mmap_pgoff. When
+			 * hugetlbfs ->mmap method fails,
+			 * do_mmap_pgoff() nullifies vma->vm_file
+			 * before calling this function to clean up.
+			 * Since no pte has actually been setup, it is
+			 * safe to do nothing in this case.
+			 */
+			if (vma->vm_file)
+				unmap_hugepage_range(vma, start, end, NULL);
+		} else
+			unmap_page_range(tlb, vma, start, end, details);
+	}
 }
 
 /**
@@ -1318,8 +1357,6 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
  * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
  * @details: details of nonlinear truncation or shared cache invalidation
  *
- * Returns the end address of the unmapping (restart addr if interrupted).
- *
  * Unmap all pages in the vma list.
  *
  * Only addresses between `start' and `end' will be unmapped.
@@ -1331,55 +1368,18 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather *tlb,
+void unmap_vmas(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
 {
-	unsigned long start = start_addr;
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
-		unsigned long end;
-
-		start = max(vma->vm_start, start_addr);
-		if (start >= vma->vm_end)
-			continue;
-		end = min(vma->vm_end, end_addr);
-		if (end <= vma->vm_start)
-			continue;
-
-		if (vma->vm_flags & VM_ACCOUNT)
-			*nr_accounted += (end - start) >> PAGE_SHIFT;
-
-		if (unlikely(is_pfn_mapping(vma)))
-			untrack_pfn_vma(vma, 0, 0);
-
-		while (start != end) {
-			if (unlikely(is_vm_hugetlb_page(vma))) {
-				/*
-				 * It is undesirable to test vma->vm_file as it
-				 * should be non-null for valid hugetlb area.
-				 * However, vm_file will be NULL in the error
-				 * cleanup path of do_mmap_pgoff. When
-				 * hugetlbfs ->mmap method fails,
-				 * do_mmap_pgoff() nullifies vma->vm_file
-				 * before calling this function to clean up.
-				 * Since no pte has actually been setup, it is
-				 * safe to do nothing in this case.
-				 */
-				if (vma->vm_file)
-					unmap_hugepage_range(vma, start, end, NULL);
-
-				start = end;
-			} else
-				start = unmap_page_range(tlb, vma, start, end, details);
-		}
-	}
-
+	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
+		unmap_single_vma(tlb, vma, start_addr, end_addr, nr_accounted,
+				 details);
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
-	return start;	/* which is now the end (or restart) address */
 }
 
 /**
@@ -1388,8 +1388,34 @@ unsigned long unmap_vmas(struct mmu_gather *tlb,
  * @address: starting address of pages to zap
  * @size: number of bytes to zap
  * @details: details of nonlinear truncation or shared cache invalidation
+ *
+ * Caller must protect the VMA list
+ */
+void zap_page_range(struct vm_area_struct *vma, unsigned long address,
+		unsigned long size, struct zap_details *details)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+	unsigned long end = address + size;
+	unsigned long nr_accounted = 0;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, 0);
+	update_hiwater_rss(mm);
+	unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	tlb_finish_mmu(&tlb, address, end);
+}
+
+/**
+ * zap_page_range_single - remove user pages in a given range
+ * @vma: vm_area_struct holding the applicable pages
+ * @address: starting address of pages to zap
+ * @size: number of bytes to zap
+ * @details: details of nonlinear truncation or shared cache invalidation
+ *
+ * The range must fit into one VMA.
  */
-unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
+static void zap_page_range_single(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -1400,9 +1426,10 @@ unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	mmu_notifier_invalidate_range_start(mm, address, end);
+	unmap_single_vma(&tlb, vma, address, end, &nr_accounted, details);
+	mmu_notifier_invalidate_range_end(mm, address, end);
 	tlb_finish_mmu(&tlb, address, end);
-	return end;
 }
 
 /**
@@ -1423,7 +1450,7 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 	if (address < vma->vm_start || address + size > vma->vm_end ||
 	    		!(vma->vm_flags & VM_PFNMAP))
 		return -1;
-	zap_page_range(vma, address, size, NULL);
+	zap_page_range_single(vma, address, size, NULL);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
@@ -2770,7 +2797,7 @@ static void unmap_mapping_range_vma(struct vm_area_struct *vma,
 		unsigned long start_addr, unsigned long end_addr,
 		struct zap_details *details)
 {
-	zap_page_range(vma, start_addr, end_addr - start_addr, details);
+	zap_page_range_single(vma, start_addr, end_addr - start_addr, details);
 }
 
 static inline void unmap_mapping_range_tree(struct prio_tree_root *root,
diff --git a/mm/mmap.c b/mm/mmap.c
index da15a79..9365a8f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2224,7 +2224,6 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
-	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
@@ -2249,11 +2248,11 @@ void exit_mmap(struct mm_struct *mm)
 	tlb_gather_mmu(&tlb, mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
-	tlb_finish_mmu(&tlb, 0, end);
+	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
