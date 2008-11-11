Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mABCVJVr014264
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:31:19 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mABCZANd141778
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:35:10 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mABCYu2U004668
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 07:34:56 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 18:04:48 +0530
Message-Id: <20081111123448.6566.55973.sendpatchset@balbir-laptop>
In-Reply-To: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
Subject: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Don't enable multiple hierarchy support by default. This patch introduces
a features element that can be set to enable the nested depth hierarchy
feature. This feature can only be enabled when the cgroup for which the
feature this is enabled, has no children.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 51 insertions(+), 1 deletion(-)

diff -puN mm/memcontrol.c~memcg-add-hierarchy-selector mm/memcontrol.c
--- linux-2.6.28-rc2/mm/memcontrol.c~memcg-add-hierarchy-selector	2008-11-11 17:51:57.000000000 +0530
+++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-11 17:51:57.000000000 +0530
@@ -137,6 +137,11 @@ struct mem_cgroup {
 	 * reclaimed from. Protected by cgroup_lock()
 	 */
 	struct mem_cgroup *last_scanned_child;
+	/*
+	 * Should the accounting and control be hierarchical, per subtree?
+	 */
+	unsigned long use_hierarchy;
+
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -1093,6 +1098,42 @@ out:
 	return ret;
 }
 
+static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cont)->use_hierarchy;
+}
+
+static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
+					u64 val)
+{
+	int retval = 0;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct cgroup *parent = cont->parent;
+	struct mem_cgroup *parent_mem = NULL;
+
+	if (parent)
+		parent_mem = mem_cgroup_from_cont(parent);
+
+	/*
+	 * If parent's use_hiearchy is set, we can't make any modifications
+	 * in the child subtrees. If it is unset, then the change can
+	 * occur, provided the current cgroup has no children.
+	 *
+	 * For the root cgroup, parent_mem is NULL, we allow value to be
+	 * set if there are no children.
+	 */
+	if (!parent_mem || (!parent_mem->use_hierarchy &&
+				(val == 1 || val == 0))) {
+		if (list_empty(&cont->children))
+			mem->use_hierarchy = val;
+		else
+			retval = -EBUSY;
+	} else
+		retval = -EINVAL;
+
+	return retval;
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
@@ -1227,6 +1268,11 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "use_hierarchy",
+		.write_u64 = mem_cgroup_hierarchy_write,
+		.read_u64 = mem_cgroup_hierarchy_read,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1303,9 +1349,13 @@ mem_cgroup_create(struct cgroup_subsys *
 		parent = mem_cgroup_from_cont(cont->parent);
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		mem->use_hierarchy = parent->use_hierarchy;
 	}
 
-	res_counter_init(&mem->res, parent ? &parent->res : NULL);
+	if (parent && parent->use_hierarchy)
+		res_counter_init(&mem->res, &parent->res);
+	else
+		res_counter_init(&mem->res, NULL);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
