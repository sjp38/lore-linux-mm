Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ECDDF8D003B
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 09:44:11 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id 13so1895210iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 06:44:10 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v6 2/3] memcg: move memcg reclaimable page into tail of inactive list
Date: Sun, 20 Feb 2011 23:43:37 +0900
Message-Id: <c76a1645aac12c3b8ffe2cc5738033f5a6da8d32.1298212517.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298212517.git.minchan.kim@gmail.com>
References: <cover.1298212517.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298212517.git.minchan.kim@gmail.com>
References: <cover.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

The rotate_reclaimable_page function moves just written out
pages, which the VM wanted to reclaim, to the end of the
inactive list.  That way the VM will find those pages first
next time it needs to free memory.
This patch apply the rule in memcg.
It can help to prevent unnecessary working page eviction of memcg.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
Changelog since v5:
 - change page_lru_base_type to page_lru - suggested by Kame

Changelog since v4:
 - add acked-by and reviewed-by
 - change description - suggested by Rik

 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   27 +++++++++++++++++++++++++++
 mm/swap.c                  |    3 ++-
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3da48ae..5a5ce70 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -62,6 +62,7 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
 extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
+extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
 extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
 extern void mem_cgroup_del_lru(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page,
@@ -215,6 +216,11 @@ static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
 	return ;
 }
 
+static inline inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
+{
+	return ;
+}
+
 static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
 {
 	return ;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 686f1ce..8a97571 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
 	mem_cgroup_del_lru_list(page, page_lru(page));
 }
 
+/*
+ * Writeback is about to end against a page which has been marked for immediate
+ * reclaim.  If it still appears to be reclaimable, move it to the tail of the
+ * inactive list.
+ */
+void mem_cgroup_rotate_reclaimable_page(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+	enum lru_list lru = page_lru(page);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(page);
+	/*
+	 * Used bit is set without atomic ops but after smp_wmb().
+	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
+	 */
+	smp_rmb();
+	/* unused or root page is not rotated. */
+	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+		return;
+	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
+	list_move_tail(&pc->lru, &mz->lists[lru]);
+}
+
 void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
diff --git a/mm/swap.c b/mm/swap.c
index 4aea806..1b9e4eb 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -200,8 +200,9 @@ static void pagevec_move_tail(struct pagevec *pvec)
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_lru_base_type(page);
+			enum lru_list lru = page_lru_base_type(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
+			mem_cgroup_rotate_reclaimable_page(page);
 			pgmoved++;
 		}
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
