Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 80B8C6B026F
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:21 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 06/11] mm: memcg: remove optimization of keeping the root_mem_cgroup LRU lists empty
Date: Mon, 12 Sep 2011 12:57:23 +0200
Message-Id: <1315825048-3437-7-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

root_mem_cgroup, lacking a configurable limit, was never subject to
limit reclaim, so the pages charged to it could be kept off its LRU
lists.  They would be found on the global per-zone LRU lists upon
physical memory pressure and it made sense to avoid uselessly linking
them to both lists.

The global per-zone LRU lists are about to go away on memcg-enabled
kernels, with all pages being exclusively linked to their respective
per-memcg LRU lists.  As a result, pages of the root_mem_cgroup must
also be linked to its LRU lists again.

The overhead is temporary until the double-LRU scheme is going away
completely.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 413e1f8..518f640 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -956,8 +956,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
 }
@@ -982,13 +980,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
 		return;
 
 	pc = lookup_page_cgroup(page);
-	/* unused or root page is not rotated. */
+	/* unused page is not rotated. */
 	if (!PageCgroupUsed(pc))
 		return;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	list_move_tail(&pc->lru, &mz->lists[lru]);
 }
@@ -1002,13 +998,11 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 		return;
 
 	pc = lookup_page_cgroup(page);
-	/* unused or root page is not rotated. */
+	/* unused page is not rotated. */
 	if (!PageCgroupUsed(pc))
 		return;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	list_move(&pc->lru, &mz->lists[lru]);
 }
@@ -1040,8 +1034,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
