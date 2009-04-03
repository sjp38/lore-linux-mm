Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4EB2F6B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:13:28 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338Dcm2031570
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:13:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F79E45DE54
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:13:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6119045DE53
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:13:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 475301DB803C
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:13:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E592F1DB805E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:13:37 +0900 (JST)
Date: Fri, 3 Apr 2009 17:12:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/9] soft limit update filter
Message-Id: <20090403171202.cd7e094b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

No changes from v1.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Check/Update softlimit information at every charge is over-killing, so
we need some filter.

This patch tries to count events in the memcg and if events > threshold
tries to update memcg's soft limit status and reset event counter to 0.

Event counter is maintained by per-cpu which has been already used,
Then, no siginificant overhead(extra cache-miss etc..) in theory.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar23/mm/memcontrol.c
@@ -66,6 +66,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 
+	MEM_CGROUP_STAT_EVENTS,  /* sum of page-in/page-out for internal use */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -105,6 +106,22 @@ static s64 mem_cgroup_local_usage(struct
 	return ret;
 }
 
+/* For intenal use of per-cpu event counting. */
+
+static inline void
+__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
+		enum mem_cgroup_stat_index idx)
+{
+	stat->count[idx] = 0;
+}
+
+static inline s64
+__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
+			    enum mem_cgroup_stat_index idx)
+{
+	return stat->count[idx];
+}
+
 /*
  * per-zone information in memory controller.
  */
@@ -235,6 +252,8 @@ static void mem_cgroup_charge_statistics
 	else
 		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
+
 	put_cpu();
 }
 
@@ -897,9 +916,26 @@ static void record_last_oom(struct mem_c
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
+#define SOFTLIMIT_EVENTS_THRESH (1024) /* 1024 times of page-in/out */
+/*
+ * Returns true if sum of page-in/page-out events since last check is
+ * over SOFTLIMIT_EVENT_THRESH. (counter is per-cpu.)
+ */
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
-	return false;
+	bool ret = false;
+	int cpu = get_cpu();
+	s64 val;
+	struct mem_cgroup_stat_cpu *cpustat;
+
+	cpustat = &mem->stat.cpustat[cpu];
+	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
+	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
+		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
+		ret = true;
+	}
+	put_cpu();
+	return ret;
 }
 
 static void mem_cgroup_update_soft_limit(struct mem_cgroup *mem)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
