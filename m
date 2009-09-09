Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 474DD6B0082
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 04:42:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n898gxoV028698
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Sep 2009 17:42:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6BCD45DE4E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:42:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 80E2E45DE52
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:42:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 563B01DB803C
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:42:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EF160E1800B
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:42:57 +0900 (JST)
Date: Wed, 9 Sep 2009 17:41:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/4][mmotm] memcg: soft limit clean up
Message-Id: <20090909174101.03d34dd0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch clean up/fixes for memcg's uncharge soft limit path.
This is also a preparation for batched uncharge.

Problems:
  Now, res_counter_charge()/uncharge() handles softlimit information at
  charge/uncharge and softlimit-check is done when event counter per memcg
  goes over limit. But event counter per memcg is updated only when
  when memcg is over soft limit. But ancerstors are handled in charge path
  but not in uncharge path.
  For batched charge/uncharge, event counter check should be more strict.

  Prolems:
  1. memcg's event counter incremented only when softlimit hits. That's bad.
     It makes event counter hard to be reused for other purpose.
  2. At uncharge, only the lowest level rescounter is handled. This is bug.
     Because ancesotor's event counter is not incremented, children should
     take care of them.
  3. res_counter_uncharge()'s 3rd argument is NULL in most case.
     ops under res_counter->lock should be small. No "if" sentense is better.

Fixes:
  * Removed soft_limit_xx poitner and checsk from charge and uncharge.
    Do-check-only-when-necessary scheme works enough well without them.

  * make event-counter of memcg checked at every charge/uncharge.
    (per-cpu area will be accessed soon anyway)

  * All ancestors are checked at soft-limit-check. This is necessary because
    ancesotor's event counter may never be modified. Then, they should be
    checked at the same time.

Todo;
  We may need to modify EVENT_COUNTER_THRESH of parent with many children.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/res_counter.h |    6 --
 kernel/res_counter.c        |   18 ------
 mm/memcontrol.c             |  115 +++++++++++++++++++-------------------------
 3 files changed, 55 insertions(+), 84 deletions(-)

Index: mmotm-2.6.31-Sep3/kernel/res_counter.c
===================================================================
--- mmotm-2.6.31-Sep3.orig/kernel/res_counter.c
+++ mmotm-2.6.31-Sep3/kernel/res_counter.c
@@ -37,27 +37,17 @@ int res_counter_charge_locked(struct res
 }
 
 int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at,
-			struct res_counter **soft_limit_fail_at)
+			struct res_counter **limit_fail_at)
 {
 	int ret;
 	unsigned long flags;
 	struct res_counter *c, *u;
 
 	*limit_fail_at = NULL;
-	if (soft_limit_fail_at)
-		*soft_limit_fail_at = NULL;
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
 		ret = res_counter_charge_locked(c, val);
-		/*
-		 * With soft limits, we return the highest ancestor
-		 * that exceeds its soft limit
-		 */
-		if (soft_limit_fail_at &&
-			!res_counter_soft_limit_check_locked(c))
-			*soft_limit_fail_at = c;
 		spin_unlock(&c->lock);
 		if (ret < 0) {
 			*limit_fail_at = c;
@@ -85,8 +75,7 @@ void res_counter_uncharge_locked(struct 
 	counter->usage -= val;
 }
 
-void res_counter_uncharge(struct res_counter *counter, unsigned long val,
-				bool *was_soft_limit_excess)
+void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 {
 	unsigned long flags;
 	struct res_counter *c;
@@ -94,9 +83,6 @@ void res_counter_uncharge(struct res_cou
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
-		if (was_soft_limit_excess)
-			*was_soft_limit_excess =
-				!res_counter_soft_limit_check_locked(c);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
 	}
Index: mmotm-2.6.31-Sep3/include/linux/res_counter.h
===================================================================
--- mmotm-2.6.31-Sep3.orig/include/linux/res_counter.h
+++ mmotm-2.6.31-Sep3/include/linux/res_counter.h
@@ -114,8 +114,7 @@ void res_counter_init(struct res_counter
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at,
-		struct res_counter **soft_limit_at);
+		unsigned long val, struct res_counter **limit_fail_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
@@ -128,8 +127,7 @@ int __must_check res_counter_charge(stru
  */
 
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
-void res_counter_uncharge(struct res_counter *counter, unsigned long val,
-				bool *was_soft_limit_excess);
+void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
 static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 {
Index: mmotm-2.6.31-Sep3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep3.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep3/mm/memcontrol.c
@@ -353,16 +353,6 @@ __mem_cgroup_remove_exceeded(struct mem_
 }
 
 static void
-mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
-{
-	spin_lock(&mctz->lock);
-	__mem_cgroup_insert_exceeded(mem, mz, mctz);
-	spin_unlock(&mctz->lock);
-}
-
-static void
 mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
 				struct mem_cgroup_per_zone *mz,
 				struct mem_cgroup_tree_per_zone *mctz)
@@ -392,34 +382,40 @@ static bool mem_cgroup_soft_limit_check(
 
 static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
 {
-	unsigned long long prev_usage_in_excess, new_usage_in_excess;
-	bool updated_tree = false;
+	unsigned long long new_usage_in_excess;
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_tree_per_zone *mctz;
-
-	mz = mem_cgroup_zoneinfo(mem, page_to_nid(page), page_zonenum(page));
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
 	mctz = soft_limit_tree_from_page(page);
 
 	/*
-	 * We do updates in lazy mode, mem's are removed
-	 * lazily from the per-zone, per-node rb tree
+	 * Necessary to update all ancestors when hierarchy is used.
+	 * because their event counter is not touched.
 	 */
-	prev_usage_in_excess = mz->usage_in_excess;
-
-	new_usage_in_excess = res_counter_soft_limit_excess(&mem->res);
-	if (prev_usage_in_excess) {
-		mem_cgroup_remove_exceeded(mem, mz, mctz);
-		updated_tree = true;
-	}
-	if (!new_usage_in_excess)
-		goto done;
-	mem_cgroup_insert_exceeded(mem, mz, mctz);
-
-done:
-	if (updated_tree) {
-		spin_lock(&mctz->lock);
-		mz->usage_in_excess = new_usage_in_excess;
-		spin_unlock(&mctz->lock);
+	for (; mem; mem = parent_mem_cgroup(mem)) {
+		mz = mem_cgroup_zoneinfo(mem, nid, zid);
+		new_usage_in_excess =
+			res_counter_soft_limit_excess(&mem->res);
+		/*
+		 * We have to update the tree if mz is on RB-tree or
+		 * mem is over its softlimit.
+		 */
+		if (new_usage_in_excess || mz->on_tree) {
+			spin_lock(&mctz->lock);
+			/* if on-tree, remove it */
+			if (mz->on_tree)
+				__mem_cgroup_remove_exceeded(mem, mz, mctz);
+			/*
+			 * if over soft limit, insert again. mz->usage_in_excess
+			 * will be updated properly.
+			 */
+			if (new_usage_in_excess)
+				__mem_cgroup_insert_exceeded(mem, mz, mctz);
+			else
+				mz->usage_in_excess = 0;
+			spin_unlock(&mctz->lock);
+		}
 	}
 }
 
@@ -1270,9 +1266,9 @@ static int __mem_cgroup_try_charge(struc
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
 			bool oom, struct page *page)
 {
-	struct mem_cgroup *mem, *mem_over_limit, *mem_over_soft_limit;
+	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res, *soft_fail_res = NULL;
+	struct res_counter *fail_res;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -1304,17 +1300,16 @@ static int __mem_cgroup_try_charge(struc
 
 		if (mem_cgroup_is_root(mem))
 			goto done;
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
-						&soft_fail_res);
+		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
 			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
-							&fail_res, NULL);
+							&fail_res);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
@@ -1353,16 +1348,11 @@ static int __mem_cgroup_try_charge(struc
 		}
 	}
 	/*
-	 * Insert just the ancestor, we should trickle down to the correct
-	 * cgroup for reclaim, since the other nodes will be below their
-	 * soft limit
-	 */
-	if (soft_fail_res) {
-		mem_over_soft_limit =
-			mem_cgroup_from_res_counter(soft_fail_res, res);
-		if (mem_cgroup_soft_limit_check(mem_over_soft_limit))
-			mem_cgroup_update_tree(mem_over_soft_limit, page);
-	}
+	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
+	 * if they exceeds softlimit.
+	 */
+	if (mem_cgroup_soft_limit_check(mem))
+		mem_cgroup_update_tree(mem, page);
 done:
 	return 0;
 nomem:
@@ -1437,10 +1427,9 @@ static void __mem_cgroup_commit_charge(s
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
 		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE,
-							NULL);
+				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 		}
 		css_put(&mem->css);
 		return;
@@ -1519,7 +1508,7 @@ static int mem_cgroup_move_account(struc
 		goto out;
 
 	if (!mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&from->res, PAGE_SIZE);
 	mem_cgroup_charge_statistics(from, pc, false);
 
 	page = pc->page;
@@ -1539,7 +1528,7 @@ static int mem_cgroup_move_account(struc
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
+		res_counter_uncharge(&from->memsw, PAGE_SIZE);
 	css_put(&from->css);
 
 	css_get(&to->css);
@@ -1610,9 +1599,9 @@ uncharge:
 	css_put(&parent->css);
 	/* uncharge if move fails */
 	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&parent->res, PAGE_SIZE);
 		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
 	}
 	return ret;
 }
@@ -1803,8 +1792,7 @@ __mem_cgroup_commit_charge_swapin(struct
 			 * calling css_tryget
 			 */
 			if (!mem_cgroup_is_root(memcg))
-				res_counter_uncharge(&memcg->memsw, PAGE_SIZE,
-							NULL);
+				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_swap_statistics(memcg, false);
 			mem_cgroup_put(memcg);
 		}
@@ -1831,9 +1819,9 @@ void mem_cgroup_cancel_charge_swapin(str
 	if (!mem)
 		return;
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	}
 	css_put(&mem->css);
 }
@@ -1848,7 +1836,6 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
-	bool soft_limit_excess = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1888,10 +1875,10 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		if (do_swap_account &&
 				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	}
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
@@ -1908,7 +1895,7 @@ __mem_cgroup_uncharge_common(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
-	if (soft_limit_excess && mem_cgroup_soft_limit_check(mem))
+	if (mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
@@ -1986,7 +1973,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 		 * This memcg can be obsolete one. We avoid calling css_tryget
 		 */
 		if (!mem_cgroup_is_root(memcg))
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(memcg, false);
 		mem_cgroup_put(memcg);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
