Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4C36B0025
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:11:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C27113EE0BB
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:11:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC8E245DE4E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:11:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B1945DE4D
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:11:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88A2B1DB803A
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:11:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A3BB1DB802C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:11:14 +0900 (JST)
Date: Tue, 10 May 2011 19:04:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/7] memcg: check margin to limit  for async reclaim
Message-Id: <20110510190433.74dba748.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

Now, the kernel supports transparent hugepage and it's used at each page fault
if configured. Then, if the THP allocation hits limit of memcg, it needs to
reclaim memory of HPAGE_SIZE. This tends to require much larger scan than
SWAP_CLUSTER_MAX and increases latency. In other allocations, page scanning
at hitting limit causes latency to some extent.

This patch adds a logic to keep usage margin to the limit in asynchronous way.
When the usage over some threshould (determined automatically), asynchronous
memory reclaim runs and shrink memory to limit - MEMCG_ASYNC_STOP_MARGIN.

By this, there will be no difference in total amount of usage of cpu to
scan the LRU but we'll have a chance to make use of wait time of applications
for freeing memory. For example, when an application read a file or socket,
to fill the newly alloated memory, it needs wait. Async reclaim can make use
of that time and give a chance to reduce latency by background works.

This patch only includes required hooks to trigger async reclaim. Core logics
will be in the following patches.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -115,10 +115,12 @@ enum mem_cgroup_events_index {
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
 	MEM_CGROUP_TARGET_SOFTLIMIT,
+	MEM_CGROUP_TARGET_ASYNC,
 	MEM_CGROUP_NTARGETS,
 };
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define SOFTLIMIT_EVENTS_TARGET (1024)
+#define ASYNC_EVENTS_TARGET	(512)	/* assume x86-64's hpagesize */
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -211,6 +213,31 @@ static void mem_cgroup_threshold(struct 
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
 /*
+ * For example, with transparent hugepages, memory reclaim scan at hitting
+ * limit can very long as to reclaim HPAGE_SIZE of memory. This increases
+ * latency of page fault and may cause fallback. At usual page allocation,
+ * we'll see some (shorter) latency, too. To reduce latency, it's appreciated
+ * to free memory in background to make margin to the limit. This consumes
+ * cpu but we'll have a chance to make use of wait time of applications
+ * (read disk etc..) by asynchronous reclaim.
+ *
+ * This async reclaim tries to reclaim HPAGE_SIZE * 2 of pages when margin
+ * to the limit is smaller than HPAGE_SIZE * 2. This will be enabled
+ * automatically when the limit is set and it's greater than the threshold.
+ */
+#if HPAGE_SIZE != PAGE_SIZE
+#define MEMCG_ASYNC_LIMIT_THRESH      (HPAGE_SIZE * 64)
+#define MEMCG_ASYNC_START_MARGIN      (HPAGE_SIZE * 2)
+#define MEMCG_ASYNC_STOP_MARGIN	      (HPAGE_SIZE * 4)
+#else /* make the margin as 4M bytes */
+#define MEMCG_ASYNC_LIMIT_THRESH      (128 * 1024 * 1024)
+#define MEMCG_ASYNC_START_MARGIN      (4 * 1024 * 1024)
+#define MEMCG_ASYNC_STOP_MARGIN       (8 * 1024 * 1024)
+#endif
+
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -259,6 +286,7 @@ struct mem_cgroup {
 
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
+	bool		need_async_reclaim;
 
 	/* protect arrays of thresholds */
 	struct mutex thresholds_lock;
@@ -722,6 +750,9 @@ static void __mem_cgroup_target_update(s
 	case MEM_CGROUP_TARGET_SOFTLIMIT:
 		next = val + SOFTLIMIT_EVENTS_TARGET;
 		break;
+	case MEM_CGROUP_TARGET_ASYNC:
+		next = val + ASYNC_EVENTS_TARGET;
+		break;
 	default:
 		return;
 	}
@@ -745,6 +776,11 @@ static void memcg_check_events(struct me
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
+		if (__memcg_event_check(mem, MEM_CGROUP_TARGET_ASYNC)) {
+			mem_cgroup_may_async_reclaim(mem);
+			__mem_cgroup_target_update(mem,
+				MEM_CGROUP_TARGET_ASYNC);
+		}
 	}
 }
 
@@ -3376,6 +3412,11 @@ static int mem_cgroup_resize_limit(struc
 				memcg->memsw_is_minimum = true;
 			else
 				memcg->memsw_is_minimum = false;
+
+			if (val >= MEMCG_ASYNC_LIMIT_THRESH)
+				memcg->need_async_reclaim = true;
+			else
+				memcg->need_async_reclaim = false;
 		}
 		mutex_unlock(&set_limit_mutex);
 
@@ -3553,6 +3594,15 @@ unsigned long mem_cgroup_soft_limit_recl
 	return nr_reclaimed;
 }
 
+static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
+{
+	if (!mem->need_async_reclaim)
+		return;
+	if (res_counter_margin(&mem->res) <= MEMCG_ASYNC_START_MARGIN) {
+		/* Fill here */
+	}
+}
+
 /*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
