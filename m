Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 689B26B01D7
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:33:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536Wxn2031200
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:33:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61F4445DE70
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:32:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29D7545DE6E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:32:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDDC51DB8042
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:32:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 664DA1DB8037
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:32:58 +0900 (JST)
Date: Thu, 3 Jun 2010 15:28:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg clean up try_charge main loop
Message-Id: <20100603152830.8b9e5e27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603150619.4bbe61bb.nishimura@mxp.nes.nec.co.jp>
References: <20100603114837.6e6d4d0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603150619.4bbe61bb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010 15:06:19 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
		}
> Well, as I said before, nr_oom_retries seems to be reset at the begining of
> this loop every time. Actually, I cannot cause oom even when I set a value
> to limit_in_bytes and run a program which uses more memory than the limit,
> because we never meet !nr_oom_retries here and oom_check will never be set to true.
> 
> 
sorry, here.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

mem_cgroup_try_charge() has a big loop in it and seems to be hard to read.
Most of routines are for slow path. This patch moves codes out from the
loop and make it clear what's done.

Summary:
 - refactoring a function to detect a memcg is under acccount move or not.
 - refactoring a function to wait for the end of moving task acct.
 - refactoring a main loop('s slow path) as a function and make it clear
   why we retry or quit by return code.
 - add fatal_signal_pending() check for bypassing charge loops.

Changelog 2010-06-03
 - fixed oom retry handling.
 - use do...while()
Changelog 2010-06-01
 - added fatal_signal_pending() to bypass charge loop. This is useful
   and valid to do because if signal is fatal, charging against it
   isn't very necessary and the user can see smooth kill even under
   heavy workload on a memcg.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  249 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 149 insertions(+), 100 deletions(-)

Index: mmotm-2.6.34-May21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-May21.orig/mm/memcontrol.c
+++ mmotm-2.6.34-May21/mm/memcontrol.c
@@ -1072,6 +1072,49 @@ static unsigned int get_swappiness(struc
 	return swappiness;
 }
 
+/* A routine for testing mem is not under move_account */
+
+static bool mem_cgroup_under_move(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *from = mc.from;
+	struct mem_cgroup *to = mc.to;
+	bool ret = false;
+
+	if (from == mem || to == mem)
+		return true;
+
+	if (!from || !to || !mem->use_hierarchy)
+		return false;
+
+	rcu_read_lock();
+	if (css_tryget(&from->css)) {
+		ret = css_is_ancestor(&from->css, &mem->css);
+		css_put(&from->css);
+	}
+	if (!ret && css_tryget(&to->css)) {
+		ret = css_is_ancestor(&to->css,	&mem->css);
+		css_put(&to->css);
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
+static bool mem_cgroup_wait_acct_move(struct mem_cgroup *mem)
+{
+	if (mc.moving_task && current != mc.moving_task) {
+		if (mem_cgroup_under_move(mem)) {
+			DEFINE_WAIT(wait);
+			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
+			/* moving charge context might have finished. */
+			if (mc.moving_task)
+				schedule();
+			finish_wait(&mc.waitq, &wait);
+			return true;
+		}
+	}
+	return false;
+}
+
 static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
 {
 	int *val = data;
@@ -1582,16 +1625,84 @@ static int __cpuinit memcg_stock_cpu_cal
 	return NOTIFY_OK;
 }
 
+
+/* See __mem_cgroup_try_charge() for details */
+enum {
+	CHARGE_OK,		/* success */
+	CHARGE_RETRY,		/* need to retry but retry is not bad */
+	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
+	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
+	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
+};
+
+static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
+				int csize, bool oom_check)
+{
+	struct mem_cgroup *mem_over_limit;
+	struct res_counter *fail_res;
+	unsigned long flags = 0;
+	int ret;
+
+	ret = res_counter_charge(&mem->res, csize, &fail_res);
+
+	if (likely(!ret)) {
+		if (!do_swap_account)
+			return CHARGE_OK;
+		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
+		if (likely(!ret))
+			return CHARGE_OK;
+
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+	} else
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+
+	if (csize > PAGE_SIZE) /* change csize and retry */
+		return CHARGE_RETRY;
+
+	if (!(gfp_mask & __GFP_WAIT))
+		return CHARGE_WOULDBLOCK;
+
+	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+					gfp_mask, flags);
+	/*
+	 * try_to_free_mem_cgroup_pages() might not give us a full
+	 * picture of reclaim. Some pages are reclaimed and might be
+	 * moved to swap cache or just unmapped from the cgroup.
+	 * Check the limit again to see if the reclaim reduced the
+	 * current usage of the cgroup before giving up
+	 */
+	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+		return CHARGE_RETRY;
+
+	/*
+	 * At task move, charge accounts can be doubly counted. So, it's
+	 * better to wait until the end of task_move if something is going on.
+	 */
+	if (mem_cgroup_wait_acct_move(mem_over_limit))
+		return CHARGE_RETRY;
+
+	/* If we don't need to call oom-killer at el, return immediately */
+	if (!oom_check)
+		return CHARGE_NOMEM;
+	/* check OOM */
+	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
+		return CHARGE_OOM_DIE;
+
+	return CHARGE_RETRY;
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
  */
+
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
+		gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
 {
-	struct mem_cgroup *mem, *mem_over_limit;
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res;
+	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct mem_cgroup *mem = NULL;
+	int ret;
 	int csize = CHARGE_SIZE;
 
 	/*
@@ -1609,120 +1720,56 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	mem = *memcg;
-	if (likely(!mem)) {
+	if (*memcg) {
+		mem = *memcg;
+		css_get(&mem->css);
+	} else {
 		mem = try_get_mem_cgroup_from_mm(mm);
+		if (unlikely(!mem))
+			return 0;
 		*memcg = mem;
-	} else {
-		css_get(&mem->css);
 	}
-	if (unlikely(!mem))
-		return 0;
 
 	VM_BUG_ON(css_is_removed(&mem->css));
 	if (mem_cgroup_is_root(mem))
 		goto done;
 
-	while (1) {
-		int ret = 0;
-		unsigned long flags = 0;
+	do {
+		bool oom_check;
 
 		if (consume_stock(mem))
-			goto done;
-
-		ret = res_counter_charge(&mem->res, csize, &fail_res);
-		if (likely(!ret)) {
-			if (!do_swap_account)
-				break;
-			ret = res_counter_charge(&mem->memsw, csize, &fail_res);
-			if (likely(!ret))
-				break;
-			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, csize);
-			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
-			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
-									memsw);
-		} else
-			/* mem counter fails */
-			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
-									res);
+			goto done; /* don't need to fill stock */
+		/* If killed, bypass charge */
+		if (fatal_signal_pending(current))
+			goto bypass;
 
-		/* reduce request size and retry */
-		if (csize > PAGE_SIZE) {
-			csize = PAGE_SIZE;
-			continue;
+		oom_check = false;
+		if (oom && !nr_oom_retries) {
+			oom_check = true;
+			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 		}
-		if (!(gfp_mask & __GFP_WAIT))
-			goto nomem;
 
-		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-						gfp_mask, flags);
-		if (ret)
-			continue;
+		ret = __mem_cgroup_do_charge(mem, gfp_mask, csize, oom_check);
 
-		/*
-		 * try_to_free_mem_cgroup_pages() might not give us a full
-		 * picture of reclaim. Some pages are reclaimed and might be
-		 * moved to swap cache or just unmapped from the cgroup.
-		 * Check the limit again to see if the reclaim reduced the
-		 * current usage of the cgroup before giving up
-		 *
-		 */
-		if (mem_cgroup_check_under_limit(mem_over_limit))
-			continue;
-
-		/* try to avoid oom while someone is moving charge */
-		if (mc.moving_task && current != mc.moving_task) {
-			struct mem_cgroup *from, *to;
-			bool do_continue = false;
-			/*
-			 * There is a small race that "from" or "to" can be
-			 * freed by rmdir, so we use css_tryget().
-			 */
-			from = mc.from;
-			to = mc.to;
-			if (from && css_tryget(&from->css)) {
-				if (mem_over_limit->use_hierarchy)
-					do_continue = css_is_ancestor(
-							&from->css,
-							&mem_over_limit->css);
-				else
-					do_continue = (from == mem_over_limit);
-				css_put(&from->css);
-			}
-			if (!do_continue && to && css_tryget(&to->css)) {
-				if (mem_over_limit->use_hierarchy)
-					do_continue = css_is_ancestor(
-							&to->css,
-							&mem_over_limit->css);
-				else
-					do_continue = (to == mem_over_limit);
-				css_put(&to->css);
-			}
-			if (do_continue) {
-				DEFINE_WAIT(wait);
-				prepare_to_wait(&mc.waitq, &wait,
-							TASK_INTERRUPTIBLE);
-				/* moving charge context might have finished. */
-				if (mc.moving_task)
-					schedule();
-				finish_wait(&mc.waitq, &wait);
-				continue;
-			}
-		}
-
-		if (!nr_retries--) {
+		switch (ret) {
+		case CHARGE_OK:
+			break;
+		case CHARGE_RETRY: /* not in OOM situation but retry */
+			csize = PAGE_SIZE;
+			break;
+		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
+			goto nomem;
+		case CHARGE_NOMEM: /* OOM routine works */
 			if (!oom)
 				goto nomem;
-			if (mem_cgroup_handle_oom(mem_over_limit, gfp_mask)) {
-				nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-				continue;
-			}
-			/* When we reach here, current task is dying .*/
-			css_put(&mem->css);
+			/* If oom, we never return -ENOMEM */
+			nr_oom_retries--;
+			break;
+		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
 			goto bypass;
 		}
-	}
+	} while (ret != CHARGE_OK);
+
 	if (csize > PAGE_SIZE)
 		refill_stock(mem, csize - PAGE_SIZE);
 done:
@@ -1731,6 +1778,8 @@ nomem:
 	css_put(&mem->css);
 	return -ENOMEM;
 bypass:
+	if (mem)
+		css_put(&mem->css);
 	*memcg = NULL;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
