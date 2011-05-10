Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDA090010E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:16:26 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AD5703EE081
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:16:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92BF745DF49
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:16:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70E0245DF43
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:16:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 649FCE08001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:16:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30BB11DB8038
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:16:22 +0900 (JST)
Date: Tue, 10 May 2011 19:09:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/7] memcg : export select victim memcg
Message-Id: <20110510190942.4213fe24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

Later change will call mem_cgroup_select_victim() from vmscan.c
to do hierarchical reclaim. Need to export an interface and add
release_victim().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   13 +++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1555,6 +1555,11 @@ mem_cgroup_select_victim(struct mem_cgro
 	return ret;
 }
 
+void mem_cgroup_release_victim(struct mem_cgroup *mem)
+{
+	css_put(&mem->css);
+}
+
 #if MAX_NUMNODES > 1
 
 /*
@@ -1699,7 +1704,7 @@ static int mem_cgroup_hierarchical_recla
 				 * no reclaimable pages under this hierarchy
 				 */
 				if (!check_soft || !total) {
-					css_put(&victim->css);
+					mem_cgroup_release_victim(victim);
 					break;
 				}
 				/*
@@ -1710,14 +1715,14 @@ static int mem_cgroup_hierarchical_recla
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
@@ -1730,7 +1735,7 @@ static int mem_cgroup_hierarchical_recla
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 					noswap);
-		css_put(&victim->css);
+		mem_cgroup_release_victim(victim);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
 		 * reclaim more. It's depends on callers. last_scanned_child
Index: mmotm-May6/include/linux/memcontrol.h
===================================================================
--- mmotm-May6.orig/include/linux/memcontrol.h
+++ mmotm-May6/include/linux/memcontrol.h
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
