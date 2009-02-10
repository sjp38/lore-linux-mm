Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D0D96B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:47:24 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ABlMTN009637
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 20:47:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E3DF45DE53
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:47:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EEA6D45DE52
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:47:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 93D0F1DB8062
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:47:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C2AD21DB8043
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:47:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] memcg: remove mem_cgroup_calc_mapped_ratio() take2
In-Reply-To: <20090210105931.GD16317@balbir.in.ibm.com>
References: <20090210184249.6FCD.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210105931.GD16317@balbir.in.ibm.com>
Message-Id: <20090210204539.6FF5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 20:47:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>


Changelog:
  v1 -> v2
    - The calc_mapped_ratio prototype also be removed.

========

Currently, mem_cgroup_calc_mapped_ratio() is unused at all.
it can be removed and KAMEZAWA-san suggested it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    6 ------
 mm/memcontrol.c            |   17 -----------------
 2 files changed, 23 deletions(-)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -445,23 +445,6 @@ int task_in_mem_cgroup(struct task_struc
 	return ret;
 }
 
-/*
- * Calculate mapped_ratio under memory controller. This will be used in
- * vmscan.c for deteremining we have to reclaim mapped pages.
- */
-int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
-{
-	long total, rss;
-
-	/*
-	 * usage is recorded in bytes. But, here, we assume the number of
-	 * physical pages can be represented by "long" on any arch.
-	 */
-	total = (long) (mem->res.usage >> PAGE_SHIFT) + 1L;
-	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
-	return (int)((rss * 100L) / total);
-}
-
 static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;
Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -88,7 +88,6 @@ extern void mem_cgroup_end_migration(str
 /*
  * For memory reclaim.
  */
-extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
 extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
@@ -203,11 +202,6 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
-static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
-{
-	return 0;
-}
-
 static inline int mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
 {
 	return 0;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
