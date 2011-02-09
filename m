Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7F58D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 06:02:26 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] memcg: keep only one charge cancelling function
Date: Wed,  9 Feb 2011 12:01:50 +0100
Message-Id: <1297249313-23746-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have two charge cancelling functions: one takes a page count, the
other a page size.  The second one just divides the parameter by
PAGE_SIZE and then calls the first one.  This is trivial, no need for
an extra function.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 236f627..cabf421 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2004,22 +2004,18 @@ bypass:
  * This function is for that and do uncharge, put css's refcnt.
  * gotten by try_charge().
  */
-static void __mem_cgroup_cancel_charge(struct mem_cgroup *mem,
-							unsigned long count)
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem,
+				     unsigned int nr_pages)
 {
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE * count);
+		unsigned long bytes = nr_pages * PAGE_SIZE;
+
+		res_counter_uncharge(&mem->res, bytes);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE * count);
+			res_counter_uncharge(&mem->memsw, bytes);
 	}
 }
 
-static void mem_cgroup_cancel_charge(struct mem_cgroup *mem,
-				     int page_size)
-{
-	__mem_cgroup_cancel_charge(mem, page_size >> PAGE_SHIFT);
-}
-
 /*
  * A helper function to get mem_cgroup from ID. must be called under
  * rcu_read_lock(). The caller must check css_is_removed() or some if
@@ -2078,7 +2074,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem, page_size);
+		mem_cgroup_cancel_charge(mem, nr_pages);
 		return;
 	}
 	/*
@@ -2216,7 +2212,7 @@ static int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
-		mem_cgroup_cancel_charge(from, charge_size);
+		mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
@@ -2281,7 +2277,7 @@ static int mem_cgroup_move_parent(struct page *page,
 
 	ret = mem_cgroup_move_account(page, pc, child, parent, true, page_size);
 	if (ret)
-		mem_cgroup_cancel_charge(parent, page_size);
+		mem_cgroup_cancel_charge(parent, page_size >> PAGE_SHIFT);
 
 	if (page_size > PAGE_SIZE)
 		compound_unlock_irqrestore(page, flags);
@@ -2512,7 +2508,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 		return;
 	if (!mem)
 		return;
-	mem_cgroup_cancel_charge(mem, PAGE_SIZE);
+	mem_cgroup_cancel_charge(mem, 1);
 }
 
 static void
@@ -4788,7 +4784,7 @@ static void __mem_cgroup_clear_mc(void)
 
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
-		__mem_cgroup_cancel_charge(mc.to, mc.precharge);
+		mem_cgroup_cancel_charge(mc.to, mc.precharge);
 		mc.precharge = 0;
 	}
 	/*
@@ -4796,7 +4792,7 @@ static void __mem_cgroup_clear_mc(void)
 	 * we must uncharge here.
 	 */
 	if (mc.moved_charge) {
-		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
+		mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
 		mc.moved_charge = 0;
 	}
 	/* we must fixup refcnts and charges */
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
