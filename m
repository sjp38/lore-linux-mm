Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AC48E6B0099
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:19:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 75B8F3EE081
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:19:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 544A845DE50
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:19:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D357745DE56
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:19:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0D361DB803E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:19:06 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 793861DB8049
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:19:06 +0900 (JST)
Message-ID: <4FE2D87D.2090500@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 17:17:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value check
References: <4FDF17A3.9060202@jp.fujitsu.com> <4FDF1830.1000504@jp.fujitsu.com> <20120619165815.5ce24be7.akpm@linux-foundation.org> <4FE2D747.20506@jp.fujitsu.com>
In-Reply-To: <4FE2D747.20506@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

You're right and I think this will be much cleaner.
==

 From 9b6224616282d74838b393485eb7c9215f546ec9 Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 17:28:55 +0900
Subject: [PATCH 2/2] memcg: make mem_cgroup_force_empty_list() as boolean function

Now, mem_cgroup_force_empty_list() just returns 0 or -EBUSY and
-EBUSY is just indicating 'you need to retry.'.
This patch makes mem_cgroup_force_empty_list() as boolean function and
make the logic simpler.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  mm/memcontrol.c |   13 +++----------
  1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90a2ad4..767440c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3797,7 +3797,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
   * This routine traverse page_cgroup in given list and drop them all.
   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
   */
-static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
+static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
  				int node, int zid, enum lru_list lru)
  {
  	struct mem_cgroup_per_zone *mz;
@@ -3805,7 +3805,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
  	struct list_head *list;
  	struct page *busy;
  	struct zone *zone;
-	int ret = 0;
  
  	zone = &NODE_DATA(node)->node_zones[zid];
  	mz = mem_cgroup_zoneinfo(memcg, node, zid);
@@ -3819,7 +3818,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
  		struct page_cgroup *pc;
  		struct page *page;
  
-		ret = 0;
  		spin_lock_irqsave(&zone->lru_lock, flags);
  		if (list_empty(list)) {
  			spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -3836,19 +3834,14 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
  
  		pc = lookup_page_cgroup(page);
  
-		ret = mem_cgroup_move_parent(page, pc, memcg);
-
-		if (ret == -EBUSY || ret == -EINVAL) {
+		if (mem_cgroup_move_parent(page, pc, memcg)) {
  			/* found lock contention or "pc" is obsolete. */
  			busy = page;
  			cond_resched();
  		} else
  			busy = NULL;
  	}
-
-	if (!ret && !list_empty(list))
-		return -EBUSY;
-	return ret;
+	return !list_empty(list);
  }
  
  /*
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
