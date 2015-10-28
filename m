Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 149A982F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 22:41:36 -0400 (EDT)
Received: by iofz202 with SMTP id z202so242006810iof.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:41:35 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id a19si19330847igr.11.2015.10.27.19.41.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Oct 2015 19:41:35 -0700 (PDT)
Message-Id: <20151028024131.613062995@linux.com>
Date: Tue, 27 Oct 2015 21:41:16 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [patch 2/3] vmstat: make vmstat_updater deferrable again and shut down on idle
References: <20151028024114.370693277@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=vmstat_quiet_on_idle
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Currently the vmstat updater is not deferrable as a result of commit
ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
interruptions of the applications because the vmstat updater may run at
different times than tick processing. No good.

Make vmstate_update deferrable again and provide a function that
shuts down the vmstat updater when we go idle by folding the differentials.
Shut it down from the load average calculation logic introduced by nohz.

Note that the shepherd thread will continue scanning the differentials
from another processor and will reenable the vmstat workers if it
detects any changes.

Fixes: ba4877b9ca51f80b5d30f304a46762f0509e1635 (do not use deferrable delay)
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1397,6 +1397,20 @@ static void vmstat_update(struct work_st
 }
 
 /*
+ * Switch off vmstat processing and then fold all the remaining differentials
+ * until the diffs stay at zero. The function is used by NOHZ and can only be
+ * invoked when tick processing is not active.
+ */
+void quiet_vmstat(void)
+{
+	do {
+		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
+			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+
+	} while (refresh_cpu_vm_stats(false));
+}
+
+/*
  * Check if the diffs for a certain cpu indicate that
  * an update is needed.
  */
@@ -1428,7 +1442,7 @@ static bool need_update(int cpu)
  */
 static void vmstat_shepherd(struct work_struct *w);
 
-static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
+static DECLARE_DEFERRABLE_WORK(shepherd, vmstat_shepherd);
 
 static void vmstat_shepherd(struct work_struct *w)
 {
Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -211,6 +211,7 @@ extern void __inc_zone_state(struct zone
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
+void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);
 
@@ -272,6 +273,7 @@ static inline void __dec_zone_page_state
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
+static inline void quiet_vmstat(void) { }
 
 static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
Index: linux/kernel/time/tick-sched.c
===================================================================
--- linux.orig/kernel/time/tick-sched.c
+++ linux/kernel/time/tick-sched.c
@@ -667,6 +667,7 @@ static ktime_t tick_nohz_stop_sched_tick
 	 */
 	if (!ts->tick_stopped) {
 		nohz_balance_enter_idle(cpu);
+		quiet_vmstat();
 		calc_load_enter_idle();
 
 		ts->last_tick = hrtimer_get_expires(&ts->sched_timer);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
