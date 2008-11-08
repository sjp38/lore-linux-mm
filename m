Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA89AgN5014510
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:10:42 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA89BU2H147096
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:11:30 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA89BUCq011002
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 02:11:30 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sat, 08 Nov 2008 14:41:13 +0530
Message-Id: <20081108091113.32236.12390.sendpatchset@localhost.localdomain>
In-Reply-To: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
Subject: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector (v2)
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

 mm/memcontrol.c |   43 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff -puN mm/memcontrol.c~memcg-add-hierarchy-selector mm/memcontrol.c
--- linux-2.6.28-rc2/mm/memcontrol.c~memcg-add-hierarchy-selector	2008-11-08 14:09:33.000000000 +0530
+++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-08 14:10:53.000000000 +0530
@@ -137,6 +137,11 @@ struct mem_cgroup {
 	 * reclaimed from.
 	 */
 	struct mem_cgroup *last_scanned_child;
+	/*
+	 * Should the accounting and control be hierarchical, per subtree?
+	 */
+	unsigned long use_hierarchy;
+
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -1079,6 +1084,33 @@ out:
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
+
+	if (val == 1) {
+		if (list_empty(&cont->children))
+			mem->use_hierarchy = val;
+		else
+			retval = -EBUSY;
+	} else if (val == 0) {
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
@@ -1213,6 +1245,11 @@ static struct cftype mem_cgroup_files[] 
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
@@ -1289,9 +1326,13 @@ mem_cgroup_create(struct cgroup_subsys *
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
