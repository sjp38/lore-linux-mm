From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/3] vmscan: report vm_flags in page_referenced()
Date: Mon, 08 Jun 2009 17:10:45 +0800
Message-ID: <20090608091201.783981551@intel.com>
References: <20090608091044.880249722@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 26B126B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 04:06:28 -0400 (EDT)
Content-Disposition: inline; filename=mm-vmscan-report-vm_flags-in-page_referenced.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

Collect vma->vm_flags of the VMAs that actually referenced the page.

This is preparing for more informed reclaim heuristics,
eg. to protect executable file pages more aggressively.
For now only the VM_EXEC bit will be used by the caller.

Thanks to Johannes, Peter and Minchan for all the good tips.

Acked-by: Peter Zijlstra <peterz@infradead.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
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
@@ -121,7 +122,7 @@ int page_wrprotect(struct page *page, in
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
+ * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
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
+ * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
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
@@ -584,6 +584,7 @@ static unsigned long shrink_page_list(st
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long vm_flags;
 
 	cond_resched();
 
@@ -634,7 +635,8 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1, sc->mem_cgroup);
+		referenced = page_referenced(page, 1,
+						sc->mem_cgroup, &vm_flags);
 		/* In active use or really unfreeable?  Activate it. */
 		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
 					referenced && page_mapping_inuse(page))
@@ -1215,6 +1217,7 @@ static void shrink_active_list(unsigned 
 {
 	unsigned long pgmoved;
 	unsigned long pgscanned;
+	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_inactive);
 	struct page *page;
@@ -1255,7 +1258,7 @@ static void shrink_active_list(unsigned 
 
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
