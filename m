Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62DF36B007B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 01:50:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C6ocjF025475
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 15:50:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E5DEB45DE5D
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E24245DE65
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5080D8F8009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:50:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE0D1DF8003
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:50:36 +0900 (JST)
Date: Fri, 12 Feb 2010 15:47:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg : update softlimit and threshold at commit.
Message-Id: <20100212154713.d8a9374d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Now, move_task introduced "batched" precharge. Because res_counter or css's refcnt
are not-scalable jobs for memcg, charge()s should be done in batched manner
if allowed.

Now, softlimit and threshold check their event counter in try_charge, but
this charge() is not per-page event. And event counter is not updated at charge().
Moreover, precharge doesn't pass "page" to try_charge() and softlimit tree
will be never updated until uncharge() causes an event.

So, the best place to check the event counter is commit_charge(). This is 
per-page event by its nature. This patch move checks to there.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb10/mm/memcontrol.c
@@ -1463,7 +1463,7 @@ static int __mem_cgroup_try_charge(struc
 		unsigned long flags = 0;
 
 		if (consume_stock(mem))
-			goto charged;
+			goto done;
 
 		ret = res_counter_charge(&mem->res, csize, &fail_res);
 		if (likely(!ret)) {
@@ -1558,16 +1558,7 @@ static int __mem_cgroup_try_charge(struc
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
@@ -1691,6 +1682,16 @@ static void __mem_cgroup_commit_charge(s
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
