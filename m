Message-Id: <20080325023121.388373000@polaris-admin.engr.sgi.com>
References: <20080325023120.859257000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:31:23 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 03/12] cpumask: reduce stack pressure in sched_affinity
Content-Disposition: inline; filename=cpumask_affinity
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, Cliff Wickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>

Remove local and passed cpumask_t variables in kernel/sched.c

Based on linux-2.6.25-rc5-mm1

Cc: Ingo Molnar <mingo@elte.hu>
Cc: Paul Jackson <pj@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/cpu/mcheck/mce_amd_64.c |   46 ++++++++++++++++----------------
 include/linux/sched.h                   |    2 -
 kernel/compat.c                         |    2 -
 kernel/rcupreempt.c                     |    4 +-
 kernel/sched.c                          |    5 ++-
 5 files changed, 30 insertions(+), 29 deletions(-)

--- linux-2.6.25-rc5.orig/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
+++ linux-2.6.25-rc5/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
@@ -251,18 +251,18 @@ struct threshold_attr {
 	ssize_t(*store) (struct threshold_block *, const char *, size_t count);
 };
 
-static cpumask_t affinity_set(unsigned int cpu)
+static void affinity_set(unsigned int cpu, cpumask_t *oldmask,
+						cpumask_t *newmask)
 {
-	cpumask_t oldmask = current->cpus_allowed;
-	cpumask_t newmask = CPU_MASK_NONE;
-	cpu_set(cpu, newmask);
-	set_cpus_allowed(current, &newmask);
-	return oldmask;
+	*oldmask = current->cpus_allowed;
+	*newmask = CPU_MASK_NONE;
+	cpu_set(cpu, *newmask);
+	set_cpus_allowed(current, newmask);
 }
 
-static void affinity_restore(cpumask_t oldmask)
+static void affinity_restore(cpumask_t *oldmask)
 {
-	set_cpus_allowed(current, &oldmask);
+	set_cpus_allowed(current, oldmask);
 }
 
 #define SHOW_FIELDS(name)                                           \
@@ -277,15 +277,15 @@ static ssize_t store_interrupt_enable(st
 				      const char *buf, size_t count)
 {
 	char *end;
-	cpumask_t oldmask;
+	cpumask_t oldmask, newmask;
 	unsigned long new = simple_strtoul(buf, &end, 0);
 	if (end == buf)
 		return -EINVAL;
 	b->interrupt_enable = !!new;
 
-	oldmask = affinity_set(b->cpu);
+	affinity_set(b->cpu, &oldmask, &newmask);
 	threshold_restart_bank(b, 0, 0);
-	affinity_restore(oldmask);
+	affinity_restore(&oldmask);
 
 	return end - buf;
 }
@@ -294,7 +294,7 @@ static ssize_t store_threshold_limit(str
 				     const char *buf, size_t count)
 {
 	char *end;
-	cpumask_t oldmask;
+	cpumask_t oldmask, newmask;
 	u16 old;
 	unsigned long new = simple_strtoul(buf, &end, 0);
 	if (end == buf)
@@ -306,9 +306,9 @@ static ssize_t store_threshold_limit(str
 	old = b->threshold_limit;
 	b->threshold_limit = new;
 
-	oldmask = affinity_set(b->cpu);
+	affinity_set(b->cpu, &oldmask, &newmask);
 	threshold_restart_bank(b, 0, old);
-	affinity_restore(oldmask);
+	affinity_restore(&oldmask);
 
 	return end - buf;
 }
@@ -316,10 +316,10 @@ static ssize_t store_threshold_limit(str
 static ssize_t show_error_count(struct threshold_block *b, char *buf)
 {
 	u32 high, low;
-	cpumask_t oldmask;
-	oldmask = affinity_set(b->cpu);
+	cpumask_t oldmask, newmask;
+	affinity_set(b->cpu, &oldmask, &newmask);
 	rdmsr(b->address, low, high);
-	affinity_restore(oldmask);
+	affinity_restore(&oldmask);
 	return sprintf(buf, "%x\n",
 		       (high & 0xFFF) - (THRESHOLD_MAX - b->threshold_limit));
 }
@@ -327,10 +327,10 @@ static ssize_t show_error_count(struct t
 static ssize_t store_error_count(struct threshold_block *b,
 				 const char *buf, size_t count)
 {
-	cpumask_t oldmask;
-	oldmask = affinity_set(b->cpu);
+	cpumask_t oldmask, newmask;
+	affinity_set(b->cpu, &oldmask, &newmask);
 	threshold_restart_bank(b, 1, 0);
-	affinity_restore(oldmask);
+	affinity_restore(&oldmask);
 	return 1;
 }
 
@@ -468,7 +468,7 @@ static __cpuinit int threshold_create_ba
 {
 	int i, err = 0;
 	struct threshold_bank *b = NULL;
-	cpumask_t oldmask = CPU_MASK_NONE;
+	cpumask_t oldmask = CPU_MASK_NONE, newmask;
 	char name[32];
 
 	sprintf(name, "threshold_bank%i", bank);
@@ -519,10 +519,10 @@ static __cpuinit int threshold_create_ba
 
 	per_cpu(threshold_banks, cpu)[bank] = b;
 
-	oldmask = affinity_set(cpu);
+	affinity_set(cpu, &oldmask, &newmask);
 	err = allocate_threshold_blocks(cpu, bank, 0,
 					MSR_IA32_MC0_MISC + bank * 4);
-	affinity_restore(oldmask);
+	affinity_restore(&oldmask);
 
 	if (err)
 		goto out_free;
--- linux-2.6.25-rc5.orig/include/linux/sched.h
+++ linux-2.6.25-rc5/include/linux/sched.h
@@ -2055,7 +2055,7 @@ ftrace_wake_up_new_task(struct task_stru
 }
 #endif
 
-extern long sched_setaffinity(pid_t pid, cpumask_t new_mask);
+extern long sched_setaffinity(pid_t pid, const cpumask_t *new_mask);
 extern long sched_getaffinity(pid_t pid, cpumask_t *mask);
 
 extern int sched_mc_power_savings, sched_smt_power_savings;
--- linux-2.6.25-rc5.orig/kernel/compat.c
+++ linux-2.6.25-rc5/kernel/compat.c
@@ -445,7 +445,7 @@ asmlinkage long compat_sys_sched_setaffi
 	if (retval)
 		return retval;
 
-	return sched_setaffinity(pid, new_mask);
+	return sched_setaffinity(pid, &new_mask);
 }
 
 asmlinkage long compat_sys_sched_getaffinity(compat_pid_t pid, unsigned int len,
--- linux-2.6.25-rc5.orig/kernel/rcupreempt.c
+++ linux-2.6.25-rc5/kernel/rcupreempt.c
@@ -1005,10 +1005,10 @@ void __synchronize_sched(void)
 	if (sched_getaffinity(0, &oldmask) < 0)
 		oldmask = cpu_possible_map;
 	for_each_online_cpu(cpu) {
-		sched_setaffinity(0, cpumask_of_cpu(cpu));
+		sched_setaffinity(0, &cpumask_of_cpu(cpu));
 		schedule();
 	}
-	sched_setaffinity(0, oldmask);
+	sched_setaffinity(0, &oldmask);
 }
 EXPORT_SYMBOL_GPL(__synchronize_sched);
 
--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -4780,9 +4780,10 @@ out_unlock:
 	return retval;
 }
 
-long sched_setaffinity(pid_t pid, cpumask_t new_mask)
+long sched_setaffinity(pid_t pid, const cpumask_t *in_mask)
 {
 	cpumask_t cpus_allowed;
+	cpumask_t new_mask = *in_mask;
 	struct task_struct *p;
 	int retval;
 
@@ -4863,7 +4864,7 @@ asmlinkage long sys_sched_setaffinity(pi
 	if (retval)
 		return retval;
 
-	return sched_setaffinity(pid, new_mask);
+	return sched_setaffinity(pid, &new_mask);
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
