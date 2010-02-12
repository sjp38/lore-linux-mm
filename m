Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A6E0B6B007D
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 04:10:12 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C9A9RK010661
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 18:10:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8204345DE55
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 18:10:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2751645DE50
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 18:10:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF5E51DB803E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 18:10:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F320E08002
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 18:10:06 +0900 (JST)
Date: Fri, 12 Feb 2010 18:06:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: update threshold and softlimit at commit v2
Message-Id: <20100212180640.39b242d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Now, move_task does "batched" precharge. Because res_counter or css's refcnt
are not-scalable jobs for memcg, try_charge_().. tend to be done in batched
manner if allowed.

Now, softlimit and threshold check their event counter in try_charge, but
charge is not per-page event. And event counter is not updated at charge().
Moreover, precharge doesn't pass "page" to try_charge() and softlimit tree
will be never updated until uncharge() causes an event."

So, the best place to check the event counter is commit_charge(). This is 
per-page event by its nature. This patch move checks to there.

Changelog: 2010/02/12
 removed an argument "page" from try_charge(). After this, try_charge()
 is independent from what the page is.
 (Maybe transparent hugepage or some needs to add some argument in future.)

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb10/mm/memcontrol.c
@@ -1424,8 +1424,7 @@ static int __cpuinit memcg_stock_cpu_cal
  * oom-killer can be invoked.
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **memcg,
-			bool oom, struct page *page)
+			gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
 {
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -1463,7 +1462,7 @@ static int __mem_cgroup_try_charge(struc
 		unsigned long flags = 0;
 
 		if (consume_stock(mem))
-			goto charged;
+			goto done;
 
 		ret = res_counter_charge(&mem->res, csize, &fail_res);
 		if (likely(!ret)) {
@@ -1558,16 +1557,7 @@ static int __mem_cgroup_try_charge(struc
 	}
 	if (csize > PAGE_SIZE)
 		refill_stock(mem, csize - PAGE_SIZE);
-charged:
-	/*
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
-	 */
-	if (page && mem_cgroup_soft_limit_check(mem))
-		mem_cgroup_update_tree(mem, page);
 done:
-	if (mem_cgroup_threshold_check(mem))
-		mem_cgroup_threshold(mem);
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -1691,6 +1681,16 @@ static void __mem_cgroup_commit_charge(s
 	mem_cgroup_charge_statistics(mem, pc, true);
 
 	unlock_page_cgroup(pc);
+	/*
+	 * "charge_statistics" updated event counter. Then, check it.
+	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
+	 * if they exceeds softlimit.
+	 */
+	if (mem_cgroup_soft_limit_check(mem))
+		mem_cgroup_update_tree(mem, pc->page);
+	if (mem_cgroup_threshold_check(mem))
+		mem_cgroup_threshold(mem);
+
 }
 
 /**
@@ -1788,7 +1788,7 @@ static int mem_cgroup_move_parent(struct
 		goto put;
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
 	if (ret || !parent)
 		goto put_back;
 
@@ -1824,7 +1824,7 @@ static int mem_cgroup_charge_common(stru
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
 	if (ret || !mem)
 		return ret;
 
@@ -1944,14 +1944,14 @@ int mem_cgroup_try_charge_swapin(struct 
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, page);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
 	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true, page);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true);
 }
 
 static void
@@ -2340,8 +2340,7 @@ int mem_cgroup_prepare_migration(struct 
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
-						page);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -3863,8 +3862,7 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem,
-								false, NULL);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
 		if (ret || !mem)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
