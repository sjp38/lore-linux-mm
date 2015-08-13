Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 12B186B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:55:04 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so20958683pdb.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:55:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pf2si4407160pdb.253.2015.08.13.08.55.02
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 08:55:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: make compound_head() robust
Date: Thu, 13 Aug 2015 18:54:46 +0300
Message-Id: <1439481286-81093-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1439481286-81093-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439481286-81093-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

Hugh has pointed that compound_head() call can be unsafe in some
context. There's one example:

	CPU0					CPU1

isolate_migratepages_block()
  page_count()
    compound_head()
      !!PageTail() == true
					put_page()
					  tail->first_page = NULL
      head = tail->first_page
					alloc_pages(__GFP_COMP)
					   prep_compound_page()
					     tail->first_page = head
					     __SetPageTail(p);
      !!PageTail() == true
    <head == NULL dereferencing>

The race is pure theoretical. I don't it's possible to trigger it in
practice. But who knows.

We can fix the race by chaging how encode PageTail() and compound_head()
within struct page to be able to update them in one shot.

The patch introduces page->compound_head into union with
page->mem_cgroup.

Set bit 0 of page->compound_head means that the page is tail. If the bit
set, rest of the page->compound_head is pointer to head page. Otherwise,
the field is NULL or pointer to memory cgroup.

page->mem_cgroup currenly only used for small or head pages, so there
shouldn't be any conflicts.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 Documentation/vm/split_page_table_lock |  4 +-
 arch/xtensa/configs/iss_defconfig      |  1 -
 include/linux/mm.h                     | 53 ++--------------------
 include/linux/mm_types.h               | 15 ++++---
 include/linux/page-flags.h             | 80 ++++++++--------------------------
 mm/Kconfig                             | 12 -----
 mm/debug.c                             |  7 ---
 mm/hugetlb.c                           |  8 +---
 mm/internal.h                          |  4 +-
 mm/memory-failure.c                    |  7 ---
 mm/page_alloc.c                        | 36 +++++++--------
 mm/swap.c                              |  4 +-
 12 files changed, 56 insertions(+), 175 deletions(-)

diff --git a/Documentation/vm/split_page_table_lock b/Documentation/vm/split_page_table_lock
index 6dea4fd5c961..62842a857dab 100644
--- a/Documentation/vm/split_page_table_lock
+++ b/Documentation/vm/split_page_table_lock
@@ -54,8 +54,8 @@ everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
 which must be called on PTE table allocation / freeing.
 
 Make sure the architecture doesn't use slab allocator for page table
-allocation: slab uses page->slab_cache and page->first_page for its pages.
-These fields share storage with page->ptl.
+allocation: slab uses page->slab_cache for its pages.
+This field shares storage with page->ptl.
 
 PMD split lock only makes sense if you have more than two page table
 levels.
diff --git a/arch/xtensa/configs/iss_defconfig b/arch/xtensa/configs/iss_defconfig
index e4d193e7a300..5c7c385f21c4 100644
--- a/arch/xtensa/configs/iss_defconfig
+++ b/arch/xtensa/configs/iss_defconfig
@@ -169,7 +169,6 @@ CONFIG_FLATMEM_MANUAL=y
 # CONFIG_SPARSEMEM_MANUAL is not set
 CONFIG_FLATMEM=y
 CONFIG_FLAT_NODE_MEM_MAP=y
-CONFIG_PAGEFLAGS_EXTENDED=y
 CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f92dbac..ce135e72e535 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -437,46 +437,6 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
-static inline struct page *compound_head_by_tail(struct page *tail)
-{
-	struct page *head = tail->first_page;
-
-	/*
-	 * page->first_page may be a dangling pointer to an old
-	 * compound page, so recheck that it is still a tail
-	 * page before returning.
-	 */
-	smp_rmb();
-	if (likely(PageTail(tail)))
-		return head;
-	return tail;
-}
-
-/*
- * Since either compound page could be dismantled asynchronously in THP
- * or we access asynchronously arbitrary positioned struct page, there
- * would be tail flag race. To handle this race, we should call
- * smp_rmb() before checking tail flag. compound_head_by_tail() did it.
- */
-static inline struct page *compound_head(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return compound_head_by_tail(page);
-	return page;
-}
-
-/*
- * If we access compound page synchronously such as access to
- * allocated page, there is no need to handle tail flag race, so we can
- * check tail flag directly without any synchronization primitive.
- */
-static inline struct page *compound_head_fast(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return page->first_page;
-	return page;
-}
-
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
@@ -525,7 +485,7 @@ static inline void get_huge_page_tail(struct page *page)
 	VM_BUG_ON_PAGE(!PageTail(page), page);
 	VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 	VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
-	if (compound_tail_refcounted(page->first_page))
+	if (compound_tail_refcounted(compound_head(page)))
 		atomic_inc(&page->_mapcount);
 }
 
@@ -548,13 +508,7 @@ static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
 
-	/*
-	 * We don't need to worry about synchronization of tail flag
-	 * when we call virt_to_head_page() since it is only called for
-	 * already allocated page and this page won't be freed until
-	 * this virt_to_head_page() is finished. So use _fast variant.
-	 */
-	return compound_head_fast(page);
+	return compound_head(page);
 }
 
 /*
@@ -1482,8 +1436,7 @@ static inline bool ptlock_init(struct page *page)
 	 * with 0. Make sure nobody took it in use in between.
 	 *
 	 * It can happen if arch try to use slab for page table allocation:
-	 * slab code uses page->slab_cache and page->first_page (for tail
-	 * pages), which share storage with page->ptl.
+	 * slab code uses page->slab_cache, which share storage with page->ptl.
 	 */
 	VM_BUG_ON_PAGE(*(unsigned long *)&page->ptl, page);
 	if (!ptlock_alloc(page))
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0038ac7466fd..e0c4c0a8ec3d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -155,7 +155,7 @@ struct page {
 #endif
 	};
 
-	/* Remainder is not double word aligned */
+	/* Fourth double word block */
 	union {
 		unsigned long private;		/* Mapping-private opaque data:
 					 	 * usually used for buffer_heads
@@ -172,13 +172,17 @@ struct page {
 #endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
-		struct page *first_page;	/* Compound tail pages */
 	};
 
-#ifdef CONFIG_MEMCG
-	struct mem_cgroup *mem_cgroup;
-#endif
+	union {
+		/* Bit zero of the word encode PageTail() */
+		struct mem_cgroup *mem_cgroup;	/* If bit zero is clear */
+		unsigned long compound_head;	/* If bit zero is set */
+	};
 
+	/* Remainder is not double word aligned */
+
+#if defined(WANT_PAGE_VIRTUAL)
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
@@ -189,7 +193,6 @@ struct page {
 	 * Architectures with slow multiplication can define
 	 * WANT_PAGE_VIRTUAL in asm/page.h
 	 */
-#if defined(WANT_PAGE_VIRTUAL)
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 41c93844fb1d..9b865158e452 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -86,12 +86,7 @@ enum pageflags {
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_private_2,		/* If pagecache, has fs aux data */
 	PG_writeback,		/* Page is under writeback */
-#ifdef CONFIG_PAGEFLAGS_EXTENDED
 	PG_head,		/* A head page */
-	PG_tail,		/* A tail page */
-#else
-	PG_compound,		/* A compound page */
-#endif
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
@@ -387,85 +382,46 @@ static inline void set_page_writeback_keepwrite(struct page *page)
 	test_set_page_writeback_keepwrite(page);
 }
 
-#ifdef CONFIG_PAGEFLAGS_EXTENDED
-/*
- * System with lots of page flags available. This allows separate
- * flags for PageHead() and PageTail() checks of compound pages so that bit
- * tests can be used in performance sensitive paths. PageCompound is
- * generally not used in hot code paths except arch/powerpc/mm/init_64.c
- * and arch/powerpc/kvm/book3s_64_vio_hv.c which use it to detect huge pages
- * and avoid handling those in real mode.
- */
 __PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
-__PAGEFLAG(Tail, tail)
 
-static inline int PageCompound(struct page *page)
-{
-	return page->flags & ((1L << PG_head) | (1L << PG_tail));
-
-}
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline void ClearPageCompound(struct page *page)
+static inline int PageTail(struct page *page)
 {
-	BUG_ON(!PageHead(page));
-	ClearPageHead(page);
+	return READ_ONCE(page->compound_head) & 1;
 }
-#endif
-
-#define PG_head_mask ((1L << PG_head))
 
-#else
-/*
- * Reduce page flag use as much as possible by overlapping
- * compound page flags with the flags used for page cache pages. Possible
- * because PageCompound is always set for compound pages and not for
- * pages on the LRU and/or pagecache.
- */
-TESTPAGEFLAG(Compound, compound)
-__SETPAGEFLAG(Head, compound)  __CLEARPAGEFLAG(Head, compound)
-
-/*
- * PG_reclaim is used in combination with PG_compound to mark the
- * head and tail of a compound page. This saves one page flag
- * but makes it impossible to use compound pages for the page cache.
- * The PG_reclaim bit would have to be used for reclaim or readahead
- * if compound pages enter the page cache.
- *
- * PG_compound & PG_reclaim	=> Tail page
- * PG_compound & ~PG_reclaim	=> Head page
- */
-#define PG_head_mask ((1L << PG_compound))
-#define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))
-
-static inline int PageHead(struct page *page)
+static inline void set_compound_head(struct page *page, struct page *head)
 {
-	return ((page->flags & PG_head_tail_mask) == PG_head_mask);
+	WRITE_ONCE(page->compound_head, (unsigned long)head + 1);
 }
 
-static inline int PageTail(struct page *page)
+static inline void clear_compound_head(struct page *page)
 {
-	return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
+	WRITE_ONCE(page->compound_head, 0);
 }
 
-static inline void __SetPageTail(struct page *page)
+static inline struct page *compound_head(struct page *page)
 {
-	page->flags |= PG_head_tail_mask;
+	unsigned long head = READ_ONCE(page->compound_head);
+
+	if (unlikely(head & 1))
+		return (struct page *) (head - 1);
+	return page;
 }
 
-static inline void __ClearPageTail(struct page *page)
+static inline int PageCompound(struct page *page)
 {
-	page->flags &= ~PG_head_tail_mask;
-}
+	return PageHead(page) || PageTail(page);
 
+}
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline void ClearPageCompound(struct page *page)
 {
-	BUG_ON((page->flags & PG_head_tail_mask) != (1 << PG_compound));
-	clear_bit(PG_compound, &page->flags);
+	BUG_ON(!PageHead(page));
+	ClearPageHead(page);
 }
 #endif
 
-#endif /* !PAGEFLAGS_EXTENDED */
+#define PG_head_mask ((1L << PG_head))
 
 #ifdef CONFIG_HUGETLB_PAGE
 int PageHuge(struct page *page);
diff --git a/mm/Kconfig b/mm/Kconfig
index e79de2bd12cd..454579d31081 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -200,18 +200,6 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
-#
-# If we have space for more page flags then we can enable additional
-# optimizations and functionality.
-#
-# Regular Sparsemem takes page flag bits for the sectionid if it does not
-# use a virtual memmap. Disable extended page flags for 32 bit platforms
-# that require the use of a sectionid in the page flags.
-#
-config PAGEFLAGS_EXTENDED
-	def_bool y
-	depends on 64BIT || SPARSEMEM_VMEMMAP || !SPARSEMEM
-
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
diff --git a/mm/debug.c b/mm/debug.c
index 76089ddf99ea..721502d40c43 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -25,12 +25,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_private,		"private"	},
 	{1UL << PG_private_2,		"private_2"	},
 	{1UL << PG_writeback,		"writeback"	},
-#ifdef CONFIG_PAGEFLAGS_EXTENDED
 	{1UL << PG_head,		"head"		},
-	{1UL << PG_tail,		"tail"		},
-#else
-	{1UL << PG_compound,		"compound"	},
-#endif
 	{1UL << PG_swapcache,		"swapcache"	},
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
 	{1UL << PG_reclaim,		"reclaim"	},
@@ -95,10 +90,8 @@ void dump_page_badflags(struct page *page, const char *reason,
 		dump_flags(page->flags & badflags,
 				pageflag_names, ARRAY_SIZE(pageflag_names));
 	}
-#ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
-#endif
 }
 
 void dump_page(struct page *page, const char *reason)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087089d8..82b99d994c69 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -824,9 +824,8 @@ static void destroy_compound_gigantic_page(struct page *page,
 	struct page *p = page + 1;
 
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
-		__ClearPageTail(p);
+		clear_compound_head(p);
 		set_page_refcounted(p);
-		p->first_page = NULL;
 	}
 
 	set_compound_order(page, 0);
@@ -1099,10 +1098,7 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 		 */
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
-		p->first_page = page;
-		/* Make sure p->first_page is always valid for PageTail() */
-		smp_wmb();
-		__SetPageTail(p);
+		set_compound_head(p, page);
 	}
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 36b23f1e2ca6..89e21a07080a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -61,9 +61,9 @@ static inline void __get_page_tail_foll(struct page *page,
 	 * speculative page access (like in
 	 * page_cache_get_speculative()) on tail pages.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
+	VM_BUG_ON_PAGE(atomic_read(&compound_head(page)->_count) <= 0, page);
 	if (get_page_head)
-		atomic_inc(&page->first_page->_count);
+		atomic_inc(&compound_head(page)->_count);
 	get_huge_page_tail(page);
 }
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ea5a93659488..f4e54be1e92a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -787,8 +787,6 @@ static int me_huge_page(struct page *p, unsigned long pfn)
 #define lru		(1UL << PG_lru)
 #define swapbacked	(1UL << PG_swapbacked)
 #define head		(1UL << PG_head)
-#define tail		(1UL << PG_tail)
-#define compound	(1UL << PG_compound)
 #define slab		(1UL << PG_slab)
 #define reserved	(1UL << PG_reserved)
 
@@ -811,12 +809,7 @@ static struct page_state {
 	 */
 	{ slab,		slab,		MF_MSG_SLAB,	me_kernel },
 
-#ifdef CONFIG_PAGEFLAGS_EXTENDED
 	{ head,		head,		MF_MSG_HUGE,		me_huge_page },
-	{ tail,		tail,		MF_MSG_HUGE,		me_huge_page },
-#else
-	{ compound,	compound,	MF_MSG_HUGE,		me_huge_page },
-#endif
 
 	{ sc|dirty,	sc|dirty,	MF_MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
 	{ sc|dirty,	sc,		MF_MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beda41710802..a5beebc033a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -419,7 +419,7 @@ out:
  *
  * The remaining PAGE_SIZE pages are called "tail pages".
  *
- * All pages have PG_compound set.  All tail pages have their ->first_page
+ * All pages have PG_compound set.  All tail pages have their compound_head()
  * pointing at the head page.
  *
  * The first tail page's ->lru.next holds the address of the compound page's
@@ -443,10 +443,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 		set_page_count(p, 0);
-		p->first_page = page;
-		/* Make sure p->first_page is always valid for PageTail() */
-		smp_wmb();
-		__SetPageTail(p);
+		set_compound_head(p, page);
 	}
 }
 
@@ -722,10 +719,8 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
 		bad_flags = PAGE_FLAGS_CHECK_AT_FREE;
 	}
-#ifdef CONFIG_MEMCG
 	if (unlikely(page->mem_cgroup))
-		bad_reason = "page still charged to cgroup";
-#endif
+		bad_reason = "non-NULL mem_cgroup";
 	if (unlikely(bad_reason)) {
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
@@ -821,17 +816,24 @@ static void free_one_page(struct zone *zone,
 
 static int free_tail_pages_check(struct page *head_page, struct page *page)
 {
-	if (!IS_ENABLED(CONFIG_DEBUG_VM))
-		return 0;
+	int ret = 1;
+
+	if (!IS_ENABLED(CONFIG_DEBUG_VM)) {
+		ret = 0;
+		goto out;
+	}
 	if (unlikely(!PageTail(page))) {
 		bad_page(page, "PageTail not set", 0);
-		return 1;
+		goto out;
 	}
-	if (unlikely(page->first_page != head_page)) {
-		bad_page(page, "first_page not consistent", 0);
-		return 1;
+	if (unlikely(compound_head(page) != head_page)) {
+		bad_page(page, "compound_head not consistent", 0);
+		goto out;
 	}
-	return 0;
+	ret = 0;
+out:
+	clear_compound_head(page);
+	return ret;
 }
 
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
@@ -1304,10 +1306,8 @@ static inline int check_new_page(struct page *page)
 		bad_reason = "PAGE_FLAGS_CHECK_AT_PREP flag set";
 		bad_flags = PAGE_FLAGS_CHECK_AT_PREP;
 	}
-#ifdef CONFIG_MEMCG
 	if (unlikely(page->mem_cgroup))
-		bad_reason = "page still charged to cgroup";
-#endif
+		bad_reason = "non-NULL mem_cgroup";
 	if (unlikely(bad_reason)) {
 		bad_page(page, bad_reason, bad_flags);
 		return 1;
diff --git a/mm/swap.c b/mm/swap.c
index a3a0a2f1f7c3..faa9e1687dea 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -200,7 +200,7 @@ out_put_single:
 				__put_single_page(page);
 			return;
 		}
-		VM_BUG_ON_PAGE(page_head != page->first_page, page);
+		VM_BUG_ON_PAGE(page_head != compound_head(page), page);
 		/*
 		 * We can release the refcount taken by
 		 * get_page_unless_zero() now that
@@ -261,7 +261,7 @@ static void put_compound_page(struct page *page)
 	 *  Case 3 is possible, as we may race with
 	 *  __split_huge_page_refcount tearing down a THP page.
 	 */
-	page_head = compound_head_by_tail(page);
+	page_head = compound_head(page);
 	if (!__compound_tail_refcounted(page_head))
 		put_unrefcounted_compound_page(page_head, page);
 	else
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
