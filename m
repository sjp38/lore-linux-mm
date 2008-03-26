Message-Id: <20080326013812.899046000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:19 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 08/12] cpumask: pass temp cpumask variables in init_sched_build_groups
Content-Disposition: inline; filename=kern_sched
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pass pointers to temporary cpumask variables instead of creating on the stack.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Cc: Ingo Molnar <mingo@elte.hu>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 kernel/sched.c |  218 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 126 insertions(+), 92 deletions(-)

--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -1670,17 +1670,17 @@ find_idlest_group(struct sched_domain *s
  * find_idlest_cpu - find the idlest cpu among the cpus in group.
  */
 static int
-find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu)
+find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu,
+		cpumask_t *tmp)
 {
-	cpumask_t tmp;
 	unsigned long load, min_load = ULONG_MAX;
 	int idlest = -1;
 	int i;
 
 	/* Traverse only the allowed CPUs */
-	cpus_and(tmp, group->cpumask, p->cpus_allowed);
+	cpus_and(*tmp, group->cpumask, p->cpus_allowed);
 
-	for_each_cpu_mask(i, tmp) {
+	for_each_cpu_mask(i, *tmp) {
 		load = weighted_cpuload(i);
 
 		if (load < min_load || (load == min_load && i == this_cpu)) {
@@ -1719,7 +1719,7 @@ static int sched_balance_self(int cpu, i
 	}
 
 	while (sd) {
-		cpumask_t span;
+		cpumask_t span, tmpmask;
 		struct sched_group *group;
 		int new_cpu, weight;
 
@@ -1735,7 +1735,7 @@ static int sched_balance_self(int cpu, i
 			continue;
 		}
 
-		new_cpu = find_idlest_cpu(group, t, cpu);
+		new_cpu = find_idlest_cpu(group, t, cpu, &tmpmask);
 		if (new_cpu == -1 || new_cpu == cpu) {
 			/* Now try balancing at a lower domain level of cpu */
 			sd = sd->child;
@@ -2616,7 +2616,7 @@ static int move_one_task(struct rq *this
 static struct sched_group *
 find_busiest_group(struct sched_domain *sd, int this_cpu,
 		   unsigned long *imbalance, enum cpu_idle_type idle,
-		   int *sd_idle, cpumask_t *cpus, int *balance)
+		   int *sd_idle, const cpumask_t *cpus, int *balance)
 {
 	struct sched_group *busiest = NULL, *this = NULL, *group = sd->groups;
 	unsigned long max_load, avg_load, total_load, this_load, total_pwr;
@@ -2917,7 +2917,7 @@ ret:
  */
 static struct rq *
 find_busiest_queue(struct sched_group *group, enum cpu_idle_type idle,
-		   unsigned long imbalance, cpumask_t *cpus)
+		   unsigned long imbalance, const cpumask_t *cpus)
 {
 	struct rq *busiest = NULL, *rq;
 	unsigned long max_load = 0;
@@ -2956,15 +2956,16 @@ find_busiest_queue(struct sched_group *g
  */
 static int load_balance(int this_cpu, struct rq *this_rq,
 			struct sched_domain *sd, enum cpu_idle_type idle,
-			int *balance)
+			int *balance, cpumask_t *cpus)
 {
 	int ld_moved, all_pinned = 0, active_balance = 0, sd_idle = 0;
 	struct sched_group *group;
 	unsigned long imbalance;
 	struct rq *busiest;
-	cpumask_t cpus = CPU_MASK_ALL;
 	unsigned long flags;
 
+	cpus_setall(*cpus);
+
 	/*
 	 * When power savings policy is enabled for the parent domain, idle
 	 * sibling can pick up load irrespective of busy siblings. In this case,
@@ -2979,7 +2980,7 @@ static int load_balance(int this_cpu, st
 
 redo:
 	group = find_busiest_group(sd, this_cpu, &imbalance, idle, &sd_idle,
-				   &cpus, balance);
+				   cpus, balance);
 
 	if (*balance == 0)
 		goto out_balanced;
@@ -2989,7 +2990,7 @@ redo:
 		goto out_balanced;
 	}
 
-	busiest = find_busiest_queue(group, idle, imbalance, &cpus);
+	busiest = find_busiest_queue(group, idle, imbalance, cpus);
 	if (!busiest) {
 		schedstat_inc(sd, lb_nobusyq[idle]);
 		goto out_balanced;
@@ -3022,8 +3023,8 @@ redo:
 
 		/* All tasks on this runqueue were pinned by CPU affinity */
 		if (unlikely(all_pinned)) {
-			cpu_clear(cpu_of(busiest), cpus);
-			if (!cpus_empty(cpus))
+			cpu_clear(cpu_of(busiest), *cpus);
+			if (!cpus_empty(*cpus))
 				goto redo;
 			goto out_balanced;
 		}
@@ -3108,7 +3109,8 @@ out_one_pinned:
  * this_rq is locked.
  */
 static int
-load_balance_newidle(int this_cpu, struct rq *this_rq, struct sched_domain *sd)
+load_balance_newidle(int this_cpu, struct rq *this_rq, struct sched_domain *sd,
+			cpumask_t *cpus)
 {
 	struct sched_group *group;
 	struct rq *busiest = NULL;
@@ -3116,7 +3118,8 @@ load_balance_newidle(int this_cpu, struc
 	int ld_moved = 0;
 	int sd_idle = 0;
 	int all_pinned = 0;
-	cpumask_t cpus = CPU_MASK_ALL;
+
+	cpus_setall(*cpus);
 
 	/*
 	 * When power savings policy is enabled for the parent domain, idle
@@ -3131,14 +3134,13 @@ load_balance_newidle(int this_cpu, struc
 	schedstat_inc(sd, lb_count[CPU_NEWLY_IDLE]);
 redo:
 	group = find_busiest_group(sd, this_cpu, &imbalance, CPU_NEWLY_IDLE,
-				   &sd_idle, &cpus, NULL);
+				   &sd_idle, cpus, NULL);
 	if (!group) {
 		schedstat_inc(sd, lb_nobusyg[CPU_NEWLY_IDLE]);
 		goto out_balanced;
 	}
 
-	busiest = find_busiest_queue(group, CPU_NEWLY_IDLE, imbalance,
-				&cpus);
+	busiest = find_busiest_queue(group, CPU_NEWLY_IDLE, imbalance, cpus);
 	if (!busiest) {
 		schedstat_inc(sd, lb_nobusyq[CPU_NEWLY_IDLE]);
 		goto out_balanced;
@@ -3160,8 +3162,8 @@ redo:
 		spin_unlock(&busiest->lock);
 
 		if (unlikely(all_pinned)) {
-			cpu_clear(cpu_of(busiest), cpus);
-			if (!cpus_empty(cpus))
+			cpu_clear(cpu_of(busiest), *cpus);
+			if (!cpus_empty(*cpus))
 				goto redo;
 		}
 	}
@@ -3195,6 +3197,7 @@ static void idle_balance(int this_cpu, s
 	struct sched_domain *sd;
 	int pulled_task = -1;
 	unsigned long next_balance = jiffies + HZ;
+	cpumask_t tmpmask;
 
 	for_each_domain(this_cpu, sd) {
 		unsigned long interval;
@@ -3204,8 +3207,8 @@ static void idle_balance(int this_cpu, s
 
 		if (sd->flags & SD_BALANCE_NEWIDLE)
 			/* If we've pulled tasks over stop searching: */
-			pulled_task = load_balance_newidle(this_cpu,
-								this_rq, sd);
+			pulled_task = load_balance_newidle(this_cpu, this_rq,
+							   sd, &tmpmask);
 
 		interval = msecs_to_jiffies(sd->balance_interval);
 		if (time_after(next_balance, sd->last_balance + interval))
@@ -3364,6 +3367,7 @@ static void rebalance_domains(int cpu, e
 	/* Earliest time when we have to do rebalance again */
 	unsigned long next_balance = jiffies + 60*HZ;
 	int update_next_balance = 0;
+	cpumask_t tmp;
 
 	for_each_domain(cpu, sd) {
 		if (!(sd->flags & SD_LOAD_BALANCE))
@@ -3387,7 +3391,7 @@ static void rebalance_domains(int cpu, e
 		}
 
 		if (time_after_eq(jiffies, sd->last_balance + interval)) {
-			if (load_balance(cpu, rq, sd, idle, &balance)) {
+			if (load_balance(cpu, rq, sd, idle, &balance, &tmp)) {
 				/*
 				 * We've pulled tasks over so either we're no
 				 * longer idle, or one of our SMT siblings is
@@ -5912,21 +5916,10 @@ void __init migration_init(void)
 
 #ifdef CONFIG_SCHED_DEBUG
 
-static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level)
+static int sched_domain_debug_one(struct sched_domain *sd, int cpu, int level,
+				  cpumask_t *groupmask, char *str, int len)
 {
 	struct sched_group *group = sd->groups;
-	cpumask_t groupmask;
-	int len = cpumask_scnprintf_len(nr_cpu_ids);
-	char *str = kmalloc(len, GFP_KERNEL);
-	int ret = 0;
-
-	if (!str) {
-		printk(KERN_DEBUG "Cannot load-balance (no memory)\n");
-		return -1;
-	}
-
-	cpumask_scnprintf(str, len, sd->span);
-	cpus_clear(groupmask);
 
 	printk(KERN_DEBUG "%*s domain %d: ", level, "", level);
 
@@ -5935,10 +5928,12 @@ static int sched_domain_debug_one(struct
 		if (sd->parent)
 			printk(KERN_ERR "ERROR: !SD_LOAD_BALANCE domain"
 					" has parent");
-		kfree(str);
 		return -1;
 	}
 
+	cpumask_scnprintf(str, len, sd->span);
+	cpus_clear(*groupmask);
+
 	printk(KERN_CONT "span %s\n", str);
 
 	if (!cpu_isset(cpu, sd->span)) {
@@ -5971,13 +5966,13 @@ static int sched_domain_debug_one(struct
 			break;
 		}
 
-		if (cpus_intersects(groupmask, group->cpumask)) {
+		if (cpus_intersects(*groupmask, group->cpumask)) {
 			printk(KERN_CONT "\n");
 			printk(KERN_ERR "ERROR: repeated CPUs\n");
 			break;
 		}
 
-		cpus_or(groupmask, groupmask, group->cpumask);
+		cpus_or(*groupmask, *groupmask, group->cpumask);
 
 		cpumask_scnprintf(str, len, group->cpumask);
 		printk(KERN_CONT " %s", str);
@@ -5986,36 +5981,49 @@ static int sched_domain_debug_one(struct
 	} while (group != sd->groups);
 	printk(KERN_CONT "\n");
 
-	if (!cpus_equal(sd->span, groupmask))
+	if (!cpus_equal(sd->span, *groupmask))
 		printk(KERN_ERR "ERROR: groups don't span domain->span\n");
 
-	if (sd->parent && !cpus_subset(groupmask, sd->parent->span))
+	if (sd->parent && !cpus_subset(*groupmask, sd->parent->span))
 		printk(KERN_ERR "ERROR: parent span is not a superset "
 			"of domain->span\n");
 
-	kfree(str);
 	return 0;
 }
 
 static void sched_domain_debug(struct sched_domain *sd, int cpu)
 {
 	int level = 0;
+	char *str = NULL;
+	cpumask_t *groupmask = NULL;
+	int len;
 
 	if (!sd) {
 		printk(KERN_DEBUG "CPU%d attaching NULL sched-domain.\n", cpu);
 		return;
 	}
 
+	groupmask = kmalloc(sizeof(cpumask_t), GFP_KERNEL);
+	len = cpumask_scnprintf_len(nr_cpu_ids);
+	str = kmalloc(len, GFP_KERNEL);
+	if (!groupmask || !str) {
+		printk(KERN_DEBUG "Cannot load-balance (out of memory)\n");
+		goto exit;
+	}
+
 	printk(KERN_DEBUG "CPU%d attaching sched-domain:\n", cpu);
 
 	for (;;) {
-		if (sched_domain_debug_one(sd, cpu, level))
+		if (sched_domain_debug_one(sd, cpu, level, groupmask, str, len))
 			break;
 		level++;
 		sd = sd->parent;
 		if (!sd)
 			break;
 	}
+exit:
+	kfree(str);
+	kfree(groupmask);
 }
 #else
 # define sched_domain_debug(sd, cpu) do { } while (0)
@@ -6203,30 +6211,33 @@ __setup("isolcpus=", isolated_cpu_setup)
  * and ->cpu_power to 0.
  */
 static void
-init_sched_build_groups(cpumask_t span, const cpumask_t *cpu_map,
+init_sched_build_groups(const cpumask_t *span, const cpumask_t *cpu_map,
 			int (*group_fn)(int cpu, const cpumask_t *cpu_map,
-					struct sched_group **sg))
+					struct sched_group **sg,
+					cpumask_t *tmpmask),
+			cpumask_t *covered, cpumask_t *tmpmask)
 {
 	struct sched_group *first = NULL, *last = NULL;
-	cpumask_t covered = CPU_MASK_NONE;
 	int i;
 
-	for_each_cpu_mask(i, span) {
+	*covered = CPU_MASK_NONE;
+
+	for_each_cpu_mask(i, *span) {
 		struct sched_group *sg;
-		int group = group_fn(i, cpu_map, &sg);
+		int group = group_fn(i, cpu_map, &sg, tmpmask);
 		int j;
 
-		if (cpu_isset(i, covered))
+		if (cpu_isset(i, *covered))
 			continue;
 
 		sg->cpumask = CPU_MASK_NONE;
 		sg->__cpu_power = 0;
 
-		for_each_cpu_mask(j, span) {
-			if (group_fn(j, cpu_map, NULL) != group)
+		for_each_cpu_mask(j, *span) {
+			if (group_fn(j, cpu_map, NULL, tmpmask) != group)
 				continue;
 
-			cpu_set(j, covered);
+			cpu_set(j, *covered);
 			cpu_set(j, sg->cpumask);
 		}
 		if (!first)
@@ -6324,7 +6335,8 @@ static DEFINE_PER_CPU(struct sched_domai
 static DEFINE_PER_CPU(struct sched_group, sched_group_cpus);
 
 static int
-cpu_to_cpu_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg)
+cpu_to_cpu_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg,
+		 cpumask_t *unused)
 {
 	if (sg)
 		*sg = &per_cpu(sched_group_cpus, cpu);
@@ -6342,19 +6354,22 @@ static DEFINE_PER_CPU(struct sched_group
 
 #if defined(CONFIG_SCHED_MC) && defined(CONFIG_SCHED_SMT)
 static int
-cpu_to_core_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg)
+cpu_to_core_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg,
+		  cpumask_t *mask)
 {
 	int group;
-	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
-	cpus_and(mask, mask, *cpu_map);
-	group = first_cpu(mask);
+
+	*mask = per_cpu(cpu_sibling_map, cpu);
+	cpus_and(*mask, *mask, *cpu_map);
+	group = first_cpu(*mask);
 	if (sg)
 		*sg = &per_cpu(sched_group_core, group);
 	return group;
 }
 #elif defined(CONFIG_SCHED_MC)
 static int
-cpu_to_core_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg)
+cpu_to_core_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg,
+		  cpumask_t *unused)
 {
 	if (sg)
 		*sg = &per_cpu(sched_group_core, cpu);
@@ -6366,17 +6381,18 @@ static DEFINE_PER_CPU(struct sched_domai
 static DEFINE_PER_CPU(struct sched_group, sched_group_phys);
 
 static int
-cpu_to_phys_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg)
+cpu_to_phys_group(int cpu, const cpumask_t *cpu_map, struct sched_group **sg,
+		  cpumask_t *mask)
 {
 	int group;
 #ifdef CONFIG_SCHED_MC
-	cpumask_t mask = cpu_coregroup_map(cpu);
-	cpus_and(mask, mask, *cpu_map);
-	group = first_cpu(mask);
+	*mask = cpu_coregroup_map(cpu);
+	cpus_and(*mask, *mask, *cpu_map);
+	group = first_cpu(*mask);
 #elif defined(CONFIG_SCHED_SMT)
-	cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
-	cpus_and(mask, mask, *cpu_map);
-	group = first_cpu(mask);
+	*mask = per_cpu(cpu_sibling_map, cpu);
+	cpus_and(*mask, *mask, *cpu_map);
+	group = first_cpu(*mask);
 #else
 	group = cpu;
 #endif
@@ -6398,13 +6414,13 @@ static DEFINE_PER_CPU(struct sched_domai
 static DEFINE_PER_CPU(struct sched_group, sched_group_allnodes);
 
 static int cpu_to_allnodes_group(int cpu, const cpumask_t *cpu_map,
-				 struct sched_group **sg)
+				 struct sched_group **sg, cpumask_t *nodemask)
 {
-	cpumask_t nodemask = node_to_cpumask(cpu_to_node(cpu));
 	int group;
 
-	cpus_and(nodemask, nodemask, *cpu_map);
-	group = first_cpu(nodemask);
+	*nodemask = node_to_cpumask(cpu_to_node(cpu));
+	cpus_and(*nodemask, *nodemask, *cpu_map);
+	group = first_cpu(*nodemask);
 
 	if (sg)
 		*sg = &per_cpu(sched_group_allnodes, group);
@@ -6440,7 +6456,7 @@ static void init_numa_sched_groups_power
 
 #ifdef CONFIG_NUMA
 /* Free memory allocated for various sched_group structures */
-static void free_sched_groups(const cpumask_t *cpu_map)
+static void free_sched_groups(const cpumask_t *cpu_map, cpumask_t *nodemask)
 {
 	int cpu, i;
 
@@ -6452,11 +6468,11 @@ static void free_sched_groups(const cpum
 			continue;
 
 		for (i = 0; i < MAX_NUMNODES; i++) {
-			cpumask_t nodemask = node_to_cpumask(i);
 			struct sched_group *oldsg, *sg = sched_group_nodes[i];
 
-			cpus_and(nodemask, nodemask, *cpu_map);
-			if (cpus_empty(nodemask))
+			*nodemask = node_to_cpumask(i);
+			cpus_and(*nodemask, *nodemask, *cpu_map);
+			if (cpus_empty(*nodemask))
 				continue;
 
 			if (sg == NULL)
@@ -6474,7 +6490,7 @@ next_sg:
 	}
 }
 #else
-static void free_sched_groups(const cpumask_t *cpu_map)
+static void free_sched_groups(const cpumask_t *cpu_map, cpumask_t *nodemask)
 {
 }
 #endif
@@ -6564,6 +6580,7 @@ static int build_sched_domains(const cpu
 {
 	int i;
 	struct root_domain *rd;
+	cpumask_t tmpmask;
 #ifdef CONFIG_NUMA
 	struct sched_group **sched_group_nodes = NULL;
 	int sd_allnodes = 0;
@@ -6601,7 +6618,8 @@ static int build_sched_domains(const cpu
 			sd = &per_cpu(allnodes_domains, i);
 			SD_INIT(sd, ALLNODES);
 			sd->span = *cpu_map;
-			cpu_to_allnodes_group(i, cpu_map, &sd->groups);
+			cpu_to_allnodes_group(i, cpu_map, &sd->groups,
+								      &tmpmask);
 			p = sd;
 			sd_allnodes = 1;
 		} else
@@ -6623,7 +6641,7 @@ static int build_sched_domains(const cpu
 		sd->parent = p;
 		if (p)
 			p->child = sd;
-		cpu_to_phys_group(i, cpu_map, &sd->groups);
+		cpu_to_phys_group(i, cpu_map, &sd->groups, &tmpmask);
 
 #ifdef CONFIG_SCHED_MC
 		p = sd;
@@ -6633,7 +6651,7 @@ static int build_sched_domains(const cpu
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
-		cpu_to_core_group(i, cpu_map, &sd->groups);
+		cpu_to_core_group(i, cpu_map, &sd->groups, &tmpmask);
 #endif
 
 #ifdef CONFIG_SCHED_SMT
@@ -6644,7 +6662,7 @@ static int build_sched_domains(const cpu
 		cpus_and(sd->span, sd->span, *cpu_map);
 		sd->parent = p;
 		p->child = sd;
-		cpu_to_cpu_group(i, cpu_map, &sd->groups);
+		cpu_to_cpu_group(i, cpu_map, &sd->groups, &tmpmask);
 #endif
 	}
 
@@ -6652,12 +6670,15 @@ static int build_sched_domains(const cpu
 	/* Set up CPU (sibling) groups */
 	for_each_cpu_mask(i, *cpu_map) {
 		cpumask_t this_sibling_map = per_cpu(cpu_sibling_map, i);
+		cpumask_t send_covered;
+
 		cpus_and(this_sibling_map, this_sibling_map, *cpu_map);
 		if (i != first_cpu(this_sibling_map))
 			continue;
 
-		init_sched_build_groups(this_sibling_map, cpu_map,
-					&cpu_to_cpu_group);
+		init_sched_build_groups(&this_sibling_map, cpu_map,
+					&cpu_to_cpu_group,
+					&send_covered, &tmpmask);
 	}
 #endif
 
@@ -6665,30 +6686,40 @@ static int build_sched_domains(const cpu
 	/* Set up multi-core groups */
 	for_each_cpu_mask(i, *cpu_map) {
 		cpumask_t this_core_map = cpu_coregroup_map(i);
+		cpumask_t send_covered;
+
 		cpus_and(this_core_map, this_core_map, *cpu_map);
 		if (i != first_cpu(this_core_map))
 			continue;
-		init_sched_build_groups(this_core_map, cpu_map,
-					&cpu_to_core_group);
+		init_sched_build_groups(&this_core_map, cpu_map,
+					&cpu_to_core_group,
+					&send_covered, &tmpmask);
 	}
 #endif
 
 	/* Set up physical groups */
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		cpumask_t nodemask = node_to_cpumask(i);
+		cpumask_t send_covered;
 
 		cpus_and(nodemask, nodemask, *cpu_map);
 		if (cpus_empty(nodemask))
 			continue;
 
-		init_sched_build_groups(nodemask, cpu_map, &cpu_to_phys_group);
+		init_sched_build_groups(&nodemask, cpu_map,
+					&cpu_to_phys_group,
+					&send_covered, &tmpmask);
 	}
 
 #ifdef CONFIG_NUMA
 	/* Set up node groups */
-	if (sd_allnodes)
-		init_sched_build_groups(*cpu_map, cpu_map,
-					&cpu_to_allnodes_group);
+	if (sd_allnodes) {
+		cpumask_t send_covered;
+
+		init_sched_build_groups(cpu_map, cpu_map,
+					&cpu_to_allnodes_group,
+					&send_covered, &tmpmask);
+	}
 
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		/* Set up node groups */
@@ -6787,7 +6818,8 @@ static int build_sched_domains(const cpu
 	if (sd_allnodes) {
 		struct sched_group *sg;
 
-		cpu_to_allnodes_group(first_cpu(*cpu_map), cpu_map, &sg);
+		cpu_to_allnodes_group(first_cpu(*cpu_map), cpu_map, &sg,
+								&tmpmask);
 		init_numa_sched_groups_power(sg);
 	}
 #endif
@@ -6809,7 +6841,7 @@ static int build_sched_domains(const cpu
 
 #ifdef CONFIG_NUMA
 error:
-	free_sched_groups(cpu_map);
+	free_sched_groups(cpu_map, &tmpmask);
 	return -ENOMEM;
 #endif
 }
@@ -6849,9 +6881,10 @@ static int arch_init_sched_domains(const
 	return err;
 }
 
-static void arch_destroy_sched_domains(const cpumask_t *cpu_map)
+static void arch_destroy_sched_domains(const cpumask_t *cpu_map,
+				       cpumask_t *tmpmask)
 {
-	free_sched_groups(cpu_map);
+	free_sched_groups(cpu_map, tmpmask);
 }
 
 /*
@@ -6860,6 +6893,7 @@ static void arch_destroy_sched_domains(c
  */
 static void detach_destroy_domains(const cpumask_t *cpu_map)
 {
+	cpumask_t tmpmask;
 	int i;
 
 	unregister_sched_domain_sysctl();
@@ -6867,7 +6901,7 @@ static void detach_destroy_domains(const
 	for_each_cpu_mask(i, *cpu_map)
 		cpu_attach_domain(NULL, &def_root_domain, i);
 	synchronize_sched();
-	arch_destroy_sched_domains(cpu_map);
+	arch_destroy_sched_domains(cpu_map, &tmpmask);
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
