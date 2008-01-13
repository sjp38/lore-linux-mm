Message-Id: <20080113183454.417848000@sgi.com>
References: <20080113183453.973425000@sgi.com>
Date: Sun, 13 Jan 2008 10:34:56 -0800
From: travis@sgi.com
Subject: [PATCH 03/10] x86: Change NR_CPUS arrays in powernow-k8
Content-Disposition: inline; filename=NR_CPUS-arrays-in-powernow-k8
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the following static arrays sized by NR_CPUS to
per_cpu data variables:

	powernow_k8_data *powernow_data[NR_CPUS];


Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/kernel/cpu/cpufreq/powernow-k8.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
+++ b/arch/x86/kernel/cpu/cpufreq/powernow-k8.c
@@ -53,7 +53,7 @@
 /* serialize freq changes  */
 static DEFINE_MUTEX(fidvid_mutex);
 
-static struct powernow_k8_data *powernow_data[NR_CPUS];
+static DEFINE_PER_CPU(struct powernow_k8_data *, powernow_data);
 
 static int cpu_family = CPU_OPTERON;
 
@@ -1052,7 +1052,7 @@ static int transition_frequency_pstate(s
 static int powernowk8_target(struct cpufreq_policy *pol, unsigned targfreq, unsigned relation)
 {
 	cpumask_t oldmask = CPU_MASK_ALL;
-	struct powernow_k8_data *data = powernow_data[pol->cpu];
+	struct powernow_k8_data *data = per_cpu(powernow_data, pol->cpu);
 	u32 checkfid;
 	u32 checkvid;
 	unsigned int newstate;
@@ -1128,7 +1128,7 @@ err_out:
 /* Driver entry point to verify the policy and range of frequencies */
 static int powernowk8_verify(struct cpufreq_policy *pol)
 {
-	struct powernow_k8_data *data = powernow_data[pol->cpu];
+	struct powernow_k8_data *data = per_cpu(powernow_data, pol->cpu);
 
 	if (!data)
 		return -EINVAL;
@@ -1233,7 +1233,7 @@ static int __cpuinit powernowk8_cpu_init
 		dprintk("cpu_init done, current fid 0x%x, vid 0x%x\n",
 			data->currfid, data->currvid);
 
-	powernow_data[pol->cpu] = data;
+	per_cpu(powernow_data, pol->cpu) = data;
 
 	return 0;
 
@@ -1247,7 +1247,7 @@ err_out:
 
 static int __devexit powernowk8_cpu_exit (struct cpufreq_policy *pol)
 {
-	struct powernow_k8_data *data = powernow_data[pol->cpu];
+	struct powernow_k8_data *data = per_cpu(powernow_data, pol->cpu);
 
 	if (!data)
 		return -EINVAL;
@@ -1268,7 +1268,7 @@ static unsigned int powernowk8_get (unsi
 	cpumask_t oldmask = current->cpus_allowed;
 	unsigned int khz = 0;
 
-	data = powernow_data[first_cpu(per_cpu(cpu_core_map, cpu))];
+	data = per_cpu(powernow_data, first_cpu(per_cpu(cpu_core_map, cpu)));
 
 	if (!data)
 		return -EINVAL;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
