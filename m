Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF0D66B473D
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:23:28 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id s27-v6so1091473ybe.14
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:23:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y136-v6sor396254ywy.18.2018.08.28.10.23.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 10:23:27 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/9] sched: loadavg: consolidate LOAD_INT, LOAD_FRAC, CALC_LOAD
Date: Tue, 28 Aug 2018 13:22:53 -0400
Message-Id: <20180828172258.3185-5-hannes@cmpxchg.org>
In-Reply-To: <20180828172258.3185-1-hannes@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

There are several definitions of those functions/macros in places that
mess with fixed-point load averages. Provide an official version.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 .../platforms/cell/cpufreq_spudemand.c        |  2 +-
 arch/powerpc/platforms/cell/spufs/sched.c     |  9 +++-----
 arch/s390/appldata/appldata_os.c              |  4 ----
 drivers/cpuidle/governors/menu.c              |  4 ----
 fs/proc/loadavg.c                             |  3 ---
 include/linux/sched/loadavg.h                 | 21 +++++++++++++++----
 kernel/debug/kdb/kdb_main.c                   |  7 +------
 kernel/sched/loadavg.c                        | 15 -------------
 8 files changed, 22 insertions(+), 43 deletions(-)

diff --git a/arch/powerpc/platforms/cell/cpufreq_spudemand.c b/arch/powerpc/platforms/cell/cpufreq_spudemand.c
index 882944c36ef5..5d8e8b6bb1cc 100644
--- a/arch/powerpc/platforms/cell/cpufreq_spudemand.c
+++ b/arch/powerpc/platforms/cell/cpufreq_spudemand.c
@@ -49,7 +49,7 @@ static int calc_freq(struct spu_gov_info_struct *info)
 	cpu = info->policy->cpu;
 	busy_spus = atomic_read(&cbe_spu_info[cpu_to_node(cpu)].busy_spus);
 
-	CALC_LOAD(info->busy_spus, EXP, busy_spus * FIXED_1);
+	info->busy_spus = calc_load(info->busy_spus, EXP, busy_spus * FIXED_1);
 	pr_debug("cpu %d: busy_spus=%d, info->busy_spus=%ld\n",
 			cpu, busy_spus, info->busy_spus);
 
diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index c9ef3c532169..9fcccb4490b9 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -987,9 +987,9 @@ static void spu_calc_load(void)
 	unsigned long active_tasks; /* fixed-point */
 
 	active_tasks = count_active_contexts() * FIXED_1;
-	CALC_LOAD(spu_avenrun[0], EXP_1, active_tasks);
-	CALC_LOAD(spu_avenrun[1], EXP_5, active_tasks);
-	CALC_LOAD(spu_avenrun[2], EXP_15, active_tasks);
+	spu_avenrun[0] = calc_load(spu_avenrun[0], EXP_1, active_tasks);
+	spu_avenrun[1] = calc_load(spu_avenrun[1], EXP_5, active_tasks);
+	spu_avenrun[2] = calc_load(spu_avenrun[2], EXP_15, active_tasks);
 }
 
 static void spusched_wake(struct timer_list *unused)
@@ -1071,9 +1071,6 @@ void spuctx_switch_state(struct spu_context *ctx,
 	}
 }
 
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static int show_spu_loadavg(struct seq_file *s, void *private)
 {
 	int a, b, c;
diff --git a/arch/s390/appldata/appldata_os.c b/arch/s390/appldata/appldata_os.c
index 433a994b1a89..54f375627532 100644
--- a/arch/s390/appldata/appldata_os.c
+++ b/arch/s390/appldata/appldata_os.c
@@ -25,10 +25,6 @@
 
 #include "appldata.h"
 
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 /*
  * OS data
  *
diff --git a/drivers/cpuidle/governors/menu.c b/drivers/cpuidle/governors/menu.c
index 1aef60d160eb..e508d08b7ccb 100644
--- a/drivers/cpuidle/governors/menu.c
+++ b/drivers/cpuidle/governors/menu.c
@@ -131,10 +131,6 @@ struct menu_device {
 	int		interval_ptr;
 };
 
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static inline int get_loadavg(unsigned long load)
 {
 	return LOAD_INT(load) * 10 + LOAD_FRAC(load) / 10;
diff --git a/fs/proc/loadavg.c b/fs/proc/loadavg.c
index d06694757201..8468baee951d 100644
--- a/fs/proc/loadavg.c
+++ b/fs/proc/loadavg.c
@@ -10,9 +10,6 @@
 #include <linux/seqlock.h>
 #include <linux/time.h>
 
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
-
 static int loadavg_proc_show(struct seq_file *m, void *v)
 {
 	unsigned long avnrun[3];
diff --git a/include/linux/sched/loadavg.h b/include/linux/sched/loadavg.h
index 80bc84ba5d2a..cc9cc62bb1f8 100644
--- a/include/linux/sched/loadavg.h
+++ b/include/linux/sched/loadavg.h
@@ -22,10 +22,23 @@ extern void get_avenrun(unsigned long *loads, unsigned long offset, int shift);
 #define EXP_5		2014		/* 1/exp(5sec/5min) */
 #define EXP_15		2037		/* 1/exp(5sec/15min) */
 
-#define CALC_LOAD(load,exp,n) \
-	load *= exp; \
-	load += n*(FIXED_1-exp); \
-	load >>= FSHIFT;
+/*
+ * a1 = a0 * e + a * (1 - e)
+ */
+static inline unsigned long
+calc_load(unsigned long load, unsigned long exp, unsigned long active)
+{
+	unsigned long newload;
+
+	newload = load * exp + active * (FIXED_1 - exp);
+	if (active >= load)
+		newload += FIXED_1-1;
+
+	return newload / FIXED_1;
+}
+
+#define LOAD_INT(x) ((x) >> FSHIFT)
+#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
 
 extern void calc_global_load(unsigned long ticks);
 
diff --git a/kernel/debug/kdb/kdb_main.c b/kernel/debug/kdb/kdb_main.c
index 2ddfce8f1e8f..bb4fe4e1a601 100644
--- a/kernel/debug/kdb/kdb_main.c
+++ b/kernel/debug/kdb/kdb_main.c
@@ -2556,16 +2556,11 @@ static int kdb_summary(int argc, const char **argv)
 	}
 	kdb_printf("%02ld:%02ld\n", val.uptime/(60*60), (val.uptime/60)%60);
 
-	/* lifted from fs/proc/proc_misc.c::loadavg_read_proc() */
-
-#define LOAD_INT(x) ((x) >> FSHIFT)
-#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
 	kdb_printf("load avg   %ld.%02ld %ld.%02ld %ld.%02ld\n",
 		LOAD_INT(val.loads[0]), LOAD_FRAC(val.loads[0]),
 		LOAD_INT(val.loads[1]), LOAD_FRAC(val.loads[1]),
 		LOAD_INT(val.loads[2]), LOAD_FRAC(val.loads[2]));
-#undef LOAD_INT
-#undef LOAD_FRAC
+
 	/* Display in kilobytes */
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	kdb_printf("\nMemTotal:       %8lu kB\nMemFree:        %8lu kB\n"
diff --git a/kernel/sched/loadavg.c b/kernel/sched/loadavg.c
index a171c1258109..54fbdfb2d86c 100644
--- a/kernel/sched/loadavg.c
+++ b/kernel/sched/loadavg.c
@@ -91,21 +91,6 @@ long calc_load_fold_active(struct rq *this_rq, long adjust)
 	return delta;
 }
 
-/*
- * a1 = a0 * e + a * (1 - e)
- */
-static unsigned long
-calc_load(unsigned long load, unsigned long exp, unsigned long active)
-{
-	unsigned long newload;
-
-	newload = load * exp + active * (FIXED_1 - exp);
-	if (active >= load)
-		newload += FIXED_1-1;
-
-	return newload / FIXED_1;
-}
-
 #ifdef CONFIG_NO_HZ_COMMON
 /*
  * Handle NO_HZ for the global load-average.
-- 
2.18.0
