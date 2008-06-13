Date: Fri, 13 Jun 2008 18:37:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 6/6] memcg: HARDWALL hierarchy
Message-Id: <20080613183741.5e2f7fda.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Support hardwall hierarchy (and no-hierarchy) in memcg.

Change log: v3->v4
 - cut out from memcg hierarchy patch set v4.
 - no major changes, but some amount of functions are moved to res_counter.
   and be more gneric.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/memory.txt |   57 +++++++++++++++++++++++++++++-
 mm/memcontrol.c                      |   65 +++++++++++++++++++++++++++++++++--
 2 files changed, 118 insertions(+), 4 deletions(-)

Index: linux-2.6.26-rc5-mm3/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/memcontrol.c
+++ linux-2.6.26-rc5-mm3/mm/memcontrol.c
@@ -941,6 +941,48 @@ static int mem_force_empty_write(struct 
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
+
+static u64 mem_cgroup_hierarchy_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *mem;
+
+	mem = mem_cgroup_from_cont(cgrp);
+
+	return mem->res.ops.hierarchy_model;
+}
+
+static int
+mem_cgroup_hierarchy_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem;
+	struct res_counter_ops ops;
+	int ret = -EBUSY;
+
+	mem = mem_cgroup_from_cont(cgrp);
+
+	if (!list_empty(&cgrp->children))
+		return ret;
+
+	switch ((int)val) {
+	case RES_CONT_NO_HIERARCHY:
+		ops.hierarchy_model = RES_CONT_NO_HIERARCHY;
+		ops.shrink_usage = mem_cgroup_shrink_usage_to;
+		ret = res_counter_set_ops(&mem->res, &ops);
+		break;
+	case RES_CONT_HARDWALL_HIERARCHY:
+		ops.hierarchy_model = RES_CONT_HARDWALL_HIERARCHY;
+		ops.shrink_usage = mem_cgroup_shrink_usage_to;
+		ret = res_counter_set_ops(&mem->res, &ops);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
@@ -951,6 +993,9 @@ static const struct mem_cgroup_stat_desc
 	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
 };
 
+
+
+
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
@@ -1024,6 +1069,16 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "used_by_children",
+		.private = RES_USED_BY_CHILDREN,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "hierarchy_model",
+		.write_u64 = mem_cgroup_hierarchy_write,
+		.read_u64 = mem_cgroup_hierarchy_read,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1093,18 +1148,23 @@ struct res_counter_ops root_ops = {
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		parent = NULL;
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		parent = mem_cgroup_from_cont(cont->parent);
 	}
 
-	res_counter_init_ops(&mem->res, &root_ops);
+	if (!parent)
+		res_counter_init_ops(&mem->res, &root_ops);
+	else
+		res_counter_init_hierarchy(&mem->res, &parent->res);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
@@ -1124,6 +1184,7 @@ static void mem_cgroup_pre_destroy(struc
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 	mem_cgroup_force_empty(mem);
+	res_counter_reset_limit(&mem->res);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
Index: linux-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
===================================================================
--- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/memory.txt
+++ linux-2.6.26-rc5-mm3/Documentation/controllers/memory.txt
@@ -154,7 +154,7 @@ The memory controller uses the following
 
 0. Configuration
 
-a. Enable CONFIG_CGROUPS
+a. Enable CONFESS_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
 c. Enable CONFIG_CGROUP_MEM_RES_CTLR
 
@@ -237,7 +237,58 @@ cgroup might have some charge associated
 tasks have migrated away from it. Such charges are automatically dropped at
 rmdir() if there are no tasks.
 
-5. TODO
+5. Supported Hierarchy Model
+
+Currently, memory controller supports following models of hierarchy in the
+kernel. (see also resource_counter.txt)
+
+2 files are related to hierarchy.
+ - memory.hierarchy_model
+ - memory.for_children
+
+Basic Rule.
+  - Hierarchy can be set per cgroup.
+  - A child inherits parent's hierarchy model at creation.
+  - A child can change its hierarchy only when the parent's hierarchy is
+    NO_HIERARCY and it has no children.
+
+
+5.1. NO_HIERARCHY
+  - Each cgroup is independent from other ones.
+  - When memory.hierarchy_model is 0, NO_HIERARCHY is used.
+    Under this model, there is no controls based on tree of cgroups.
+    This is the default model of root cgroup.
+
+5.2 HARDWALL_HIERARCHY
+  - A child is a isolated portion of the parent.
+  - When memory.hierarchy_model is 1, HARDWALL_HIERARCHY is used.
+    In this model a child's limit is charged as parent's usage.
+
+  Hard-Wall Hierarchy Example)
+  1) Assume a cgroup with 1GB limits. (and no tasks belongs to this, now)
+     - group_A limit=1G,usage=0M.
+
+  2) create group B, C under A.
+     - group A limit=1G, usage=0M, for_childre=0M
+          - group B limit=0M, usage=0M.
+          - group C limit=0M, usage=0M.
+
+  3) increase group B's limit to 300M.
+     - group A limit=1G, usage=300M, for_children=300M
+          - group B limit=300M, usage=0M.
+          - group C limit=0M, usage=0M.
+
+  4) increase group C's limit to 500M
+     - group A limit=1G, usage=800M, for_children=800M
+          - group B limit=300M, usage=0M.
+          - group C limit=500M, usage=0M.
+
+  5) reduce group B's limit to 100M
+     - group A limit=1G, usage=600M, for_children=600M.
+          - group B limit=100M, usage=0M.
+          - group C limit=500M, usage=0M.
+
+6. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
@@ -274,3 +325,5 @@ References
     http://lkml.org/lkml/2007/8/17/69
 12. Corbet, Jonathan, Controlling memory use in cgroups,
     http://lwn.net/Articles/243795/
+
+ LocalWords:  lru CONFIG CTLR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
