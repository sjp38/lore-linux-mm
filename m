Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34CC06B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 17:07:46 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p74L7hBS009128
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:43 -0700
Received: from iyk2 (iyk2.prod.google.com [10.241.51.130])
	by wpaz13.hot.corp.google.com with ESMTP id p74L5eOi008128
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 14:07:42 -0700
Received: by iyk2 with SMTP id 2so2688882iyk.18
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 14:07:41 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 2/3] mm: page count lock
Date: Thu,  4 Aug 2011 14:07:21 -0700
Message-Id: <1312492042-13184-3-git-send-email-walken@google.com>
In-Reply-To: <1312492042-13184-1-git-send-email-walken@google.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

This change introduces a new lock in order to simplify the way
__split_huge_page_refcount and put_compound_page interact.

The synchronization problem in this code is that when operating on
tail pages, put_page() needs to adjust page counts for both the tail
and head pages. On the other hand, when splitting compound pages
__split_huge_page_refcount() needs to adjust the head page count so that
it does not reflect tail page references anymore. When the two race
together, they must agree as to the order things happen so that the head
page reference count does not end up with an improper value.

I propose doing this using a new lock on the tail page. Compared to
the previous version using the compound lock on the head page,
the compound page case of put_page() ends up being much simpler.

The new lock is implemented using the lowest bit of page->_count.
Page count accessor functions are modified to handle this transparently.
New accessors are added in mm/internal.h to lock/unlock the
page count lock while simultaneously accessing the page count value.
The number of atomic operations required is thus minimized.

Note that the current implementation takes advantage of the implicit
memory barrier provided by x86 on atomic RMW instructions to provide
the expected lock/unlock semantics. Clearly this is not portable
accross architectures, and will have to be accomodated for using
an explicit memory barrier on architectures that require it.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h      |   17 +++++---
 include/linux/pagemap.h |    6 ++-
 mm/huge_memory.c        |   20 ++++-----
 mm/internal.h           |   68 ++++++++++++++++++++++++++++++--
 mm/swap.c               |   98 ++++++++++++-----------------------------------
 5 files changed, 113 insertions(+), 96 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7984f90..fa64aa7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -266,9 +266,14 @@ struct inode;
  * routine so they can be sure the page doesn't go away from under them.
  */
 
+#define _PAGE_COUNT_LOCK (1 << 0)
+
+#define _PAGE_COUNT_SHIFT 1
+#define _PAGE_COUNT_ONE (1 << _PAGE_COUNT_SHIFT)
+
 static inline int __page_count(struct page *page)
 {
-	return atomic_read(&page->_count);
+	return atomic_read(&page->_count) >> _PAGE_COUNT_SHIFT;
 }
 
 /*
@@ -277,7 +282,7 @@ static inline int __page_count(struct page *page)
 static inline int put_page_testzero(struct page *page)
 {
 	VM_BUG_ON(__page_count(page) <= 0);
-	return atomic_dec_and_test(&page->_count);
+	return atomic_sub_and_test(_PAGE_COUNT_ONE, &page->_count);
 }
 
 /*
@@ -286,7 +291,7 @@ static inline int put_page_testzero(struct page *page)
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	return atomic_inc_not_zero(&page->_count);
+	return atomic_add_unless(&page->_count, _PAGE_COUNT_ONE, 0);
 }
 
 extern int page_is_ram(unsigned long pfn);
@@ -367,12 +372,12 @@ static inline int page_count(struct page *page)
 
 static inline void __add_page_count(int nr, struct page *page)
 {
-	atomic_add(nr, &page->_count);
+	atomic_add(nr << _PAGE_COUNT_SHIFT, &page->_count);
 }
 
 static inline void __get_page(struct page *page)
 {
-	atomic_inc(&page->_count);
+	__add_page_count(1, page);
 }
 
 static inline void get_page(struct page *page)
@@ -414,7 +419,7 @@ static inline struct page *virt_to_head_page(const void *x)
  */
 static inline void init_page_count(struct page *page)
 {
-	atomic_set(&page->_count, 1);
+	atomic_set(&page->_count, _PAGE_COUNT_ONE);
 }
 
 /*
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3dc3334..e9ec235 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -179,7 +179,8 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 	__add_page_count(count, page);
 
 #else
-	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
+	if (unlikely(!atomic_add_unless(&page->_count,
+					count << _PAGE_COUNT_SHIFT, 0)))
 		return 0;
 #endif
 	VM_BUG_ON(PageCompound(page) && page != compound_head(page));
@@ -189,6 +190,7 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 
 static inline int page_freeze_refs(struct page *page, int count)
 {
+	count <<= _PAGE_COUNT_SHIFT;
 	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
 }
 
@@ -197,7 +199,7 @@ static inline void page_unfreeze_refs(struct page *page, int count)
 	VM_BUG_ON(page_count(page) != 0);
 	VM_BUG_ON(count == 0);
 
-	atomic_set(&page->_count, count);
+	atomic_set(&page->_count, count << _PAGE_COUNT_SHIFT);
 }
 
 #ifdef CONFIG_NUMA
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2d45af2..8c0295f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1165,14 +1165,16 @@ static void __split_huge_page_refcount(struct page *page)
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 
-		/* tail_page->_count cannot change */
-		tail_counts += __page_count(page_tail);
-		__add_page_count(page_mapcount(page) + 1, page_tail);
+		/*
+		 * To prevent a race against put_page(), reading the
+		 * tail page count value (prior to splitting) and
+		 * clearing the PageTail flag must be done together
+		 * under protection of the tail page count lock.
+		 */
+		tail_counts += lock_add_page_count(page_mapcount(page) + 1,
+						   page_tail);
 		BUG_ON(__page_count(page_tail) <= 0);
 
-		/* after clearing PageTail the gup refcount can be released */
-		smp_mb();
-
 		/*
 		 * retain hwpoison flag of the poisoned tail page:
 		 *   fix for the unsuitable process killed on Guest Machine(KVM)
@@ -1186,11 +1188,7 @@ static void __split_huge_page_refcount(struct page *page)
 				      (1L << PG_uptodate)));
 		page_tail->flags |= (1L << PG_dirty);
 
-		/*
-		 * 1) clear PageTail before overwriting first_page
-		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
-		 */
-		smp_wmb();
+		unlock_page_count(page_tail);
 
 		/*
 		 * __split_huge_page_splitting() already set the
diff --git a/mm/internal.h b/mm/internal.h
index 93d8da4..8dde36d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -18,7 +18,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 static inline void set_page_count(struct page *page, int v)
 {
-	atomic_set(&page->_count, v);
+	atomic_set(&page->_count, v << _PAGE_COUNT_SHIFT);
 }
 
 /*
@@ -34,17 +34,77 @@ static inline void set_page_refcounted(struct page *page)
 
 static inline void __sub_page_count(int nr, struct page *page)
 {
-	atomic_sub(nr, &page->_count);
+	atomic_sub(nr << _PAGE_COUNT_SHIFT, &page->_count);
 }
 
 static inline void __put_page(struct page *page)
 {
-	atomic_dec(&page->_count);
+	__sub_page_count(1, page);
 }
 
 static inline int __put_page_return(struct page *page)
 {
-	return atomic_dec_return(&page->_count) >> 1;
+	return atomic_sub_return(_PAGE_COUNT_ONE,
+				 &page->_count) >> _PAGE_COUNT_SHIFT;
+}
+
+static inline int lock_add_page_count(int nr, struct page *page)
+{
+	int count, prev, next;
+
+retry_spin:
+	count = atomic_read(&page->_count);
+retry:
+	if (count & _PAGE_COUNT_LOCK) {
+		cpu_relax();
+		goto retry_spin;
+	}
+	prev = count;
+	next = count + (nr << _PAGE_COUNT_SHIFT) + _PAGE_COUNT_LOCK;
+	preempt_disable();
+	count = atomic_cmpxchg(&page->_count, prev, next);
+	if (count != prev) {
+		preempt_enable();
+		goto retry;
+	}
+	__acquire(page_count_lock);
+	return count >> _PAGE_COUNT_SHIFT;
+}
+
+static inline void lock_page_count(struct page *page)
+{
+	/* Faster implementation would be possible using atomic test and set,
+	   but linux only provides atomic bit operations on long types... */
+	lock_add_page_count(0, page);
+}
+
+static inline void unlock_page_count(struct page *page)
+{
+	VM_BUG_ON(!(atomic_read(&page->_count) & _PAGE_COUNT_LOCK));
+	BUG_ON(_PAGE_COUNT_LOCK != 1);
+	atomic_dec(&page->_count);
+	preempt_enable();
+	__release(page_count_lock);
+}
+
+static inline void unlock_sub_page_count(int nr, struct page *page)
+{
+	VM_BUG_ON(!(atomic_read(&page->_count) & _PAGE_COUNT_LOCK));
+	atomic_sub((nr << _PAGE_COUNT_SHIFT) + _PAGE_COUNT_LOCK,
+		   &page->_count);
+	preempt_enable();
+	__release(page_count_lock);
+}
+
+static inline int unlock_sub_test_page_count(int nr, struct page *page)
+{
+	int zero;
+	VM_BUG_ON(!(atomic_read(&page->_count) & _PAGE_COUNT_LOCK));
+	zero = atomic_sub_and_test((nr << _PAGE_COUNT_SHIFT) + _PAGE_COUNT_LOCK,
+				   &page->_count);
+	preempt_enable();
+	__release(page_count_lock);
+	return zero;
 }
 
 extern unsigned long highest_memmap_pfn;
diff --git a/mm/swap.c b/mm/swap.c
index 46ae089..1e91a1b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -74,90 +74,42 @@ static void __put_compound_page(struct page *page)
 	(*dtor)(page);
 }
 
-static void put_compound_page(struct page *page)
+void put_page(struct page *page)
 {
 	if (unlikely(PageTail(page))) {
-		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = page->first_page;
-		smp_rmb();
+		struct page *page_tail = page;
+
 		/*
-		 * If PageTail is still set after smp_rmb() we can be sure
-		 * that the page->first_page we read wasn't a dangling pointer.
-		 * See __split_huge_page_refcount() smp_wmb().
+		 * To prevent a race against __split_huge_page_refcount(),
+		 * updating the tail page count and checking the
+		 * TailPage flag must be done together under
+		 * protection of the tail page count lock.
 		 */
-		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
-			unsigned long flags;
-			/*
-			 * Verify that our page_head wasn't converted
-			 * to a a regular page before we got a
-			 * reference on it.
-			 */
-			if (unlikely(!PageHead(page_head))) {
-				/* PageHead is cleared after PageTail */
-				smp_rmb();
-				VM_BUG_ON(PageTail(page));
-				goto out_put_head;
-			}
-			/*
-			 * Only run compound_lock on a valid PageHead,
-			 * after having it pinned with
-			 * get_page_unless_zero() above.
-			 */
-			smp_mb();
-			/* page_head wasn't a dangling pointer */
-			flags = compound_lock_irqsave(page_head);
-			if (unlikely(!PageTail(page))) {
-				/* __split_huge_page_refcount run before us */
-				compound_unlock_irqrestore(page_head, flags);
-				VM_BUG_ON(PageHead(page_head));
-			out_put_head:
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
-			 * get_page_unless_zero now that
-			 * split_huge_page_refcount is blocked on the
-			 * compound_lock.
-			 */
-			if (put_page_testzero(page_head))
-				VM_BUG_ON(1);
-			/* __split_huge_page_refcount will wait now */
+		lock_page_count(page);
+		if (unlikely(!PageTail(page))) {
 			VM_BUG_ON(__page_count(page) <= 0);
-			__put_page(page);
-			VM_BUG_ON(__page_count(page_head) <= 0);
-			compound_unlock_irqrestore(page_head, flags);
-			if (put_page_testzero(page_head)) {
-				if (PageHead(page_head))
-					__put_compound_page(page_head);
-				else
-					__put_single_page(page_head);
-			}
-		} else {
-			/* page_head is a dangling pointer */
-			VM_BUG_ON(PageTail(page));
-			goto out_put_single;
+			if (unlock_sub_test_page_count(1, page))
+				__put_single_page(page);
+			return;
 		}
-	} else if (put_page_testzero(page)) {
+
+		/*
+		 * The head page must be located under protection of the
+		 * tail page count lock, but we can release this lock
+		 * before putting the head page.
+		 */
+		page = page->first_page;
+		VM_BUG_ON(__page_count(page_tail) <= 0);
+		unlock_sub_page_count(1, page_tail);
+	}
+
+	if (put_page_testzero(page)) {
 		if (PageHead(page))
 			__put_compound_page(page);
 		else
 			__put_single_page(page);
 	}
 }
-
-void put_page(struct page *page)
-{
-	if (unlikely(PageCompound(page)))
-		put_compound_page(page);
-	else if (put_page_testzero(page))
-		__put_single_page(page);
-}
 EXPORT_SYMBOL(put_page);
 
 /**
@@ -575,7 +527,7 @@ void release_pages(struct page **pages, int nr, int cold)
 				spin_unlock_irqrestore(&zone->lru_lock, flags);
 				zone = NULL;
 			}
-			put_compound_page(page);
+			put_page(page);
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
