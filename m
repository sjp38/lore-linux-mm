Message-Id: <20080208233738.292421000@polaris-admin.engr.sgi.com>
References: <20080208233738.108449000@polaris-admin.engr.sgi.com>
Date: Fri, 08 Feb 2008 15:37:39 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/4] cpufreq: change cpu freq tables to per_cpu variables
Content-Disposition: inline; filename=nr_cpus-in-cpufreq
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Jones <davej@codemonkey.org.uk>, cpufreq@lists.linux.org.uk
List-ID: <linux-mm.kvack.org>

Change cpu frequency tables from arrays to per_cpu variables.

Based on linux-2.6.git + x86.git

Cc: Dave Jones <davej@codemonkey.org.uk>
Cc: cpufreq@lists.linux.org.uk
Signed-off-by: Mike Travis <travis@sgi.com>
---
 drivers/cpufreq/cpufreq_userspace.c |   71 +++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 32 deletions(-)

--- a/drivers/cpufreq/cpufreq_userspace.c
+++ b/drivers/cpufreq/cpufreq_userspace.c
@@ -30,11 +30,11 @@
 /**
  * A few values needed by the userspace governor
  */
-static unsigned int	cpu_max_freq[NR_CPUS];
-static unsigned int	cpu_min_freq[NR_CPUS];
-static unsigned int	cpu_cur_freq[NR_CPUS]; /* current CPU freq */
-static unsigned int	cpu_set_freq[NR_CPUS]; /* CPU freq desired by userspace */
-static unsigned int	cpu_is_managed[NR_CPUS];
+DEFINE_PER_CPU(int, cpu_max_freq);
+DEFINE_PER_CPU(int, cpu_min_freq);
+DEFINE_PER_CPU(int, cpu_cur_freq); /* current CPU freq */
+DEFINE_PER_CPU(int, cpu_set_freq); /* CPU freq desired by userspace */
+DEFINE_PER_CPU(int, cpu_is_managed);
 
 static DEFINE_MUTEX	(userspace_mutex);
 static int cpus_using_userspace_governor;
@@ -48,12 +48,12 @@ userspace_cpufreq_notifier(struct notifi
 {
         struct cpufreq_freqs *freq = data;
 
-	if (!cpu_is_managed[freq->cpu])
+	if (!per_cpu(cpu_is_managed, freq->cpu))
 		return 0;
 
 	dprintk("saving cpu_cur_freq of cpu %u to be %u kHz\n",
 			freq->cpu, freq->new);
-	cpu_cur_freq[freq->cpu] = freq->new;
+	per_cpu(cpu_cur_freq, freq->cpu) = freq->new;
 
         return 0;
 }
@@ -77,15 +77,15 @@ static int cpufreq_set(unsigned int freq
 	dprintk("cpufreq_set for cpu %u, freq %u kHz\n", policy->cpu, freq);
 
 	mutex_lock(&userspace_mutex);
-	if (!cpu_is_managed[policy->cpu])
+	if (!per_cpu(cpu_is_managed, policy->cpu))
 		goto err;
 
-	cpu_set_freq[policy->cpu] = freq;
+	per_cpu(cpu_set_freq, policy->cpu) = freq;
 
-	if (freq < cpu_min_freq[policy->cpu])
-		freq = cpu_min_freq[policy->cpu];
-	if (freq > cpu_max_freq[policy->cpu])
-		freq = cpu_max_freq[policy->cpu];
+	if (freq < per_cpu(cpu_min_freq, policy->cpu))
+		freq = per_cpu(cpu_min_freq, policy->cpu);
+	if (freq > per_cpu(cpu_max_freq, policy->cpu))
+		freq = per_cpu(cpu_max_freq, policy->cpu);
 
 	/*
 	 * We're safe from concurrent calls to ->target() here
@@ -105,7 +105,7 @@ static int cpufreq_set(unsigned int freq
 /************************** sysfs interface ************************/
 static ssize_t show_speed (struct cpufreq_policy *policy, char *buf)
 {
-	return sprintf (buf, "%u\n", cpu_cur_freq[policy->cpu]);
+	return sprintf (buf, "%u\n", per_cpu(cpu_cur_freq, policy->cpu));
 }
 
 static ssize_t
@@ -154,12 +154,16 @@ static int cpufreq_governor_userspace(st
 		}
 		cpus_using_userspace_governor++;
 
-		cpu_is_managed[cpu] = 1;
-		cpu_min_freq[cpu] = policy->min;
-		cpu_max_freq[cpu] = policy->max;
-		cpu_cur_freq[cpu] = policy->cur;
-		cpu_set_freq[cpu] = policy->cur;
-		dprintk("managing cpu %u started (%u - %u kHz, currently %u kHz)\n", cpu, cpu_min_freq[cpu], cpu_max_freq[cpu], cpu_cur_freq[cpu]);
+		per_cpu(cpu_is_managed, cpu) = 1;
+		per_cpu(cpu_min_freq, cpu) = policy->min;
+		per_cpu(cpu_max_freq, cpu) = policy->max;
+		per_cpu(cpu_cur_freq, cpu) = policy->cur;
+		per_cpu(cpu_set_freq, cpu) = policy->cur;
+		dprintk("managing cpu %u started "
+			"(%u - %u kHz, currently %u kHz)\n", cpu,
+				per_cpu(cpu_min_freq, cpu),
+				per_cpu(cpu_max_freq, cpu),
+				per_cpu(cpu_cur_freq, cpu));
 start_out:
 		mutex_unlock(&userspace_mutex);
 		break;
@@ -172,11 +176,12 @@ start_out:
 					CPUFREQ_TRANSITION_NOTIFIER);
 		}
 
-		cpu_is_managed[cpu] = 0;
-		cpu_min_freq[cpu] = 0;
-		cpu_max_freq[cpu] = 0;
-		cpu_set_freq[cpu] = 0;
-		sysfs_remove_file (&policy->kobj, &freq_attr_scaling_setspeed.attr);
+		per_cpu(cpu_is_managed, cpu) = 0;
+		per_cpu(cpu_min_freq, cpu) = 0;
+		per_cpu(cpu_max_freq, cpu) = 0;
+		per_cpu(cpu_set_freq, cpu) = 0;
+		sysfs_remove_file (&policy->kobj,
+					&freq_attr_scaling_setspeed.attr);
 		dprintk("managing cpu %u stopped\n", cpu);
 		mutex_unlock(&userspace_mutex);
 		break;
@@ -185,22 +190,24 @@ start_out:
 		dprintk("limit event for cpu %u: %u - %u kHz,"
 			"currently %u kHz, last set to %u kHz\n",
 			cpu, policy->min, policy->max,
-			cpu_cur_freq[cpu], cpu_set_freq[cpu]);
-		if (policy->max < cpu_set_freq[cpu]) {
+			per_cpu(cpu_cur_freq, cpu),
+			per_cpu(cpu_set_freq, cpu));
+		if (policy->max < per_cpu(cpu_set_freq, cpu)) {
 			__cpufreq_driver_target(policy, policy->max,
 						CPUFREQ_RELATION_H);
 		}
-		else if (policy->min > cpu_set_freq[cpu]) {
+		else if (policy->min > per_cpu(cpu_set_freq, cpu)) {
 			__cpufreq_driver_target(policy, policy->min,
 						CPUFREQ_RELATION_L);
 		}
 		else {
-			__cpufreq_driver_target(policy, cpu_set_freq[cpu],
+			__cpufreq_driver_target(policy,
+						per_cpu(cpu_set_freq, cpu),
 						CPUFREQ_RELATION_L);
 		}
-		cpu_min_freq[cpu] = policy->min;
-		cpu_max_freq[cpu] = policy->max;
-		cpu_cur_freq[cpu] = policy->cur;
+		per_cpu(cpu_min_freq, cpu) = policy->min;
+		per_cpu(cpu_max_freq, cpu) = policy->max;
+		per_cpu(cpu_cur_freq, cpu) = policy->cur;
 		mutex_unlock(&userspace_mutex);
 		break;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
