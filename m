Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B8B136B0038
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 02:37:31 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so2221277pad.30
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:37:31 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id my2si3015002pab.281.2014.03.13.23.37.28
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 23:37:30 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/6] mm: support madvise(MADV_FREE)
Date: Fri, 14 Mar 2014 15:37:47 +0900
Message-Id: <1394779070-8545-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Linux doesn't have an ability to free pages lazy while other OS
already have been supported that named by madvise(MADV_FREE).

The gain is clear that kernel can evict freed pages rather than
swapping out or OOM if memory pressure happens.

Without memory pressure, freed pages would be reused by userspace
without another additional overhead(ex, page fault + + page allocation
+ page zeroing).

Firstly, heavy users would be general allocators(ex, jemalloc,
I hope ptmalloc support it) and jemalloc already have supported
the feature for other OS(ex, FreeBSD)

At the moment, this patch would break build other ARCHs which have
own TLB flush scheme other than that x86 but if there is no objection
in this direction, I will add patches for handling other ARCHs
in next iteration.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/asm-generic/tlb.h              |  9 ++++++++
 include/linux/mm.h                     | 35 ++++++++++++++++++++++++++++++-
 include/linux/rmap.h                   |  1 +
 include/linux/swap.h                   | 15 ++++++++++++++
 include/uapi/asm-generic/mman-common.h |  1 +
 mm/madvise.c                           | 17 +++++++++++++--
 mm/memory.c                            | 12 ++++++++++-
 mm/rmap.c                              | 21 +++++++++++++++++--
 mm/swap_state.c                        | 38 +++++++++++++++++++++++++++++++++-
 mm/vmscan.c                            | 22 +++++++++++++++++++-
 10 files changed, 163 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 5672d7ea1fa0..b82ee729a065 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -116,8 +116,17 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
+int __tlb_madvfree_page(struct mmu_gather *tlb, struct page *page);
 int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
 
+static inline void tlb_madvfree_page(struct mmu_gather *tlb, struct page *page)
+{
+	/* Prevent page free */
+	get_page(page);
+	if (!__tlb_remove_page(tlb, MarkLazyFree(page)))
+		tlb_flush_mmu(tlb);
+}
+
 /* tlb_remove_page
  *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
  *	required.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414c7bef..9b048cabce27 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -933,10 +933,16 @@ void page_address_init(void);
  * Please note that, confusingly, "page_mapping" refers to the inode
  * address_space which maps the page from disk; whereas "page_mapped"
  * refers to user virtual address space into which the page is mapped.
+ *
+ * PAGE_MAPPING_LZFREE bit is set along with PAGE_MAPPING_ANON bit
+ * and then page->mapping points to an anon_vma. This flag is used
+ * for lazy freeing the page instead of swap.
  */
 #define PAGE_MAPPING_ANON	1
 #define PAGE_MAPPING_KSM	2
-#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
+#define PAGE_MAPPING_LZFREE	4
+#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM | \
+				 PAGE_MAPPING_LZFREE)
 
 extern struct address_space *page_mapping(struct page *page);
 
@@ -962,6 +968,32 @@ static inline int PageAnon(struct page *page)
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
+static inline void SetPageLazyFree(struct page *page)
+{
+	BUG_ON(!PageAnon(page));
+	BUG_ON(!PageLocked(page));
+
+	page->mapping = (void *)((unsigned long)page->mapping |
+			PAGE_MAPPING_LZFREE);
+}
+
+static inline void ClearPageLazyFree(struct page *page)
+{
+	BUG_ON(!PageAnon(page));
+	BUG_ON(!PageLocked(page));
+
+	page->mapping = (void *)((unsigned long)page->mapping &
+				~PAGE_MAPPING_LZFREE);
+}
+
+static inline int PageLazyFree(struct page *page)
+{
+	if (((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
+			(PAGE_MAPPING_ANON|PAGE_MAPPING_LZFREE))
+		return 1;
+	return 0;
+}
+
 /*
  * Return the pagecache index of the passed page.  Regular pagecache pages
  * use ->index whereas swapcache pages use ->private
@@ -1054,6 +1086,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
+	int lazy_free;				/* do lazy free */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1da693d51255..19e74aebb3d5 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -75,6 +75,7 @@ enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
 	TTU_MIGRATION = 1,		/* migration mode */
 	TTU_MUNLOCK = 2,		/* munlock mode */
+	TTU_LAZYFREE  = 3,		/* free lazyfree page */
 	TTU_ACTION_MASK = 0xff,
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6c219f..223909c14703 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -13,6 +13,21 @@
 #include <linux/page-flags.h>
 #include <asm/page.h>
 
+static inline struct page *MarkLazyFree(struct page *p)
+{
+	return (struct page *)((unsigned long)p | 0x1UL);
+}
+
+static inline struct page *ClearLazyFree(struct page *p)
+{
+	return (struct page *)((unsigned long)p & ~0x1UL);
+}
+
+static inline bool LazyFree(struct page *p)
+{
+	return ((unsigned long)p & 0x1UL) ? true : false;
+}
+
 struct notifier_block;
 
 struct bio;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529a94f9..7e257e49be2e 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -34,6 +34,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_FREE	5		/* do lazy free */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_REMOVE	9		/* remove these pages & resources */
diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb96b323..2e904289a2bb 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -31,6 +31,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -272,7 +273,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
  */
 static long madvise_dontneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     int behavior)
 {
 	*prev = vma;
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
@@ -284,8 +286,17 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			.last_index = ULONG_MAX,
 		};
 		zap_page_range(vma, start, end - start, &details);
+	} else if (behavior == MADV_FREE) {
+		struct zap_details details = {
+			.lazy_free = 1,
+		};
+
+		if (vma->vm_file)
+			return -EINVAL;
+		zap_page_range(vma, start, end - start, &details);
 	} else
 		zap_page_range(vma, start, end - start, NULL);
+
 	return 0;
 }
 
@@ -384,8 +395,9 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_FREE:
 	case MADV_DONTNEED:
-		return madvise_dontneed(vma, prev, start, end);
+		return madvise_dontneed(vma, prev, start, end, behavior);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -403,6 +415,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_FREE:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa617bddb..f1f0dc13e8d1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1093,6 +1093,15 @@ again:
 
 			page = vm_normal_page(vma, addr, ptent);
 			if (unlikely(details) && page) {
+				if (details->lazy_free && PageAnon(page)) {
+					ptent = pte_mkold(ptent);
+					ptent = pte_mkclean(ptent);
+					set_pte_at(mm, addr, pte, ptent);
+					tlb_remove_tlb_entry(tlb, pte, addr);
+					tlb_madvfree_page(tlb, page);
+					continue;
+				}
+
 				/*
 				 * unmap_shared_mapping_pages() wants to
 				 * invalidate cache without truncating:
@@ -1276,7 +1285,8 @@ static void unmap_page_range(struct mmu_gather *tlb,
 	pgd_t *pgd;
 	unsigned long next;
 
-	if (details && !details->check_mapping && !details->nonlinear_vma)
+	if (details && !details->check_mapping && !details->nonlinear_vma &&
+		!details->lazy_free)
 		details = NULL;
 
 	BUG_ON(addr >= end);
diff --git a/mm/rmap.c b/mm/rmap.c
index 76069afa6b81..7712f39acfee 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -377,6 +377,15 @@ void __init anon_vma_init(void)
 	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain, SLAB_PANIC);
 }
 
+static inline bool is_anon_vma(unsigned long mapping)
+{
+	unsigned long anon_mapping = mapping & PAGE_MAPPING_FLAGS;
+	if ((anon_mapping != PAGE_MAPPING_ANON) &&
+	    (anon_mapping != (PAGE_MAPPING_ANON|PAGE_MAPPING_LZFREE)))
+		return false;
+	return true;
+}
+
 /*
  * Getting a lock on a stable anon_vma from a page off the LRU is tricky!
  *
@@ -407,7 +416,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 
 	rcu_read_lock();
 	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
-	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
+	if (!is_anon_vma(anon_mapping))
 		goto out;
 	if (!page_mapped(page))
 		goto out;
@@ -450,7 +459,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 
 	rcu_read_lock();
 	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
-	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
+	if (!is_anon_vma(anon_mapping))
 		goto out;
 	if (!page_mapped(page))
 		goto out;
@@ -1165,6 +1174,14 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
+	} else if ((flags & TTU_LAZYFREE) && PageLazyFree(page)) {
+		BUG_ON(!PageAnon(page));
+		if (unlikely(pte_dirty(pteval))) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+		dec_mm_counter(mm, MM_ANONPAGES);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e76ace30d436..0718ecd166dc 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/page_cgroup.h>
+#include <linux/ksm.h>
 
 #include <asm/pgtable.h>
 
@@ -256,8 +257,36 @@ void free_page_and_swap_cache(struct page *page)
 }
 
 /*
+ * move @page to inactive LRU's tail so that VM can discard it
+ * rather than swapping hot pages out when memory pressure happens.
+ */
+static bool move_lazyfree(struct page *page)
+{
+	if (!trylock_page(page))
+		return false;
+
+	if (PageKsm(page)) {
+		unlock_page(page);
+		return false;
+	}
+
+	if (PageSwapCache(page) &&
+			try_to_free_swap(page))
+		ClearPageDirty(page);
+
+	if (!PageLazyFree(page)) {
+		SetPageLazyFree(page);
+		deactivate_page(page);
+	}
+
+	unlock_page(page);
+	return true;
+}
+
+/*
  * Passed an array of pages, drop them all from swapcache and then release
  * them.  They are removed from the LRU and freed if this is their last use.
+ * If page passed are lazyfree, deactivate them intead of freeing.
  */
 void free_pages_and_swap_cache(struct page **pages, int nr)
 {
@@ -269,7 +298,14 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 		int i;
 
 		for (i = 0; i < todo; i++)
-			free_swap_cache(pagep[i]);
+			if (LazyFree(pagep[i])) {
+				pagep[i] = ClearLazyFree(pagep[i]);
+				/* If we failed, just free */
+				if (!move_lazyfree(pagep[i]))
+					free_swap_cache(pagep[i]);
+			} else {
+				free_swap_cache(pagep[i]);
+			}
 		release_pages(pagep, todo, 0);
 		pagep += todo;
 		nr -= todo;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..0ab38faebe98 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -817,6 +817,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		sc->nr_scanned++;
 
+		if (PageLazyFree(page)) {
+			switch (try_to_unmap(page, ttu_flags)) {
+			case SWAP_FAIL:
+				ClearPageLazyFree(page);
+				goto activate_locked;
+			case SWAP_AGAIN:
+				ClearPageLazyFree(page);
+				goto keep_locked;
+			case SWAP_SUCCESS:
+				ClearPageLazyFree(page);
+				if (unlikely(PageSwapCache(page)))
+					try_to_free_swap(page);
+				if (!page_freeze_refs(page, 1))
+					goto keep_locked;
+				unlock_page(page);
+				goto free_it;
+			}
+		}
+
 		if (unlikely(!page_evictable(page)))
 			goto cull_mlocked;
 
@@ -1481,7 +1500,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
+				TTU_UNMAP|TTU_LAZYFREE,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
 				&nr_writeback, &nr_immediate,
 				false);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
