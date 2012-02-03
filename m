Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1CA136B13F1
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 12:28:30 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH] mm: Change of refcounting method for compound page.
Date: Fri,  3 Feb 2012 18:28:13 +0100
Message-Id: <1328290093-19294-2-git-send-email-mail@smogura.eu>
In-Reply-To: <1328290093-19294-1-git-send-email-mail@smogura.eu>
References: <1328290093-19294-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Yongqiang Yang <xiaoqiangnk@gmail.com>

Compound pages are now refcounted in way allowing tracking of tail pages
and automatically free of compound page when all references (counter)
fell to zero. This in addition make get_page and get_page_unless_zero
similar in work, as well put_page and put_page_unless_zero. In addition
it  makes procedures more friendly. One thing that should be taken, by
developer, on account is to take care when page is putted or geted when
compound lock is obtained, to avoid deadlocks. Locking is used to
prevent concurrent compound split and only when page refcount goes from
0 to 1 or vice versa.

Technically implementation uses 3rd element of compound page to store
"tails usage counter". This counter is decremented when tail pages count
goes to zero, and bumped when tail page is getted from zero usage
(recovered) a?? this is to keep backward compatible usage of tail pages.
If "tails usage counter" fell to zero head counter is decremented, if
"tails usage counter" is increased to one the head count is increased,
too. For compound pages without 3rd element (order of 1, two pages) 2nd
page count is used in similar way as for higher order pages.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/mm.h       |   94 ++++++++++++-----
 include/linux/mm_types.h |   24 ++++-
 include/linux/pagemap.h  |    1 -
 mm/huge_memory.c         |   25 +----
 mm/internal.h            |   46 ---------
 mm/memory.c              |    2 +-
 mm/page_alloc.c          |    2 +
 mm/swap.c                |  254 +++++++++++++++++++++++++++++-----------------
 8 files changed, 256 insertions(+), 192 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..cda2d59 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -267,14 +267,28 @@ struct inode;
  * Also, many kernel routines increase the page count before a critical
  * routine so they can be sure the page doesn't go away from under them.
  */
+extern int put_compound_head(struct page *head);
+extern int put_compound_tail(struct page *page);
 
-/*
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+/**
  * Drop a ref, return true if the refcount fell to zero (the page has no users)
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
-	return atomic_dec_and_test(&page->_count);
+	if (unlikely(PageCompound(page))) {
+		if (likely(PageTail(page)))
+			return put_compound_tail(page);
+		else
+			return put_compound_head(page);
+	} else {
+		return atomic_dec_and_test(&page->_count);
+	}
 }
 
 /*
@@ -350,13 +364,6 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
-static inline struct page *compound_head(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return page->first_page;
-	return page;
-}
-
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
@@ -374,33 +381,35 @@ static inline int page_mapcount(struct page *page)
 
 static inline int page_count(struct page *page)
 {
-	return atomic_read(&compound_head(page)->_count);
+	return atomic_read(&page->_count);
 }
 
-static inline void get_huge_page_tail(struct page *page)
+extern void __recover_compound(struct page *page);
+
+static inline void get_page(struct page *page)
 {
-	/*
-	 * __split_huge_page_refcount() cannot run
-	 * from under us.
+	/* Disallow of getting any page (event tail) if it refcount felt
+	 * to zero
 	 */
-	VM_BUG_ON(page_mapcount(page) < 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
+	if (likely(!PageCompound(page) || PageHead(page))) {
+		VM_BUG_ON(atomic_read(&page->_count) <= 0);
+		atomic_inc(&page->_count);
+	} else {
+		/* PageCompound(page) && !PageHead(page) == tail */
+		if (!get_page_unless_zero(page))
+			__recover_compound(page);
+	}
 }
 
-extern bool __get_page_tail(struct page *page);
-
-static inline void get_page(struct page *page)
+static inline void get_huge_page_tail(struct page *page)
 {
-	if (unlikely(PageTail(page)))
-		if (likely(__get_page_tail(page)))
-			return;
 	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count.
+	 * __split_huge_page_refcount() cannot run
+	 * from under us. Hoply current do not have compound_lock.
 	 */
-	VM_BUG_ON(atomic_read(&page->_count) <= 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(page_mapcount(page) < 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	get_page(page);
 }
 
 static inline struct page *virt_to_head_page(const void *x)
@@ -495,7 +504,34 @@ static inline void set_compound_order(struct page *page, unsigned long order)
 {
 	page[1].lru.prev = (void *)order;
 }
-
+/** Returns number of used elements (number of head and tail pages in compound
+ * page that have usege count <<{@code _count}>> greatet then {@code 0}.<br/>
+ * This method is valid for head, tail and "single" pages. For single pages
+ * just page usege count is returned.
+ * <p>
+ * <b>Warning!</b> This operation is not atomic and do not involves any page
+ * or compound page locks. In certain cases page may be cuncurrently splitted,
+ * so returned number may be invalid, or may be read from freed page.
+ * </p>
+ */
+static inline int compound_elements(struct page *page)
+{
+	if (likely(PageCompound(page))) {
+		struct page *head = compound_head(page);
+		if (likely(compound_order(head) > 1)) {
+			return atomic_add_return(0, &head[3]._tail_count);
+		} else {
+			/* This bug informs about under us operations. It is not
+			 * desired situation in any way :)
+			 */
+			VM_BUG_ON(compound_order(head) == 0);
+			return !!atomic_add_return(0, &head[0]._count) +
+				!!atomic_add_return(0, &head[1]._count);
+		}
+	} else {
+		return page_count(page);
+	}
+}
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..af64b60 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -93,9 +93,26 @@ struct page {
 
 	/* Third double word block */
 	union {
-		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
-					 */
+		/** Pageout list, eg. active_list protected by
+		 * {@code zone->lru_lock} !
+		 */
+		struct list_head lru;
+
+		/** On 3rd page of compund page (if page has order greater then
+		 * {@code 1}) contains additional data.
+		 */
+		struct {
+			/** Number of pages in compound page (including head and
+			 * tails) that are used (have {@code _count > 0}).
+			 * If this number fell to zero, then compound page may
+			 * be freed by kernel.
+			 */
+			atomic_t _tail_count;
+
+			/** Reserved spece. */
+			void *resrved;
+		};
+
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT
@@ -149,6 +166,7 @@ struct page {
 	 */
 	void *shadow;
 #endif
+	char *lastLockedBy;
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cfaaa69..8ee9d13 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -159,7 +159,6 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON(PageTail(page));
 
 	return 1;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b3ffc21..d2582199 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1019,7 +1019,7 @@ struct page *follow_trans_huge_pmd(struct mm_struct *mm,
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
 	VM_BUG_ON(!PageCompound(page));
 	if (flags & FOLL_GET)
-		get_page_foll(page);
+		get_page(page);
 
 out:
 	return page;
@@ -1050,7 +1050,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			spin_unlock(&tlb->mm->page_table_lock);
 			tlb_remove_page(tlb, page);
 			pte_free(tlb->mm, pgtable);
-			ret = 1;
 		}
 	} else
 		spin_unlock(&tlb->mm->page_table_lock);
@@ -1229,7 +1228,6 @@ static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
 	struct zone *zone = page_zone(page);
-	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1242,25 +1240,13 @@ static void __split_huge_page_refcount(struct page *page)
 
 		/* tail_page->_mapcount cannot change */
 		BUG_ON(page_mapcount(page_tail) < 0);
-		tail_count += page_mapcount(page_tail);
 		/* check for overflow */
-		BUG_ON(tail_count < 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
+
 		/*
-		 * tail_page->_count is zero and not changing from
-		 * under us. But get_page_unless_zero() may be running
-		 * from under us on the tail_page. If we used
-		 * atomic_set() below instead of atomic_add(), we
-		 * would then run atomic_set() concurrently with
-		 * get_page_unless_zero(), and atomic_set() is
-		 * implemented in C not using locked ops. spin_unlock
-		 * on x86 sometime uses locked ops because of PPro
-		 * errata 66, 92, so unless somebody can guarantee
-		 * atomic_set() here would be safe on all archs (and
-		 * not only on x86), it's safer to use atomic_add().
+		 * tail_page->_count represents actuall number of tail pages
 		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
+		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();
@@ -1310,7 +1296,6 @@ static void __split_huge_page_refcount(struct page *page)
 
 		lru_add_page_tail(zone, page, page_tail);
 	}
-	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
@@ -1318,6 +1303,8 @@ static void __split_huge_page_refcount(struct page *page)
 
 	ClearPageCompound(page);
 	compound_unlock(page);
+	/* Remove additional reference used in compound. */
+	put_page(page);
 	spin_unlock_irq(&zone->lru_lock);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..d071d38 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -37,52 +37,6 @@ static inline void __put_page(struct page *page)
 	atomic_dec(&page->_count);
 }
 
-static inline void __get_page_tail_foll(struct page *page,
-					bool get_page_head)
-{
-	/*
-	 * If we're getting a tail page, the elevated page->_count is
-	 * required only in the head page and we will elevate the head
-	 * page->_count and tail page->_mapcount.
-	 *
-	 * We elevate page_tail->_mapcount for tail pages to force
-	 * page_tail->_count to be zero at all times to avoid getting
-	 * false positives from get_page_unless_zero() with
-	 * speculative page access (like in
-	 * page_cache_get_speculative()) on tail pages.
-	 */
-	VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	VM_BUG_ON(page_mapcount(page) < 0);
-	if (get_page_head)
-		atomic_inc(&page->first_page->_count);
-	atomic_inc(&page->_mapcount);
-}
-
-/*
- * This is meant to be called as the FOLL_GET operation of
- * follow_page() and it must be called while holding the proper PT
- * lock while the pte (or pmd_trans_huge) is still mapping the page.
- */
-static inline void get_page_foll(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		/*
-		 * This is safe only because
-		 * __split_huge_page_refcount() can't run under
-		 * get_page_foll() because we hold the proper PT lock.
-		 */
-		__get_page_tail_foll(page, true);
-	else {
-		/*
-		 * Getting a normal page or the head of a compound page
-		 * requires to already have an elevated page->_count.
-		 */
-		VM_BUG_ON(atomic_read(&page->_count) <= 0);
-		atomic_inc(&page->_count);
-	}
-}
-
 extern unsigned long highest_memmap_pfn;
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..a0ab73c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1522,7 +1522,7 @@ split_fallthrough:
 	}
 
 	if (flags & FOLL_GET)
-		get_page_foll(page);
+		get_page(page);
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2186ec..a3ae13e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -354,6 +354,8 @@ void prep_compound_page(struct page *page, unsigned long order)
 		set_page_count(p, 0);
 		p->first_page = page;
 	}
+	if (order > 1)
+		atomic_set(&page[3]._tail_count, 0);
 }
 
 /* update __split_huge_page_refcount if you change this function */
diff --git a/mm/swap.c b/mm/swap.c
index b0f529b..f2fb9c56 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 
+
 #include "internal.h"
 
 /* How many pages do we try to swap or page in/out together? */
@@ -64,123 +65,190 @@ static void __put_single_page(struct page *page)
 	free_hot_cold_page(page, 0);
 }
 
-static void __put_compound_page(struct page *page)
+static void __free_compound_page(struct page *head)
 {
 	compound_page_dtor *dtor;
+	VM_BUG_ON(PageTail(head));
+	VM_BUG_ON(!PageCompound(head));
 
-	__page_cache_release(page);
-	dtor = get_compound_page_dtor(page);
-	(*dtor)(page);
+#if CONFIG_DEBUG_VM
+	/* Debug test if all tails are zero ref - we do not have lock,
+	 * but we shuld not have refcount, so no one should split us!
+	 */
+	do {
+		unsigned long toCheck = 1 << compound_order(head);
+		unsigned long i;
+		for (i = 0; i < toCheck; i++) {
+			if (atomic_read(&head[i]._count)) {
+				VM_BUG_ON(atomic_read(&head[i]._count));
+			}
+		}
+	} while (0);
+#endif
+	__page_cache_release(head);
+	dtor = get_compound_page_dtor(head);
+	(*dtor)(head);
 }
 
-static void put_compound_page(struct page *page)
+int put_compound_head(struct page *head)
 {
-	if (unlikely(PageTail(page))) {
-		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = compound_trans_head(page);
+	VM_BUG_ON(PageTail(head));
 
-		if (likely(page != page_head &&
-			   get_page_unless_zero(page_head))) {
-			unsigned long flags;
-			/*
-			 * page_head wasn't a dangling pointer but it
-			 * may not be a head page anymore by the time
-			 * we obtain the lock. That is ok as long as it
-			 * can't be freed from under us.
-			 */
-			flags = compound_lock_irqsave(page_head);
-			if (unlikely(!PageTail(page))) {
-				/* __split_huge_page_refcount run before us */
-				compound_unlock_irqrestore(page_head, flags);
-				VM_BUG_ON(PageHead(page_head));
-				if (put_page_testzero(page_head))
-					__put_single_page(page_head);
-			out_put_single:
-				if (put_page_testzero(page))
-					__put_single_page(page);
-				return;
-			}
-			VM_BUG_ON(page_head != page->first_page);
-			/*
-			 * We can release the refcount taken by
-			 * get_page_unless_zero() now that
-			 * __split_huge_page_refcount() is blocked on
-			 * the compound_lock.
-			 */
-			if (put_page_testzero(page_head))
-				VM_BUG_ON(1);
-			/* __split_huge_page_refcount will wait now */
-			VM_BUG_ON(page_mapcount(page) <= 0);
-			atomic_dec(&page->_mapcount);
-			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
-			VM_BUG_ON(atomic_read(&page->_count) != 0);
-			compound_unlock_irqrestore(page_head, flags);
-			if (put_page_testzero(page_head)) {
-				if (PageHead(page_head))
-					__put_compound_page(page_head);
-				else
-					__put_single_page(page_head);
+	if (atomic_dec_and_test(&head->_count)) {
+		/* We have putted head, and it's refcount fell to zero.
+		 *
+		 * head->_count may be bummped only in following situations
+		 * 1. get_page - this should not happend, there is VM_BUG_ON
+		 *    for this situation.
+		 * 2. __recover_page - bumps head->count, only after
+		 *    get_page_unless_zero, so only one may be winner, because
+		 *    __recover_page bumps if head->_count > 0, then at this
+		 *    point head->_count will be 1 - contradiction.
+		 */
+		if (PageCompound(head))
+			__free_compound_page(head);
+		else
+			__put_single_page(head);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(put_compound_head);
+
+int put_compound_tail(struct page *page)
+{
+	unsigned long flags;
+	VM_BUG_ON(PageHead(page));
+
+	if (atomic_dec_and_test(&page->_count)) {
+		struct page *head = compound_head(page);
+
+		/* We have putted page, and it's refcount fell to zero. */
+		if (!get_page_unless_zero(head)) {
+			/* Page was splitted or freed - nothing to do */
+			__put_single_page(page);
+			return 1;
+		}
+
+		flags = compound_lock_irqsave(head);
+		if (!PageCompound(page)) {
+			/* Page was splitted .*/
+			compound_unlock_irqrestore(head, flags);
+			put_page(head);
+			__put_single_page(page);
+			return 1;
+		}
+
+		/* Page is compound. */
+		if (compound_order(head) > 1) {
+			if (atomic_dec_and_test(
+				(atomic_t *) &head[3]._tail_count)) {
+				/* Tail count has fallen to zero. No one may
+				 * concurrently recover page, bacause we have
+				 * compound_lock, so &head[3]._tail_count
+				 * is managed only by us, because of this
+				 * no one may recover tail page.
+				 */
+				atomic_dec(&head->_count);
+
+				/* At least one ref should exist. */
+				VM_BUG_ON(!atomic_read(&head->_count));
+
+				if (atomic_dec_and_test(&head->_count)) {
+					/* Putted last ref - now noone may get
+					* head. Details in put_compound_head
+					*/
+					compound_unlock_irqrestore(head, flags);
+					__free_compound_page(head);
+					return 1;
+				}
 			}
 		} else {
-			/* page_head is a dangling pointer */
-			VM_BUG_ON(PageTail(page));
-			goto out_put_single;
+			/* Almost same as for order >= 2. */
+			if (atomic_dec_and_test(&head->_count)) {
+				compound_unlock_irqrestore(head, flags);
+				__free_compound_page(head);
+			}
 		}
-	} else if (put_page_testzero(page)) {
-		if (PageHead(page))
-			__put_compound_page(page);
-		else
-			__put_single_page(page);
+		/* One ref is "managed by" _tail_count, so head->_count >= 2. */
+		atomic_dec(&head->_count);
+		compound_unlock_irqrestore(head, flags);
+		return 1;
 	}
+	return 0;
 }
+EXPORT_SYMBOL(put_compound_tail);
 
 void put_page(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
-		put_compound_page(page);
-	else if (put_page_testzero(page))
+	if (unlikely(PageCompound(page))) {
+		if (likely(PageTail(page)))
+			put_compound_tail(page);
+		else
+			put_compound_head(page);
+	} else if (put_page_testzero(page)) {
 		__put_single_page(page);
+	}
 }
 EXPORT_SYMBOL(put_page);
 
-/*
- * This function is exported but must not be called by anything other
- * than get_page(). It implements the slow path of get_page().
- */
-bool __get_page_tail(struct page *page)
+void __recover_compound(struct page *page)
 {
-	/*
-	 * This takes care of get_page() if run on a tail page
-	 * returned by one of the get_user_pages/follow_page variants.
-	 * get_user_pages/follow_page itself doesn't need the compound
-	 * lock because it runs __get_page_tail_foll() under the
-	 * proper PT lock that already serializes against
-	 * split_huge_page().
-	 */
 	unsigned long flags;
-	bool got = false;
-	struct page *page_head = compound_trans_head(page);
+	struct page *head = compound_head(page);
+
+	if (get_page_unless_zero(head)) {
+		flags = compound_lock_irqsave(head);
+		if (!PageCompound(head)) {
+			/* Page was splitted under us. */
+			compound_unlock_irqrestore(head, flags);
+			put_page(head);
+			BUG();
+			return;
+		}
 
-	if (likely(page != page_head && get_page_unless_zero(page_head))) {
-		/*
-		 * page_head wasn't a dangling pointer but it
-		 * may not be a head page anymore by the time
-		 * we obtain the lock. That is ok as long as it
-		 * can't be freed from under us.
+		/* Now, page can't be splitted, because we have lock, we
+		 * exclusivly manage _tail_count, too. Head->_count >= 2.
 		 */
-		flags = compound_lock_irqsave(page_head);
-		/* here __split_huge_page_refcount won't run anymore */
-		if (likely(PageTail(page))) {
-			__get_page_tail_foll(page, false);
-			got = true;
+		if (likely(compound_order(head) > 1)) {
+			/* If put_page will be called here, then we may bump
+			 * _tail_count, but this tail count will be dropped
+			 * down, by put_page, because it waits for
+			 * compound_lock.
+			 */
+			if (atomic_add_return(1, &page->_count) > 1) {
+				/* Page was recovered by someone else,
+				 * before we have taken compound lock.
+				 * Nothing to do.
+				 */
+			} else {
+				/* If put_page was called here, then it waits
+				 * for compound_lock, and will immediatly
+				 * decrease _tail_count.
+				 */
+				if (atomic_add_return(1,
+					&head[3]._tail_count) == 1) {
+					/* _tail_count was 0, bump head. */
+					atomic_inc(&head->_count);
+				}
+			}
+		} else {
+			if (atomic_add_return(1, &page->_count) > 1) {
+				/* Page was recovered by someone else,
+				 * before we have taken compound lock.
+				 */
+				atomic_inc(&head->_count);
+			}
 		}
-		compound_unlock_irqrestore(page_head, flags);
-		if (unlikely(!got))
-			put_page(page_head);
+		compound_unlock_irqrestore(head, flags);
+		put_page(head);
+	} else {
+		/* If compound head fell to zero this means whole page was
+		 * splited - recall normal get_page. */
+		get_page(page);
 	}
-	return got;
 }
-EXPORT_SYMBOL(__get_page_tail);
+EXPORT_SYMBOL(__recover_compound);
 
 /**
  * put_pages_list() - release a list of pages
@@ -598,7 +666,7 @@ void release_pages(struct page **pages, int nr, int cold)
 				spin_unlock_irqrestore(&zone->lru_lock, flags);
 				zone = NULL;
 			}
-			put_compound_page(page);
+			put_page(page);
 			continue;
 		}
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
