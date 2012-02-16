Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 053156B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:48 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 02/18] Change of refcounting method for compound pages and atomic heads
Date: Thu, 16 Feb 2012 15:31:29 +0100
Message-Id: <1329402705-25454-2-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Compound pages are now refcounted in way allowing tracking of tail pages
and automatically free of compound page when all references (counter)
fell to zero. This in addition make get_page and get_page_unless_zero
similar in work, as well put_page and put_page_unless_zero. In addition
it  makes procedures more friendly. One thing that should be taken, by
developer, on account is to take care when page is putted or geted when
compound lock is obtained, to avoid deadlocks. Locking is used to
prevent concurrent compound split and only when page refcount goes from
0 to 1 or vice versa.

Technically, implementation uses 3rd element of compound page to store
"tails usage counter". This counter is decremented when tail pages count
goes to zero, and bumped when tail page is getted from zero usage
(recovered) a?? this is to keep backward compatible usage of tail pages.
If "tails usage counter" fell to zero head counter is decremented, if
"tails usage counter" is increased to one the head count is increased,
too. For compound pages without 3rd element (order of 1, two pages) 2nd
page's _count is used in similar way as for higher order pages
_tail_count.

Previous memory barrier logic actually made this safe for
getting page head, but assume that we have cleared tail bit

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/huge_mm.h    |   21 ++--
 include/linux/mm.h         |  147 +++++++++++++++---------
 include/linux/mm_types.h   |   72 +++++++++---
 include/linux/page-flags.h |    1 +
 include/linux/pagemap.h    |    1 -
 mm/huge_memory.c           |   40 +++----
 mm/hugetlb.c               |    3 +-
 mm/internal.h              |   46 --------
 mm/memory.c                |    2 +-
 mm/page_alloc.c            |   13 ++-
 mm/swap.c                  |  275 +++++++++++++++++++++++++++++---------------
 11 files changed, 373 insertions(+), 248 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1b92129..c2407e4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -130,18 +130,17 @@ static inline int hpage_nr_pages(struct page *page)
 }
 static inline struct page *compound_trans_head(struct page *page)
 {
-	if (PageTail(page)) {
-		struct page *head;
-		head = page->first_page;
+	if (unlikely(PageTail(page))) {
+		void *result = page->_compound_order;
 		smp_rmb();
-		/*
-		 * head may be a dangling pointer.
-		 * __split_huge_page_refcount clears PageTail before
-		 * overwriting first_page, so if PageTail is still
-		 * there it means the head pointer isn't dangling.
-		 */
-		if (PageTail(page))
-			return head;
+		if (PageTail(page)) {
+			if (((unsigned long) result) == 1)
+				return page - 1;
+			else
+				return (struct page *) result;
+		} else {
+			return page;
+		}
 	}
 	return page;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..bacb023 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -267,14 +267,55 @@ struct inode;
  * Also, many kernel routines increase the page count before a critical
  * routine so they can be sure the page doesn't go away from under them.
  */
+extern int put_compound_head(struct page *head);
+extern int put_compound_tail(struct page *page);
 
-/*
+static inline void compound_lock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_lock(PG_compound_lock, &page->flags);
+#endif
+}
+
+static inline void compound_unlock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_unlock(PG_compound_lock, &page->flags);
+#endif
+}
+
+/** Gets head of compound page. If page is no longer head returns {@code page}.
+ * This function involves makes memory barrier to ensure page was not splitted.
+ */
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page))) {
+		void *result = page->_compound_order;
+		smp_rmb();
+		if (PageTail(page)) {
+			if (((unsigned long) result) < 64)
+				return page - 1;
+			else
+				return (struct page *) result;
+		} else {
+			return page;
+		}
+	}
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
@@ -317,20 +358,6 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 }
 #endif
 
-static inline void compound_lock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	bit_spin_lock(PG_compound_lock, &page->flags);
-#endif
-}
-
-static inline void compound_unlock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	bit_spin_unlock(PG_compound_lock, &page->flags);
-#endif
-}
-
 static inline unsigned long compound_lock_irqsave(struct page *page)
 {
 	unsigned long uninitialized_var(flags);
@@ -350,13 +377,6 @@ static inline void compound_unlock_irqrestore(struct page *page,
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
@@ -374,33 +394,35 @@ static inline int page_mapcount(struct page *page)
 
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
@@ -452,29 +474,22 @@ void put_pages_list(struct list_head *pages);
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
 
-/*
- * Compound pages have a destructor function.  Provide a
- * prototype for that function and accessor functions.
- * These are _only_ valid on the head of a PG_compound page.
- */
-typedef void compound_page_dtor(struct page *);
-
 static inline void set_compound_page_dtor(struct page *page,
 						compound_page_dtor *dtor)
 {
-	page[1].lru.next = (void *)dtor;
+	page[1]._dtor = (void *)dtor;
 }
 
 static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 {
-	return (compound_page_dtor *)page[1].lru.next;
+	 return page[1]._dtor;
 }
 
 static inline int compound_order(struct page *page)
 {
 	if (!PageHead(page))
 		return 0;
-	return (unsigned long)page[1].lru.prev;
+	return (unsigned long)page[1]._compound_order;
 }
 
 static inline int compound_trans_order(struct page *page)
@@ -493,9 +508,33 @@ static inline int compound_trans_order(struct page *page)
 
 static inline void set_compound_order(struct page *page, unsigned long order)
 {
-	page[1].lru.prev = (void *)order;
+	page[1]._compound_order = (void *)order;
+}
+/** Returns number of used tails (not including head). The tail is used when
+ * its {@code _count > 0}.
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
+			return !!atomic_add_return(0, &head[1]._count);
+		}
+	} else {
+		return page_count(page);
+	}
 }
-
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..05fefae 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,9 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
+/** Type describing destructor of compound page. */
+typedef void compound_page_dtor(struct page *);
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -67,16 +70,6 @@ struct page {
 					 * mms, to show when page is
 					 * mapped & limit reverse map
 					 * searches.
-					 *
-					 * Used also for tail pages
-					 * refcounting instead of
-					 * _count. Tail pages cannot
-					 * be mapped and keeping the
-					 * tail page _count zero at
-					 * all times guarantees
-					 * get_page_unless_zero() will
-					 * never succeed on tail
-					 * pages.
 					 */
 					atomic_t _mapcount;
 
@@ -93,9 +86,61 @@ struct page {
 
 	/* Third double word block */
 	union {
-		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
-					 */
+		/** Pageout list, eg. active_list protected by
+		 * {@code zone->lru_lock} !
+		 * Valid on head pages and "single" pages.
+		 */
+		struct list_head lru;
+
+		/** Represent special structures for compound page's tail. Some
+		 * values are specific only for higher order pages, so if page
+		 * has order e. g. 1 (two pages) then there are no values as
+		 * head[2].
+		 */
+		struct {
+			/** First union of compound page, overlaps first pointer
+			 * in list_head.
+			 */
+			union {
+				/* This should be cast to int, and it must be
+				 * pointer to keep align and size with other.
+				 * <b>Valid only on head[1].</b>
+				 */
+				void *_compound_order;
+
+				/** Pointer to first page in compound.
+				 * Distinction between first page and valid
+				 * order depends on simple observation page
+				 * struct pointer can't have some values. It's
+				 * rather architecture specific where 1st page
+				 * header pointer may exists, but it is after
+				 * address 64L. So if we will see here value
+				 * less then 64L we are sure it's 2nd page of
+				 * compound (so first page is "this - 1").
+				 * <b>Valid only on 3rd and next elements</b>
+				 */
+				struct page *__first_page;
+			};
+
+			/** 2nd union of compound page, overlaps first pointer
+			 * in list_head.
+			 */
+			union {
+				/** Destructor of compound page, stored in
+				 * head[1].
+				 */
+				compound_page_dtor *_dtor;
+
+				/** Number of pages in compound page(including
+				 * head and tails) that are used (having
+				 * {@code _count > 0}). If this number fell to
+				 * zero, then compound page may be freed by
+				 * kernel. This is stored in head[3].
+				 */
+				atomic_t _tail_count;
+			};
+		};
+
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT
@@ -121,7 +166,6 @@ struct page {
 		spinlock_t ptl;
 #endif
 		struct kmem_cache *slab;	/* SLUB: Pointer to slab */
-		struct page *first_page;	/* Compound tail pages */
 	};
 
 	/*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..393b8af 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -105,6 +105,7 @@ enum pageflags {
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/** For page head it's raised to protect page from spliting */
 	PG_compound_lock,
 #endif
 	__NR_PAGEFLAGS,
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
index 91d3efb..e3b4c38 100644
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
@@ -1228,8 +1227,8 @@ static int __split_huge_page_splitting(struct page *page,
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
+	int tail_counter;
 	struct zone *zone = page_zone(page);
-	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -1237,30 +1236,18 @@ static void __split_huge_page_refcount(struct page *page)
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
 
+	tail_counter = compound_elements(page);
+
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
 		BUG_ON(page_mapcount(page_tail) < 0);
-		tail_count += page_mapcount(page_tail);
-		/* check for overflow */
-		BUG_ON(tail_count < 0);
-		BUG_ON(atomic_read(&page_tail->_count) != 0);
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
@@ -1269,8 +1256,13 @@ static void __split_huge_page_refcount(struct page *page)
 		 * retain hwpoison flag of the poisoned tail page:
 		 *   fix for the unsuitable process killed on Guest Machine(KVM)
 		 *   by the memory-failure.
+		 * retain lock, and compound lock
 		 */
-		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON;
+		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP
+			| __PG_HWPOISON
+			| PG_locked
+			| PG_compound_lock;
+
 		page_tail->flags |= (page->flags &
 				     ((1L << PG_referenced) |
 				      (1L << PG_swapbacked) |
@@ -1307,10 +1299,8 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
 
-
 		lru_add_page_tail(zone, page, page_tail);
 	}
-	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
@@ -1318,6 +1308,10 @@ static void __split_huge_page_refcount(struct page *page)
 
 	ClearPageCompound(page);
 	compound_unlock(page);
+	/* Remove additional reference used in compound. */
+	if (tail_counter)
+		put_page(page);
+
 	spin_unlock_irq(&zone->lru_lock);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f34bd8..d3f3f30 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -577,7 +577,8 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
 		__SetPageTail(p);
 		set_page_count(p, 0);
-		p->first_page = page;
+		if (order > 1)
+			p->__first_page = page;
 	}
 }
 
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
index d2186ec..b48e313 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -345,15 +345,20 @@ void prep_compound_page(struct page *page, unsigned long order)
 	int i;
 	int nr_pages = 1 << order;
 
-	set_compound_page_dtor(page, free_compound_page);
-	set_compound_order(page, order);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 		__SetPageTail(p);
 		set_page_count(p, 0);
-		p->first_page = page;
+		if (order > 1)
+			p->__first_page = page;
 	}
+
+	/* Order, dtor was replaced in for loop, set it correctly. */
+	set_compound_order(page, order);
+	set_compound_page_dtor(page, free_compound_page);
+	if (order > 1)
+		atomic_set(&page[3]._tail_count, 0);
 }
 
 /* update __split_huge_page_refcount if you change this function */
@@ -374,7 +379,7 @@ static int destroy_compound_page(struct page *page, unsigned long order)
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		if (unlikely(!PageTail(p) || (p->first_page != page))) {
+		if (unlikely(!PageTail(p) || (compound_head(page) != page))) {
 			bad_page(page);
 			bad++;
 		}
diff --git a/mm/swap.c b/mm/swap.c
index fff1ff7..365363c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 
+
 #include "internal.h"
 
 /* How many pages do we try to swap or page in/out together? */
@@ -64,123 +65,211 @@ static void __put_single_page(struct page *page)
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
+			if (atomic_read(&head[i]._count))
+				VM_BUG_ON(atomic_read(&head[i]._count));
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
+	/* We need, first, test if we may drop reference to zero. If we would
+	 * drop reference to zero (e. g. by atomic_dec_and_test), split
+	 * refcount could raise compound lock, before us, and we decreased
+	 * _tail_count. Whith improper _tail_count "split" may not decrease
+	 * head refcount, and head page would leak.
+	 */
+	if (__atomic_add_unless(&page->_count, -1, 1) == 1) {
+		struct page *head = compound_head(page);
+
+		VM_BUG_ON(!atomic_read(&page->_count));
+
+		if (!get_page_unless_zero(head)) {
+			/* Page was splitted or freed - nothing to do */
+			__put_single_page(page);
+			return 1;
+		}
+
+		flags = compound_lock_irqsave(head);
+
+		/* Having exclusive lock check if we putted page to 0, meantime
+		 * others could get_page. This is like double check lock.
+		 */
+		if (!atomic_dec_and_test(&page->_count)) {
+			compound_unlock_irqrestore(head, flags);
+			put_page(head);
+			return 0;
+		}
+
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
+				 *
+				 * This drops usage count for tail pages.
+				 */
+				atomic_dec(&head->_count);
+
+				/* At least one ref should exists. */
+				VM_BUG_ON(!atomic_read(&head->_count));
+
+				/* and this one for get_page_unless_zero(head)*/
+				if (atomic_dec_and_test(&head->_count)) {
+					/* Putted last ref - now noone may get
+					* head. Details in put_compound_head
+					*/
+					compound_unlock_irqrestore(head, flags);
+					__free_compound_page(head);
+					return 1;
+				} else {
+					compound_unlock_irqrestore(head, flags);
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
+	return 1;
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
+			if (!(atomic_add_return(1, &page->_count) > 1)) {
+				/* Page wasn't recovered by someone else,
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
@@ -598,7 +687,7 @@ void release_pages(struct page **pages, int nr, int cold)
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
