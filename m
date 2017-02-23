Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2D116B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d18so41081171pgh.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 05:36:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h11si4355834pln.300.2017.02.23.05.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 05:36:49 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1NDSpXn105352
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:49 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28shbjtf8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:49 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 13:36:46 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] mm/cgroup: delay soft limit data allocation
Date: Thu, 23 Feb 2017 14:36:39 +0100
In-Reply-To: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1487856999-16581-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Until a soft limit is set to a cgroup, the soft limit data are useless
so delay this allocation when a limit is set.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memcontrol.c | 67 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 52 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a9f10fde44a6..c639c898809d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -142,7 +142,7 @@ struct mem_cgroup_tree {
 	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
 };
 
-static struct mem_cgroup_tree soft_limit_tree __read_mostly;
+static struct mem_cgroup_tree *soft_limit_tree __read_mostly;
 
 /* for OOM */
 struct mem_cgroup_eventfd_list {
@@ -381,10 +381,52 @@ mem_cgroup_page_nodeinfo(struct mem_cgroup *memcg, struct page *page)
 	return memcg->nodeinfo[nid];
 }
 
+static bool soft_limit_initialize(void)
+{
+	static DEFINE_MUTEX(soft_limit_mutex);
+	struct mem_cgroup_tree *tree;
+	bool ret = true;
+	int node;
+
+	mutex_lock(&soft_limit_mutex);
+	if (soft_limit_tree)
+		goto bail;
+
+	tree = kmalloc(sizeof(*soft_limit_tree), GFP_KERNEL);
+	if (!tree) {
+		ret = false;
+		goto bail;
+	}
+	for_each_node(node) {
+		struct mem_cgroup_tree_per_node *rtpn;
+
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
+				    node_online(node) ? node : NUMA_NO_NODE);
+		if (!rtpn)
+			goto cleanup;
+
+		rtpn->rb_root = RB_ROOT;
+		spin_lock_init(&rtpn->lock);
+		tree->rb_tree_per_node[node] = rtpn;
+	}
+	WRITE_ONCE(soft_limit_tree, tree);
+bail:
+	mutex_unlock(&soft_limit_mutex);
+	return ret;
+cleanup:
+	for_each_node(node)
+		kfree(tree->rb_tree_per_node[node]);
+	kfree(tree);
+	ret = false;
+	goto bail;
+}
+
 static struct mem_cgroup_tree_per_node *
 soft_limit_tree_node(int nid)
 {
-	return soft_limit_tree.rb_tree_per_node[nid];
+	if (!soft_limit_tree)
+		return NULL;
+	return soft_limit_tree->rb_tree_per_node[nid];
 }
 
 static struct mem_cgroup_tree_per_node *
@@ -392,7 +434,9 @@ soft_limit_tree_from_page(struct page *page)
 {
 	int nid = page_to_nid(page);
 
-	return soft_limit_tree.rb_tree_per_node[nid];
+	if (!soft_limit_tree)
+		return NULL;
+	return soft_limit_tree->rb_tree_per_node[nid];
 }
 
 static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_node *mz,
@@ -3003,6 +3047,10 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 		}
 		break;
 	case RES_SOFT_LIMIT:
+		if (!soft_limit_initialize()) {
+			ret = -ENOMEM;
+			break;
+		}
 		memcg->soft_limit = nr_pages;
 		ret = 0;
 		break;
@@ -5777,7 +5825,7 @@ __setup("cgroup.memory=", cgroup_memory);
  */
 static int __init mem_cgroup_init(void)
 {
-	int cpu, node;
+	int cpu;
 
 #ifndef CONFIG_SLOB
 	/*
@@ -5797,17 +5845,6 @@ static int __init mem_cgroup_init(void)
 		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
 			  drain_local_stock);
 
-	for_each_node(node) {
-		struct mem_cgroup_tree_per_node *rtpn;
-
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
-				    node_online(node) ? node : NUMA_NO_NODE);
-
-		rtpn->rb_root = RB_ROOT;
-		spin_lock_init(&rtpn->lock);
-		soft_limit_tree.rb_tree_per_node[node] = rtpn;
-	}
-
 	return 0;
 }
 subsys_initcall(mem_cgroup_init);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
