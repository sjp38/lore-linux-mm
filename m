Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 728F06B0266
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 13:39:04 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id y204so26569539oie.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 10:39:04 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0065.outbound.protection.outlook.com. [157.56.112.65])
        by mx.google.com with ESMTPS id p7si14484289oew.31.2016.04.05.10.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 10:39:03 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v12 02/13] vmstat: add vmstat_idle function
Date: Tue, 5 Apr 2016 13:38:31 -0400
Message-ID: <1459877922-15512-3-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1459877922-15512-1-git-send-email-cmetcalf@mellanox.com>
References: <1459877922-15512-1-git-send-email-cmetcalf@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@ezchip.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van
 Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@mellanox.com>

This function checks to see if a vmstat worker is not running,
and the vmstat diffs don't require an update.  The function is
called from the task-isolation code to see if we need to
actually do some work to quiet vmstat.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
 include/linux/vmstat.h |  2 ++
 mm/vmstat.c            | 12 ++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 43b2f1c33266..504ebd1fdf33 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -191,6 +191,7 @@ extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void quiet_vmstat(void);
 void quiet_vmstat_sync(void);
+bool vmstat_idle(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);
 
@@ -253,6 +254,7 @@ static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
 static inline void quiet_vmstat(void) { }
 static inline void quiet_vmstat_sync(void) { }
+static inline bool vmstat_idle(void) { return true; }
 
 static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7a1cfe383349..fa34ea480ac0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1469,6 +1469,18 @@ void quiet_vmstat_sync(void)
 }
 
 /*
+ * Report on whether vmstat processing is quiesced on the core currently:
+ * no vmstat worker running and no vmstat updates to perform.
+ */
+bool vmstat_idle(void)
+{
+	int cpu = smp_processor_id();
+	return cpumask_test_cpu(cpu, cpu_stat_off) &&
+		!delayed_work_pending(this_cpu_ptr(&vmstat_work)) &&
+		!need_update(cpu);
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
