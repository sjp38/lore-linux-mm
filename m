From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080507193926.5765.78883.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie>
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/3] Guarantee that COW faults for a process that called mmap(MAP_PRIVATE) on hugetlbfs will succeed
Date: Wed,  7 May 2008 20:39:26 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

After patch 2 in this series, a process that successfully calls mmap()
for a MAP_PRIVATE mapping will be guaranteed to successfully fault until a
process calls fork().  At that point, the next write fault from the parent
could fail due to COW if the child still has a reference.

We only reserve pages for the parent but a copy must be made to avoid leaking
data from the parent to the child after fork(). Reserves could be taken for
both parent and child at fork time to guarantee faults but if the mapping
is large it is highly likely we will not have sufficient pages for the
reservation, and it is common to fork only to exec() immediatly after. A
failure here would be very undesirable.

Note that the current behaviour of mainline with MAP_PRIVATE pages is
pretty bad.  The following situation is allowed to occur today.

1. Process calls mmap(MAP_PRIVATE)
2. Process calls mlock() to fault all pages and makes sure it succeeds
3. Process forks()
4. Process writes to MAP_PRIVATE mapping while child still exists
5. If the COW fails at this point, the process gets SIGKILLed even though it
   had taken care to ensure the pages existed

This patch improves the situation by guaranteeing the reliability of the
process that successfully calls mmap(). When the parent performs COW, it
will try to satisfy the allocation without using reserves. If that fails the
parent will steal the page leaving any children without a page. Faults from
the child after that point will result in failure. If the child COW happens
first, an attempt will be made to allocate the page without reserves and
the child will get SIGKILLed on failure.

To summarise the new behaviour:

1. If the original mapper performs COW on a private mapping with multiple
   references, it will attempt to allocate a hugepage from the pool or
   the buddy allocator without using the existing reserves. On fail, VMAs
   mapping the same area are traversed and the page being COW'd is unmapped
   where found. It will then steal the original page as the last mapper in
   the normal way.

2. The VMAs the pages were unmapped from are flagged to note that pages
   with data no longer exist. Future no-page faults on those VMAs will
   terminate the process as otherwise it would appear that data was corrupted.
   A warning is printed to the console that this situation occured.

2. If the child performs COW first, it will attempt to satisfy the COW
   from the pool if there are enough pages or via the buddy allocator if
   overcommit is allowed and the buddy allocator can satisfy the request. If
   it fails, the child will be killed.

If the pool is large enough, existing applications will not notice that the
reserves were a factor. Existing applications depending on the no-reserves
been set are unlikely to exist as for much of the history of hugetlbfs,
pages were prefaulted at mmap(), allocating the pages at that point or failing
the mmap().

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 fs/hugetlbfs/inode.c    |    2 
 include/linux/hugetlb.h |    6 +
 mm/hugetlb.c            |  167 +++++++++++++++++++++++++++++++++++++++----
 mm/memory.c             |    2 
 4 files changed, 159 insertions(+), 18 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020-map_private_reserve/fs/hugetlbfs/inode.c linux-2.6.25-mm1-0030-reliable_parent_faults/fs/hugetlbfs/inode.c
--- linux-2.6.25-mm1-0020-map_private_reserve/fs/hugetlbfs/inode.c	2008-05-07 18:29:27.000000000 +0100
+++ linux-2.6.25-mm1-0030-reliable_parent_faults/fs/hugetlbfs/inode.c	2008-05-07 18:31:44.000000000 +0100
@@ -441,7 +441,7 @@ hugetlb_vmtruncate_list(struct prio_tree
 			v_offset = 0;
 
 		__unmap_hugepage_range(vma,
-				vma->vm_start + v_offset, vma->vm_end);
+				vma->vm_start + v_offset, vma->vm_end, NULL);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020-map_private_reserve/include/linux/hugetlb.h linux-2.6.25-mm1-0030-reliable_parent_faults/include/linux/hugetlb.h
--- linux-2.6.25-mm1-0020-map_private_reserve/include/linux/hugetlb.h	2008-05-07 18:29:27.000000000 +0100
+++ linux-2.6.25-mm1-0030-reliable_parent_faults/include/linux/hugetlb.h	2008-05-07 18:35:37.000000000 +0100
@@ -23,8 +23,10 @@ int hugetlb_overcommit_handler(struct ct
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
-void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
-void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
+void unmap_hugepage_range(struct vm_area_struct *,
+			unsigned long, unsigned long, struct page *);
+void __unmap_hugepage_range(struct vm_area_struct *,
+			unsigned long, unsigned long, struct page *);
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020-map_private_reserve/mm/hugetlb.c linux-2.6.25-mm1-0030-reliable_parent_faults/mm/hugetlb.c
--- linux-2.6.25-mm1-0020-map_private_reserve/mm/hugetlb.c	2008-05-07 18:39:34.000000000 +0100
+++ linux-2.6.25-mm1-0030-reliable_parent_faults/mm/hugetlb.c	2008-05-07 20:05:18.000000000 +0100
@@ -40,6 +40,9 @@ static int hugetlb_next_nid;
  */
 static DEFINE_SPINLOCK(hugetlb_lock);
 
+#define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
+#define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
+#define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
 /*
  * These three helpers are used to track how many pages are reserved for
  * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
@@ -49,20 +52,23 @@ static unsigned long vma_resv_huge_pages
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
 	if (!(vma->vm_flags & VM_SHARED))
-		return (unsigned long)vma->vm_private_data;
+		return (unsigned long)vma->vm_private_data & ~HPAGE_RESV_MASK;
 	return 0;
 }
 
 static void adjust_vma_resv_huge_pages(struct vm_area_struct *vma, int delta)
 {
 	unsigned long reserve;
+	unsigned long flags;
 	VM_BUG_ON(vma->vm_flags & VM_SHARED);
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
 
 	reserve = (unsigned long)vma->vm_private_data + delta;
-	vma->vm_private_data = (void *)reserve;
+	flags = (unsigned long)vma->vm_private_data & HPAGE_RESV_MASK;
+	vma->vm_private_data = (void *)(reserve | flags);
 }
 
+/* Reset counters to 0 and clear all HPAGE_RESV_* flags */
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
@@ -73,10 +79,27 @@ void reset_vma_resv_huge_pages(struct vm
 static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
 							unsigned long reserve)
 {
+	unsigned long flags;
+
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
 	VM_BUG_ON(vma->vm_flags & VM_SHARED);
 
-	vma->vm_private_data = (void *)reserve;
+	flags = (unsigned long)vma->vm_private_data & HPAGE_RESV_MASK;
+	vma->vm_private_data = (void *)(reserve | flags);
+}
+
+static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
+{
+	unsigned long reserveflags = (unsigned long)vma->vm_private_data;
+	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	reserveflags |= flags;
+	vma->vm_private_data = (void *)reserveflags;
+}
+
+static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
+{
+	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	return ((unsigned long)vma->vm_private_data & flag) != 0;
 }
 
 static void clear_huge_page(struct page *page, unsigned long addr)
@@ -139,7 +162,7 @@ static void decrement_hugepage_resv_vma(
 		 * Only the process that called mmap() has reserves for
 		 * private mappings.
 		 */
-		if (vma_resv_huge_pages(vma)) {
+		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 			resv_huge_pages--;
 			adjust_vma_resv_huge_pages(vma, -1);
 		}
@@ -147,7 +170,7 @@ static void decrement_hugepage_resv_vma(
 }
 
 static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
-				unsigned long address)
+				unsigned long address, int avoid_reserve)
 {
 	int nid;
 	struct page *page = NULL;
@@ -168,6 +191,10 @@ static struct page *dequeue_huge_page_vm
 			free_huge_pages - resv_huge_pages == 0)
 		return NULL;
 
+	/* If reserves cannot be used, ensure enough pages are in the pool */
+	if (avoid_reserve && free_huge_pages - resv_huge_pages == 0)
+		return NULL;
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
@@ -178,7 +205,9 @@ static struct page *dequeue_huge_page_vm
 			list_del(&page->lru);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
-			decrement_hugepage_resv_vma(vma);
+
+			if (!avoid_reserve)
+				decrement_hugepage_resv_vma(vma);
 
 			break;
 		}
@@ -529,7 +558,7 @@ static void return_unused_surplus_pages(
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr)
+				    unsigned long addr, int avoid_reserve)
 {
 	struct page *page;
 	struct address_space *mapping = vma->vm_file->f_mapping;
@@ -542,14 +571,14 @@ static struct page *alloc_huge_page(stru
 	 * the quota can be made before satisfying the allocation
 	 */
 	if (!(vma->vm_flags & VM_SHARED) &&
-				!vma_resv_huge_pages(vma)) {
+				!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
 		chg = 1;
 		if (hugetlb_get_quota(inode->i_mapping, chg))
 			return ERR_PTR(-ENOSPC);
 	}
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(vma, addr);
+	page = dequeue_huge_page_vma(vma, addr, avoid_reserve);
 	spin_unlock(&hugetlb_lock);
 
 	if (!page) {
@@ -906,7 +935,7 @@ nomem:
 }
 
 void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
-			    unsigned long end)
+			    unsigned long end, struct page *ref_page)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -934,6 +963,27 @@ void __unmap_hugepage_range(struct vm_ar
 		if (huge_pmd_unshare(mm, &address, ptep))
 			continue;
 
+		/*
+		 * If a reference page is supplied, it is because a specific
+		 * page is being unmapped, not a range. Ensure the page we
+		 * are about to unmap is the actual page of interest.
+		 */
+		if (ref_page) {
+			pte = huge_ptep_get(ptep);
+			if (huge_pte_none(pte))
+				continue;
+			page = pte_page(pte);
+			if (page != ref_page)
+				continue;
+
+			/*
+			 * Mark the VMA as having unmapped its page so that
+			 * future faults in this VMA will fail rather than
+			 * looking like data was lost
+			 */
+			set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
+		}
+
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		if (huge_pte_none(pte))
 			continue;
@@ -952,7 +1002,7 @@ void __unmap_hugepage_range(struct vm_ar
 }
 
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
-			  unsigned long end)
+			  unsigned long end, struct page *ref_page)
 {
 	/*
 	 * It is undesirable to test vma->vm_file as it should be non-null
@@ -964,19 +1014,65 @@ void unmap_hugepage_range(struct vm_area
 	 */
 	if (vma->vm_file) {
 		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
-		__unmap_hugepage_range(vma, start, end);
+		__unmap_hugepage_range(vma, start, end, ref_page);
 		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 	}
 }
 
+/*
+ * This is called when a parent is failing to COW a MAP_PRIVATE mapping
+ * it owns the reserve page for. The intention is to unmap the page from
+ * other VMAs and let the children be SIGKILLed if they are faulting the
+ * same region.
+ */
+int unmap_ref_private(struct mm_struct *mm,
+					struct vm_area_struct *vma,
+					struct page *page,
+					unsigned long address)
+{
+	struct vm_area_struct *iter_vma;
+	struct address_space *mapping;
+	pgoff_t pgoff = ((address - vma->vm_start) >> HPAGE_SHIFT)
+		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+	struct prio_tree_iter iter;
+
+	if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+		return 0;
+
+	mapping = (struct address_space *)page_private(page);
+	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		BUG_ON(vma->vm_start != iter_vma->vm_start);
+
+		/* Do not unmap the current VMA */
+		if (iter_vma == vma)
+			continue;
+
+		/*
+		 * Unmap the page from other VMAs and then mark them so they
+		 * get SIGKILLed if they fault in these areas. This is because
+		 * a future no-page fault on this VMA could insert a zeroed
+		 * page instead of the data existing from the time of fork.
+		 * This would look like data corruption so we take much more
+		 * obvious steps instead.
+		 */
+		unmap_hugepage_range(iter_vma,
+				address, address + HPAGE_SIZE,
+				page);
+	}
+
+	return 1;
+}
+
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pte_t pte)
 {
 	struct page *old_page, *new_page;
 	int avoidcopy;
+	int outside_reserve = 0;
 
 	old_page = pte_page(pte);
 
+retry_avoidcopy:
 	/* If no-one else is actually using this page, avoid the copy
 	 * and just make the page writable */
 	avoidcopy = (page_count(old_page) == 1);
@@ -985,11 +1081,41 @@ static int hugetlb_cow(struct mm_struct 
 		return 0;
 	}
 
+	/*
+	 * If the process that created a MAP_PRIVATE mapping is about to
+	 * perform a COW due to a shared page count, attempt to satisfy
+	 * the allocation without using the existing reserves. If reserves
+	 * were used, a partial faulted mapping at the time of fork() could
+	 * consume its reserves on COW instead of the full address range.
+	 */
+	if (!(vma->vm_flags & VM_SHARED) &&
+				is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+		outside_reserve = 1;
+
 	page_cache_get(old_page);
-	new_page = alloc_huge_page(vma, address);
+	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
 		page_cache_release(old_page);
+
+		/*
+		 * If a process owning a MAP_PRIVATE mapping fails to COW,
+		 * it is due to multiple references from the child and not
+		 * enough pages in the pool that are not already reserved. To
+		 * guarantee the parents reliability, unmap the page from
+		 * the other process. The child may get SIGKILLed later as
+		 * a result if it faults.
+		 */
+		if (outside_reserve) {
+			BUG_ON(huge_pte_none(pte));
+			if (unmap_ref_private(mm, vma, old_page, address)) {
+				BUG_ON(page_count(old_page) != 1);
+				BUG_ON(huge_pte_none(pte));
+				goto retry_avoidcopy;
+			}
+			WARN_ON_ONCE(1);
+		}
+
 		return -PTR_ERR(new_page);
 	}
 
@@ -1022,6 +1148,18 @@ static int hugetlb_no_page(struct mm_str
 	struct address_space *mapping;
 	pte_t new_pte;
 
+	/*
+	 * Currently, we are forced to kill the process in the event the
+	 * parent has unmapped pages from the child due to a failed COW.
+	 * Warn that such a situation has occured as it may not be obvious
+	 */
+	if (is_vma_resv_set(vma, HPAGE_RESV_UNMAPPED)) {
+		printk(KERN_WARNING
+			"PID %d killed due to inadequate hugepage pool\n",
+			current->pid);
+		return ret;
+	}
+
 	mapping = vma->vm_file->f_mapping;
 	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
 		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
@@ -1036,7 +1174,7 @@ retry:
 		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 		if (idx >= size)
 			goto out;
-		page = alloc_huge_page(vma, address);
+		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
 			ret = -PTR_ERR(page);
 			goto out;
@@ -1368,6 +1506,7 @@ int hugetlb_reserve_pages(struct inode *
 	else {
 		chg = to - from;
 		set_vma_resv_huge_pages(vma, chg);
+		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
 	}
 
 	if (chg < 0)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0020-map_private_reserve/mm/memory.c linux-2.6.25-mm1-0030-reliable_parent_faults/mm/memory.c
--- linux-2.6.25-mm1-0020-map_private_reserve/mm/memory.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0030-reliable_parent_faults/mm/memory.c	2008-05-07 18:31:44.000000000 +0100
@@ -882,7 +882,7 @@ unsigned long unmap_vmas(struct mmu_gath
 			}
 
 			if (unlikely(is_vm_hugetlb_page(vma))) {
-				unmap_hugepage_range(vma, start, end);
+				unmap_hugepage_range(vma, start, end, NULL);
 				zap_work -= (end - start) /
 						(HPAGE_SIZE / PAGE_SIZE);
 				start = end;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
