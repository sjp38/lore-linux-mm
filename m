Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 03EA06B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 00:59:56 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R56wXc007929
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:06:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5C0245DE55
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:06:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FE0845DE50
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:06:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C69551DB8037
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:06:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A78BE08010
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:06:55 +0900 (JST)
Date: Fri, 27 Mar 2009 14:05:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/8] trigger for updating soft limit information
Message-Id: <20090327140528.48c14bce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Check/Update softlimit information at every charge is over-killing, so
we need some filter.

This patch tries to count events in the memcg and if events > threshold
tries to update memcg's soft limit status and reset event counter to 0.
Both of page-in/out is counted as event.

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
