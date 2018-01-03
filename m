Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5E16B0304
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:26:15 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x1so526943plb.2
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:26:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m16sor94243pgn.249.2018.01.03.00.26.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 00:26:13 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm: unclutter THP migration
Date: Wed,  3 Jan 2018 09:25:55 +0100
Message-Id: <20180103082555.14592-4-mhocko@kernel.org>
In-Reply-To: <20180103082555.14592-1-mhocko@kernel.org>
References: <20180103082555.14592-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

THP migration is hacked into the generic migration with rather
surprising semantic. The migration allocation callback is supposed to
check whether the THP can be migrated at once and if that is not the
case then it allocates a simple page to migrate. unmap_and_move then
fixes that up by spliting the THP into small pages while moving the
head page to the newly allocated order-0 page. Remaning pages are moved
to the LRU list by split_huge_page. The same happens if the THP
allocation fails. This is really ugly and error prone [1].

I also believe that split_huge_page to the LRU lists is inherently
wrong because all tail pages are not migrated. Some callers will just
work around that by retrying (e.g. memory hotplug). There are other
pfn walkers which are simply broken though. e.g. madvise_inject_error
will migrate head and then advances next pfn by the huge page size.
do_move_page_to_node_array, queue_pages_range (migrate_pages, mbind),
will simply split the THP before migration if the THP migration is not
supported then falls back to single page migration but it doesn't handle
tail pages if the THP migration path is not able to allocate a fresh
THP so we end up with ENOMEM and fail the whole migration which is
a questionable behavior. Page compaction doesn't try to migrate large
pages so it should be immune.

This patch tries to unclutter the situation by moving the special THP
handling up to the migrate_pages layer where it actually belongs. We
simply split the THP page into the existing list if unmap_and_move fails
with ENOMEM and retry. So we will _always_ migrate all THP subpages and
specific migrate_pages users do not have to deal with this case in a
special way.

[1] http://lkml.kernel.org/r/20171121021855.50525-1-zi.yan@sent.com

- document changed ordering of split THP page in migrate_pages as per
  Zi Yan

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/migrate.h |  4 ++--
 mm/huge_memory.c        |  6 ++++++
 mm/memory_hotplug.c     |  2 +-
 mm/mempolicy.c          | 31 +++----------------------------
 mm/migrate.c            | 34 ++++++++++++++++++++++++----------
 5 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e5d99ade2319..0c6fe904bc97 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -42,9 +42,9 @@ static inline struct page *new_page_nodemask(struct page *page,
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
 
-	if (thp_migration_supported() && PageTransHuge(page)) {
-		order = HPAGE_PMD_ORDER;
+	if (PageTransHuge(page)) {
 		gfp_mask |= GFP_TRANSHUGE;
+		order = HPAGE_PMD_ORDER;
 	}
 
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 93d729fc94a4..8c296f19ff6e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2417,6 +2417,12 @@ static void __split_huge_page_tail(struct page *head, int tail,
 
 	page_tail->index = head->index + tail;
 	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
+
+	/*
+	 * always add to the tail because some iterators expect new
+	 * pages to show after the currently processed elements - e.g.
+	 * migrate_pages
+	 */
 	lru_add_page_tail(head, page_tail, lruvec, list);
 }
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9a2381469172..25060b0184e9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1387,7 +1387,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
-		} else if (thp_migration_supported() && PageTransHuge(page))
+		} else if (PageTransHuge(page))
 			pfn = page_to_pfn(compound_head(page))
 				+ hpage_nr_pages(page) - 1;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4d849d3098e5..b6f4fcf9df64 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -446,15 +446,6 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
 		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
 		goto out;
 	}
-	if (!thp_migration_supported()) {
-		get_page(page);
-		spin_unlock(ptl);
-		lock_page(page);
-		ret = split_huge_page(page);
-		unlock_page(page);
-		put_page(page);
-		goto out;
-	}
 	if (!queue_pages_required(page, qp)) {
 		ret = 1;
 		goto unlock;
@@ -495,7 +486,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
-retry:
+
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		if (!pte_present(*pte))
@@ -511,22 +502,6 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		if (!queue_pages_required(page, qp))
 			continue;
-		if (PageTransCompound(page) && !thp_migration_supported()) {
-			get_page(page);
-			pte_unmap_unlock(pte, ptl);
-			lock_page(page);
-			ret = split_huge_page(page);
-			unlock_page(page);
-			put_page(page);
-			/* Failed to split -- skip. */
-			if (ret) {
-				pte = pte_offset_map_lock(walk->mm, pmd,
-						addr, &ptl);
-				continue;
-			}
-			goto retry;
-		}
-
 		migrate_page_add(page, qp->pagelist, flags);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
@@ -948,7 +923,7 @@ struct page *alloc_new_node_page(struct page *page, unsigned long node)
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else if (thp_migration_supported() && PageTransHuge(page)) {
+	else if (PageTransHuge(page)) {
 		struct page *thp;
 
 		thp = alloc_pages_node(node,
@@ -1124,7 +1099,7 @@ static struct page *new_page(struct page *page, unsigned long start)
 	if (PageHuge(page)) {
 		BUG_ON(!vma);
 		return alloc_huge_page_noerr(vma, address, 1);
-	} else if (thp_migration_supported() && PageTransHuge(page)) {
+	} else if (PageTransHuge(page)) {
 		struct page *thp;
 
 		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
diff --git a/mm/migrate.c b/mm/migrate.c
index aba3759a2e27..feba2e63e165 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1138,6 +1138,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	int rc = MIGRATEPAGE_SUCCESS;
 	struct page *newpage;
 
+	if (!thp_migration_supported() && PageTransHuge(page))
+		return -ENOMEM;
+
 	newpage = get_new_page(page, private);
 	if (!newpage)
 		return -ENOMEM;
@@ -1159,14 +1162,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
-		lock_page(page);
-		rc = split_huge_page(page);
-		unlock_page(page);
-		if (rc)
-			goto out;
-	}
-
 	rc = __unmap_and_move(page, newpage, force, mode);
 	if (rc == MIGRATEPAGE_SUCCESS)
 		set_page_owner_migrate_reason(newpage, reason);
@@ -1381,6 +1376,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
+retry:
 			cond_resched();
 
 			if (PageHuge(page))
@@ -1394,6 +1390,26 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 
 			switch(rc) {
 			case -ENOMEM:
+				/*
+				 * THP migration might be unsupported or the
+				 * allocation could've failed so we should
+				 * retry on the same page with the THP split
+				 * to base pages.
+				 *
+				 * Head page is retried immediately and tail
+				 * pages are added to the tail of the list so
+				 * we encounter them after the rest of the list
+				 * is processed.
+				 */
+				if (PageTransHuge(page)) {
+					lock_page(page);
+					rc = split_huge_page_to_list(page, from);
+					unlock_page(page);
+					if (!rc) {
+						list_safe_reset_next(page, page2, lru);
+						goto retry;
+					}
+				}
 				nr_failed++;
 				goto out;
 			case -EAGAIN:
@@ -1480,8 +1496,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 
 	/* FOLL_DUMP to ignore special (like zero) pages */
 	follflags = FOLL_GET | FOLL_DUMP;
-	if (!thp_migration_supported())
-		follflags |= FOLL_SPLIT;
 	page = follow_page(vma, addr, follflags);
 
 	err = PTR_ERR(page);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
