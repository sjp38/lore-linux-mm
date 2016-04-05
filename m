Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A3D47828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:48:02 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 184so18866910pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:48:02 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id v71si5338345pfi.22.2016.04.05.14.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:48:01 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id bx7so2377146pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:48:01 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:47:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 20/31] huge tmpfs: mem_cgroup shmem_hugepages accounting
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051446131.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

Keep track of all hugepages, not just those mapped.

This has gone through several anguished iterations, memcg stats being
harder to protect against mem_cgroup_move_account() than you might
expect.  Abandon the pretence that miscellaneous stats can all be
protected by the same lock_page_memcg(),unlock_page_memcg() scheme:
add mem_cgroup_update_page_stat_treelocked(), using mapping->tree_lock
for safe updates of MEM_CGROUP_STAT_SHMEM_HUGEPAGES (where tree_lock
is already held, but nests inside not outside of memcg->move_lock).

Nowadays, when mem_cgroup_move_account() takes page lock, and is only
called when immigrating pages found in page tables, it almost seems as
if this reliance on tree_lock is unnecessary.  But consider the case
when the team head is pte-mapped, and being migrated to a new memcg,
racing with the last page of the team being instantiated: the page
lock is held on the page being instantiated, not on the team head,
so we do still need the tree_lock to serialize them.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/cgroup-v1/memory.txt  |    2 +
 Documentation/filesystems/tmpfs.txt |    8 ++++
 include/linux/memcontrol.h          |   10 +++++
 include/linux/pageteam.h            |    3 +
 mm/memcontrol.c                     |   47 ++++++++++++++++++++++----
 mm/shmem.c                          |    4 ++
 6 files changed, 66 insertions(+), 8 deletions(-)

--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -487,6 +487,8 @@ rss		- # of bytes of anonymous and swap
 		transparent hugepages).
 rss_huge	- # of bytes of anonymous transparent hugepages.
 mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
+shmem_hugepages - # of bytes of tmpfs huge pages completed (subset of cache)
+shmem_pmdmapped - # of bytes of tmpfs huge mapped huge (subset of mapped_file)
 pgpgin		- # of charging events to the memory cgroup. The charging
 		event happens each time a page is accounted as either mapped
 		anon page(RSS) or cache page(Page Cache) to the cgroup.
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -200,6 +200,14 @@ nr_shmem_hugepages 13         tmpfs huge
 nr_shmem_pmdmapped 6          tmpfs hugepages with huge mappings in userspace
 nr_shmem_freeholes 167861     pages reserved for team but available to shrinker
 
+/sys/fs/cgroup/memory/<cgroup>/memory.stat shows:
+
+shmem_hugepages 27262976   bytes tmpfs hugepage completed (subset of cache)
+shmem_pmdmapped 12582912   bytes tmpfs huge mapped huge (subset of mapped_file)
+
+Note: the individual pages of a huge team might be charged to different
+memcgs, but these counts assume that they are all charged to the same as head.
+
 Author:
    Christoph Rohland <cr@sap.com>, 1.12.01
 Updated:
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -50,6 +50,8 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
+	/* # of pages charged as non-disbanded huge teams */
+	MEM_CGROUP_STAT_SHMEM_HUGEPAGES,
 	/* # of pages charged as hugely mapped teams */
 	MEM_CGROUP_STAT_SHMEM_PMDMAPPED,
 	MEM_CGROUP_STAT_NSTATS,
@@ -491,6 +493,9 @@ static inline void mem_cgroup_update_pag
 		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
 }
 
+void mem_cgroup_update_page_stat_treelocked(struct page *page,
+				enum mem_cgroup_stat_index idx, int val);
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
@@ -706,6 +711,11 @@ static inline void mem_cgroup_update_pag
 				enum mem_cgroup_stat_index idx, int val)
 {
 }
+
+static inline void mem_cgroup_update_page_stat_treelocked(struct page *page,
+				enum mem_cgroup_stat_index idx, int val)
+{
+}
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -139,12 +139,13 @@ static inline bool dec_team_pmd_mapped(s
  * needs to maintain memcg's huge tmpfs stats correctly.
  */
 static inline void count_team_pmd_mapped(struct page *head, int *file_mapped,
-					 bool *pmd_mapped)
+					 bool *pmd_mapped, bool *team_complete)
 {
 	long team_usage;
 
 	*file_mapped = 1;
 	team_usage = atomic_long_read(&head->team_usage);
+	*team_complete = team_usage >= TEAM_COMPLETE;
 	*pmd_mapped = team_usage >= TEAM_PMD_MAPPED;
 	if (*pmd_mapped)
 		*file_mapped = HPAGE_PMD_NR - team_pte_count(team_usage);
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -107,6 +107,7 @@ static const char * const mem_cgroup_sta
 	"dirty",
 	"writeback",
 	"swap",
+	"shmem_hugepages",
 	"shmem_pmdmapped",
 };
 
@@ -4431,6 +4432,17 @@ static struct page *mc_handle_file_pte(s
 	return page;
 }
 
+void mem_cgroup_update_page_stat_treelocked(struct page *page,
+				enum mem_cgroup_stat_index idx, int val)
+{
+	/* Update this VM_BUG_ON if other cases are added */
+	VM_BUG_ON(idx != MEM_CGROUP_STAT_SHMEM_HUGEPAGES);
+	lockdep_assert_held(&page->mapping->tree_lock);
+
+	if (page->mem_cgroup)
+		__this_cpu_add(page->mem_cgroup->stat->count[idx], val);
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -4448,6 +4460,7 @@ static int mem_cgroup_move_account(struc
 				   struct mem_cgroup *from,
 				   struct mem_cgroup *to)
 {
+	spinlock_t *tree_lock = NULL;
 	unsigned long flags;
 	int nr_pages = compound ? hpage_nr_pages(page) : 1;
 	int file_mapped = 1;
@@ -4487,9 +4500,9 @@ static int mem_cgroup_move_account(struc
 	 * So mapping should be stable for dirty pages.
 	 */
 	if (!anon && PageDirty(page)) {
-		struct address_space *mapping = page_mapping(page);
+		struct address_space *mapping = page->mapping;
 
-		if (mapping_cap_account_dirty(mapping)) {
+		if (mapping && mapping_cap_account_dirty(mapping)) {
 			__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_DIRTY],
 				       nr_pages);
 			__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_DIRTY],
@@ -4498,10 +4511,28 @@ static int mem_cgroup_move_account(struc
 	}
 
 	if (!anon && PageTeam(page)) {
-		if (page == team_head(page)) {
-			bool pmd_mapped;
+		struct address_space *mapping = page->mapping;
 
-			count_team_pmd_mapped(page, &file_mapped, &pmd_mapped);
+		if (mapping && page == team_head(page)) {
+			bool pmd_mapped, team_complete;
+			/*
+			 * We avoided taking mapping->tree_lock unnecessarily.
+			 * Is it safe to take mapping->tree_lock below?  Was it
+			 * safe to peek at PageTeam above, without tree_lock?
+			 * Yes, this is a team head, just now taken from its
+			 * lru: PageTeam must already be set. And we took
+			 * page lock above, so page->mapping is stable.
+			 */
+			tree_lock = &mapping->tree_lock;
+			spin_lock(tree_lock);
+			count_team_pmd_mapped(page, &file_mapped, &pmd_mapped,
+					      &team_complete);
+			if (team_complete) {
+				__this_cpu_sub(from->stat->count[
+				MEM_CGROUP_STAT_SHMEM_HUGEPAGES], HPAGE_PMD_NR);
+				__this_cpu_add(to->stat->count[
+				MEM_CGROUP_STAT_SHMEM_HUGEPAGES], HPAGE_PMD_NR);
+			}
 			if (pmd_mapped) {
 				__this_cpu_sub(from->stat->count[
 				MEM_CGROUP_STAT_SHMEM_PMDMAPPED], HPAGE_PMD_NR);
@@ -4522,10 +4553,12 @@ static int mem_cgroup_move_account(struc
 	 * It is safe to change page->mem_cgroup here because the page
 	 * is referenced, charged, and isolated - we can't race with
 	 * uncharging, charging, migration, or LRU putback.
+	 * Caller should have done css_get.
 	 */
-
-	/* caller should have done css_get */
 	page->mem_cgroup = to;
+
+	if (tree_lock)
+		spin_unlock(tree_lock);
 	spin_unlock_irqrestore(&from->move_lock, flags);
 
 	ret = 0;
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -413,6 +413,8 @@ static void shmem_added_to_hugeteam(stru
 				&head->team_usage) >= TEAM_COMPLETE) {
 			shmem_clear_tag_hugehole(mapping, head->index);
 			__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
+			mem_cgroup_update_page_stat_treelocked(head,
+				MEM_CGROUP_STAT_SHMEM_HUGEPAGES, HPAGE_PMD_NR);
 		}
 		__dec_zone_state(zone, NR_SHMEM_FREEHOLES);
 	}
@@ -523,6 +525,8 @@ again2:
 		if (nr >= HPAGE_PMD_NR) {
 			ClearPageChecked(head);
 			__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
+			mem_cgroup_update_page_stat_treelocked(head,
+				MEM_CGROUP_STAT_SHMEM_HUGEPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(nr != HPAGE_PMD_NR);
 		} else if (nr) {
 			shmem_clear_tag_hugehole(mapping, head->index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
