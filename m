Message-Id: <20080325021955.937511000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:20:00 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 06/10] x86: reduce memory and stack usage in intel_cacheinfo
Content-Disposition: inline; filename=nr_cpus-in-intel_cacheinfo
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

* Change the following static arrays sized by NR_CPUS to
  per_cpu data variables:

	_cpuid4_info *cpuid4_info[NR_CPUS];
	_index_kobject *index_kobject[NR_CPUS];
	kobject * cache_kobject[NR_CPUS];

* Remove the local NR_CPUS array with a kmalloc'd region in
  show_shared_cpu_map().

Also some minor complaints from checkpatch.pl fixed.

Based on linux-2.6.25-rc5-mm1

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andi Kleen <ak@suse.de>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/cpu/intel_cacheinfo.c |   70 +++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 30 deletions(-)

--- linux-2.6.25-rc5.orig/arch/x86/kernel/cpu/intel_cacheinfo.c
+++ linux-2.6.25-rc5/arch/x86/kernel/cpu/intel_cacheinfo.c
@@ -129,7 +129,7 @@ struct _cpuid4_info {
 	union _cpuid4_leaf_ebx ebx;
 	union _cpuid4_leaf_ecx ecx;
 	unsigned long size;
-	cpumask_t shared_cpu_map;
+	cpumask_t shared_cpu_map;	/* future?: only cpus/node is needed */
 };
 
 unsigned short			num_cache_leaves;
@@ -451,8 +451,8 @@ unsigned int __cpuinit init_intel_cachei
 }
 
 /* pointer to _cpuid4_info array (for each cache leaf) */
-static struct _cpuid4_info *cpuid4_info[NR_CPUS];
-#define CPUID4_INFO_IDX(x,y)    (&((cpuid4_info[x])[y]))
+static DEFINE_PER_CPU(struct _cpuid4_info *, cpuid4_info);
+#define CPUID4_INFO_IDX(x, y)    (&((per_cpu(cpuid4_info, x))[y]))
 
 #ifdef CONFIG_SMP
 static void __cpuinit cache_shared_cpu_map_setup(unsigned int cpu, int index)
@@ -474,7 +474,7 @@ static void __cpuinit cache_shared_cpu_m
 			if (cpu_data(i).apicid >> index_msb ==
 			    c->apicid >> index_msb) {
 				cpu_set(i, this_leaf->shared_cpu_map);
-				if (i != cpu && cpuid4_info[i])  {
+				if (i != cpu && per_cpu(cpuid4_info, i))  {
 					sibling_leaf = CPUID4_INFO_IDX(i, index);
 					cpu_set(cpu, sibling_leaf->shared_cpu_map);
 				}
@@ -505,8 +505,8 @@ static void __cpuinit free_cache_attribu
 	for (i = 0; i < num_cache_leaves; i++)
 		cache_remove_shared_cpu_map(cpu, i);
 
-	kfree(cpuid4_info[cpu]);
-	cpuid4_info[cpu] = NULL;
+	kfree(per_cpu(cpuid4_info, cpu));
+	per_cpu(cpuid4_info, cpu) = NULL;
 }
 
 static int __cpuinit detect_cache_attributes(unsigned int cpu)
@@ -519,9 +519,9 @@ static int __cpuinit detect_cache_attrib
 	if (num_cache_leaves == 0)
 		return -ENOENT;
 
-	cpuid4_info[cpu] = kzalloc(
+	per_cpu(cpuid4_info, cpu) = kzalloc(
 	    sizeof(struct _cpuid4_info) * num_cache_leaves, GFP_KERNEL);
-	if (cpuid4_info[cpu] == NULL)
+	if (per_cpu(cpuid4_info, cpu) == NULL)
 		return -ENOMEM;
 
 	oldmask = current->cpus_allowed;
@@ -546,8 +546,8 @@ static int __cpuinit detect_cache_attrib
 
 out:
 	if (retval) {
-		kfree(cpuid4_info[cpu]);
-		cpuid4_info[cpu] = NULL;
+		kfree(per_cpu(cpuid4_info, cpu));
+		per_cpu(cpuid4_info, cpu) = NULL;
 	}
 
 	return retval;
@@ -561,7 +561,7 @@ out:
 extern struct sysdev_class cpu_sysdev_class; /* from drivers/base/cpu.c */
 
 /* pointer to kobject for cpuX/cache */
-static struct kobject * cache_kobject[NR_CPUS];
+static DEFINE_PER_CPU(struct kobject *, cache_kobject);
 
 struct _index_kobject {
 	struct kobject kobj;
@@ -570,8 +570,8 @@ struct _index_kobject {
 };
 
 /* pointer to array of kobjects for cpuX/cache/indexY */
-static struct _index_kobject *index_kobject[NR_CPUS];
-#define INDEX_KOBJECT_PTR(x,y)    (&((index_kobject[x])[y]))
+static DEFINE_PER_CPU(struct _index_kobject *, index_kobject);
+#define INDEX_KOBJECT_PTR(x, y)    (&((per_cpu(index_kobject, x))[y]))
 
 #define show_one_plus(file_name, object, val)				\
 static ssize_t show_##file_name						\
@@ -593,9 +593,16 @@ static ssize_t show_size(struct _cpuid4_
 
 static ssize_t show_shared_cpu_map(struct _cpuid4_info *this_leaf, char *buf)
 {
-	char mask_str[NR_CPUS];
-	cpumask_scnprintf(mask_str, NR_CPUS, this_leaf->shared_cpu_map);
-	return sprintf(buf, "%s\n", mask_str);
+	int n = 0;
+	int len = cpumask_scnprintf_len(nr_cpu_ids);
+	char *mask_str = kmalloc(len, GFP_KERNEL);
+
+	if (mask_str) {
+		cpumask_scnprintf(mask_str, len, this_leaf->shared_cpu_map);
+		n = sprintf(buf, "%s\n", mask_str);
+		kfree(mask_str);
+	}
+	return n;
 }
 
 static ssize_t show_type(struct _cpuid4_info *this_leaf, char *buf) {
@@ -684,10 +691,10 @@ static struct kobj_type ktype_percpu_ent
 
 static void __cpuinit cpuid4_cache_sysfs_exit(unsigned int cpu)
 {
-	kfree(cache_kobject[cpu]);
-	kfree(index_kobject[cpu]);
-	cache_kobject[cpu] = NULL;
-	index_kobject[cpu] = NULL;
+	kfree(per_cpu(cache_kobject, cpu));
+	kfree(per_cpu(index_kobject, cpu));
+	per_cpu(cache_kobject, cpu) = NULL;
+	per_cpu(index_kobject, cpu) = NULL;
 	free_cache_attributes(cpu);
 }
 
@@ -703,13 +710,14 @@ static int __cpuinit cpuid4_cache_sysfs_
 		return err;
 
 	/* Allocate all required memory */
-	cache_kobject[cpu] = kzalloc(sizeof(struct kobject), GFP_KERNEL);
-	if (unlikely(cache_kobject[cpu] == NULL))
+	per_cpu(cache_kobject, cpu) =
+		kzalloc(sizeof(struct kobject), GFP_KERNEL);
+	if (unlikely(per_cpu(cache_kobject, cpu) == NULL))
 		goto err_out;
 
-	index_kobject[cpu] = kzalloc(
+	per_cpu(index_kobject, cpu) = kzalloc(
 	    sizeof(struct _index_kobject ) * num_cache_leaves, GFP_KERNEL);
-	if (unlikely(index_kobject[cpu] == NULL))
+	if (unlikely(per_cpu(index_kobject, cpu) == NULL))
 		goto err_out;
 
 	return 0;
@@ -733,7 +741,8 @@ static int __cpuinit cache_add_dev(struc
 	if (unlikely(retval < 0))
 		return retval;
 
-	retval = kobject_init_and_add(cache_kobject[cpu], &ktype_percpu_entry,
+	retval = kobject_init_and_add(per_cpu(cache_kobject, cpu),
+				      &ktype_percpu_entry,
 				      &sys_dev->kobj, "%s", "cache");
 	if (retval < 0) {
 		cpuid4_cache_sysfs_exit(cpu);
@@ -745,13 +754,14 @@ static int __cpuinit cache_add_dev(struc
 		this_object->cpu = cpu;
 		this_object->index = i;
 		retval = kobject_init_and_add(&(this_object->kobj),
-					      &ktype_cache, cache_kobject[cpu],
+					      &ktype_cache,
+					      per_cpu(cache_kobject, cpu),
 					      "index%1lu", i);
 		if (unlikely(retval)) {
 			for (j = 0; j < i; j++) {
 				kobject_put(&(INDEX_KOBJECT_PTR(cpu,j)->kobj));
 			}
-			kobject_put(cache_kobject[cpu]);
+			kobject_put(per_cpu(cache_kobject, cpu));
 			cpuid4_cache_sysfs_exit(cpu);
 			break;
 		}
@@ -760,7 +770,7 @@ static int __cpuinit cache_add_dev(struc
 	if (!retval)
 		cpu_set(cpu, cache_dev_map);
 
-	kobject_uevent(cache_kobject[cpu], KOBJ_ADD);
+	kobject_uevent(per_cpu(cache_kobject, cpu), KOBJ_ADD);
 	return retval;
 }
 
@@ -769,7 +779,7 @@ static void __cpuinit cache_remove_dev(s
 	unsigned int cpu = sys_dev->id;
 	unsigned long i;
 
-	if (cpuid4_info[cpu] == NULL)
+	if (per_cpu(cpuid4_info, cpu) == NULL)
 		return;
 	if (!cpu_isset(cpu, cache_dev_map))
 		return;
@@ -777,7 +787,7 @@ static void __cpuinit cache_remove_dev(s
 
 	for (i = 0; i < num_cache_leaves; i++)
 		kobject_put(&(INDEX_KOBJECT_PTR(cpu,i)->kobj));
-	kobject_put(cache_kobject[cpu]);
+	kobject_put(per_cpu(cache_kobject, cpu));
 	cpuid4_cache_sysfs_exit(cpu);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
