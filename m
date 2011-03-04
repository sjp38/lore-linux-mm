Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16A288D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 02:51:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 27DDF3EE0BB
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:51:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ECD345DD74
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:51:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED2F445DE61
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:51:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF51A1DB802C
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:51:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A53A6E08001
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:51:10 +0900 (JST)
Date: Fri, 4 Mar 2011 16:44:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix event counter breakage with THP.
Message-Id: <20110304164450.4cf80ef1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memcg: Fix event counter, event leak with THP

With THP, event counter is updated by the size of large page because
event counter is for catching the change in usage.
This is now used for threshold notifier and soft limit.

Current event counter cathces the event by mask, as

   !(counter & mask)

Before THP, counter is always updated by 1, this never misses target.
But now, this can miss.

This patch makes the trigger for event as

  counter > target.

target is updated when the event happens.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   59 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 45 insertions(+), 14 deletions(-)

Index: mmotm-0303/mm/memcontrol.c
===================================================================
--- mmotm-0303.orig/mm/memcontrol.c
+++ mmotm-0303/mm/memcontrol.c
@@ -73,15 +73,6 @@ static int really_do_swap_account __init
 #define do_swap_account		(0)
 #endif
 
-/*
- * Per memcg event counter is incremented at every pagein/pageout. This counter
- * is used for trigger some periodic events. This is straightforward and better
- * than using jiffies etc. to handle periodic memcg event.
- *
- * These values will be used as !((event) & ((1 <<(thresh)) - 1))
- */
-#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
-#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
 
 /*
  * Statistics for memory cgroup.
@@ -105,10 +96,24 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
+/*
+ * Per memcg event counter is incremented at every pagein/pageout. With THP,
+ * it will be incremated by the number of pages. This counter is used for
+ * for trigger some periodic events. This is straightforward and better
+ * than using jiffies etc. to handle periodic memcg event.
+ */
+enum mem_cgroup_events_target {
+        MEM_CGROUP_TARGET_THRESH,
+        MEM_CGROUP_TARGET_SOFTLIMIT,
+        MEM_CGROUP_NTARGETS,
+};
+#define THRESHOLDS_EVENTS_TARGET (128)
+#define SOFTLIMIT_EVENTS_TARGET (1024)
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
 	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
+        unsigned long targets[MEM_CGROUP_NTARGETS];
 };
 
 /*
@@ -634,13 +639,34 @@ static unsigned long mem_cgroup_get_loca
 	return total;
 }
 
-static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
+static bool __memcg_event_check(struct mem_cgroup *mem, int target)
 {
-	unsigned long val;
+	unsigned long val, next;
 
 	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
+	next = this_cpu_read(mem->stat->targets[target]);
+        /* from time_after() in jiffies.h */
+	return ((long)next - (long)val < 0);
+}
 
-	return !(val & ((1 << event_mask_shift) - 1));
+static void __mem_cgroup_target_update(struct mem_cgroup *mem, int target)
+{
+        unsigned long val, next;
+
+	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
+
+        switch (target) {
+        case MEM_CGROUP_TARGET_THRESH:
+		next = val + THRESHOLDS_EVENTS_TARGET;
+            	break;
+        case MEM_CGROUP_TARGET_SOFTLIMIT:
+		next = val + SOFTLIMIT_EVENTS_TARGET;
+            	break;
+	default:
+		return;
+        }
+
+        this_cpu_write(mem->stat->targets[target], next);
 }
 
 /*
@@ -650,10 +676,15 @@ static bool __memcg_event_check(struct m
 static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 {
 	/* threshold event is triggered in finer grain than soft limit */
-	if (unlikely(__memcg_event_check(mem, THRESHOLDS_EVENTS_THRESH))) {
+	if (unlikely(__memcg_event_check(mem, MEM_CGROUP_TARGET_THRESH))) {
 		mem_cgroup_threshold(mem);
-		if (unlikely(__memcg_event_check(mem, SOFTLIMIT_EVENTS_THRESH)))
+                __mem_cgroup_target_update(mem, MEM_CGROUP_TARGET_THRESH);
+		if (unlikely(__memcg_event_check(mem,
+			MEM_CGROUP_TARGET_SOFTLIMIT))){
 			mem_cgroup_update_tree(mem, page);
+			__mem_cgroup_target_update(mem,
+				MEM_CGROUP_TARGET_SOFTLIMIT);
+		}
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
