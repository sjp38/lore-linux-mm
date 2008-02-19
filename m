Message-Id: <20080219203226.928527000@polaris-admin.engr.sgi.com>
References: <20080219203226.746641000@polaris-admin.engr.sgi.com>
Date: Tue, 19 Feb 2008 12:32:27 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/2] init: move setup of nr_cpu_ids to as early as possible v3
Content-Disposition: inline; filename=mv-set-nr_cpu_ids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move the setting of nr_cpu_ids from sched_init() to init/main.c,
so that it's available as early as possible.

Based on git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
v3: * split generic/x86-specific into two patches
v2: * rebased and retested using linux-2.6.git
    * fixed errors reported by checkpatch.pl
---
 init/main.c    |   20 ++++++++++++++++++++
 kernel/sched.c |    7 -------
 2 files changed, 20 insertions(+), 7 deletions(-)

--- a/init/main.c
+++ b/init/main.c
@@ -365,10 +365,29 @@ static void __init smp_init(void)
 #endif
 
 static inline void setup_per_cpu_areas(void) { }
+static inline void setup_nr_cpu_ids(void) { }
 static inline void smp_prepare_cpus(unsigned int maxcpus) { }
 
 #else
 
+/*
+ * Setup number of possible processor ids.
+ * This is different than setup_max_cpus as it accounts for zero
+ * bits embedded between one bits in the cpu possible map.
+ */
+int nr_cpu_ids __read_mostly = NR_CPUS;
+EXPORT_SYMBOL(nr_cpu_ids);
+
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
 
@@ -542,6 +561,7 @@ asmlinkage void __init start_kernel(void
 	setup_arch(&command_line);
 	setup_command_line(command_line);
 	unwind_setup();
+	setup_nr_cpu_ids();
 	setup_per_cpu_areas();
 	smp_prepare_boot_cpu();	/* arch-specific boot-cpu hooks */
 
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5954,10 +5954,6 @@ void __init migration_init(void)
 
 #ifdef CONFIG_SMP
 
-/* Number of possible processor ids */
-int nr_cpu_ids __read_mostly = NR_CPUS;
-EXPORT_SYMBOL(nr_cpu_ids);
-
 #ifdef CONFIG_SCHED_DEBUG
 
 static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level)
@@ -7193,7 +7189,6 @@ static void init_tg_rt_entry(struct rq *
 
 void __init sched_init(void)
 {
-	int highest_cpu = 0;
 	int i, j;
 
 #ifdef CONFIG_SMP
@@ -7248,7 +7243,6 @@ void __init sched_init(void)
 #endif
 		init_rq_hrtick(rq);
 		atomic_set(&rq->nr_iowait, 0);
-		highest_cpu = i;
 	}
 
 	set_load_weight(&init_task);
@@ -7258,7 +7252,6 @@ void __init sched_init(void)
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
