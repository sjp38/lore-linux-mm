Message-Id: <20080116170903.245969000@sgi.com>
References: <20080116170902.006151000@sgi.com>
Date: Wed, 16 Jan 2008 09:09:11 -0800
From: travis@sgi.com
Subject: [PATCH 09/10] x86: Change NR_CPUS arrays in acpi-cpufreq V3
Content-Disposition: inline; filename=NR_CPUS-arrays-in-acpi-cpufreq
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	acpi_cpufreq_data *drv_data[NR_CPUS]

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - (none)
---
 arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

--- a/arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c
+++ b/arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.c
@@ -67,7 +67,8 @@ struct acpi_cpufreq_data {
 	unsigned int cpu_feature;
 };
 
-static struct acpi_cpufreq_data *drv_data[NR_CPUS];
+static DEFINE_PER_CPU(struct acpi_cpufreq_data *, drv_data);
+
 /* acpi_perf_data is a pointer to percpu data. */
 static struct acpi_processor_performance *acpi_perf_data;
 
@@ -218,14 +219,14 @@ static u32 get_cur_val(cpumask_t mask)
 	if (unlikely(cpus_empty(mask)))
 		return 0;
 
-	switch (drv_data[first_cpu(mask)]->cpu_feature) {
+	switch (per_cpu(drv_data, first_cpu(mask))->cpu_feature) {
 	case SYSTEM_INTEL_MSR_CAPABLE:
 		cmd.type = SYSTEM_INTEL_MSR_CAPABLE;
 		cmd.addr.msr.reg = MSR_IA32_PERF_STATUS;
 		break;
 	case SYSTEM_IO_CAPABLE:
 		cmd.type = SYSTEM_IO_CAPABLE;
-		perf = drv_data[first_cpu(mask)]->acpi_data;
+		perf = per_cpu(drv_data, first_cpu(mask))->acpi_data;
 		cmd.addr.io.port = perf->control_register.address;
 		cmd.addr.io.bit_width = perf->control_register.bit_width;
 		break;
@@ -325,7 +326,7 @@ static unsigned int get_measured_perf(un
 
 #endif
 
-	retval = drv_data[cpu]->max_freq * perf_percent / 100;
+	retval = per_cpu(drv_data, cpu)->max_freq * perf_percent / 100;
 
 	put_cpu();
 	set_cpus_allowed(current, saved_mask);
@@ -336,7 +337,7 @@ static unsigned int get_measured_perf(un
 
 static unsigned int get_cur_freq_on_cpu(unsigned int cpu)
 {
-	struct acpi_cpufreq_data *data = drv_data[cpu];
+	struct acpi_cpufreq_data *data = per_cpu(drv_data, cpu);
 	unsigned int freq;
 
 	dprintk("get_cur_freq_on_cpu (%d)\n", cpu);
@@ -370,7 +371,7 @@ static unsigned int check_freqs(cpumask_
 static int acpi_cpufreq_target(struct cpufreq_policy *policy,
 			       unsigned int target_freq, unsigned int relation)
 {
-	struct acpi_cpufreq_data *data = drv_data[policy->cpu];
+	struct acpi_cpufreq_data *data = per_cpu(drv_data, policy->cpu);
 	struct acpi_processor_performance *perf;
 	struct cpufreq_freqs freqs;
 	cpumask_t online_policy_cpus;
@@ -466,7 +467,7 @@ static int acpi_cpufreq_target(struct cp
 
 static int acpi_cpufreq_verify(struct cpufreq_policy *policy)
 {
-	struct acpi_cpufreq_data *data = drv_data[policy->cpu];
+	struct acpi_cpufreq_data *data = per_cpu(drv_data, policy->cpu);
 
 	dprintk("acpi_cpufreq_verify\n");
 
@@ -570,7 +571,7 @@ static int acpi_cpufreq_cpu_init(struct 
 		return -ENOMEM;
 
 	data->acpi_data = percpu_ptr(acpi_perf_data, cpu);
-	drv_data[cpu] = data;
+	per_cpu(drv_data, cpu) = data;
 
 	if (cpu_has(c, X86_FEATURE_CONSTANT_TSC))
 		acpi_cpufreq_driver.flags |= CPUFREQ_CONST_LOOPS;
@@ -714,20 +715,20 @@ err_unreg:
 	acpi_processor_unregister_performance(perf, cpu);
 err_free:
 	kfree(data);
-	drv_data[cpu] = NULL;
+	per_cpu(drv_data, cpu) = NULL;
 
 	return result;
 }
 
 static int acpi_cpufreq_cpu_exit(struct cpufreq_policy *policy)
 {
-	struct acpi_cpufreq_data *data = drv_data[policy->cpu];
+	struct acpi_cpufreq_data *data = per_cpu(drv_data, policy->cpu);
 
 	dprintk("acpi_cpufreq_cpu_exit\n");
 
 	if (data) {
 		cpufreq_frequency_table_put_attr(policy->cpu);
-		drv_data[policy->cpu] = NULL;
+		per_cpu(drv_data, policy->cpu) = NULL;
 		acpi_processor_unregister_performance(data->acpi_data,
 						      policy->cpu);
 		kfree(data);
@@ -738,7 +739,7 @@ static int acpi_cpufreq_cpu_exit(struct 
 
 static int acpi_cpufreq_resume(struct cpufreq_policy *policy)
 {
-	struct acpi_cpufreq_data *data = drv_data[policy->cpu];
+	struct acpi_cpufreq_data *data = per_cpu(drv_data, policy->cpu);
 
 	dprintk("acpi_cpufreq_resume\n");
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
