Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3598D003D
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:27:16 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] memcg: change page_cgroup_zoneinfo signature
Date: Thu,  3 Feb 2011 15:26:03 +0100
Message-Id: <1296743166-9412-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Instead of passing a whole struct page_cgroup to this function, let it
take only what it really needs from it: the struct mem_cgroup and the
page.

This has the advantage that reading pc->mem_cgroup is now done at the
same place where the ordering rules for this pointer are enforced and
explained.

It is also in preparation for removing the pc->page backpointer.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_cgroup.h |   10 ----------
 mm/memcontrol.c             |   17 ++++++++---------
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 6d6cb7a..363bbc8 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -85,16 +85,6 @@ SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)
 
-static inline int page_cgroup_nid(struct page_cgroup *pc)
-{
-	return page_to_nid(pc->page);
-}
-
-static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
-{
-	return page_zonenum(pc->page);
-}
-
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	/*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 85b4b5a..77a3f87 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -364,11 +364,10 @@ struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
 }
 
 static struct mem_cgroup_per_zone *
-page_cgroup_zoneinfo(struct page_cgroup *pc)
+page_cgroup_zoneinfo(struct mem_cgroup *mem, struct page *page)
 {
-	struct mem_cgroup *mem = pc->mem_cgroup;
-	int nid = page_cgroup_nid(pc);
-	int zid = page_cgroup_zid(pc);
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
 
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
@@ -800,7 +799,7 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
 	 * removed from global LRU.
 	 */
-	mz = page_cgroup_zoneinfo(pc);
+	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
@@ -830,7 +829,7 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	smp_rmb();
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
-	mz = page_cgroup_zoneinfo(pc);
+	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	list_move(&pc->lru, &mz->lists[lru]);
 }
 
@@ -847,7 +846,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 		return;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc);
+	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
@@ -1017,7 +1016,7 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 		return NULL;
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc);
+	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	if (!mz)
 		return NULL;
 
@@ -2166,7 +2165,7 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
 		 * We hold lru_lock, then, reduce counter directly.
 		 */
 		lru = page_lru(head);
-		mz = page_cgroup_zoneinfo(head_pc);
+		mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
 		MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 	}
 	tail_pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
