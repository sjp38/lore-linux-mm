Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BB8D76007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:43:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48hqqY007103
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:43:52 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E17B45DE82
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:43:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CE6E45DE7C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:43:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0BA1DB8044
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:43:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2199B1DB803E
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:43:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/7] Replace page_referenced() with wipe_page_reference()
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174253.589D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:43:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom d9110c2804a4b88e460edada140b8bb0f7eb3a18 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 4 Dec 2009 11:45:18 +0900
Subject: [PATCH 4/7] Replace page_referenced() with wipe_page_reference()

page_referenced() imply "test the page was referenced or not", but
shrink_active_list() use it for drop pte young bit. then, it should be
renamed.

Plus, vm_flags argument is really ugly. instead, introduce new
struct page_reference_context, it's for collect some statistics.

This patch doesn't have any behavior change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/ksm.h  |   11 +++--
 include/linux/rmap.h |   16 +++++--
 mm/ksm.c             |   17 +++++---
 mm/rmap.c            |  112 ++++++++++++++++++++++++----------------------=
---
 mm/vmscan.c          |   46 ++++++++++++--------
 5 files changed, 112 insertions(+), 90 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index bed5f16..e1a60d3 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -85,8 +85,8 @@ static inline struct page *ksm_might_need_to_copy(struct =
page *page,
 	return ksm_does_need_to_copy(page, vma, address);
 }
=20
-int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+int wipe_page_reference_ksm(struct page *page, struct mem_cgroup *memcg,
+			    struct page_reference_context *refctx);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -120,10 +120,11 @@ static inline struct page *ksm_might_need_to_copy(str=
uct page *page,
 	return page;
 }
=20
-static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+static inline int wipe_page_reference_ksm(struct page *page,
+					  struct mem_cgroup *memcg,
+					  struct page_reference_context *refctx)
 {
-	return 0;
+	return SWAP_SUCCESS;
 }
=20
 static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags=
)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b019ae6..564d981 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -108,13 +108,21 @@ static inline void page_dup_rmap(struct page *page)
 	atomic_inc(&page->_mapcount);
 }
=20
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
=20
 enum ttu_flags {
 	TTU_UNMAP =3D 0,			/* unmap mode */
diff --git a/mm/ksm.c b/mm/ksm.c
index c1647a2..3c121c8 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1544,15 +1544,15 @@ struct page *ksm_does_need_to_copy(struct page *pag=
e,
 	return new_page;
 }
=20
-int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+int wipe_page_reference_ksm(struct page *page, struct mem_cgroup *memcg,
+			    struct page_reference_context *refctx)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
 	unsigned int mapcount =3D page_mapcount(page);
-	int referenced =3D 0;
 	int search_new_forks =3D 0;
+	int ret =3D SWAP_SUCCESS;
=20
 	VM_BUG_ON(!PageKsm(page));
 	VM_BUG_ON(!PageLocked(page));
@@ -1582,10 +1582,15 @@ again:
 			if ((rmap_item->mm =3D=3D vma->vm_mm) =3D=3D search_new_forks)
 				continue;
=20
-			referenced +=3D page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+			ret =3D wipe_page_reference_one(page, refctx, vma,
+						      rmap_item->address);
+			if (ret !=3D SWAP_SUCCESS)
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
=20
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
diff --git a/mm/rmap.c b/mm/rmap.c
index fb0983a..2f4451b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -371,17 +371,16 @@ int page_mapped_in_vma(struct page *page, struct vm_a=
rea_struct *vma)
 }
=20
 /*
- * Subfunctions of page_referenced: page_referenced_one called
- * repeatedly from either page_referenced_anon or page_referenced_file.
+ * Subfunctions of wipe_page_reference: wipe_page_reference_one called
+ * repeatedly from either wipe_page_reference_anon or wipe_page_reference_=
file.
  */
-int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+int wipe_page_reference_one(struct page *page,
+			    struct page_reference_context *refctx,
+			    struct vm_area_struct *vma, unsigned long address)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int referenced =3D 0;
=20
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
@@ -389,8 +388,7 @@ int page_referenced_one(struct page *page, struct vm_ar=
ea_struct *vma,
 	 * unevictable list.
 	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount =3D 0;	/* break early from loop */
-		*vm_flags |=3D VM_LOCKED;
+		refctx->maybe_mlocked =3D 1;
 		goto out;
 	}
=20
@@ -406,37 +404,38 @@ int page_referenced_one(struct page *page, struct vm_=
area_struct *vma,
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
=20
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
 	if (mm !=3D current->mm && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
-		referenced++;
+		refctx->referenced++;
=20
-	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
=20
-	if (referenced)
-		*vm_flags |=3D vma->vm_flags;
 out:
-	return referenced;
+	return SWAP_SUCCESS;
 }
=20
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
-	int referenced =3D 0;
+	int ret =3D SWAP_SUCCESS;
=20
 	anon_vma =3D page_lock_anon_vma(page);
 	if (!anon_vma)
-		return referenced;
+		return ret;
=20
 	mapcount =3D page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
@@ -448,20 +447,22 @@ static int page_referenced_anon(struct page *page,
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
+		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
-		referenced +=3D page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
+		ret =3D wipe_page_reference_one(page, refctx, vma, address);
+		if (ret !=3D SWAP_SUCCESS)
+			break;
+		mapcount--;
+		if (!mapcount || refctx->maybe_mlocked)
 			break;
 	}
=20
 	page_unlock_anon_vma(anon_vma);
-	return referenced;
+	return ret;
 }
=20
 /**
- * page_referenced_file - referenced check for object-based rmap
+ * wipe_page_reference_file - wipe page reference for object-based rmap
  * @page: the page we're checking references on.
  * @mem_cont: target memory controller
  * @vm_flags: collect encountered vma->vm_flags who actually referenced th=
e page
@@ -471,18 +472,18 @@ static int page_referenced_anon(struct page *page,
  * pointer, then walking the chain of vmas it holds.  It returns the numbe=
r
  * of references it found.
  *
- * This function is only called from page_referenced for object-based page=
s.
+ * This function is only called from wipe_page_reference for object-based =
pages.
  */
-static int page_referenced_file(struct page *page,
-				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+static int wipe_page_reference_file(struct page *page,
+				    struct mem_cgroup *memcg,
+				    struct page_reference_context *refctx)
 {
 	unsigned int mapcount;
 	struct address_space *mapping =3D page->mapping;
 	pgoff_t pgoff =3D page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
-	int referenced =3D 0;
+	int ret =3D SWAP_SUCCESS;
=20
 	/*
 	 * The caller's checks on page->mapping and !PageAnon have made
@@ -516,65 +517,62 @@ static int page_referenced_file(struct page *page,
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
+		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
-		referenced +=3D page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
+		ret =3D wipe_page_reference_one(page, refctx, vma, address);
+		if (ret !=3D SWAP_SUCCESS)
+			break;
+		mapcount--;
+		if (!mapcount || refctx->maybe_mlocked)
 			break;
 	}
=20
 	spin_unlock(&mapping->i_mmap_lock);
-	return referenced;
+	return ret;
 }
=20
 /**
- * page_referenced - test if the page was referenced
+ * wipe_page_reference - clear and test the page reference and pte young b=
it
  * @page: the page to test
- * @is_locked: caller holds lock on the page
- * @mem_cont: target memory controller
- * @vm_flags: collect encountered vma->vm_flags who actually referenced th=
e page
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
-	int referenced =3D 0;
 	int we_locked =3D 0;
+	int ret =3D SWAP_SUCCESS;
=20
 	if (TestClearPageReferenced(page))
-		referenced++;
+		refctx->referenced++;
=20
-	*vm_flags =3D 0;
 	if (page_mapped(page) && page_rmapping(page)) {
-		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
+		if (!refctx->is_page_locked &&
+		    (!PageAnon(page) || PageKsm(page))) {
 			we_locked =3D trylock_page(page);
 			if (!we_locked) {
-				referenced++;
+				refctx->referenced++;
 				goto out;
 			}
 		}
 		if (unlikely(PageKsm(page)))
-			referenced +=3D page_referenced_ksm(page, mem_cont,
-								vm_flags);
+			ret =3D wipe_page_reference_ksm(page, memcg, refctx);
 		else if (PageAnon(page))
-			referenced +=3D page_referenced_anon(page, mem_cont,
-								vm_flags);
+			ret =3D wipe_page_reference_anon(page, memcg, refctx);
 		else if (page->mapping)
-			referenced +=3D page_referenced_file(page, mem_cont,
-								vm_flags);
+			ret =3D wipe_page_reference_file(page, memcg, refctx);
 		if (we_locked)
 			unlock_page(page);
 	}
 out:
 	if (page_test_and_clear_young(page))
-		referenced++;
+		refctx->referenced++;
=20
-	return referenced;
+	return ret;
 }
=20
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4ba08da..0db9c06 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -569,7 +569,6 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 	struct pagevec freed_pvec;
 	int pgactivate =3D 0;
 	unsigned long nr_reclaimed =3D 0;
-	unsigned long vm_flags;
=20
 	cond_resched();
=20
@@ -578,7 +577,9 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		int referenced;
+		struct page_reference_context refctx =3D {
+			.is_page_locked =3D 1,
+		};
=20
 		cond_resched();
=20
@@ -620,16 +621,15 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
 				goto keep_locked;
 		}
=20
-		referenced =3D page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
+		wipe_page_reference(page, sc->mem_cgroup, &refctx);
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
 		 * try_to_unmap moves it to unevictable list
 		 */
 		if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapped(page)
-					&& !(vm_flags & VM_LOCKED))
+		    page_mapped(page) && refctx.referenced &&
+		    !refctx.maybe_mlocked)
 			goto activate_locked;
=20
 		/*
@@ -664,7 +664,8 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 		}
=20
 		if (PageDirty(page)) {
-			if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER && referenced)
+			if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER &&
+			    refctx.referenced)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -1243,9 +1244,10 @@ static inline void note_zone_scanning_priority(struc=
t zone *zone, int priority)
  *
  * If the pages are mostly unmapped, the processing is fast and it is
  * appropriate to hold zone->lru_lock across the whole operation.  But if
- * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop zone->lru_lock around each page.  It's impossible to balanc=
e
- * this, so instead we remove the pages from the LRU while processing them.
+ * the pages are mapped, the processing is slow (because wipe_page_referen=
ce()
+ * walk each ptes) so we should drop zone->lru_lock around each page.  It'=
s
+ * impossible to balance this, so instead we remove the pages from the LRU
+ * while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here becau=
se
  * nobody will play with that bit on a non-LRU page.
  *
@@ -1291,7 +1293,6 @@ static void shrink_active_list(unsigned long nr_pages=
, struct zone *zone,
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
-	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
@@ -1325,6 +1326,10 @@ static void shrink_active_list(unsigned long nr_page=
s, struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
=20
 	while (!list_empty(&l_hold)) {
+		struct page_reference_context refctx =3D {
+			.is_page_locked =3D 0,
+		};
+
 		cond_resched();
 		page =3D lru_to_page(&l_hold);
 		list_del(&page->lru);
@@ -1334,10 +1339,17 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,
 			continue;
 		}
=20
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
@@ -1347,10 +1359,8 @@ static void shrink_active_list(unsigned long nr_page=
s, struct zone *zone,
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
=20
 		ClearPageActive(page);	/* we are de-activating */
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
