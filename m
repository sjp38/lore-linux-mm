Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC386B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:21:27 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so6256798qcx.16
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:21:27 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id u90si1325394qge.3.2014.01.20.11.21.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 11:21:26 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH 3/6] numa,sched: build per numa_group active node mask from faults_from statistics
Date: Mon, 20 Jan 2014 14:21:04 -0500
Message-Id: <1390245667-24193-4-git-send-email-riel@redhat.com>
In-Reply-To: <1390245667-24193-1-git-send-email-riel@redhat.com>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com, chegu_vinod@hp.com

From: Rik van Riel <riel@redhat.com>

The faults_from statistics are used to maintain an active_nodes nodemask
per numa_group. This allows us to be smarter about when to do numa migrations.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Chegu Vinod <chegu_vinod@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 1945ddc..ea8b2ae 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -885,6 +885,7 @@ struct numa_group {
 	struct list_head task_list;
 
 	struct rcu_head rcu;
+	nodemask_t active_nodes;
 	unsigned long total_faults;
 	unsigned long *faults_from;
 	unsigned long faults[0];
@@ -1275,6 +1276,41 @@ static void numa_migrate_preferred(struct task_struct *p)
 }
 
 /*
+ * Find the nodes on which the workload is actively running. We do this by
+ * tracking the nodes from which NUMA hinting faults are triggered. This can
+ * be different from the set of nodes where the workload's memory is currently
+ * located.
+ *
+ * The bitmask is used to make smarter decisions on when to do NUMA page
+ * migrations, To prevent flip-flopping, and excessive page migrations, nodes
+ * are added when they cause over 6/16 of the maximum number of faults, but
+ * only removed when they drop below 3/16.
+ */
+static void update_numa_active_node_mask(struct task_struct *p)
+{
+	unsigned long faults, max_faults = 0;
+	struct numa_group *numa_group = p->numa_group;
+	int nid;
+
+	for_each_online_node(nid) {
+		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
+			 numa_group->faults_from[task_faults_idx(nid, 1)];
+		if (faults > max_faults)
+			max_faults = faults;
+	}
+
+	for_each_online_node(nid) {
+		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
+			 numa_group->faults_from[task_faults_idx(nid, 1)];
+		if (!node_isset(nid, numa_group->active_nodes)) {
+			if (faults > max_faults * 6 / 16)
+				node_set(nid, numa_group->active_nodes);
+		} else if (faults < max_faults * 3 / 16)
+			node_clear(nid, numa_group->active_nodes);
+	}
+}
+
+/*
  * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
  * increments. The more local the fault statistics are, the higher the scan
  * period will be for the next scan window. If local/remote ratio is below
@@ -1416,6 +1452,7 @@ static void task_numa_placement(struct task_struct *p)
 	update_task_scan_period(p, fault_types[0], fault_types[1]);
 
 	if (p->numa_group) {
+		update_numa_active_node_mask(p);
 		/*
 		 * If the preferred task and group nids are different,
 		 * iterate over the nodes again to find the best place.
@@ -1478,6 +1515,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		/* Second half of the array tracks where faults come from */
 		grp->faults_from = grp->faults + 2 * nr_node_ids;
 
+		node_set(task_node(current), grp->active_nodes);
+
 		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults[i];
 
@@ -1547,6 +1586,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 	my_grp->nr_tasks--;
 	grp->nr_tasks++;
 
+	update_numa_active_node_mask(p);
+
 	spin_unlock(&my_grp->lock);
 	spin_unlock(&grp->lock);
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
