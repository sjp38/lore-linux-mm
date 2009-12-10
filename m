Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D25906B006A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:32:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7W5fd012155
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:32:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ADF545DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AF3A45DE4E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 459941DB803C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1FB41DB803E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  4/8] Replace page_referenced() with wipe_page_reference()
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210163123.255C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:32:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

page_referenced() imply "test the page was referenced or not", but
shrink_active_list() use it for drop pte young bit. then, it should be
renamed.

Plus, vm_flags argument is really ugly. instead, introduce new
struct page_reference_context, it's for collect some statistics.

This patch doesn't have any behavior change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/ksm.h  |   11 +++--
 include/linux/rmap.h |   16 +++++--
 mm/ksm.c             |   17 +++++---
 mm/rmap.c            |  112 ++++++++++++++++++++++++-------------------------
 mm/vmscan.c          |   46 ++++++++++++--------
 5 files changed, 112 insertions(+), 90 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index bed5f16..e1a60d3 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -85,8 +85,8 @@ static inline struct page *ksm_might_need_to_copy(struct page *page,
 	return ksm_does_need_to_copy(page, vma, address);
 }
 
-int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+int wipe_page_reference_ksm(struct page *page, struct mem_cgroup *memcg,
+			    struct page_reference_context *refctx);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -120,10 +120,11 @@ static inline struct page *ksm_might_need_to_copy(struct page *page,
 	return page;
 }
 
-static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+static inline int wipe_page_reference_ksm(struct page *page,
+					  struct mem_cgroup *memcg,
+					  struct page_reference_context *refctx)
 {
-	return 0;
+	return SWAP_SUCCESS;
 }
 
 static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b019ae6..564d981 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -108,13 +108,21 @@ static inline void page_dup_rmap(struct page *page)
 	atomic_inc(&page->_mapcount);
 }
 
+struct page_reference_context {
+	int is_page_locked;
+	unsigned long referenced;
+	unsigned long exec_referenced;
+	int maybe_mlocked;	/* found VM_LOCKED, but it's unstable result */
+};
+
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
-int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+int wipe_page_reference(struct page *page, struct mem_cgroup *memcg,
+		    struct page_reference_context *refctx);
+int wipe_page_reference_one(struct page *page,
+			    struct page_reference_context *refctx,
+			    struct vm_area_struct *vma, unsigned long address);
 
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
diff --git a/mm/ksm.c b/mm/ksm.c
index 56a0da1..19559ae 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1544,15 +1544,15 @@ struct page *ksm_does_need_to_copy(struct page *page,
 	return new_page;
 }
 
-int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+int wipe_page_reference_ksm(struct page *page, struct mem_cgroup *memcg,
+			    struct page_reference_context *refctx)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
 	unsigned int mapcount = page_mapcount(page);
-	int referenced = 0;
 	int search_new_forks = 0;
+	int ret = SWAP_SUCCESS;
 
 	VM_BUG_ON(!PageKsm(page));
 	VM_BUG_ON(!PageLocked(page));
@@ -1582,10 +1582,15 @@ again:
 			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 				continue;
 
-			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+			ret = wipe_page_reference_one(page, refctx, vma,
+						      rmap_item->address);
+			if (ret != SWAP_SUCCESS)
+				goto out;
+			mapcount--;
 			if (!search_new_forks || !mapcount)
 				break;
+			if (refctx->maybe_mlocked)
+				goto out;
 		}
 		spin_unlock(&anon_vma->lock);
 		if (!mapcount)
@@ -1594,7 +1599,7 @@ again:
 	if (!search_new_forks++)
 		goto again;
 out:
-	return referenced;
+	return ret;
 }
 
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
diff --git a/mm/rmap.c b/mm/rmap.c
index fb0983a..2f4451b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -371,17 +371,16 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 }
 
 /*
- * Subfunctions of page_referenced: page_referenced_one called
- * repeatedly from either page_referenced_anon or page_referenced_file.
+ * Subfunctions of wipe_page_reference: wipe_page_reference_one called
+ * repeatedly from either wipe_page_reference_anon or wipe_page_reference_file.
  */
-int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+int wipe_page_reference_one(struct page *page,
+			    struct page_reference_context *refctx,
+			    struct vm_area_struct *vma, unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int referenced = 0;
 
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
@@ -389,8 +388,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	 * unevictable list.
 	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount = 0;	/* break early from loop */
-		*vm_flags |= VM_LOCKED;
+		refctx->maybe_mlocked = 1;
 		goto out;
 	}
 
@@ -406,37 +404,38 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		 * mapping is already gone, the unmap path will have
 		 * set PG_referenced or activated the page.
 		 */
-		if (likely(!VM_SequentialReadHint(vma)))
-			referenced++;
+		if (likely(!VM_SequentialReadHint(vma))) {
+			refctx->referenced++;
+			if (vma->vm_flags & VM_EXEC) {
+				refctx->exec_referenced++;
+			}
+		}
 	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
 	if (mm != current->mm && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
-		referenced++;
+		refctx->referenced++;
 
-	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 
-	if (referenced)
-		*vm_flags |= vma->vm_flags;
 out:
-	return referenced;
+	return SWAP_SUCCESS;
 }
 
-static int page_referenced_anon(struct page *page,
-				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+static int wipe_page_reference_anon(struct page *page,
+				    struct mem_cgroup *memcg,
+				    struct page_reference_context *refctx)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
-	int referenced = 0;
+	int ret = SWAP_SUCCESS;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
-		return referenced;
+		return ret;
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
@@ -448,20 +447,22 @@ static int page_referenced_anon(struct page *page,
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
+		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
+		ret = wipe_page_reference_one(page, refctx, vma, address);
+		if (ret != SWAP_SUCCESS)
+			break;
+		mapcount--;
+		if (!mapcount || refctx->maybe_mlocked)
 			break;
 	}
 
 	page_unlock_anon_vma(anon_vma);
-	return referenced;
+	return ret;
 }
 
 /**
- * page_referenced_file - referenced check for object-based rmap
+ * wipe_page_reference_file - wipe page reference for object-based rmap
  * @page: the page we're checking references on.
  * @mem_cont: target memory controller
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
@@ -471,18 +472,18 @@ static int page_referenced_anon(struct page *page,
  * pointer, then walking the chain of vmas it holds.  It returns the number
  * of references it found.
  *
- * This function is only called from page_referenced for object-based pages.
+ * This function is only called from wipe_page_reference for object-based pages.
  */
-static int page_referenced_file(struct page *page,
-				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+static int wipe_page_reference_file(struct page *page,
+				    struct mem_cgroup *memcg,
+				    struct page_reference_context *refctx)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
-	int referenced = 0;
+	int ret = SWAP_SUCCESS;
 
 	/*
 	 * The caller's checks on page->mapping and !PageAnon have made
@@ -516,65 +517,62 @@ static int page_referenced_file(struct page *page,
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
+		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
+		ret = wipe_page_reference_one(page, refctx, vma, address);
+		if (ret != SWAP_SUCCESS)
+			break;
+		mapcount--;
+		if (!mapcount || refctx->maybe_mlocked)
 			break;
 	}
 
 	spin_unlock(&mapping->i_mmap_lock);
-	return referenced;
+	return ret;
 }
 
 /**
- * page_referenced - test if the page was referenced
+ * wipe_page_reference - clear and test the page reference and pte young bit
  * @page: the page to test
- * @is_locked: caller holds lock on the page
- * @mem_cont: target memory controller
- * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @memcg: target memory controller
+ * @refctx: context for collect some statistics
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page,
-		    int is_locked,
-		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+int wipe_page_reference(struct page *page,
+			struct mem_cgroup *memcg,
+			struct page_reference_context *refctx)
 {
-	int referenced = 0;
 	int we_locked = 0;
+	int ret = SWAP_SUCCESS;
 
 	if (TestClearPageReferenced(page))
-		referenced++;
+		refctx->referenced++;
 
-	*vm_flags = 0;
 	if (page_mapped(page) && page_rmapping(page)) {
-		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
+		if (!refctx->is_page_locked &&
+		    (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
 			if (!we_locked) {
-				referenced++;
+				refctx->referenced++;
 				goto out;
 			}
 		}
 		if (unlikely(PageKsm(page)))
-			referenced += page_referenced_ksm(page, mem_cont,
-								vm_flags);
+			ret = wipe_page_reference_ksm(page, memcg, refctx);
 		else if (PageAnon(page))
-			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+			ret = wipe_page_reference_anon(page, memcg, refctx);
 		else if (page->mapping)
-			referenced += page_referenced_file(page, mem_cont,
-								vm_flags);
+			ret = wipe_page_reference_file(page, memcg, refctx);
 		if (we_locked)
 			unlock_page(page);
 	}
 out:
 	if (page_test_and_clear_young(page))
-		referenced++;
+		refctx->referenced++;
 
-	return referenced;
+	return ret;
 }
 
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3366bec..c59baa9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -569,7 +569,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
-	unsigned long vm_flags;
 
 	cond_resched();
 
@@ -578,7 +577,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		int referenced;
+		struct page_reference_context refctx = {
+			.is_page_locked = 1,
+		};
 
 		cond_resched();
 
@@ -620,16 +621,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
+		wipe_page_reference(page, sc->mem_cgroup, &refctx);
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
 		 * try_to_unmap moves it to unevictable list
 		 */
 		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapped(page)
-					&& !(vm_flags & VM_LOCKED))
+		    page_mapped(page) && refctx.referenced &&
+		    !refctx.maybe_mlocked)
 			goto activate_locked;
 
 		/*
@@ -664,7 +664,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
+			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
+			    refctx.referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -1241,9 +1242,10 @@ static inline void note_zone_scanning_priority(struct zone *zone, int priority)
  *
  * If the pages are mostly unmapped, the processing is fast and it is
  * appropriate to hold zone->lru_lock across the whole operation.  But if
- * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balance
- * this, so instead we remove the pages from the LRU while processing them.
+ * the pages are mapped, the processing is slow (because wipe_page_reference()
+ * walk each ptes) so we should drop zone->lru_lock around each page.  It's
+ * impossible to balance this, so instead we remove the pages from the LRU
+ * while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
  *
@@ -1289,7 +1291,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
-	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
@@ -1320,6 +1321,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
+		struct page_reference_context refctx = {
+			.is_page_locked = 0,
+		};
+
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
@@ -1329,10 +1334,17 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		/* page_referenced clears PageReferenced */
-		if (page_mapped(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (!page_mapped(page)) {
+			ClearPageActive(page);	/* we are de-activating */
+			list_add(&page->lru, &l_inactive);
+			continue;
+		}
+
+		wipe_page_reference(page, sc->mem_cgroup, &refctx);
+
+		if (refctx.referenced)
 			nr_rotated++;
+		if (refctx.exec_referenced && page_is_file_cache(page)) {
 			/*
 			 * Identify referenced, file-backed active pages and
 			 * give them one more trip around the active list. So
@@ -1342,10 +1354,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			 * IO, plus JVM can create lots of anon VM_EXEC pages,
 			 * so we ignore them here.
 			 */
-			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
+			list_add(&page->lru, &l_active);
+			continue;
 		}
 
 		ClearPageActive(page);	/* we are de-activating */
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
