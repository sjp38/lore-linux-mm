Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E98B88D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:55:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4F6FB3EE0BB
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:55:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31DEF45DE5E
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:55:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D0745DE54
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:55:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EEF6FE08003
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:55:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B09641DB8040
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:55:17 +0900 (JST)
Date: Thu, 21 Apr 2011 12:48:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH V6
 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org


memcg-kswapd visits each memcg in round-robin. But required
amounts of works depends on memcg' usage and hi/low watermark
and taking it into account will be good.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |   17 +++++++++++++++++
 mm/vmscan.c                |    2 ++
 3 files changed, 20 insertions(+)

Index: mmotm-Apr14/include/linux/memcontrol.h
===================================================================
--- mmotm-Apr14.orig/include/linux/memcontrol.h
+++ mmotm-Apr14/include/linux/memcontrol.h
@@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(
 extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
 extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
 extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
+extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
Index: mmotm-Apr14/mm/memcontrol.c
===================================================================
--- mmotm-Apr14.orig/mm/memcontrol.c
+++ mmotm-Apr14/mm/memcontrol.c
@@ -4673,6 +4673,23 @@ struct memcg_kswapd_work
 
 struct memcg_kswapd_work	memcg_kswapd_control;
 
+int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)
+{
+	unsigned long long usage, lowat, hiwat;
+	int rate;
+
+	usage = res_counter_read_u64(&mem->res, RES_USAGE);
+	lowat = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
+	hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
+	if (lowat == hiwat)
+		return 0;
+
+	rate = (usage - hiwat) * 10 / (lowat - hiwat);
+	/* If usage is big, we reclaim more */
+	return rate * SWAP_CLUSTER_MAX;
+}
+
+
 static void wake_memcg_kswapd(struct mem_cgroup *mem)
 {
 	if (atomic_read(&mem->kswapd_running)) /* already running */
Index: mmotm-Apr14/mm/vmscan.c
===================================================================
--- mmotm-Apr14.orig/mm/vmscan.c
+++ mmotm-Apr14/mm/vmscan.c
@@ -2732,6 +2732,8 @@ static int shrink_mem_cgroup(struct mem_
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
 
+	sc.nr_to_reclaim += mem_cgroup_kswapd_bonus(mem_cont);
+
 	do_nodes = node_states[N_ONLINE];
 
 	for (priority = DEF_PRIORITY;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
