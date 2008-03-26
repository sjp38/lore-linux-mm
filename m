Message-Id: <20080326212347.654559000@polaris-admin.engr.sgi.com>
References: <20080326212347.466221000@polaris-admin.engr.sgi.com>
Date: Wed, 26 Mar 2008 14:23:48 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/2] init: move setup of nr_cpu_ids to as early as possible v3
Content-Disposition: inline; filename=setup-nr_cpu_ids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Move the setting of nr_cpu_ids from sched_init() to start_kernel()
so that it's available as early as possible.

Note that an arch has the option of setting it even earlier if need be,
but it should not result in a different value than the setup_nr_cpu_ids()
function.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 init/main.c    |   17 +++++++++++++++++
 kernel/sched.c |    7 -------
 2 files changed, 17 insertions(+), 7 deletions(-)

--- linux.trees.git.orig/init/main.c
+++ linux.trees.git/init/main.c
@@ -360,10 +360,26 @@ static void __init smp_init(void)
 #endif
 
 static inline void setup_per_cpu_areas(void) { }
+static inline void setup_nr_cpu_ids(void) { }
 static inline void smp_prepare_cpus(unsigned int maxcpus) { }
 
 #else
 
+/* Setup number of possible processor ids */
+int nr_cpu_ids __read_mostly = NR_CPUS;
+EXPORT_SYMBOL(nr_cpu_ids);
+
+/* An arch may set nr_cpu_ids earlier if needed, so this would be redundant */
+static void __init setup_nr_cpu_ids(void)
+{
+	int cpu, highest_cpu = 0;
+
+	for_each_possible_cpu(cpu)
+		highest_cpu = cpu;
+
+	nr_cpu_ids = highest_cpu + 1;
+}
+
 #ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
 
@@ -544,6 +560,7 @@ asmlinkage void __init start_kernel(void
 	setup_command_line(command_line);
 	unwind_setup();
 	setup_per_cpu_areas();
+	setup_nr_cpu_ids();
 	smp_prepare_boot_cpu();	/* arch-specific boot-cpu hooks */
 
 	/*
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -5923,10 +5923,6 @@ void __init migration_init(void)
 
 #ifdef CONFIG_SMP
 
-/* Number of possible processor ids */
-int nr_cpu_ids __read_mostly = NR_CPUS;
-EXPORT_SYMBOL(nr_cpu_ids);
-
 #ifdef CONFIG_SCHED_DEBUG
 
 static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level)
@@ -7152,7 +7148,6 @@ static void init_tg_rt_entry(struct rq *
 
 void __init sched_init(void)
 {
-	int highest_cpu = 0;
 	int i, j;
 
 #ifdef CONFIG_SMP
@@ -7207,7 +7202,6 @@ void __init sched_init(void)
 #endif
 		init_rq_hrtick(rq);
 		atomic_set(&rq->nr_iowait, 0);
-		highest_cpu = i;
 	}
 
 	set_load_weight(&init_task);
@@ -7217,7 +7211,6 @@ void __init sched_init(void)
 #endif
 
 #ifdef CONFIG_SMP
-	nr_cpu_ids = highest_cpu + 1;
 	open_softirq(SCHED_SOFTIRQ, run_rebalance_domains, NULL);
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
