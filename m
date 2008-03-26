Message-Id: <20080326013813.184939000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:21 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 10/12] cpumask: reduce stack usage in build_sched_domains
Content-Disposition: inline; filename=build_sched_domains
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Reduce the amount of stack used in build_sched_domains by allocating
all the masks at once, and setting up individual pointers.  If
NR_CPUS <= 128, then stack space is used instead.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Ingo Molnar <mingo@elte.hu>

Signed-off-by: Mike Travis <travis@sgi.com>
---
One checkpatch warning that I'm not sure how to remove:

ERROR: Macros with complex values should be enclosed in parenthesis
#61: FILE: kernel/sched.c:6656:
+#define        SCHED_CPU_VAR(v, a)     cpumask_t *v = (cpumask_t *) \
			((unsigned long)(a) + offsetof(struct allmasks, v))
---
 kernel/sched.c |  165 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 112 insertions(+), 53 deletions(-)

--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -6573,6 +6573,40 @@ SD_INIT_FUNC(CPU)
 #endif
 
 /*
+ * To minimize stack usage kmalloc room for cpumasks and share the
+ * space as the usage in build_sched_domains() dictates.  Used only
+ * if the amount of space is significant.
+ */
+struct allmasks {
+	cpumask_t tmpmask;			/* make this one first */
+	union {
+		cpumask_t nodemask;
+		cpumask_t this_sibling_map;
+		cpumask_t this_core_map;
+	};
+	cpumask_t send_covered;
+
+#ifdef CONFIG_NUMA
+	cpumask_t domainspan;
+	cpumask_t covered;
+	cpumask_t notcovered;
+#endif
+};
+
+#if	NR_CPUS > 128
+#define	SCHED_CPUMASK_ALLOC		1
+#define	SCHED_CPUMASK_FREE(v)		kfree(v)
+#define	SCHED_CPUMASK_DECLARE(v)	struct allmasks *v
+#else
+#define	SCHED_CPUMASK_ALLOC		0
+#define	SCHED_CPUMASK_FREE(v)
+#define	SCHED_CPUMASK_DECLARE(v)	struct allmasks _v, *v = &_v
+#endif
+
+#define	SCHED_CPUMASK_VAR(v, a) 	cpumask_t *v = (cpumask_t *) \
+			((unsigned long)(a) + offsetof(struct allmasks, v))
+
+/*
  * Build sched domains for a given set of cpus and attach the sched domains
  * to the individual cpus
  */
@@ -6580,7 +6614,8 @@ static int build_sched_domains(const cpu
 {
 	int i;
 	struct root_domain *rd;
-	cpumask_t tmpmask;
+	SCHED_CPUMASK_DECLARE(allmasks);
+	cpumask_t *tmpmask;
 #ifdef CONFIG_NUMA
 	struct sched_group **sched_group_nodes = NULL;
 	int sd_allnodes = 0;
@@ -6605,6 +6640,21 @@ static int build_sched_domains(const cpu
 		return -ENOMEM;
 	}
 
+#if SCHED_CPUMASK_ALLOC
+	/* get space for all scratch cpumask variables */
+	allmasks = kmalloc(sizeof(*allmasks), GFP_KERNEL);
+	if (!allmasks) {
+		printk(KERN_WARNING "Cannot alloc cpumask array\n");
+		kfree(rd);
+#ifdef CONFIG_NUMA
+		kfree(sched_group_nodes);
+#endif
+		return -ENOMEM;
+	}
+#endif
+	tmpmask = (cpumask_t *)allmasks;
+
+
 #ifdef CONFIG_NUMA
 	sched_group_nodes_bycpu[first_cpu(*cpu_map)] = sched_group_nodes;
 #endif
@@ -6614,18 +6664,18 @@ static int build_sched_domains(const cpu
 	 */
 	for_each_cpu_mask(i, *cpu_map) {
 		struct sched_domain *sd = NULL, *p;
-		cpumask_t nodemask = node_to_cpumask(cpu_to_node(i));
+		SCHED_CPUMASK_VAR(nodemask, allmasks);
 
-		cpus_and(nodemask, nodemask, *cpu_map);
+		*nodemask = node_to_cpumask(cpu_to_node(i));
+		cpus_and(*nodemask, *nodemask, *cpu_map);
 
 #ifdef CONFIG_NUMA
 		if (cpus_weight(*cpu_map) >
-				SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+				SD_NODES_PER_DOMAIN*cpus_weight(*nodemask)) {
 			sd = &per_cpu(allnodes_domains, i);
 			SD_INIT(sd, ALLNODES);
 			sd->span = *cpu_map;
-			cpu_to_allnodes_group(i, cpu_map, &sd->groups,
-								      &tmpmask);
+			cpu_to_allnodes_group(i, cpu_map, &sd->groups, tmpmask);
 			p = sd;
 			sd_allnodes = 1;
 		} else
@@ -6643,11 +6693,11 @@ static int build_sched_domains(const cpu
 		p = sd;
 		sd = &per_cpu(phys_domains, i);
 		SD_INIT(sd, CPU);
-		sd->span = nodemask;
+		sd->span = *nodemask;
 		sd->parent = p;
 		if (p)
 			p->child = sd;
-		cpu_to_phys_group(i, cpu_map, &sd->groups, &tmpmask);
+		cpu_to_phys_group(i, cpu_map, &sd->groups, tmpmask);
 
 #ifdef CONFIG_SCHED_MC
 		p = sd;
@@ -6657,7 +6707,7 @@ static int build_sched_domains(const cpu
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
-		cpu_to_core_group(i, cpu_map, &sd->groups, &tmpmask);
+		cpu_to_core_group(i, cpu_map, &sd->groups, tmpmask);
 #endif
 
 #ifdef CONFIG_SCHED_SMT
@@ -6668,81 +6718,88 @@ static int build_sched_domains(const cpu
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
-		cpu_to_cpu_group(i, cpu_map, &sd->groups, &tmpmask);
+		cpu_to_cpu_group(i, cpu_map, &sd->groups, tmpmask);
 #endif
 	}
 
 #ifdef CONFIG_SCHED_SMT
 	/* Set up CPU (sibling) groups */
 	for_each_cpu_mask(i, *cpu_map) {
-		cpumask_t this_sibling_map = per_cpu(cpu_sibling_map, i);
-		cpumask_t send_covered;
+		SCHED_CPUMASK_VAR(this_sibling_map, allmasks);
+		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
-		cpus_and(this_sibling_map, this_sibling_map, *cpu_map);
-		if (i != first_cpu(this_sibling_map))
+		*this_sibling_map = per_cpu(cpu_sibling_map, i);
+		cpus_and(*this_sibling_map, *this_sibling_map, *cpu_map);
+		if (i != first_cpu(*this_sibling_map))
 			continue;
 
-		init_sched_build_groups(&this_sibling_map, cpu_map,
-					&cpu_to_cpu_group,
-					&send_covered, &tmpmask);
+		init_sched_build_groups(this_sibling_map, cpu_map,
+					cpu_to_cpu_group,
+					send_covered, tmpmask);
 	}
 #endif
 
 #ifdef CONFIG_SCHED_MC
 	/* Set up multi-core groups */
 	for_each_cpu_mask(i, *cpu_map) {
-		cpumask_t this_core_map = cpu_coregroup_map(i);
-		cpumask_t send_covered;
+		SCHED_CPUMASK_VAR(this_core_map, allmasks);
+		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
-		cpus_and(this_core_map, this_core_map, *cpu_map);
-		if (i != first_cpu(this_core_map))
+		*this_core_map = cpu_coregroup_map(i);
+		cpus_and(*this_core_map, *this_core_map, *cpu_map);
+		if (i != first_cpu(*this_core_map))
 			continue;
-		init_sched_build_groups(&this_core_map, cpu_map,
+
+		init_sched_build_groups(this_core_map, cpu_map,
 					&cpu_to_core_group,
-					&send_covered, &tmpmask);
+					send_covered, tmpmask);
 	}
 #endif
 
 	/* Set up physical groups */
 	for (i = 0; i < MAX_NUMNODES; i++) {
-		cpumask_t nodemask = node_to_cpumask(i);
-		cpumask_t send_covered;
+		SCHED_CPUMASK_VAR(nodemask, allmasks);
+		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
-		cpus_and(nodemask, nodemask, *cpu_map);
-		if (cpus_empty(nodemask))
+		*nodemask = node_to_cpumask(i);
+		cpus_and(*nodemask, *nodemask, *cpu_map);
+		if (cpus_empty(*nodemask))
 			continue;
 
-		init_sched_build_groups(&nodemask, cpu_map,
+		init_sched_build_groups(nodemask, cpu_map,
 					&cpu_to_phys_group,
-					&send_covered, &tmpmask);
+					send_covered, tmpmask);
 	}
 
 #ifdef CONFIG_NUMA
 	/* Set up node groups */
 	if (sd_allnodes) {
-		cpumask_t send_covered;
+		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
 		init_sched_build_groups(cpu_map, cpu_map,
 					&cpu_to_allnodes_group,
-					&send_covered, &tmpmask);
+					send_covered, tmpmask);
 	}
 
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		/* Set up node groups */
 		struct sched_group *sg, *prev;
-		cpumask_t nodemask = node_to_cpumask(i);
-		cpumask_t domainspan;
-		cpumask_t covered = CPU_MASK_NONE;
+		SCHED_CPUMASK_VAR(nodemask, allmasks);
+		SCHED_CPUMASK_VAR(domainspan, allmasks);
+		SCHED_CPUMASK_VAR(covered, allmasks);
 		int j;
 
-		cpus_and(nodemask, nodemask, *cpu_map);
-		if (cpus_empty(nodemask)) {
+		*nodemask = node_to_cpumask(i);
+		*covered = CPU_MASK_NONE;
+
+		cpus_and(*nodemask, *nodemask, *cpu_map);
+		if (cpus_empty(*nodemask)) {
 			sched_group_nodes[i] = NULL;
 			continue;
 		}
 
-		domainspan = sched_domain_node_span(i);
-		cpus_and(domainspan, domainspan, *cpu_map);
+		*domainspan = sched_domain_node_span(i);
+		cpus_and(*domainspan, *domainspan, *cpu_map);
 
 		sg = kmalloc_node(sizeof(struct sched_group), GFP_KERNEL, i);
 		if (!sg) {
@@ -6751,31 +6808,31 @@ static int build_sched_domains(const cpu
 			goto error;
 		}
 		sched_group_nodes[i] = sg;
-		for_each_cpu_mask(j, nodemask) {
+		for_each_cpu_mask(j, *nodemask) {
 			struct sched_domain *sd;
 
 			sd = &per_cpu(node_domains, j);
 			sd->groups = sg;
 		}
 		sg->__cpu_power = 0;
-		sg->cpumask = nodemask;
+		sg->cpumask = *nodemask;
 		sg->next = sg;
-		cpus_or(covered, covered, nodemask);
+		cpus_or(*covered, *covered, *nodemask);
 		prev = sg;
 
 		for (j = 0; j < MAX_NUMNODES; j++) {
-			cpumask_t tmp, notcovered;
+			SCHED_CPUMASK_VAR(notcovered, allmasks);
 			int n = (i + j) % MAX_NUMNODES;
-			node_to_cpumask_ptr(nodemask, n);
 
-			cpus_complement(notcovered, covered);
-			cpus_and(tmp, notcovered, *cpu_map);
-			cpus_and(tmp, tmp, domainspan);
-			if (cpus_empty(tmp))
+			cpus_complement(*notcovered, *covered);
+			cpus_and(*tmpmask, *notcovered, *cpu_map);
+			cpus_and(*tmpmask, *tmpmask, *domainspan);
+			if (cpus_empty(*tmpmask))
 				break;
 
-			cpus_and(tmp, tmp, *nodemask);
-			if (cpus_empty(tmp))
+			*nodemask = node_to_cpumask(n);
+			cpus_and(*tmpmask, *tmpmask, *nodemask);
+			if (cpus_empty(*tmpmask))
 				continue;
 
 			sg = kmalloc_node(sizeof(struct sched_group),
@@ -6786,9 +6843,9 @@ static int build_sched_domains(const cpu
 				goto error;
 			}
 			sg->__cpu_power = 0;
-			sg->cpumask = tmp;
+			sg->cpumask = *tmpmask;
 			sg->next = prev->next;
-			cpus_or(covered, covered, tmp);
+			cpus_or(*covered, *covered, *tmpmask);
 			prev->next = sg;
 			prev = sg;
 		}
@@ -6825,7 +6882,7 @@ static int build_sched_domains(const cpu
 		struct sched_group *sg;
 
 		cpu_to_allnodes_group(first_cpu(*cpu_map), cpu_map, &sg,
-								&tmpmask);
+								tmpmask);
 		init_numa_sched_groups_power(sg);
 	}
 #endif
@@ -6843,11 +6900,13 @@ static int build_sched_domains(const cpu
 		cpu_attach_domain(sd, rd, i);
 	}
 
+	SCHED_CPUMASK_FREE((void *)allmasks);
 	return 0;
 
 #ifdef CONFIG_NUMA
 error:
-	free_sched_groups(cpu_map, &tmpmask);
+	free_sched_groups(cpu_map, tmpmask);
+	SCHED_CPUMASK_FREE((void *)allmasks);
 	return -ENOMEM;
 #endif
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
