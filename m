Message-Id: <20080326013812.186940000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:14 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 03/12] cpumask: reduce stack pressure in sched_affinity
Content-Disposition: inline; filename=cpumask_affinity
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Jackson <pj@sgi.com>, Cliff Wickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>

Remove local and passed cpumask_t variables in kernel/sched.c

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

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

--- linux.trees.git.orig/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
+++ linux.trees.git/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
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
--- linux.trees.git.orig/include/linux/sched.h
+++ linux.trees.git/include/linux/sched.h
@@ -2026,7 +2026,7 @@ static inline void arch_pick_mmap_layout
 }
 #endif
 
-extern long sched_setaffinity(pid_t pid, cpumask_t new_mask);
+extern long sched_setaffinity(pid_t pid, const cpumask_t *new_mask);
 extern long sched_getaffinity(pid_t pid, cpumask_t *mask);
 
 extern int sched_mc_power_savings, sched_smt_power_savings;
--- linux.trees.git.orig/kernel/compat.c
+++ linux.trees.git/kernel/compat.c
@@ -446,7 +446,7 @@ asmlinkage long compat_sys_sched_setaffi
 	if (retval)
 		return retval;
 
-	return sched_setaffinity(pid, new_mask);
+	return sched_setaffinity(pid, &new_mask);
 }
 
 asmlinkage long compat_sys_sched_getaffinity(compat_pid_t pid, unsigned int len,
--- linux.trees.git.orig/kernel/rcupreempt.c
+++ linux.trees.git/kernel/rcupreempt.c
@@ -1007,10 +1007,10 @@ void __synchronize_sched(void)
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
 
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -4706,9 +4706,10 @@ out_unlock:
 	return retval;
 }
 
-long sched_setaffinity(pid_t pid, cpumask_t new_mask)
+long sched_setaffinity(pid_t pid, const cpumask_t *in_mask)
 {
 	cpumask_t cpus_allowed;
+	cpumask_t new_mask = *in_mask;
 	struct task_struct *p;
 	int retval;
 
@@ -4789,7 +4790,7 @@ asmlinkage long sys_sched_setaffinity(pi
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
