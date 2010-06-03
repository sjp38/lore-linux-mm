Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18A0D6B0219
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 06:00:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o53A0Nmd027643
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 19:00:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A89845DE6F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:00:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F21545DE4D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:00:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 185A81DB8037
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:00:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD66B1DB803B
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:00:22 +0900 (JST)
Date: Thu, 3 Jun 2010 18:56:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/2] memcg: coalescing css_get() at charge
Message-Id: <20100603185607.b5aa5c8e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603185407.3161e924.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100603185407.3161e924.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

based on a clean up patch I sent.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Coalessing multiple css_get() to a __css_get(count) as res_counter does.
This reduces memcg's cost, cache ping-pong very much.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   35 ++++++++++++++++++++++++++++-------
 1 file changed, 28 insertions(+), 7 deletions(-)

Index: mmotm-2.6.34-May21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-May21.orig/mm/memcontrol.c
+++ mmotm-2.6.34-May21/mm/memcontrol.c
@@ -1542,6 +1542,7 @@ static void drain_stock(struct memcg_sto
 		res_counter_uncharge(&old->res, stock->charge);
 		if (do_swap_account)
 			res_counter_uncharge(&old->memsw, stock->charge);
+		__css_put(&old->css, stock->charge/PAGE_SIZE);
 	}
 	stock->cached = NULL;
 	stock->charge = 0;
@@ -1570,6 +1571,7 @@ static void refill_stock(struct mem_cgro
 		stock->cached = mem;
 	}
 	stock->charge += val;
+	__css_get(&mem->css, val/PAGE_SIZE);
 	put_cpu_var(memcg_stock);
 }
 
@@ -1710,6 +1712,7 @@ static int __mem_cgroup_try_charge(struc
 	 * in system level. So, allow to go ahead dying process in addition to
 	 * MEMDIE process.
 	 */
+again:
 	if (unlikely(test_thread_flag(TIF_MEMDIE)
 		     || fatal_signal_pending(current)))
 		goto bypass;
@@ -1720,25 +1723,42 @@ static int __mem_cgroup_try_charge(struc
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
+
+	rcu_read_lock();
 	if (*memcg) {
 		mem = *memcg;
-		css_get(&mem->css);
 	} else {
-		mem = try_get_mem_cgroup_from_mm(mm);
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 		if (unlikely(!mem))
 			return 0;
 		*memcg = mem;
 	}
 
-	VM_BUG_ON(css_is_removed(&mem->css));
-	if (mem_cgroup_is_root(mem))
+	/* racy ? (but seems to never happen in usual */
+	if (unlikely(css_is_removed(&mem->css))) {
+		rcu_read_unlock();
+		mem = NULL;
+		goto bypass;
+	}
+
+	if (mem_cgroup_is_root(mem)) {
+		rcu_read_unlock();
 		goto done;
+	}
 
+	if (consume_stock(mem)) {
+		rcu_read_unlock();
+		goto done;
+	}
+	if (!css_tryget(&mem->css)) {
+		rcu_read_unlock();
+		goto again;
+	}
+	rcu_read_unlock();
+	/* Enter memory reclaim loop */
 	do {
 		bool oom_check;
 
-		if (consume_stock(mem))
-			goto done; /* don't need to fill stock */
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current))
 			goto bypass;
@@ -1756,7 +1776,8 @@ static int __mem_cgroup_try_charge(struc
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			csize = PAGE_SIZE;
-			break;
+			css_put(&mem->css);
+			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
