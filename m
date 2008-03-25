Message-Id: <20080325220651.146336000@polaris-admin.engr.sgi.com>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 15:06:52 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 02/10] init: move setup of nr_cpu_ids to as early as possible v2
Content-Disposition: inline; filename=setup-nr_cpu_ids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Move the setting of nr_cpu_ids from sched_init() to setup_per_cpu_areas(),
so that it's available as early as possible.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

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

v2: rebased on linux-2.6.git + linux-2.6-x86.git
---

 arch/ia64/kernel/acpi.c        |    4 ++++
 arch/ia64/kernel/setup.c       |    7 +++++++
 arch/powerpc/kernel/setup_64.c |    5 ++++-
 arch/sparc64/mm/init.c         |   10 +++++++++-
 arch/x86/kernel/setup.c        |   10 +++++++---
 init/main.c                    |   15 ++++++++++++---
 kernel/sched.c                 |    7 -------
 7 files changed, 43 insertions(+), 15 deletions(-)

--- linux.trees.git.orig/arch/ia64/kernel/acpi.c
+++ linux.trees.git/arch/ia64/kernel/acpi.c
@@ -831,6 +831,10 @@ __init void prefill_possible_map(void)
 
 	for (i = 0; i < possible; i++)
 		cpu_set(i, cpu_possible_map);
+
+#ifdef CONFIG_SMP
+	nr_cpu_ids = possible;
+#endif
 }
 
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
--- linux.trees.git.orig/arch/ia64/kernel/setup.c
+++ linux.trees.git/arch/ia64/kernel/setup.c
@@ -765,6 +765,13 @@ setup_per_cpu_areas (void)
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
 
--- linux.trees.git.orig/arch/powerpc/kernel/setup_64.c
+++ linux.trees.git/arch/powerpc/kernel/setup_64.c
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
--- linux.trees.git.orig/arch/sparc64/mm/init.c
+++ linux.trees.git/arch/sparc64/mm/init.c
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
--- linux.trees.git.orig/arch/x86/kernel/setup.c
+++ linux.trees.git/arch/x86/kernel/setup.c
@@ -54,7 +54,7 @@ EXPORT_SYMBOL(__per_cpu_offset);
  */
 void __init setup_per_cpu_areas(void)
 {
-	int i;
+	int i, highest_cpu = 0;
 	unsigned long size;
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -80,15 +80,19 @@ void __init setup_per_cpu_areas(void)
 		else
 			ptr = alloc_bootmem_pages_node(NODE_DATA(node), size);
 #endif
-		if (!ptr)
-			panic("Cannot allocate cpu data for CPU %d\n", i);
+
 #ifdef CONFIG_X86_64
 		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 #else
 		__per_cpu_offset[i] = ptr - __per_cpu_start;
 #endif
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+
+		if (i > highest_cpu)
+			highest_cpu = i;
 	}
+	nr_cpu_ids = highest_cpu + 1;
+	printk(KERN_DEBUG "NR_CPUS:%d (nr_cpu_ids:%d)\n", NR_CPUS, nr_cpu_ids);
 
 	/* Setup percpu data maps */
 	setup_per_cpu_maps();
--- linux.trees.git.orig/init/main.c
+++ linux.trees.git/init/main.c
@@ -364,16 +364,20 @@ static inline void smp_prepare_cpus(unsi
 
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
@@ -383,7 +387,12 @@ static void __init setup_per_cpu_areas(v
 		__per_cpu_offset[i] = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 		ptr += size;
+		if (i > highest_cpu)
+			highest_cpu = i;
 	}
+
+	nr_cpu_ids = highest_cpu + 1;
+	printk(KERN_DEBUG "NR_CPUS:%d (nr_cpu_ids:%d)\n", NR_CPUS, nr_cpu_ids);
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 
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
