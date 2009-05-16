From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/3] vmscan: report vm_flags in page_referenced()
Date: Sat, 16 May 2009 17:00:06 +0800
Message-ID: <20090516090448.249602749@intel.com>
References: <20090516090005.916779788@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D58906B006A
	for <linux-mm@kvack.org>; Sat, 16 May 2009 05:07:06 -0400 (EDT)
Content-Disposition: inline; filename=mm-vmscan-report-vm_flags-in-page_referenced.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-Id: linux-mm.kvack.org

Collect vma->vm_flags of the VMAs that actually referenced the page.

This is preparing for more informed reclaim heuristics,
eg. to protect executable file pages more aggressively.
For now only the VM_EXEC bit will be used by the caller.

CC: Minchan Kim <minchan.kim@gmail.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/rmap.h |    5 +++--
 mm/rmap.c            |   37 ++++++++++++++++++++++++++-----------
 mm/vmscan.c          |    7 +++++--
 3 files changed, 34 insertions(+), 15 deletions(-)

--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -83,7 +83,8 @@ static inline void page_dup_rmap(struct 
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
+int page_referenced(struct page *, int is_locked,
+			struct mem_cgroup *cnt, unsigned long *vm_flags);
 int try_to_unmap(struct page *, int ignore_refs);
 
 /*
@@ -128,7 +129,7 @@ int page_wrprotect(struct page *page, in
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-#define page_referenced(page,l,cnt) TestClearPageReferenced(page)
+#define page_referenced(page, locked, cnt, flags) TestClearPageReferenced(page)
 #define try_to_unmap(page, refs) SWAP_FAIL
 
 static inline int page_mkclean(struct page *page)
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -333,7 +333,9 @@ static int page_mapped_in_vma(struct pag
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
 static int page_referenced_one(struct page *page,
-	struct vm_area_struct *vma, unsigned int *mapcount)
+			       struct vm_area_struct *vma,
+			       unsigned int *mapcount,
+			       unsigned long *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -381,11 +383,14 @@ out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
+	if (referenced)
+		*vm_flags |= vma->vm_flags;
 	return referenced;
 }
 
 static int page_referenced_anon(struct page *page,
-				struct mem_cgroup *mem_cont)
+				struct mem_cgroup *mem_cont,
+				unsigned long *vm_flags)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -405,7 +410,8 @@ static int page_referenced_anon(struct p
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma, &mapcount);
+		referenced += page_referenced_one(page, vma,
+						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
 	}
@@ -418,6 +424,7 @@ static int page_referenced_anon(struct p
  * page_referenced_file - referenced check for object-based rmap
  * @page: the page we're checking references on.
  * @mem_cont: target memory controller
+ * @vm_flags: collect encountered vma->vm_flags
  *
  * For an object-based mapped page, find all the places it is mapped and
  * check/clear the referenced flag.  This is done by following the page->mapping
@@ -427,7 +434,8 @@ static int page_referenced_anon(struct p
  * This function is only called from page_referenced for object-based pages.
  */
 static int page_referenced_file(struct page *page,
-				struct mem_cgroup *mem_cont)
+				struct mem_cgroup *mem_cont,
+				unsigned long *vm_flags)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -467,7 +475,8 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma, &mapcount);
+		referenced += page_referenced_one(page, vma,
+						  &mapcount, vm_flags);
 		if (!mapcount)
 			break;
 	}
@@ -481,29 +490,35 @@ static int page_referenced_file(struct p
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
+ * @vm_flags: collect encountered vma->vm_flags
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page, int is_locked,
-			struct mem_cgroup *mem_cont)
+int page_referenced(struct page *page,
+		    int is_locked,
+		    struct mem_cgroup *mem_cont,
+		    unsigned long *vm_flags)
 {
 	int referenced = 0;
 
 	if (TestClearPageReferenced(page))
 		referenced++;
 
+	*vm_flags = 0;
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
-			referenced += page_referenced_anon(page, mem_cont);
+			referenced += page_referenced_anon(page, mem_cont,
+								vm_flags);
 		else if (is_locked)
-			referenced += page_referenced_file(page, mem_cont);
+			referenced += page_referenced_file(page, mem_cont,
+								vm_flags);
 		else if (!trylock_page(page))
 			referenced++;
 		else {
 			if (page->mapping)
-				referenced +=
-					page_referenced_file(page, mem_cont);
+				referenced += page_referenced_file(page,
+							mem_cont, vm_flags);
 			unlock_page(page);
 		}
 	}
--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -598,6 +598,7 @@ static unsigned long shrink_page_list(st
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long vm_flags;
 
 	cond_resched();
 
@@ -648,7 +649,8 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1, sc->mem_cgroup);
+		referenced = page_referenced(page, 1,
+						sc->mem_cgroup, &vm_flags);
 		/* In active use or really unfreeable?  Activate it. */
 		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
 					referenced && page_mapping_inuse(page))
@@ -1229,6 +1231,7 @@ static void shrink_active_list(unsigned 
 {
 	unsigned long pgmoved;
 	unsigned long pgscanned;
+	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);
 	struct page *page;
@@ -1269,7 +1272,7 @@ static void shrink_active_list(unsigned 
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup))
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
 			pgmoved++;
 
 		list_add(&page->lru, &l_inactive);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
