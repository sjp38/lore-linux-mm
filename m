Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADDA56B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 07:48:27 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y15so4009257wrc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 04:48:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u83sor225462wmu.91.2017.12.07.04.48.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 04:48:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm: unclutter THP migration
Date: Thu,  7 Dec 2017 13:48:15 +0100
Message-Id: <20171207124815.12075-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this is a follow up for [2]. I find this approach much less hackish and
easier to maintain as well. It also fixes few bugs. I didn't really go
deeply into each migration path and evaluate the user visible bugs but
at least the explicit migration is suboptimal to say the least

# A simple 100M mmap with MADV_HUGEPAGE and explicit migrate from node 0
# to node 1 with results displayed "After pause"
root@test1:~# numactl -m 0 ./map_thp 
7f749d0aa000 bind:0 anon=25600 dirty=25600 N0=25600 kernelpagesize_kB=4
7f749d0aa000-7f74a34aa000 rw-p 00000000 00:00 0 
Size:             102400 kB
Rss:              102400 kB
AnonHugePages:    100352 kB

After pause
7f749d0aa000 bind:0 anon=25600 dirty=25600 N0=18602 N1=6998 kernelpagesize_kB=4
7f749d0aa000-7f74a34aa000 rw-p 00000000 00:00 0 
Size:             102400 kB
Rss:              102400 kB
AnonHugePages:    100352 kB

root@test1:~# migratepages $(pgrep map_thp) 0 1
migrate_pages: Cannot allocate memory

While the migration succeeds with the patch applied even though some THP
had to be split and migrated page by page.

I believe that thp_migration_supported shouldn't be spread outside
of the migration code but I've left few assertion in place. Maybe
they should go as well. I haven't spent too much time on those. My
testing was quite limited and this might still blow up so I would really
appreciate a careful review.

Thanks!

[2] http://lkml.kernel.org/r/20171122130121.ujp6qppa7nhahazh@dhcp22.suse.cz

 include/linux/migrate.h |  6 ++++--
 mm/huge_memory.c        |  6 ++++++
 mm/memory_hotplug.c     |  2 +-
 mm/mempolicy.c          | 29 ++---------------------------
 mm/migrate.c            | 31 ++++++++++++++++++++-----------
 5 files changed, 33 insertions(+), 41 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2246cf670ba..ec9503e5f2c2 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -43,9 +43,11 @@ static inline struct page *new_page_nodemask(struct page *page,
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
 
-	if (thp_migration_supported() && PageTransHuge(page)) {
-		order = HPAGE_PMD_ORDER;
+	if (PageTransHuge(page)) {
+		if (!thp_migration_supported())
+			return NULL;
 		gfp_mask |= GFP_TRANSHUGE;
+		order = HPAGE_PMD_ORDER;
 	}
 
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7544ce4ef4dc..304f39b9aa5c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2425,6 +2425,12 @@ static void __split_huge_page_tail(struct page *head, int tail,
 
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
index d0856ab2f28d..ad0a84aa7b53 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1391,7 +1391,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			if (isolate_huge_page(page, &source))
 				move_pages -= 1 << compound_order(head);
 			continue;
-		} else if (thp_migration_supported() && PageTransHuge(page))
+		} else if (PageTransHuge(page))
 			pfn = page_to_pfn(compound_head(page))
 				+ hpage_nr_pages(page) - 1;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f604b22ebb65..49ecbb50b5f0 100644
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
@@ -947,7 +922,7 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else if (thp_migration_supported() && PageTransHuge(page)) {
+	else if (PageTransHuge(page)) {
 		struct page *thp;
 
 		thp = alloc_pages_node(node,
@@ -1123,7 +1098,7 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	if (PageHuge(page)) {
 		BUG_ON(!vma);
 		return alloc_huge_page_noerr(vma, address, 1);
-	} else if (thp_migration_supported() && PageTransHuge(page)) {
+	} else if (PageTransHuge(page)) {
 		struct page *thp;
 
 		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
diff --git a/mm/migrate.c b/mm/migrate.c
index 4d0be47a322a..ed21642a5c1d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1139,6 +1139,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	int *result = NULL;
 	struct page *newpage;
 
+	if (!thp_migration_supported() && PageTransHuge(page))
+		return -ENOMEM;
+
 	newpage = get_new_page(page, private, &result);
 	if (!newpage)
 		return -ENOMEM;
@@ -1160,14 +1163,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
@@ -1395,6 +1390,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
+retry:
 			cond_resched();
 
 			if (PageHuge(page))
@@ -1408,6 +1404,21 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 
 			switch(rc) {
 			case -ENOMEM:
+				/*
+				 * THP migration might be unsupported or the
+				 * allocation could've failed so we should
+				 * retry on the same page with the THP split
+				 * to base pages.
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
@@ -1470,7 +1481,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 					pm->node);
-	else if (thp_migration_supported() && PageTransHuge(p)) {
+	else if (PageTransHuge(p)) {
 		struct page *thp;
 
 		thp = alloc_pages_node(pm->node,
@@ -1517,8 +1528,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 
 		/* FOLL_DUMP to ignore special (like zero) pages */
 		follflags = FOLL_GET | FOLL_DUMP;
-		if (!thp_migration_supported())
-			follflags |= FOLL_SPLIT;
 		page = follow_page(vma, pp->addr, follflags);
 
 		err = PTR_ERR(page);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
