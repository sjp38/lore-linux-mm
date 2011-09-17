Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D91589000C4
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:42 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p8H3dd7s026405
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:39 -0700
Received: from iabz21 (iabz21.prod.google.com [10.12.102.21])
	by hpaq1.eem.corp.google.com with ESMTP id p8H3daCk011278
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:37 -0700
Received: by iabz21 with SMTP id z21so4505427iab.37
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:36 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/8] page_referenced: replace vm_flags parameter with struct pr_info
Date: Fri, 16 Sep 2011 20:39:06 -0700
Message-Id: <1316230753-8693-2-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

Introduce struct pr_info, passed into page_referenced() family of functions,
to represent information about the pte references that have been found for
that page. Currently contains the vm_flags information as well as
a PR_REFERENCED flag. The idea is to make it easy to extend the API
with new flags.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/ksm.h  |    9 ++---
 include/linux/rmap.h |   28 ++++++++++-----
 mm/ksm.c             |   15 +++-----
 mm/rmap.c            |   92 +++++++++++++++++++++++---------------------------
 mm/vmscan.c          |   18 +++++----
 5 files changed, 81 insertions(+), 81 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 3319a69..432c49b 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -83,8 +83,8 @@ static inline int ksm_might_need_to_copy(struct page *page,
 		 page->index != linear_page_index(vma, address));
 }
 
-int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+void page_referenced_ksm(struct page *page,
+			struct mem_cgroup *memcg, struct pr_info *info);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -119,10 +119,9 @@ static inline int ksm_might_need_to_copy(struct page *page,
 	return 0;
 }
 
-static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+static inline void page_referenced_ksm(struct page *page,
+			struct mem_cgroup *memcg, struct pr_info *info)
 {
-	return 0;
 }
 
 static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 2148b12..7c99c6f 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -67,6 +67,15 @@ struct anon_vma_chain {
 	struct list_head same_anon_vma;	/* locked by anon_vma->mutex */
 };
 
+/*
+ * Information to be filled by page_referenced() and friends.
+ */
+struct pr_info {
+	unsigned long vm_flags;
+	unsigned int pr_flags;
+#define PR_REFERENCED  1
+};
+
 #ifdef CONFIG_MMU
 static inline void get_anon_vma(struct anon_vma *anon_vma)
 {
@@ -156,10 +165,11 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
-int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+void page_referenced(struct page *, int is_locked,
+		     struct mem_cgroup *cnt, struct pr_info *info);
+void page_referenced_one(struct page *, struct vm_area_struct *,
+			 unsigned long address, unsigned int *mapcount,
+			 struct pr_info *info);
 
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
@@ -234,12 +244,12 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-static inline int page_referenced(struct page *page, int is_locked,
-				  struct mem_cgroup *cnt,
-				  unsigned long *vm_flags)
+static inline void page_referenced(struct page *page, int is_locked,
+				   struct mem_cgroup *cnt,
+				   struct pr_info *info)
 {
-	*vm_flags = 0;
-	return 0;
+	info->vm_flags = 0;
+	info->pr_flags = 0;
 }
 
 #define try_to_unmap(page, refs) SWAP_FAIL
diff --git a/mm/ksm.c b/mm/ksm.c
index 9a68b0c..5f540a4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1587,14 +1587,13 @@ struct page *ksm_does_need_to_copy(struct page *page,
 	return new_page;
 }
 
-int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+void page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
+			struct pr_info *info)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
 	unsigned int mapcount = page_mapcount(page);
-	int referenced = 0;
 	int search_new_forks = 0;
 
 	VM_BUG_ON(!PageKsm(page));
@@ -1602,7 +1601,7 @@ int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
 
 	stable_node = page_stable_node(page);
 	if (!stable_node)
-		return 0;
+		return;
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
@@ -1627,19 +1626,17 @@ again:
 			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 				continue;
 
-			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+			page_referenced_one(page, vma, rmap_item->address,
+					    &mapcount, info);
 			if (!search_new_forks || !mapcount)
 				break;
 		}
 		anon_vma_unlock(anon_vma);
 		if (!mapcount)
-			goto out;
+			return;
 	}
 	if (!search_new_forks++)
 		goto again;
-out:
-	return referenced;
 }
 
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
diff --git a/mm/rmap.c b/mm/rmap.c
index 23295f6..6ff8ecf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -648,12 +648,12 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
-int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+void page_referenced_one(struct page *page, struct vm_area_struct *vma,
+			 unsigned long address, unsigned int *mapcount,
+			 struct pr_info *info)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int referenced = 0;
+	bool referenced = false;
 
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
@@ -667,19 +667,19 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 					     PAGE_CHECK_ADDRESS_PMD_FLAG);
 		if (!pmd) {
 			spin_unlock(&mm->page_table_lock);
-			goto out;
+			return;
 		}
 
 		if (vma->vm_flags & VM_LOCKED) {
 			spin_unlock(&mm->page_table_lock);
 			*mapcount = 0;	/* break early from loop */
-			*vm_flags |= VM_LOCKED;
-			goto out;
+			info->vm_flags |= VM_LOCKED;
+			return;
 		}
 
 		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced++;
+			referenced = true;
 		spin_unlock(&mm->page_table_lock);
 	} else {
 		pte_t *pte;
@@ -691,13 +691,13 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		 */
 		pte = page_check_address(page, mm, address, &ptl, 0);
 		if (!pte)
-			goto out;
+			return;
 
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
 			*mapcount = 0;	/* break early from loop */
-			*vm_flags |= VM_LOCKED;
-			goto out;
+			info->vm_flags |= VM_LOCKED;
+			return;
 		}
 
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
@@ -709,7 +709,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			 * set PG_referenced or activated the page.
 			 */
 			if (likely(!VM_SequentialReadHint(vma)))
-				referenced++;
+				referenced = true;
 		}
 		pte_unmap_unlock(pte, ptl);
 	}
@@ -718,28 +718,27 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	   swap token and is in the middle of a page fault. */
 	if (mm != current->mm && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
-		referenced++;
+		referenced = true;
 
 	(*mapcount)--;
 
-	if (referenced)
-		*vm_flags |= vma->vm_flags;
-out:
-	return referenced;
+	if (referenced) {
+		info->vm_flags |= vma->vm_flags;
+		info->pr_flags |= PR_REFERENCED;
+	}
 }
 
-static int page_referenced_anon(struct page *page,
-				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+static void page_referenced_anon(struct page *page,
+				 struct mem_cgroup *mem_cont,
+				 struct pr_info *info)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
-	int referenced = 0;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
-		return referenced;
+		return;
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
@@ -754,21 +753,20 @@ static int page_referenced_anon(struct page *page,
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+		page_referenced_one(page, vma, address, &mapcount, info);
 		if (!mapcount)
 			break;
 	}
 
 	page_unlock_anon_vma(anon_vma);
-	return referenced;
 }
 
 /**
  * page_referenced_file - referenced check for object-based rmap
  * @page: the page we're checking references on.
  * @mem_cont: target memory controller
- * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @info: collect encountered vma->vm_flags who actually referenced the page
+ *        as well as flags describing the page references encountered.
  *
  * For an object-based mapped page, find all the places it is mapped and
  * check/clear the referenced flag.  This is done by following the page->mapping
@@ -777,16 +775,15 @@ static int page_referenced_anon(struct page *page,
  *
  * This function is only called from page_referenced for object-based pages.
  */
-static int page_referenced_file(struct page *page,
-				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+static void page_referenced_file(struct page *page,
+				 struct mem_cgroup *mem_cont,
+				 struct pr_info *info)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
-	int referenced = 0;
 
 	/*
 	 * The caller's checks on page->mapping and !PageAnon have made
@@ -822,14 +819,12 @@ static int page_referenced_file(struct page *page,
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+		page_referenced_one(page, vma, address, &mapcount, info);
 		if (!mapcount)
 			break;
 	}
 
 	mutex_unlock(&mapping->i_mmap_mutex);
-	return referenced;
 }
 
 /**
@@ -837,45 +832,42 @@ static int page_referenced_file(struct page *page,
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
- * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @info: collect encountered vma->vm_flags who actually referenced the page
+ *        as well as flags describing the page references encountered.
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page,
-		    int is_locked,
-		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+void page_referenced(struct page *page,
+		     int is_locked,
+		     struct mem_cgroup *mem_cont,
+		     struct pr_info *info)
 {
-	int referenced = 0;
 	int we_locked = 0;
 
-	*vm_flags = 0;
+	info->vm_flags = 0;
+	info->pr_flags = 0;
+
 	if (page_mapped(page) && page_rmapping(page)) {
 		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
 			if (!we_locked) {
-				referenced++;
+				info->pr_flags |= PR_REFERENCED;
 				goto out;
 			}
 		}
 		if (unlikely(PageKsm(page)))
-			referenced += page_referenced_ksm(page, mem_cont,
-								vm_flags);
+			page_referenced_ksm(page, mem_cont, info);
 		else if (PageAnon(page))
-			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+			page_referenced_anon(page, mem_cont, info);
 		else if (page->mapping)
-			referenced += page_referenced_file(page, mem_cont,
-								vm_flags);
+			page_referenced_file(page, mem_cont, info);
 		if (we_locked)
 			unlock_page(page);
 	}
 out:
 	if (page_test_and_clear_young(page_to_pfn(page)))
-		referenced++;
-
-	return referenced;
+		info->pr_flags |= PR_REFERENCED;
 }
 
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d036e59..7bd9868 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -647,10 +647,10 @@ enum page_references {
 static enum page_references page_check_references(struct page *page,
 						  struct scan_control *sc)
 {
-	int referenced_ptes, referenced_page;
-	unsigned long vm_flags;
+	int referenced_page;
+	struct pr_info info;
 
-	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	page_referenced(page, 1, sc->mem_cgroup, &info);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -661,10 +661,10 @@ static enum page_references page_check_references(struct page *page,
 	 * Mlock lost the isolation race with us.  Let try_to_unmap()
 	 * move the page to the unevictable list.
 	 */
-	if (vm_flags & VM_LOCKED)
+	if (info.vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
-	if (referenced_ptes) {
+	if (info.pr_flags & PR_REFERENCED) {
 		if (PageAnon(page))
 			return PAGEREF_ACTIVATE;
 		/*
@@ -1535,7 +1535,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
-	unsigned long vm_flags;
+	struct pr_info info;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
@@ -1582,7 +1582,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		page_referenced(page, 0, sc->mem_cgroup, &info);
+		if (info.pr_flags & PR_REFERENCED) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
@@ -1593,7 +1594,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			 * IO, plus JVM can create lots of anon VM_EXEC pages,
 			 * so we ignore them here.
 			 */
-			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
+			if ((info.vm_flags & VM_EXEC) &&
+			    page_is_file_cache(page)) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
