Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B7BF8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 22:30:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E5D4A3EE0B5
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:30:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9CD145DE6B
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:30:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9321E45DE61
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:30:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 806591DB803E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:30:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 371EC1DB803F
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:30:51 +0900 (JST)
Date: Fri, 28 Jan 2011 12:24:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Current memory cgroup's code tends to assume page_size == PAGE_SIZE
and arrangement for THP is not enough yet.

This is one of fixes for supporing THP. This adds
mem_cgroup_check_margin() and checks whether there are required amount of
free resource after memory reclaim. By this, THP page allocation
can know whether it really succeeded or not and avoid infinite-loop
and hangup.

Total fixes for do_charge()/reclaim memory will follow this patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |   11 +++++++++++
 mm/memcontrol.c             |   25 ++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

Index: mmotm-0125/include/linux/res_counter.h
===================================================================
--- mmotm-0125.orig/include/linux/res_counter.h
+++ mmotm-0125/include/linux/res_counter.h
@@ -182,6 +182,17 @@ static inline bool res_counter_check_und
 	return ret;
 }
 
+static inline s64 res_counter_check_margin(struct res_counter *cnt)
+{
+	s64 ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = cnt->limit - cnt->usage;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
 {
 	bool ret;
Index: mmotm-0125/mm/memcontrol.c
===================================================================
--- mmotm-0125.orig/mm/memcontrol.c
+++ mmotm-0125/mm/memcontrol.c
@@ -1111,6 +1111,22 @@ static bool mem_cgroup_check_under_limit
 	return false;
 }
 
+static s64  mem_cgroup_check_margin(struct mem_cgroup *mem)
+{
+	s64 mem_margin;
+
+	if (do_swap_account) {
+		s64 memsw_margin;
+
+		mem_margin = res_counter_check_margin(&mem->res);
+		memsw_margin = res_counter_check_margin(&mem->memsw);
+		if (mem_margin > memsw_margin)
+			mem_margin = memsw_margin;
+	} else
+		mem_margin = res_counter_check_margin(&mem->res);
+	return mem_margin;
+}
+
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
@@ -1853,7 +1869,14 @@ static int __mem_cgroup_do_charge(struct
 	 * Check the limit again to see if the reclaim reduced the
 	 * current usage of the cgroup before giving up
 	 */
-	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+	if (mem_cgroup_check_margin(mem_over_limit) >= csize)
+		return CHARGE_RETRY;
+
+	/*
+ 	 * If the charge size is a PAGE_SIZE, it's not hopeless while
+ 	 * we can reclaim a page.
+ 	 */
+	if (csize == PAGE_SIZE && ret)
 		return CHARGE_RETRY;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
