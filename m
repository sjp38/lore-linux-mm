Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 075AD6B00A6
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:18:17 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id f11so4986342qae.5
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:18:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si12527999qao.90.2013.11.26.14.18.16
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 14:18:16 -0800 (PST)
From: riel@redhat.com
Subject: [RFC PATCH 3/4] build per numa_group active node mask from faults_from statistics
Date: Tue, 26 Nov 2013 17:03:27 -0500
Message-Id: <1385503408-30041-4-git-send-email-riel@redhat.com>
In-Reply-To: <1385503408-30041-1-git-send-email-riel@redhat.com>
References: <1385503408-30041-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, chegu_vinod@hp.com, peterz@infradead.org

From: Rik van Riel <riel@redhat.com>

The faults_from statistics are used to maintain an active_nodes nodemask
per numa_group. This allows us to be smarter about when to do numa migrations.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 89b5217..91b8f11 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -869,6 +869,7 @@ struct numa_group {
 	struct list_head task_list;
 
 	struct rcu_head rcu;
+	nodemask_t active_nodes;
 	unsigned long total_faults;
 	unsigned long *faults_from;
 	unsigned long faults[0];
@@ -1228,6 +1229,34 @@ static void numa_migrate_preferred(struct task_struct *p)
 	task_numa_migrate(p);
 }
 
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
+	/*
+	 * Mark any node where more than 40% of the faults
+	 * (half minus some hysteresis) as part of this
+	 * group's active nodes.
+	 */
+	for_each_online_node(nid) {
+		faults = numa_group->faults_from[task_faults_idx(nid, 0)] +
+			 numa_group->faults_from[task_faults_idx(nid, 1)];
+		if (faults > max_faults * 4 / 10)
+			node_set(nid, numa_group->active_nodes);
+		else
+			node_clear(nid, numa_group->active_nodes);
+	}
+}
+
 /*
  * When adapting the scan rate, the period is divided into NUMA_PERIOD_SLOTS
  * increments. The more local the fault statistics are, the higher the scan
@@ -1387,6 +1416,8 @@ static void task_numa_placement(struct task_struct *p)
 			}
 		}
 
+		update_numa_active_node_mask(p);
+
 		spin_unlock(group_lock);
 	}
 
@@ -1433,6 +1464,8 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		/* Second half of the array tracks where faults come from */
 		grp->faults_from = grp->faults + 2 * nr_node_ids;
 
+		node_set(task_node(current), grp->active_nodes);
+
 		for (i = 0; i < 4*nr_node_ids; i++)
 			grp->faults[i] = p->numa_faults[i];
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
