Message-Id: <20080325021955.394649000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:19:56 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 02/10] init: move setup of nr_cpu_ids to as early as possible v4
Content-Disposition: inline; filename=setup-nr_cpu_ids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Move the setting of nr_cpu_ids from sched_init() to setup_per_cpu_areas(),
so that it's available as early as possible.

Based on linux-2.6.25-rc5-mm1

# ia64
Cc: Tony Luck <tony.luck@intel.com>

# powerpc
Cc: Paul Mackerras <paulus@samba.org>
Cc: Anton Blanchard <anton@samba.org>

# sparc
Cc: David S. Miller <davem@davemloft.net>
Cc: William L. Irwin <wli@holomorphy.com>

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---

Moved from the zero-based percpu variables patchset and redone to be
integrated with setup_per_cpu_areas instead of being called before
that function.  This had to be done because some arch's call
prefill_possible_map() from setup_per_cpu_areas() which may increase
the number of possible cpus.

---

 arch/ia64/kernel/acpi.c        |    4 ++++
 arch/ia64/kernel/setup.c       |    7 +++++++
 arch/powerpc/kernel/setup_64.c |    5 ++++-
 arch/sparc64/mm/init.c         |   10 +++++++++-
 arch/x86/kernel/setup64.c      |    7 ++++++-
 init/main.c                    |   15 ++++++++++++---
 kernel/sched.c                 |    7 -------
 7 files changed, 42 insertions(+), 13 deletions(-)

--- linux-2.6.25-rc5.orig/arch/ia64/kernel/acpi.c
+++ linux-2.6.25-rc5/arch/ia64/kernel/acpi.c
@@ -831,6 +831,10 @@ __init void prefill_possible_map(void)
 
 	for (i = 0; i < possible; i++)
 		cpu_set(i, cpu_possible_map);
+
+#ifdef CONFIG_SMP
+	nr_cpu_ids = possible;
+#endif
 }
 
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
--- linux-2.6.25-rc5.orig/arch/ia64/kernel/setup.c
+++ linux-2.6.25-rc5/arch/ia64/kernel/setup.c
@@ -766,6 +766,13 @@ setup_per_cpu_areas (void)
 	/* start_kernel() requires this... */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
+#elif defined(CONFIG_SMP)
+	int cpu, highest_cpu = 0;
+
+	for_each_possible_cpu(cpu)
+		highest_cpu = cpu;
+
+	nr_cpu_ids = highest_cpu + 1;
 #endif
 }
 
--- linux-2.6.25-rc5.orig/arch/powerpc/kernel/setup_64.c
+++ linux-2.6.25-rc5/arch/powerpc/kernel/setup_64.c
@@ -576,7 +576,7 @@ void cpu_die(void)
 #ifdef CONFIG_SMP
 void __init setup_per_cpu_areas(void)
 {
-	int i;
+	int i, highest_cpu = 0;
 	unsigned long size;
 	char *ptr;
 
@@ -594,7 +594,10 @@ void __init setup_per_cpu_areas(void)
 
 		paca[i].data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+		if (i > highest_cpu)
+			highest_cpu = i;
 	}
+	nr_cpu_ids = highest_cpu + 1;
 
 	/* Now that per_cpu is setup, initialize cpu_sibling_map */
 	smp_setup_cpu_sibling_map();
--- linux-2.6.25-rc5.orig/arch/sparc64/mm/init.c
+++ linux-2.6.25-rc5/arch/sparc64/mm/init.c
@@ -1292,10 +1292,18 @@ pgd_t swapper_pg_dir[2048];
 static void sun4u_pgprot_init(void);
 static void sun4v_pgprot_init(void);
 
-/* Dummy function */
+#ifdef CONFIG_SMP
+/* set nr_cpu_ids */
 void __init setup_per_cpu_areas(void)
 {
+	int cpu, highest_cpu = 0;
+
+	for_each_possible_cpu(cpu)
+		highest_cpu = cpu;
+
+	nr_cpu_ids = highest_cpu + 1;
 }
+#endif
 
 void __init paging_init(void)
 {
--- linux-2.6.25-rc5.orig/arch/x86/kernel/setup64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/setup64.c
@@ -122,7 +122,7 @@ static void __init setup_per_cpu_maps(vo
  */
 void __init setup_per_cpu_areas(void)
 { 
-	int i;
+	int i, highest_cpu = 0;
 	unsigned long size;
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -157,7 +157,12 @@ void __init setup_per_cpu_areas(void)
 
 		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+
+		if (i > highest_cpu)
+			highest_cpu = i;
 	}
+	nr_cpu_ids = highest_cpu + 1;
+	printk(KERN_DEBUG "NR_CPUS: %d (nr_cpu_ids: %d)\n", NR_CPUS, nr_cpu_ids);
 
 	/* Setup percpu data maps */
 	setup_per_cpu_maps();
--- linux-2.6.25-rc5.orig/init/main.c
+++ linux-2.6.25-rc5/init/main.c
@@ -369,16 +369,20 @@ static inline void smp_prepare_cpus(unsi
 
 #else
 
+int nr_cpu_ids __read_mostly = NR_CPUS;
+EXPORT_SYMBOL(nr_cpu_ids);
+
 #ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
-
 EXPORT_SYMBOL(__per_cpu_offset);
 
+/* nr_cpu_ids is set as a side effect */
 static void __init setup_per_cpu_areas(void)
 {
-	unsigned long size, i;
-	char *ptr;
+	unsigned long size;
+	int i, highest_cpu = 0;
 	unsigned long nr_possible_cpus = num_possible_cpus();
+	char *ptr;
 
 	/* Copy section for each CPU (we discard the original) */
 	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
@@ -388,7 +392,12 @@ static void __init setup_per_cpu_areas(v
 		__per_cpu_offset[i] = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 		ptr += size;
+		if (i > highest_cpu)
+			highest_cpu = i;
 	}
+
+	nr_cpu_ids = highest_cpu + 1;
+	printk(KERN_DEBUG "NR_CPUS: %d (nr_cpu_ids: %d)\n", NR_CPUS, nr_cpu_ids);
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 
--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -5995,10 +5995,6 @@ void __init migration_init(void)
 
 #ifdef CONFIG_SMP
 
-/* Number of possible processor ids */
-int nr_cpu_ids __read_mostly = NR_CPUS;
-EXPORT_SYMBOL(nr_cpu_ids);
-
 #ifdef CONFIG_SCHED_DEBUG
 
 static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level)
@@ -7199,7 +7195,6 @@ static void init_tg_rt_entry(struct rq *
 
 void __init sched_init(void)
 {
-	int highest_cpu = 0;
 	int i, j;
 
 #ifdef CONFIG_SMP
@@ -7255,7 +7250,6 @@ void __init sched_init(void)
 #endif
 		init_rq_hrtick(rq);
 		atomic_set(&rq->nr_iowait, 0);
-		highest_cpu = i;
 	}
 
 	set_load_weight(&init_task);
@@ -7265,7 +7259,6 @@ void __init sched_init(void)
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
