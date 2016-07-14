Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7783F6B0264
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:48:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so1534960wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:48:37 -0700 (PDT)
Received: from mellanox.co.il (mail-il-dmz.mellanox.com. [193.47.165.129])
        by mx.google.com with ESMTP id t4si171508wma.107.2016.07.14.13.48.36
        for <linux-mm@kvack.org>;
        Thu, 14 Jul 2016 13:48:36 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v13 02/12] vmstat: add vmstat_idle function
Date: Thu, 14 Jul 2016 16:48:09 -0400
Message-Id: <1468529299-27929-3-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1468529299-27929-1-git-send-email-cmetcalf@mellanox.com>
References: <1468529299-27929-1-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@mellanox.com>

This function checks to see if a vmstat worker is not running,
and the vmstat diffs don't require an update.  The function is
called from the task-isolation code to see if we need to
actually do some work to quiet vmstat.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
 include/linux/vmstat.h |  2 ++
 mm/vmstat.c            | 10 ++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 0d96b6b2079d..1168c612a580 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -189,6 +189,7 @@ extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void quiet_vmstat(void);
 void quiet_vmstat_sync(void);
+bool vmstat_idle(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);
 
@@ -255,6 +256,7 @@ static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
 static inline void quiet_vmstat(void) { }
 static inline void quiet_vmstat_sync(void) { }
+static inline bool vmstat_idle(void) { return true; }
 
 static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 945af7ab624e..d742947df35d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1492,6 +1492,16 @@ void quiet_vmstat_sync(void)
 }
 
 /*
+ * Report on whether vmstat processing is quiesced on the core currently:
+ * no vmstat worker running and no vmstat updates to perform.
+ */
+bool vmstat_idle(void)
+{
+	return !delayed_work_pending(this_cpu_ptr(&vmstat_work)) &&
+		!need_update(smp_processor_id());
+}
+
+/*
  * Shepherd worker thread that checks the
  * differentials of processors that have their worker
  * threads for vm statistics updates disabled because of
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
