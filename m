Message-Id: <20080326013812.028736000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:13 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 02/12] cpumask: pass pointer to cpumask for set_cpus_allowed() v2
Content-Disposition: inline; filename=set_cpus_allowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Instead of passing by value, the "newly allowed cpus" cpumask
argument, pass a pointer:

-int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+int set_cpus_allowed(struct task_struct *p, const cpumask_t *new_mask)

This is a major ABI change and unfortunately touches a number of files
as the function is very commonly used.  I had thought of using a macro
to "silently" pass the 2nd arg as a pointer, but you lose in the
situation where you already have a pointer to the new cpumask.

This removes 10792 bytes of stack usage.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
v2: rebased on linux-2.6.git + linux-2.6-x86.git
---
 arch/arm/mach-integrator/cpu.c                   |   10 ++++-----
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c          |   10 ++++-----
 arch/ia64/kernel/salinfo.c                       |    4 +--
 arch/ia64/kernel/topology.c                      |    4 +--
 arch/ia64/sn/kernel/sn2/sn_hwperf.c              |    4 +--
 arch/ia64/sn/kernel/xpc_main.c                   |    4 +--
 arch/mips/kernel/mips-mt-fpaff.c                 |    4 +--
 arch/mips/kernel/traps.c                         |    2 -
 arch/powerpc/kernel/smp.c                        |    4 +--
 arch/powerpc/kernel/sysfs.c                      |    4 +--
 arch/powerpc/platforms/pseries/rtasd.c           |    4 +--
 arch/sh/kernel/cpufreq.c                         |    4 +--
 arch/sparc64/kernel/sysfs.c                      |    4 +--
 arch/sparc64/kernel/us2e_cpufreq.c               |    8 +++----
 arch/sparc64/kernel/us3_cpufreq.c                |    8 +++----
 arch/x86/kernel/acpi/cstate.c                    |    4 +--
 arch/x86/kernel/apm_32.c                         |    6 ++---
 arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c       |   12 +++++------
 arch/x86/kernel/cpu/cpufreq/powernow-k8.c        |   20 +++++++++---------
 arch/x86/kernel/cpu/cpufreq/speedstep-centrino.c |   12 +++++------
 arch/x86/kernel/cpu/cpufreq/speedstep-ich.c      |   12 +++++------
 arch/x86/kernel/cpu/intel_cacheinfo.c            |    4 +--
 arch/x86/kernel/cpu/mcheck/mce_amd_64.c          |    4 +--
 arch/x86/kernel/microcode.c                      |   16 +++++++-------
 arch/x86/kernel/process_64.c                     |    1 
 arch/x86/kernel/reboot.c                         |    2 -
 drivers/acpi/processor_throttling.c              |   10 ++++-----
 drivers/firmware/dcdbas.c                        |    4 +--
 drivers/pci/pci-driver.c                         |   10 ++++++---
 include/linux/cpuset.h                           |   13 ++++++-----
 include/linux/sched.h                            |   10 +++++----
 init/main.c                                      |    2 -
 kernel/cpu.c                                     |    4 +--
 kernel/cpuset.c                                  |   22 +++++++-------------
 kernel/kmod.c                                    |    2 -
 kernel/kthread.c                                 |    4 +--
 kernel/rcutorture.c                              |   11 +++++-----
 kernel/sched.c                                   |   25 +++++++++++------------
 kernel/sched_rt.c                                |    3 +-
 kernel/stop_machine.c                            |    2 -
 mm/pdflush.c                                     |    4 +--
 mm/vmscan.c                                      |    6 ++---
 net/sunrpc/svc.c                                 |   18 +++++++++++-----
 43 files changed, 166 insertions(+), 155 deletions(-)

--- linux.trees.git.orig/arch/arm/mach-integrator/cpu.c
+++ linux.trees.git/arch/arm/mach-integrator/cpu.c
@@ -94,7 +94,7 @@ static int integrator_set_target(struct 
 	 * Bind to the specified CPU.  When this call returns,
 	 * we should be running on the right CPU.
 	 */
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	BUG_ON(cpu != smp_processor_id());
 
 	/* get current setting */
@@ -122,7 +122,7 @@ static int integrator_set_target(struct 
 	freqs.cpu = policy->cpu;
 
 	if (freqs.old == freqs.new) {
-		set_cpus_allowed(current, cpus_allowed);
+		set_cpus_allowed(current, &cpus_allowed);
 		return 0;
 	}
 
@@ -145,7 +145,7 @@ static int integrator_set_target(struct 
 	/*
 	 * Restore the CPUs allowed mask.
 	 */
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	cpufreq_notify_transition(&freqs, CPUFREQ_POSTCHANGE);
 
@@ -161,7 +161,7 @@ static unsigned int integrator_get(unsig
 
 	cpus_allowed = current->cpus_allowed;
 
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	BUG_ON(cpu != smp_processor_id());
 
 	/* detect memory etc. */
@@ -177,7 +177,7 @@ static unsigned int integrator_get(unsig
 
 	current_freq = icst525_khz(&cclk_params, vco); /* current freq */
 
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	return current_freq;
 }
--- linux.trees.git.orig/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ linux.trees.git/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -112,7 +112,7 @@ processor_get_freq (
 	dprintk("processor_get_freq\n");
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (smp_processor_id() != cpu)
 		goto migrate_end;
 
@@ -120,7 +120,7 @@ processor_get_freq (
 	ret = processor_get_pstate(&value);
 
 	if (ret) {
-		set_cpus_allowed(current, saved_mask);
+		set_cpus_allowed(current, &saved_mask);
 		printk(KERN_WARNING "get performance failed with error %d\n",
 		       ret);
 		ret = 0;
@@ -130,7 +130,7 @@ processor_get_freq (
 	ret = (clock_freq*1000);
 
 migrate_end:
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return ret;
 }
 
@@ -150,7 +150,7 @@ processor_set_freq (
 	dprintk("processor_set_freq\n");
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (smp_processor_id() != cpu) {
 		retval = -EAGAIN;
 		goto migrate_end;
@@ -207,7 +207,7 @@ processor_set_freq (
 	retval = 0;
 
 migrate_end:
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return (retval);
 }
 
--- linux.trees.git.orig/arch/ia64/kernel/salinfo.c
+++ linux.trees.git/arch/ia64/kernel/salinfo.c
@@ -405,9 +405,9 @@ call_on_cpu(int cpu, void (*fn)(void *),
 {
 	cpumask_t save_cpus_allowed = current->cpus_allowed;
 	cpumask_t new_cpus_allowed = cpumask_of_cpu(cpu);
-	set_cpus_allowed(current, new_cpus_allowed);
+	set_cpus_allowed(current, &new_cpus_allowed);
 	(*fn)(arg);
-	set_cpus_allowed(current, save_cpus_allowed);
+	set_cpus_allowed(current, &save_cpus_allowed);
 }
 
 static void
--- linux.trees.git.orig/arch/ia64/kernel/topology.c
+++ linux.trees.git/arch/ia64/kernel/topology.c
@@ -345,12 +345,12 @@ static int __cpuinit cache_add_dev(struc
 		return 0;
 
 	oldmask = current->cpus_allowed;
-	retval = set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	retval = set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (unlikely(retval))
 		return retval;
 
 	retval = cpu_cache_sysfs_init(cpu);
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	if (unlikely(retval < 0))
 		return retval;
 
--- linux.trees.git.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ linux.trees.git/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -635,9 +635,9 @@ static int sn_hwperf_op_cpu(struct sn_hw
 		else {
 			/* migrate the task before calling SAL */ 
 			save_allowed = current->cpus_allowed;
-			set_cpus_allowed(current, cpumask_of_cpu(cpu));
+			set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 			sn_hwperf_call_sal(op_info);
-			set_cpus_allowed(current, save_allowed);
+			set_cpus_allowed(current, &save_allowed);
 		}
 	}
 	r = op_info->ret;
--- linux.trees.git.orig/arch/ia64/sn/kernel/xpc_main.c
+++ linux.trees.git/arch/ia64/sn/kernel/xpc_main.c
@@ -255,7 +255,7 @@ xpc_hb_checker(void *ignore)
 
 	daemonize(XPC_HB_CHECK_THREAD_NAME);
 
-	set_cpus_allowed(current, cpumask_of_cpu(XPC_HB_CHECK_CPU));
+	set_cpus_allowed(current, &cpumask_of_cpu(XPC_HB_CHECK_CPU));
 
 	/* set our heartbeating to other partitions into motion */
 	xpc_hb_check_timeout = jiffies + (xpc_hb_check_interval * HZ);
@@ -509,7 +509,7 @@ xpc_activating(void *__partid)
 	}
 
 	/* allow this thread and its children to run on any CPU */
-	set_cpus_allowed(current, CPU_MASK_ALL);
+	set_cpus_allowed(current, &CPU_MASK_ALL);
 
 	/*
 	 * Register the remote partition's AMOs with SAL so it can handle
--- linux.trees.git.orig/arch/mips/kernel/mips-mt-fpaff.c
+++ linux.trees.git/arch/mips/kernel/mips-mt-fpaff.c
@@ -98,10 +98,10 @@ asmlinkage long mipsmt_sys_sched_setaffi
 	if (test_ti_thread_flag(ti, TIF_FPUBOUND) &&
 	    cpus_intersects(new_mask, mt_fpu_cpumask)) {
 		cpus_and(effective_mask, new_mask, mt_fpu_cpumask);
-		retval = set_cpus_allowed(p, effective_mask);
+		retval = set_cpus_allowed(p, &effective_mask);
 	} else {
 		clear_ti_thread_flag(ti, TIF_FPUBOUND);
-		retval = set_cpus_allowed(p, new_mask);
+		retval = set_cpus_allowed(p, &new_mask);
 	}
 
 out_unlock:
--- linux.trees.git.orig/arch/mips/kernel/traps.c
+++ linux.trees.git/arch/mips/kernel/traps.c
@@ -804,7 +804,7 @@ static void mt_ase_fp_affinity(void)
 
 			cpus_and(tmask, current->thread.user_cpus_allowed,
 			         mt_fpu_cpumask);
-			set_cpus_allowed(current, tmask);
+			set_cpus_allowed(current, &tmask);
 			set_thread_flag(TIF_FPUBOUND);
 		}
 	}
--- linux.trees.git.orig/arch/powerpc/kernel/smp.c
+++ linux.trees.git/arch/powerpc/kernel/smp.c
@@ -618,12 +618,12 @@ void __init smp_cpus_done(unsigned int m
 	 * se we pin us down to CPU 0 for a short while
 	 */
 	old_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(boot_cpuid));
+	set_cpus_allowed(current, &cpumask_of_cpu(boot_cpuid));
 	
 	if (smp_ops)
 		smp_ops->setup_cpu(boot_cpuid);
 
-	set_cpus_allowed(current, old_mask);
+	set_cpus_allowed(current, &old_mask);
 
 	snapshot_timebases();
 
--- linux.trees.git.orig/arch/powerpc/kernel/sysfs.c
+++ linux.trees.git/arch/powerpc/kernel/sysfs.c
@@ -131,12 +131,12 @@ static unsigned long run_on_cpu(unsigned
 	unsigned long ret;
 
 	/* should return -EINVAL to userspace */
-	if (set_cpus_allowed(current, cpumask_of_cpu(cpu)))
+	if (set_cpus_allowed(current, &cpumask_of_cpu(cpu)))
 		return 0;
 
 	ret = func(arg);
 
-	set_cpus_allowed(current, old_affinity);
+	set_cpus_allowed(current, &old_affinity);
 
 	return ret;
 }
--- linux.trees.git.orig/arch/powerpc/platforms/pseries/rtasd.c
+++ linux.trees.git/arch/powerpc/platforms/pseries/rtasd.c
@@ -385,9 +385,9 @@ static void do_event_scan_all_cpus(long 
 	get_online_cpus();
 	cpu = first_cpu(cpu_online_map);
 	for (;;) {
-		set_cpus_allowed(current, cpumask_of_cpu(cpu));
+		set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 		do_event_scan();
-		set_cpus_allowed(current, CPU_MASK_ALL);
+		set_cpus_allowed(current, &CPU_MASK_ALL);
 
 		/* Drop hotplug lock, and sleep for the specified delay */
 		put_online_cpus();
--- linux.trees.git.orig/arch/sh/kernel/cpufreq.c
+++ linux.trees.git/arch/sh/kernel/cpufreq.c
@@ -48,7 +48,7 @@ static int sh_cpufreq_target(struct cpuf
 		return -ENODEV;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	BUG_ON(smp_processor_id() != cpu);
 
@@ -66,7 +66,7 @@ static int sh_cpufreq_target(struct cpuf
 	freqs.flags	= 0;
 
 	cpufreq_notify_transition(&freqs, CPUFREQ_PRECHANGE);
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 	clk_set_rate(cpuclk, freq);
 	cpufreq_notify_transition(&freqs, CPUFREQ_POSTCHANGE);
 
--- linux.trees.git.orig/arch/sparc64/kernel/sysfs.c
+++ linux.trees.git/arch/sparc64/kernel/sysfs.c
@@ -104,12 +104,12 @@ static unsigned long run_on_cpu(unsigned
 	unsigned long ret;
 
 	/* should return -EINVAL to userspace */
-	if (set_cpus_allowed(current, cpumask_of_cpu(cpu)))
+	if (set_cpus_allowed(current, &cpumask_of_cpu(cpu)))
 		return 0;
 
 	ret = func(arg);
 
-	set_cpus_allowed(current, old_affinity);
+	set_cpus_allowed(current, &old_affinity);
 
 	return ret;
 }
--- linux.trees.git.orig/arch/sparc64/kernel/us2e_cpufreq.c
+++ linux.trees.git/arch/sparc64/kernel/us2e_cpufreq.c
@@ -238,12 +238,12 @@ static unsigned int us2e_freq_get(unsign
 		return 0;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	clock_tick = sparc64_get_clock_tick(cpu) / 1000;
 	estar = read_hbreg(HBIRD_ESTAR_MODE_ADDR);
 
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	return clock_tick / estar_to_divisor(estar);
 }
@@ -259,7 +259,7 @@ static void us2e_set_cpu_divider_index(u
 		return;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	new_freq = clock_tick = sparc64_get_clock_tick(cpu) / 1000;
 	new_bits = index_to_estar_mode(index);
@@ -281,7 +281,7 @@ static void us2e_set_cpu_divider_index(u
 
 	cpufreq_notify_transition(&freqs, CPUFREQ_POSTCHANGE);
 
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 }
 
 static int us2e_freq_target(struct cpufreq_policy *policy,
--- linux.trees.git.orig/arch/sparc64/kernel/us3_cpufreq.c
+++ linux.trees.git/arch/sparc64/kernel/us3_cpufreq.c
@@ -86,12 +86,12 @@ static unsigned int us3_freq_get(unsigne
 		return 0;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	reg = read_safari_cfg();
 	ret = get_current_freq(cpu, reg);
 
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	return ret;
 }
@@ -106,7 +106,7 @@ static void us3_set_cpu_divider_index(un
 		return;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	new_freq = sparc64_get_clock_tick(cpu) / 1000;
 	switch (index) {
@@ -140,7 +140,7 @@ static void us3_set_cpu_divider_index(un
 
 	cpufreq_notify_transition(&freqs, CPUFREQ_POSTCHANGE);
 
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 }
 
 static int us3_freq_target(struct cpufreq_policy *policy,
--- linux.trees.git.orig/arch/x86/kernel/acpi/cstate.c
+++ linux.trees.git/arch/x86/kernel/acpi/cstate.c
@@ -91,7 +91,7 @@ int acpi_processor_ffh_cstate_probe(unsi
 
 	/* Make sure we are running on right CPU */
 	saved_mask = current->cpus_allowed;
-	retval = set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	retval = set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (retval)
 		return -1;
 
@@ -128,7 +128,7 @@ int acpi_processor_ffh_cstate_probe(unsi
 		 cx->address);
 
 out:
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return retval;
 }
 EXPORT_SYMBOL_GPL(acpi_processor_ffh_cstate_probe);
--- linux.trees.git.orig/arch/x86/kernel/apm_32.c
+++ linux.trees.git/arch/x86/kernel/apm_32.c
@@ -496,14 +496,14 @@ static cpumask_t apm_save_cpus(void)
 {
 	cpumask_t x = current->cpus_allowed;
 	/* Some bioses don't like being called from CPU != 0 */
-	set_cpus_allowed(current, cpumask_of_cpu(0));
+	set_cpus_allowed(current, &cpumask_of_cpu(0));
 	BUG_ON(smp_processor_id() != 0);
 	return x;
 }
 
 static inline void apm_restore_cpus(cpumask_t mask)
 {
-	set_cpus_allowed(current, mask);
+	set_cpus_allowed(current, &mask);
 }
 
 #else
@@ -1694,7 +1694,7 @@ static int apm(void *unused)
 	 * Some bioses don't like being called from CPU != 0.
 	 * Method suggested by Ingo Molnar.
 	 */
-	set_cpus_allowed(current, cpumask_of_cpu(0));
+	set_cpus_allowed(current, &cpumask_of_cpu(0));
 	BUG_ON(smp_processor_id() != 0);
 #endif
 
--- linux.trees.git.orig/arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c
+++ linux.trees.git/arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c
@@ -192,9 +192,9 @@ static void drv_read(struct drv_cmd *cmd
 	cpumask_t saved_mask = current->cpus_allowed;
 	cmd->val = 0;
 
-	set_cpus_allowed(current, cmd->mask);
+	set_cpus_allowed(current, &cmd->mask);
 	do_drv_read(cmd);
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 }
 
 static void drv_write(struct drv_cmd *cmd)
@@ -203,11 +203,11 @@ static void drv_write(struct drv_cmd *cm
 	unsigned int i;
 
 	for_each_cpu_mask(i, cmd->mask) {
-		set_cpus_allowed(current, cpumask_of_cpu(i));
+		set_cpus_allowed(current, &cpumask_of_cpu(i));
 		do_drv_write(cmd);
 	}
 
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return;
 }
 
@@ -271,7 +271,7 @@ static unsigned int get_measured_perf(un
 	unsigned int retval;
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (get_cpu() != cpu) {
 		/* We were not able to run on requested processor */
 		put_cpu();
@@ -329,7 +329,7 @@ static unsigned int get_measured_perf(un
 	retval = per_cpu(drv_data, cpu)->max_freq * perf_percent / 100;
 
 	put_cpu();
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 
 	dprintk("cpu %d: performance percent %d\n", cpu, perf_percent);
 	return retval;
--- linux.trees.git.orig/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
+++ linux.trees.git/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
@@ -483,7 +483,7 @@ static int check_supported_cpu(unsigned 
 	unsigned int rc = 0;
 
 	oldmask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	if (smp_processor_id() != cpu) {
 		printk(KERN_ERR PFX "limiting to cpu %u failed\n", cpu);
@@ -528,7 +528,7 @@ static int check_supported_cpu(unsigned 
 	rc = 1;
 
 out:
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	return rc;
 }
 
@@ -1030,7 +1030,7 @@ static int powernowk8_target(struct cpuf
 
 	/* only run on specific CPU from here on */
 	oldmask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(pol->cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(pol->cpu));
 
 	if (smp_processor_id() != pol->cpu) {
 		printk(KERN_ERR PFX "limiting to cpu %u failed\n", pol->cpu);
@@ -1085,7 +1085,7 @@ static int powernowk8_target(struct cpuf
 	ret = 0;
 
 err_out:
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	return ret;
 }
 
@@ -1145,7 +1145,7 @@ static int __cpuinit powernowk8_cpu_init
 
 	/* only run on specific CPU from here on */
 	oldmask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(pol->cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(pol->cpu));
 
 	if (smp_processor_id() != pol->cpu) {
 		printk(KERN_ERR PFX "limiting to cpu %u failed\n", pol->cpu);
@@ -1164,7 +1164,7 @@ static int __cpuinit powernowk8_cpu_init
 		fidvid_msr_init();
 
 	/* run on any CPU again */
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 
 	if (cpu_family == CPU_HW_PSTATE)
 		pol->cpus = cpumask_of_cpu(pol->cpu);
@@ -1205,7 +1205,7 @@ static int __cpuinit powernowk8_cpu_init
 	return 0;
 
 err_out:
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	powernow_k8_cpu_exit_acpi(data);
 
 	kfree(data);
@@ -1242,10 +1242,10 @@ static unsigned int powernowk8_get (unsi
 	if (!data)
 		return -EINVAL;
 
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (smp_processor_id() != cpu) {
 		printk(KERN_ERR PFX "limiting to CPU %d failed in powernowk8_get\n", cpu);
-		set_cpus_allowed(current, oldmask);
+		set_cpus_allowed(current, &oldmask);
 		return 0;
 	}
 
@@ -1259,7 +1259,7 @@ static unsigned int powernowk8_get (unsi
 
 
 out:
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	return khz;
 }
 
--- linux.trees.git.orig/arch/x86/kernel/cpu/cpufreq/speedstep-centrino.c
+++ linux.trees.git/arch/x86/kernel/cpu/cpufreq/speedstep-centrino.c
@@ -315,7 +315,7 @@ static unsigned int get_cur_freq(unsigne
 	cpumask_t saved_mask;
 
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (smp_processor_id() != cpu)
 		return 0;
 
@@ -333,7 +333,7 @@ static unsigned int get_cur_freq(unsigne
 		clock_freq = extract_clock(l, cpu, 1);
 	}
 
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return clock_freq;
 }
 
@@ -487,7 +487,7 @@ static int centrino_target (struct cpufr
 		else
 			cpu_set(j, set_mask);
 
-		set_cpus_allowed(current, set_mask);
+		set_cpus_allowed(current, &set_mask);
 		preempt_disable();
 		if (unlikely(!cpu_isset(smp_processor_id(), set_mask))) {
 			dprintk("couldn't limit to CPUs in this domain\n");
@@ -555,7 +555,7 @@ static int centrino_target (struct cpufr
 
 		if (!cpus_empty(covered_cpus)) {
 			for_each_cpu_mask(j, covered_cpus) {
-				set_cpus_allowed(current, cpumask_of_cpu(j));
+				set_cpus_allowed(current, &cpumask_of_cpu(j));
 				wrmsr(MSR_IA32_PERF_CTL, oldmsr, h);
 			}
 		}
@@ -569,12 +569,12 @@ static int centrino_target (struct cpufr
 			cpufreq_notify_transition(&freqs, CPUFREQ_POSTCHANGE);
 		}
 	}
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return 0;
 
 migrate_end:
 	preempt_enable();
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return 0;
 }
 
--- linux.trees.git.orig/arch/x86/kernel/cpu/cpufreq/speedstep-ich.c
+++ linux.trees.git/arch/x86/kernel/cpu/cpufreq/speedstep-ich.c
@@ -235,9 +235,9 @@ static unsigned int _speedstep_get(cpuma
 	cpumask_t cpus_allowed;
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, cpus);
+	set_cpus_allowed(current, &cpus);
 	speed = speedstep_get_processor_frequency(speedstep_processor);
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 	dprintk("detected %u kHz as current frequency\n", speed);
 	return speed;
 }
@@ -285,12 +285,12 @@ static int speedstep_target (struct cpuf
 	}
 
 	/* switch to physical CPU where state is to be changed */
-	set_cpus_allowed(current, policy->cpus);
+	set_cpus_allowed(current, &policy->cpus);
 
 	speedstep_set_state(newstate);
 
 	/* allow to be run on all CPUs */
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	for_each_cpu_mask(i, policy->cpus) {
 		freqs.cpu = i;
@@ -326,7 +326,7 @@ static int speedstep_cpu_init(struct cpu
 #endif
 
 	cpus_allowed = current->cpus_allowed;
-	set_cpus_allowed(current, policy->cpus);
+	set_cpus_allowed(current, &policy->cpus);
 
 	/* detect low and high frequency and transition latency */
 	result = speedstep_get_freqs(speedstep_processor,
@@ -334,7 +334,7 @@ static int speedstep_cpu_init(struct cpu
 				     &speedstep_freqs[SPEEDSTEP_HIGH].frequency,
 				     &policy->cpuinfo.transition_latency,
 				     &speedstep_set_state);
-	set_cpus_allowed(current, cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 	if (result)
 		return result;
 
--- linux.trees.git.orig/arch/x86/kernel/cpu/intel_cacheinfo.c
+++ linux.trees.git/arch/x86/kernel/cpu/intel_cacheinfo.c
@@ -525,7 +525,7 @@ static int __cpuinit detect_cache_attrib
 		return -ENOMEM;
 
 	oldmask = current->cpus_allowed;
-	retval = set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	retval = set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	if (retval)
 		goto out;
 
@@ -542,7 +542,7 @@ static int __cpuinit detect_cache_attrib
 		}
 		cache_shared_cpu_map_setup(cpu, j);
 	}
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 
 out:
 	if (retval) {
--- linux.trees.git.orig/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
+++ linux.trees.git/arch/x86/kernel/cpu/mcheck/mce_amd_64.c
@@ -256,13 +256,13 @@ static cpumask_t affinity_set(unsigned i
 	cpumask_t oldmask = current->cpus_allowed;
 	cpumask_t newmask = CPU_MASK_NONE;
 	cpu_set(cpu, newmask);
-	set_cpus_allowed(current, newmask);
+	set_cpus_allowed(current, &newmask);
 	return oldmask;
 }
 
 static void affinity_restore(cpumask_t oldmask)
 {
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 }
 
 #define SHOW_FIELDS(name)                                           \
--- linux.trees.git.orig/arch/x86/kernel/microcode.c
+++ linux.trees.git/arch/x86/kernel/microcode.c
@@ -402,7 +402,7 @@ static int do_microcode_update (void)
 
 			if (!uci->valid)
 				continue;
-			set_cpus_allowed(current, cpumask_of_cpu(cpu));
+			set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 			error = get_maching_microcode(new_mc, cpu);
 			if (error < 0)
 				goto out;
@@ -416,7 +416,7 @@ out:
 		vfree(new_mc);
 	if (cursor < 0)
 		error = cursor;
-	set_cpus_allowed(current, old);
+	set_cpus_allowed(current, &old);
 	return error;
 }
 
@@ -579,7 +579,7 @@ static int apply_microcode_check_cpu(int
 		return 0;
 
 	old = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 	/* Check if the microcode we have in memory matches the CPU */
 	if (c->x86_vendor != X86_VENDOR_INTEL || c->x86 < 6 ||
@@ -610,7 +610,7 @@ static int apply_microcode_check_cpu(int
 			" sig=0x%x, pf=0x%x, rev=0x%x\n",
 			cpu, uci->sig, uci->pf, uci->rev);
 
-	set_cpus_allowed(current, old);
+	set_cpus_allowed(current, &old);
 	return err;
 }
 
@@ -621,13 +621,13 @@ static void microcode_init_cpu(int cpu, 
 
 	old = current->cpus_allowed;
 
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 	mutex_lock(&microcode_mutex);
 	collect_cpu_info(cpu);
 	if (uci->valid && system_state == SYSTEM_RUNNING && !resume)
 		cpu_request_microcode(cpu);
 	mutex_unlock(&microcode_mutex);
-	set_cpus_allowed(current, old);
+	set_cpus_allowed(current, &old);
 }
 
 static void microcode_fini_cpu(int cpu)
@@ -657,14 +657,14 @@ static ssize_t reload_store(struct sys_d
 		old = current->cpus_allowed;
 
 		get_online_cpus();
-		set_cpus_allowed(current, cpumask_of_cpu(cpu));
+		set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 
 		mutex_lock(&microcode_mutex);
 		if (uci->valid)
 			err = cpu_request_microcode(cpu);
 		mutex_unlock(&microcode_mutex);
 		put_online_cpus();
-		set_cpus_allowed(current, old);
+		set_cpus_allowed(current, &old);
 	}
 	if (err)
 		return err;
--- linux.trees.git.orig/arch/x86/kernel/process_64.c
+++ linux.trees.git/arch/x86/kernel/process_64.c
@@ -37,6 +37,7 @@
 #include <linux/kprobes.h>
 #include <linux/kdebug.h>
 #include <linux/tick.h>
+#include <linux/sched.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
--- linux.trees.git.orig/arch/x86/kernel/reboot.c
+++ linux.trees.git/arch/x86/kernel/reboot.c
@@ -420,7 +420,7 @@ static void native_machine_shutdown(void
 		reboot_cpu_id = smp_processor_id();
 
 	/* Make certain I only run on the appropriate processor */
-	set_cpus_allowed(current, cpumask_of_cpu(reboot_cpu_id));
+	set_cpus_allowed(current, &cpumask_of_cpu(reboot_cpu_id));
 
 	/* O.K Now that I'm on the appropriate processor,
 	 * stop all of the others.
--- linux.trees.git.orig/drivers/acpi/processor_throttling.c
+++ linux.trees.git/drivers/acpi/processor_throttling.c
@@ -838,10 +838,10 @@ static int acpi_processor_get_throttling
 	 * Migrate task to the cpu pointed by pr.
 	 */
 	saved_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(pr->id));
+	set_cpus_allowed(current, &cpumask_of_cpu(pr->id));
 	ret = pr->throttling.acpi_processor_get_throttling(pr);
 	/* restore the previous state */
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 
 	return ret;
 }
@@ -1025,7 +1025,7 @@ int acpi_processor_set_throttling(struct
 	 * it can be called only for the cpu pointed by pr.
 	 */
 	if (p_throttling->shared_type == DOMAIN_COORD_TYPE_SW_ANY) {
-		set_cpus_allowed(current, cpumask_of_cpu(pr->id));
+		set_cpus_allowed(current, &cpumask_of_cpu(pr->id));
 		ret = p_throttling->acpi_processor_set_throttling(pr,
 						t_state.target_state);
 	} else {
@@ -1056,7 +1056,7 @@ int acpi_processor_set_throttling(struct
 				continue;
 			}
 			t_state.cpu = i;
-			set_cpus_allowed(current, cpumask_of_cpu(i));
+			set_cpus_allowed(current, &cpumask_of_cpu(i));
 			ret = match_pr->throttling.
 				acpi_processor_set_throttling(
 				match_pr, t_state.target_state);
@@ -1074,7 +1074,7 @@ int acpi_processor_set_throttling(struct
 							&t_state);
 	}
 	/* restore the previous state */
-	set_cpus_allowed(current, saved_mask);
+	set_cpus_allowed(current, &saved_mask);
 	return ret;
 }
 
--- linux.trees.git.orig/drivers/firmware/dcdbas.c
+++ linux.trees.git/drivers/firmware/dcdbas.c
@@ -265,7 +265,7 @@ static int smi_request(struct smi_cmd *s
 
 	/* SMI requires CPU 0 */
 	old_mask = current->cpus_allowed;
-	set_cpus_allowed(current, cpumask_of_cpu(0));
+	set_cpus_allowed(current, &cpumask_of_cpu(0));
 	if (smp_processor_id() != 0) {
 		dev_dbg(&dcdbas_pdev->dev, "%s: failed to get CPU 0\n",
 			__FUNCTION__);
@@ -285,7 +285,7 @@ static int smi_request(struct smi_cmd *s
 	);
 
 out:
-	set_cpus_allowed(current, old_mask);
+	set_cpus_allowed(current, &old_mask);
 	return ret;
 }
 
--- linux.trees.git.orig/drivers/pci/pci-driver.c
+++ linux.trees.git/drivers/pci/pci-driver.c
@@ -182,15 +182,19 @@ static int pci_call_probe(struct pci_dri
 	struct mempolicy *oldpol;
 	cpumask_t oldmask = current->cpus_allowed;
 	int node = dev_to_node(&dev->dev);
-	if (node >= 0)
-	    set_cpus_allowed(current, node_to_cpumask(node));
+
+	if (node >= 0) {
+		cpumask_t nodecpumask = node_to_cpumask(node);
+		set_cpus_allowed(current, &nodecpumask);
+	}
+
 	/* And set default memory allocation policy */
 	oldpol = current->mempolicy;
 	current->mempolicy = NULL;	/* fall back to system default policy */
 #endif
 	error = drv->probe(dev, id);
 #ifdef CONFIG_NUMA
-	set_cpus_allowed(current, oldmask);
+	set_cpus_allowed(current, &oldmask);
 	current->mempolicy = oldpol;
 #endif
 	return error;
--- linux.trees.git.orig/include/linux/cpuset.h
+++ linux.trees.git/include/linux/cpuset.h
@@ -20,8 +20,8 @@ extern int number_of_cpusets;	/* How man
 extern int cpuset_init_early(void);
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
-extern cpumask_t cpuset_cpus_allowed(struct task_struct *p);
-extern cpumask_t cpuset_cpus_allowed_locked(struct task_struct *p);
+extern void cpuset_cpus_allowed(struct task_struct *p, cpumask_t *mask);
+extern void cpuset_cpus_allowed_locked(struct task_struct *p, cpumask_t *mask);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 #define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
@@ -84,13 +84,14 @@ static inline int cpuset_init_early(void
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
-static inline cpumask_t cpuset_cpus_allowed(struct task_struct *p)
+static inline void cpuset_cpus_allowed(struct task_struct *p, cpumask_t *mask)
 {
-	return cpu_possible_map;
+	*mask = cpu_possible_map;
 }
-static inline cpumask_t cpuset_cpus_allowed_locked(struct task_struct *p)
+static inline void cpuset_cpus_allowed_locked(struct task_struct *p,
+								cpumask_t *mask)
 {
-	return cpu_possible_map;
+	*mask = cpu_possible_map;
 }
 
 static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
--- linux.trees.git.orig/include/linux/sched.h
+++ linux.trees.git/include/linux/sched.h
@@ -889,7 +889,8 @@ struct sched_class {
 	void (*set_curr_task) (struct rq *rq);
 	void (*task_tick) (struct rq *rq, struct task_struct *p, int queued);
 	void (*task_new) (struct rq *rq, struct task_struct *p);
-	void (*set_cpus_allowed)(struct task_struct *p, cpumask_t *newmask);
+	void (*set_cpus_allowed)(struct task_struct *p,
+						const cpumask_t *newmask);
 
 	void (*join_domain)(struct rq *rq);
 	void (*leave_domain)(struct rq *rq);
@@ -1501,11 +1502,12 @@ static inline void put_task_struct(struc
 #define used_math() tsk_used_math(current)
 
 #ifdef CONFIG_SMP
-extern int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask);
+extern int set_cpus_allowed(struct task_struct *p, const cpumask_t *new_mask);
 #else
-static inline int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+static inline int set_cpus_allowed(struct task_struct *p,
+				   const cpumask_t *new_mask)
 {
-	if (!cpu_isset(0, new_mask))
+	if (!cpu_isset(0, *new_mask))
 		return -EINVAL;
 	return 0;
 }
--- linux.trees.git.orig/init/main.c
+++ linux.trees.git/init/main.c
@@ -845,7 +845,7 @@ static int __init kernel_init(void * unu
 	/*
 	 * init can run on any cpu.
 	 */
-	set_cpus_allowed(current, CPU_MASK_ALL);
+	set_cpus_allowed(current, &CPU_MASK_ALL);
 	/*
 	 * Tell the world that we're going to be the grim
 	 * reaper of innocent orphaned children.
--- linux.trees.git.orig/kernel/cpu.c
+++ linux.trees.git/kernel/cpu.c
@@ -234,7 +234,7 @@ static int _cpu_down(unsigned int cpu, i
 	old_allowed = current->cpus_allowed;
 	tmp = CPU_MASK_ALL;
 	cpu_clear(cpu, tmp);
-	set_cpus_allowed(current, tmp);
+	set_cpus_allowed(current, &tmp);
 
 	p = __stop_machine_run(take_cpu_down, &tcd_param, cpu);
 
@@ -268,7 +268,7 @@ static int _cpu_down(unsigned int cpu, i
 out_thread:
 	err = kthread_stop(p);
 out_allowed:
-	set_cpus_allowed(current, old_allowed);
+	set_cpus_allowed(current, &old_allowed);
 out_release:
 	cpu_hotplug_done();
 	return err;
--- linux.trees.git.orig/kernel/cpuset.c
+++ linux.trees.git/kernel/cpuset.c
@@ -729,7 +729,8 @@ int cpuset_test_cpumask(struct task_stru
  */
 void cpuset_change_cpumask(struct task_struct *tsk, struct cgroup_scanner *scan)
 {
-	set_cpus_allowed(tsk, (cgroup_cs(scan->cg))->cpus_allowed);
+	cpumask_t newmask = cgroup_cs(scan->cg)->cpus_allowed;
+	set_cpus_allowed(tsk, &newmask);
 }
 
 /**
@@ -1178,7 +1179,7 @@ static void cpuset_attach(struct cgroup_
 
 	mutex_lock(&callback_mutex);
 	guarantee_online_cpus(cs, &cpus);
-	set_cpus_allowed(tsk, cpus);
+	set_cpus_allowed(tsk, &cpus);
 	mutex_unlock(&callback_mutex);
 
 	from = oldcs->mems_allowed;
@@ -1844,6 +1845,7 @@ void __init cpuset_init_smp(void)
 
  * cpuset_cpus_allowed - return cpus_allowed mask from a tasks cpuset.
  * @tsk: pointer to task_struct from which to obtain cpuset->cpus_allowed.
+ * @mask: pointer to cpumask to be returned.
  *
  * Description: Returns the cpumask_t cpus_allowed of the cpuset
  * attached to the specified @tsk.  Guaranteed to return some non-empty
@@ -1851,30 +1853,22 @@ void __init cpuset_init_smp(void)
  * tasks cpuset.
  **/
 
-cpumask_t cpuset_cpus_allowed(struct task_struct *tsk)
+void cpuset_cpus_allowed(struct task_struct *tsk, cpumask_t *mask)
 {
-	cpumask_t mask;
-
 	mutex_lock(&callback_mutex);
-	mask = cpuset_cpus_allowed_locked(tsk);
+	cpuset_cpus_allowed_locked(tsk, mask);
 	mutex_unlock(&callback_mutex);
-
-	return mask;
 }
 
 /**
  * cpuset_cpus_allowed_locked - return cpus_allowed mask from a tasks cpuset.
  * Must be called with callback_mutex held.
  **/
-cpumask_t cpuset_cpus_allowed_locked(struct task_struct *tsk)
+void cpuset_cpus_allowed_locked(struct task_struct *tsk, cpumask_t *mask)
 {
-	cpumask_t mask;
-
 	task_lock(tsk);
-	guarantee_online_cpus(task_cs(tsk), &mask);
+	guarantee_online_cpus(task_cs(tsk), mask);
 	task_unlock(tsk);
-
-	return mask;
 }
 
 void cpuset_init_current_mems_allowed(void)
--- linux.trees.git.orig/kernel/kmod.c
+++ linux.trees.git/kernel/kmod.c
@@ -165,7 +165,7 @@ static int ____call_usermodehelper(void 
 	}
 
 	/* We can run anywhere, unlike our parent keventd(). */
-	set_cpus_allowed(current, CPU_MASK_ALL);
+	set_cpus_allowed(current, &CPU_MASK_ALL);
 
 	/*
 	 * Our parent is keventd, which runs with elevated scheduling priority.
--- linux.trees.git.orig/kernel/kthread.c
+++ linux.trees.git/kernel/kthread.c
@@ -107,7 +107,7 @@ static void create_kthread(struct kthrea
 		 */
 		sched_setscheduler(create->result, SCHED_NORMAL, &param);
 		set_user_nice(create->result, KTHREAD_NICE_LEVEL);
-		set_cpus_allowed(create->result, CPU_MASK_ALL);
+		set_cpus_allowed(create->result, &CPU_MASK_ALL);
 	}
 	complete(&create->done);
 }
@@ -232,7 +232,7 @@ int kthreadd(void *unused)
 	set_task_comm(tsk, "kthreadd");
 	ignore_signals(tsk);
 	set_user_nice(tsk, KTHREAD_NICE_LEVEL);
-	set_cpus_allowed(tsk, CPU_MASK_ALL);
+	set_cpus_allowed(tsk, &CPU_MASK_ALL);
 
 	current->flags |= PF_NOFREEZE;
 
--- linux.trees.git.orig/kernel/rcutorture.c
+++ linux.trees.git/kernel/rcutorture.c
@@ -737,25 +737,26 @@ static void rcu_torture_shuffle_tasks(vo
 	if (rcu_idle_cpu != -1)
 		cpu_clear(rcu_idle_cpu, tmp_mask);
 
-	set_cpus_allowed(current, tmp_mask);
+	set_cpus_allowed(current, &tmp_mask);
 
 	if (reader_tasks) {
 		for (i = 0; i < nrealreaders; i++)
 			if (reader_tasks[i])
-				set_cpus_allowed(reader_tasks[i], tmp_mask);
+				set_cpus_allowed(reader_tasks[i], &tmp_mask);
 	}
 
 	if (fakewriter_tasks) {
 		for (i = 0; i < nfakewriters; i++)
 			if (fakewriter_tasks[i])
-				set_cpus_allowed(fakewriter_tasks[i], tmp_mask);
+				set_cpus_allowed(fakewriter_tasks[i],
+						 &tmp_mask);
 	}
 
 	if (writer_task)
-		set_cpus_allowed(writer_task, tmp_mask);
+		set_cpus_allowed(writer_task, &tmp_mask);
 
 	if (stats_task)
-		set_cpus_allowed(stats_task, tmp_mask);
+		set_cpus_allowed(stats_task, &tmp_mask);
 
 	if (rcu_idle_cpu == -1)
 		rcu_idle_cpu = num_online_cpus() - 1;
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -4739,13 +4739,13 @@ long sched_setaffinity(pid_t pid, cpumas
 	if (retval)
 		goto out_unlock;
 
-	cpus_allowed = cpuset_cpus_allowed(p);
+	cpuset_cpus_allowed(p, &cpus_allowed);
 	cpus_and(new_mask, new_mask, cpus_allowed);
  again:
-	retval = set_cpus_allowed(p, new_mask);
+	retval = set_cpus_allowed(p, &new_mask);
 
 	if (!retval) {
-		cpus_allowed = cpuset_cpus_allowed(p);
+		cpuset_cpus_allowed(p, &cpus_allowed);
 		if (!cpus_subset(new_mask, cpus_allowed)) {
 			/*
 			 * We must have raced with a concurrent cpuset
@@ -5280,7 +5280,7 @@ static inline void sched_init_granularit
  * task must not exit() & deallocate itself prematurely. The
  * call is not atomic; no spinlocks may be held.
  */
-int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+int set_cpus_allowed(struct task_struct *p, const cpumask_t *new_mask)
 {
 	struct migration_req req;
 	unsigned long flags;
@@ -5288,23 +5288,23 @@ int set_cpus_allowed(struct task_struct 
 	int ret = 0;
 
 	rq = task_rq_lock(p, &flags);
-	if (!cpus_intersects(new_mask, cpu_online_map)) {
+	if (!cpus_intersects(*new_mask, cpu_online_map)) {
 		ret = -EINVAL;
 		goto out;
 	}
 
 	if (p->sched_class->set_cpus_allowed)
-		p->sched_class->set_cpus_allowed(p, &new_mask);
+		p->sched_class->set_cpus_allowed(p, new_mask);
 	else {
-		p->cpus_allowed = new_mask;
-		p->rt.nr_cpus_allowed = cpus_weight(new_mask);
+		p->cpus_allowed = *new_mask;
+		p->rt.nr_cpus_allowed = cpus_weight(*new_mask);
 	}
 
 	/* Can the task run on the task's current CPU? If so, we're done */
-	if (cpu_isset(task_cpu(p), new_mask))
+	if (cpu_isset(task_cpu(p), *new_mask))
 		goto out;
 
-	if (migrate_task(p, any_online_cpu(new_mask), &req)) {
+	if (migrate_task(p, any_online_cpu(*new_mask), &req)) {
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
@@ -5460,7 +5460,8 @@ static void move_task_off_dead_cpu(int d
 
 		/* No more Mr. Nice Guy. */
 		if (dest_cpu >= nr_cpu_ids) {
-			cpumask_t cpus_allowed = cpuset_cpus_allowed_locked(p);
+			cpumask_t cpus_allowed;
+			cpuset_cpus_allowed_locked(p, &cpus_allowed);
 			/*
 			 * Try to stay on the same cpuset, where the
 			 * current cpuset may be a subset of all cpus.
@@ -7049,7 +7050,7 @@ void __init sched_init_smp(void)
 	hotcpu_notifier(update_sched_domains, 0);
 
 	/* Move init over to a non-isolated CPU */
-	if (set_cpus_allowed(current, non_isolated_cpus) < 0)
+	if (set_cpus_allowed(current, &non_isolated_cpus) < 0)
 		BUG();
 	sched_init_granularity();
 }
--- linux.trees.git.orig/kernel/sched_rt.c
+++ linux.trees.git/kernel/sched_rt.c
@@ -1001,7 +1001,8 @@ move_one_task_rt(struct rq *this_rq, int
 	return 0;
 }
 
-static void set_cpus_allowed_rt(struct task_struct *p, cpumask_t *new_mask)
+static void set_cpus_allowed_rt(struct task_struct *p,
+				const cpumask_t *new_mask)
 {
 	int weight = cpus_weight(*new_mask);
 
--- linux.trees.git.orig/kernel/stop_machine.c
+++ linux.trees.git/kernel/stop_machine.c
@@ -35,7 +35,7 @@ static int stopmachine(void *cpu)
 	int irqs_disabled = 0;
 	int prepared = 0;
 
-	set_cpus_allowed(current, cpumask_of_cpu((int)(long)cpu));
+	set_cpus_allowed(current, &cpumask_of_cpu((int)(long)cpu));
 
 	/* Ack: we are alive */
 	smp_mb(); /* Theoretically the ack = 0 might not be on this CPU yet. */
--- linux.trees.git.orig/mm/pdflush.c
+++ linux.trees.git/mm/pdflush.c
@@ -187,8 +187,8 @@ static int pdflush(void *dummy)
 	 * This is needed as pdflush's are dynamically created and destroyed.
 	 * The boottime pdflush's are easily placed w/o these 2 lines.
 	 */
-	cpus_allowed = cpuset_cpus_allowed(current);
-	set_cpus_allowed(current, cpus_allowed);
+	cpuset_cpus_allowed(current, &cpus_allowed);
+	set_cpus_allowed(current, &cpus_allowed);
 
 	return __pdflush(&my_work);
 }
--- linux.trees.git.orig/mm/vmscan.c
+++ linux.trees.git/mm/vmscan.c
@@ -1668,7 +1668,7 @@ static int kswapd(void *p)
 
 	cpumask = node_to_cpumask(pgdat->node_id);
 	if (!cpus_empty(cpumask))
-		set_cpus_allowed(tsk, cpumask);
+		set_cpus_allowed(tsk, &cpumask);
 	current->reclaim_state = &reclaim_state;
 
 	/*
@@ -1905,9 +1905,9 @@ static int __devinit cpu_callback(struct
 		for_each_node_state(nid, N_HIGH_MEMORY) {
 			pgdat = NODE_DATA(nid);
 			mask = node_to_cpumask(pgdat->node_id);
-			if (any_online_cpu(mask) != NR_CPUS)
+			if (any_online_cpu(mask) < nr_cpu_ids)
 				/* One of our CPUs online: restore mask */
-				set_cpus_allowed(pgdat->kswapd, mask);
+				set_cpus_allowed(pgdat->kswapd, &mask);
 		}
 	}
 	return NOTIFY_OK;
--- linux.trees.git.orig/net/sunrpc/svc.c
+++ linux.trees.git/net/sunrpc/svc.c
@@ -301,7 +301,6 @@ static inline int
 svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
 {
 	struct svc_pool_map *m = &svc_pool_map;
-	unsigned int node; /* or cpu */
 
 	/*
 	 * The caller checks for sv_nrpools > 1, which
@@ -314,16 +313,23 @@ svc_pool_map_set_cpumask(unsigned int pi
 	default:
 		return 0;
 	case SVC_POOL_PERCPU:
-		node = m->pool_to[pidx];
+	{
+		unsigned int cpu = m->pool_to[pidx];
+
 		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, cpumask_of_cpu(node));
+		set_cpus_allowed(current, &cpumask_of_cpu(cpu));
 		return 1;
+	}
 	case SVC_POOL_PERNODE:
-		node = m->pool_to[pidx];
+	{
+		unsigned int node = m->pool_to[pidx];
+		cpumask_t nodecpumask = node_to_cpumask(node);
+
 		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, node_to_cpumask(node));
+		set_cpus_allowed(current, &nodecpumask);
 		return 1;
 	}
+	}
 }
 
 /*
@@ -598,7 +604,7 @@ __svc_create_thread(svc_thread_fn func, 
 	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
 
 	if (have_oldmask)
-		set_cpus_allowed(current, oldmask);
+		set_cpus_allowed(current, &oldmask);
 
 	if (error < 0)
 		goto out_thread;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
