Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 461A16B006C
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 16:36:20 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so7179469dam.32
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 13:36:19 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/13] cpuset: introduce ->css_on/offline()
Date: Thu,  3 Jan 2013 13:35:57 -0800
Message-Id: <1357248967-24959-4-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Add cpuset_css_on/offline() and rearrange css init/exit such that,

* Allocation and clearing to the default values happen in css_alloc().
  Allocation now uses kzalloc().

* Config inheritance and registration happen in css_online().

* css_offline() undoes what css_online() did.

* css_free() frees.

This doesn't introduce any visible behavior changes.  This will help
cleaning up locking.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 66 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 5372b6f..1d7a611 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1790,15 +1790,12 @@ static struct cftype files[] = {
 
 static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 {
-	struct cgroup *parent_cg = cont->parent;
-	struct cgroup *tmp_cg;
-	struct cpuset *parent, *cs;
+	struct cpuset *cs;
 
-	if (!parent_cg)
+	if (!cont->parent)
 		return &top_cpuset.css;
-	parent = cgroup_cs(parent_cg);
 
-	cs = kmalloc(sizeof(*cs), GFP_KERNEL);
+	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
 	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL)) {
@@ -1806,22 +1803,34 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	cs->flags = 0;
-	if (is_spread_page(parent))
-		set_bit(CS_SPREAD_PAGE, &cs->flags);
-	if (is_spread_slab(parent))
-		set_bit(CS_SPREAD_SLAB, &cs->flags);
 	set_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
 	fmeter_init(&cs->fmeter);
 	cs->relax_domain_level = -1;
+	cs->parent = cgroup_cs(cont->parent);
+
+	return &cs->css;
+}
+
+static int cpuset_css_online(struct cgroup *cgrp)
+{
+	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *parent = cs->parent;
+	struct cgroup *tmp_cg;
+
+	if (!parent)
+		return 0;
+
+	if (is_spread_page(parent))
+		set_bit(CS_SPREAD_PAGE, &cs->flags);
+	if (is_spread_slab(parent))
+		set_bit(CS_SPREAD_SLAB, &cs->flags);
 
-	cs->parent = parent;
 	number_of_cpusets++;
 
-	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cont->flags))
-		goto skip_clone;
+	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags))
+		return 0;
 
 	/*
 	 * Clone @parent's configuration if CGRP_CPUSET_CLONE_CHILDREN is
@@ -1836,19 +1845,34 @@ static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 	 * changed to grant parent->cpus_allowed-sibling_cpus_exclusive
 	 * (and likewise for mems) to the new cgroup.
 	 */
-	list_for_each_entry(tmp_cg, &parent_cg->children, sibling) {
+	list_for_each_entry(tmp_cg, &cgrp->parent->children, sibling) {
 		struct cpuset *tmp_cs = cgroup_cs(tmp_cg);
 
 		if (is_mem_exclusive(tmp_cs) || is_cpu_exclusive(tmp_cs))
-			goto skip_clone;
+			return 0;
 	}
 
 	mutex_lock(&callback_mutex);
 	cs->mems_allowed = parent->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
 	mutex_unlock(&callback_mutex);
-skip_clone:
-	return &cs->css;
+
+	return 0;
+}
+
+static void cpuset_css_offline(struct cgroup *cgrp)
+{
+	struct cpuset *cs = cgroup_cs(cgrp);
+
+	/* css_offline is called w/o cgroup_mutex, grab it */
+	cgroup_lock();
+
+	if (is_sched_load_balance(cs))
+		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
+
+	number_of_cpusets--;
+
+	cgroup_unlock();
 }
 
 /*
@@ -1861,10 +1885,6 @@ static void cpuset_css_free(struct cgroup *cont)
 {
 	struct cpuset *cs = cgroup_cs(cont);
 
-	if (is_sched_load_balance(cs))
-		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
-
-	number_of_cpusets--;
 	free_cpumask_var(cs->cpus_allowed);
 	kfree(cs);
 }
@@ -1872,6 +1892,8 @@ static void cpuset_css_free(struct cgroup *cont)
 struct cgroup_subsys cpuset_subsys = {
 	.name = "cpuset",
 	.css_alloc = cpuset_css_alloc,
+	.css_online = cpuset_css_online,
+	.css_offline = cpuset_css_offline,
 	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
