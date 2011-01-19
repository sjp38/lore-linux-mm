Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36DE76B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 07:03:40 -0500 (EST)
Date: Wed, 19 Jan 2011 13:03:19 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch rfc] memcg: correctly order reading PCG_USED and
 pc->mem_cgroup
Message-ID: <20110119120319.GA2232@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The placement of the read-side barrier is confused: the writer first
sets pc->mem_cgroup, then PCG_USED.  The read-side barrier has to be
between testing PCG_USED and reading pc->mem_cgroup.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   27 +++++++++------------------
 1 files changed, 9 insertions(+), 18 deletions(-)

I am a bit dumbfounded as to why this has never had any impact.  I see
two scenarios where charging can race with LRU operations:

One is shmem pages on swapoff.  They are on the LRU when charged as
page cache, which could race with isolation/putback.  This seems
sufficiently rare.

The other case is a swap cache page being charged while somebody else
had it isolated.  mem_cgroup_lru_del_before_commit_swapcache() would
see the page isolated and skip it.  The commit then has to race with
putback, which could see PCG_USED but not pc->mem_cgroup, and crash
with a NULL pointer dereference.  This does sound a bit more likely.

Any idea?  Am I missing something?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5b562b3..db76ef7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -836,13 +836,12 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 		return;
 
 	pc = lookup_page_cgroup(page);
-	/*
-	 * Used bit is set without atomic ops but after smp_wmb().
-	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
-	 */
-	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+	if (!PageCgroupUsed(pc))
+		return;
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
+	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -857,14 +856,10 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 		return;
 	pc = lookup_page_cgroup(page);
 	VM_BUG_ON(PageCgroupAcctLRU(pc));
-	/*
-	 * Used bit is set without atomic ops but after smp_wmb().
-	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
-	 */
-	smp_rmb();
 	if (!PageCgroupUsed(pc))
 		return;
-
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
@@ -1031,14 +1026,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 		return NULL;
 
 	pc = lookup_page_cgroup(page);
-	/*
-	 * Used bit is set without atomic ops but after smp_wmb().
-	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
-	 */
-	smp_rmb();
 	if (!PageCgroupUsed(pc))
 		return NULL;
-
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc);
 	if (!mz)
 		return NULL;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
