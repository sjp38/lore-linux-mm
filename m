Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5469B8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:47:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 48FC23EE0C2
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:47:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C5CB45DE6B
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:47:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1144E45DE61
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:47:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE2231DB8040
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:47:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A46961DB803B
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:47:38 +0900 (JST)
Date: Fri, 21 Jan 2011 15:41:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/7] memcg : fix mem_cgroup_check_under_limit
Message-Id: <20110121154141.680c96d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Current memory cgroup's code tends to assume page_size == PAGE_SIZE
but THP does HPAGE_SIZE charge.

This is one of fixes for supporing THP. This modifies
mem_cgroup_check_under_limit to take page_size into account.

Total fixes for do_charge()/reclaim memory will follow this patch.

TODO: By this reclaim function can get page_size as argument.
So...there may be something should be improvoed.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |   11 +++++++++++
 mm/memcontrol.c             |   27 ++++++++++++++-------------
 2 files changed, 25 insertions(+), 13 deletions(-)

Index: mmotm-0107/include/linux/res_counter.h
===================================================================
--- mmotm-0107.orig/include/linux/res_counter.h
+++ mmotm-0107/include/linux/res_counter.h
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
Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -1099,14 +1099,14 @@ unsigned long mem_cgroup_isolate_pages(u
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
-static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
+static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem, int page_size)
 {
 	if (do_swap_account) {
-		if (res_counter_check_under_limit(&mem->res) &&
-			res_counter_check_under_limit(&mem->memsw))
+		if (res_counter_check_margin(&mem->res) >= page_size &&
+			res_counter_check_margin(&mem->memsw) >= page_size)
 			return true;
 	} else
-		if (res_counter_check_under_limit(&mem->res))
+		if (res_counter_check_margin(&mem->res) >= page_size)
 			return true;
 	return false;
 }
@@ -1367,7 +1367,8 @@ mem_cgroup_select_victim(struct mem_cgro
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 						struct zone *zone,
 						gfp_t gfp_mask,
-						unsigned long reclaim_options)
+						unsigned long reclaim_options,
+						int page_size)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
@@ -1434,7 +1435,7 @@ static int mem_cgroup_hierarchical_recla
 		if (check_soft) {
 			if (res_counter_check_under_soft_limit(&root_mem->res))
 				return total;
-		} else if (mem_cgroup_check_under_limit(root_mem))
+		} else if (mem_cgroup_check_under_limit(root_mem, page_size))
 			return 1 + total;
 	}
 	return total;
@@ -1844,7 +1845,7 @@ static int __mem_cgroup_do_charge(struct
 		return CHARGE_WOULDBLOCK;
 
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					gfp_mask, flags);
+					gfp_mask, flags, csize);
 	/*
 	 * try_to_free_mem_cgroup_pages() might not give us a full
 	 * picture of reclaim. Some pages are reclaimed and might be
@@ -1852,7 +1853,7 @@ static int __mem_cgroup_do_charge(struct
 	 * Check the limit again to see if the reclaim reduced the
 	 * current usage of the cgroup before giving up
 	 */
-	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+	if (ret || mem_cgroup_check_under_limit(mem_over_limit, csize))
 		return CHARGE_RETRY;
 
 	/*
@@ -3058,7 +3059,7 @@ static int mem_cgroup_resize_limit(struc
 			break;
 
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_SHRINK);
+					MEM_CGROUP_RECLAIM_SHRINK, PAGE_SIZE);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -3117,8 +3118,8 @@ static int mem_cgroup_resize_memsw_limit
 			break;
 
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
-						MEM_CGROUP_RECLAIM_NOSWAP |
-						MEM_CGROUP_RECLAIM_SHRINK);
+			MEM_CGROUP_RECLAIM_NOSWAP | MEM_CGROUP_RECLAIM_SHRINK,
+			PAGE_SIZE);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3159,8 +3160,8 @@ unsigned long mem_cgroup_soft_limit_recl
 			break;
 
 		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
-						gfp_mask,
-						MEM_CGROUP_RECLAIM_SOFT);
+					gfp_mask,
+					MEM_CGROUP_RECLAIM_SOFT, PAGE_SIZE);
 		nr_reclaimed += reclaimed;
 		spin_lock(&mctz->lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
