Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 220618D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:04:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B3C633EE0B3
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:04:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98CF445DE52
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:04:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76E2A45DE4F
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:04:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 677281DB8040
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:04:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F4EF1DB803B
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:04:45 +0900 (JST)
Date: Fri, 28 Jan 2011 13:58:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

How about this ?
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Current memory cgroup's code tends to assume page_size == PAGE_SIZE
and arrangement for THP is not enough yet.

This is one of fixes for supporing THP. This adds
mem_cgroup_check_margin() and checks whether there are required amount of
free resource after memory reclaim. By this, THP page allocation
can know whether it really succeeded or not and avoid infinite-loop
and hangup.

Total fixes for do_charge()/reclaim memory will follow this patch.

Changelog v1->v2:
 - style fix.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |   11 +++++++++++
 mm/memcontrol.c             |   22 +++++++++++++++++++++-
 2 files changed, 32 insertions(+), 1 deletion(-)

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
@@ -1111,6 +1111,19 @@ static bool mem_cgroup_check_under_limit
 	return false;
 }
 
+static s64 mem_cgroup_check_margin(struct mem_cgroup *mem)
+{
+	s64 mem_margin = res_counter_check_margin(&mem->res);
+	s64 memsw_margin;
+
+	if (do_swap_account)
+		memsw_margin = res_counter_check_margin(&mem->memsw);
+	else
+		memsw_margin = RESOURCE_MAX;
+
+	return min(mem_margin, memsw_margin);
+}
+
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
@@ -1853,7 +1866,14 @@ static int __mem_cgroup_do_charge(struct
 	 * Check the limit again to see if the reclaim reduced the
 	 * current usage of the cgroup before giving up
 	 */
-	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+	if (mem_cgroup_check_margin(mem_over_limit) >= csize)
+		return CHARGE_RETRY;
+
+	/*
+	 * If the charge size is a PAGE_SIZE, it's not hopeless while
+	 * we can reclaim a page.
+	 */
+	if (csize == PAGE_SIZE && ret)
 		return CHARGE_RETRY;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
