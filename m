Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E5F8E9003CD
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:14:09 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so49521876pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:14:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q4si6730109pap.168.2015.09.03.08.13.55
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:13:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 16/36] mm, thp: remove compound_lock
Date: Thu,  3 Sep 2015 18:13:02 +0300
Message-Id: <1441293202-137314-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to use migration entries to stabilize page counts. It means
we don't need compound_lock() for that.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/mm.h         | 35 -----------------------------------
 include/linux/page-flags.h | 12 +-----------
 mm/debug.c                 |  3 ---
 mm/memcontrol.c            | 11 +++--------
 4 files changed, 4 insertions(+), 57 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c3a1fd44cd0a..9fc4367eb591 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -384,41 +384,6 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 
 extern void kvfree(const void *addr);
 
-static inline void compound_lock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
-	bit_spin_lock(PG_compound_lock, &page->flags);
-#endif
-}
-
-static inline void compound_unlock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
-	bit_spin_unlock(PG_compound_lock, &page->flags);
-#endif
-}
-
-static inline unsigned long compound_lock_irqsave(struct page *page)
-{
-	unsigned long uninitialized_var(flags);
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	local_irq_save(flags);
-	compound_lock(page);
-#endif
-	return flags;
-}
-
-static inline void compound_unlock_irqrestore(struct page *page,
-					      unsigned long flags)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	compound_unlock(page);
-	local_irq_restore(flags);
-#endif
-}
-
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index ab1a0e9c5087..125f8cbf2c9a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -101,9 +101,6 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	PG_compound_lock,
-#endif
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
@@ -611,12 +608,6 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 #define __PG_MLOCKED		0
 #endif
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
-#else
-#define __PG_COMPOUND_LOCK		0
-#endif
-
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
@@ -626,8 +617,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | \
-	 __PG_COMPOUND_LOCK)
+	 1 << PG_unevictable | __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/mm/debug.c b/mm/debug.c
index 668aa35191ca..afe95cf61456 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -40,9 +40,6 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_MEMORY_FAILURE
 	{1UL << PG_hwpoison,		"hwpoison"	},
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	{1UL << PG_compound_lock,	"compound_lock"	},
-#endif
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	{1UL << PG_young,		"young"		},
 	{1UL << PG_idle,		"idle"		},
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8d7392fac80e..f0efdf89b495 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2463,9 +2463,7 @@ struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr)
 
 /*
  * Because tail pages are not marked as "used", set it. We're under
- * zone->lru_lock, 'splitting on pmd' and compound_lock.
- * charge/uncharge will be never happen and move_account() is done under
- * compound_lock(), so we don't have to take care of races.
+ * zone->lru_lock and migration entries setup in all page mappings.
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
@@ -4548,9 +4546,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  *
- * The caller must confirm following.
- * - page is not on LRU (isolate_page() is useful.)
- * - compound_lock is held when nr_pages > 1
+ * The caller must make sure the page is not on LRU (isolate_page() is useful.)
  *
  * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
  * from old cgroup.
@@ -4893,8 +4889,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	struct page *page;
 
 	/*
-	 * We don't take compound_lock() here but no race with splitting thp
-	 * happens because:
+	 * No race with splitting thp happens because:
 	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
 	 *    under splitting, which means there's no concurrent thp split,
 	 *  - if another thread runs into split_huge_page() just after we
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
