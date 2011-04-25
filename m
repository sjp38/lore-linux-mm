Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8CC8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:41:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ED11C3EE0B6
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:41:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D527145DE54
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:41:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B500845DE59
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:41:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A7478E08001
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:41:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A4BEF8001
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:41:02 +0900 (JST)
Date: Mon, 25 Apr 2011 18:34:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/7] memcg fix scan ratio with small memcg.
Message-Id: <20110425183426.6a791ec9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>


At memcg memory reclaim, get_scan_count() may returns [0, 0, 0, 0]
and no scan was not issued at the reclaim priority.

The reason is because memory cgroup may not be enough big to have
the number of pages, which is greater than 1 << priority.

Because priority affects many routines in vmscan.c, it's better
to scan memory even if usage >> priority < 0. 
>From another point of view, if memcg's zone doesn't have enough memory which
meets priority, it should be skipped. So, this patch creates a temporal priority
in get_scan_count() and scan some amount of pages even when
usage is small. By this, memcg's reclaim goes smoother without
having too high priority, which will cause unnecessary congestion_wait(), etc.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |    5 +++++
 mm/vmscan.c                |   11 +++++++++++
 3 files changed, 22 insertions(+)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -152,6 +152,7 @@ unsigned long mem_cgroup_soft_limit_recl
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+u64 mem_cgroup_get_usage(struct mem_cgroup *mem);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -357,6 +358,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 	return 0;
 }
 
+static inline u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_split_huge_fixup(struct page *head,
 						struct page *tail)
 {
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -1483,6 +1483,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 	return min(limit, memsw);
 }
 
+u64 mem_cgroup_get_usage(struct mem_cgroup *memcg)
+{
+	return res_counter_read_u64(&memcg->res, RES_USAGE);
+}
+
 /*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -1762,6 +1762,17 @@ static void get_scan_count(struct zone *
 			denominator = 1;
 			goto out;
 		}
+	} else {
+		u64 usage;
+		/*
+		 * When memcg is enough small, anon+file >> priority
+		 * can be 0 and we'll do no scan. Adjust it to proper
+		 * value against its usage. If this zone's usage is enough
+		 * small, scan will ignore this zone until priority goes down.
+		 */
+		for (usage = mem_cgroup_get_usage(sc->mem_cgroup) >> PAGE_SHIFT;
+		     priority && ((usage >> priority) < SWAP_CLUSTER_MAX);
+		     priority--);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
