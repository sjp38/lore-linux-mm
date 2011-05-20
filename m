Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDFA6B0023
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:51:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B101F3EE0BB
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:51:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 968F745DF57
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:51:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7352C45DF54
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:51:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 667EF1DB803F
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:51:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CED71DB8038
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:51:14 +0900 (JST)
Date: Fri, 20 May 2011 12:44:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/8] memcg: export release victim
Message-Id: <20110520124430.6f463803.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Later change will call mem_cgroup_select_victim() from vmscan.c
Need to export an interface and add release_victim().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   13 +++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -1487,7 +1487,7 @@ u64 mem_cgroup_get_limit(struct mem_cgro
  * of the cgroup list, since we track last_scanned_child) of @mem and use
  * that to reclaim free pages from.
  */
-static struct mem_cgroup *
+struct mem_cgroup *
 mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 {
 	struct mem_cgroup *ret = NULL;
@@ -1519,6 +1519,11 @@ mem_cgroup_select_victim(struct mem_cgro
 	return ret;
 }
 
+void mem_cgroup_release_victim(struct mem_cgroup *mem)
+{
+	css_put(&mem->css);
+}
+
 #if MAX_NUMNODES > 1
 
 /*
@@ -1663,7 +1668,7 @@ static int mem_cgroup_hierarchical_recla
 				 * no reclaimable pages under this hierarchy
 				 */
 				if (!check_soft || !total) {
-					css_put(&victim->css);
+					mem_cgroup_release_victim(victim);
 					break;
 				}
 				/*
@@ -1674,14 +1679,14 @@ static int mem_cgroup_hierarchical_recla
 				 */
 				if (total >= (excess >> 2) ||
 					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
-					css_put(&victim->css);
+					mem_cgroup_release_victim(victim);
 					break;
 				}
 			}
 		}
 		if (!mem_cgroup_local_usage(victim)) {
 			/* this cgroup's local usage == 0 */
-			css_put(&victim->css);
+			mem_cgroup_release_victim(victim);
 			continue;
 		}
 		/* we use swappiness of local cgroup */
@@ -1694,7 +1699,7 @@ static int mem_cgroup_hierarchical_recla
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 					noswap);
-		css_put(&victim->css);
+		mem_cgroup_release_victim(victim);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
 		 * reclaim more. It's depends on callers. last_scanned_child
Index: mmotm-May11/include/linux/memcontrol.h
===================================================================
--- mmotm-May11.orig/include/linux/memcontrol.h
+++ mmotm-May11/include/linux/memcontrol.h
@@ -122,6 +122,8 @@ struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
+struct mem_cgroup *mem_cgroup_select_victim(struct mem_cgroup *mem);
+void mem_cgroup_release_victim(struct mem_cgroup *mem);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
