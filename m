Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 05D466B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 12:30:19 -0400 (EDT)
Message-ID: <51CDBA15.9000207@oracle.com>
Date: Fri, 28 Jun 2013 11:30:13 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] mm: sched: numa: fix NUMA balancing when !SCHED_DEBUG
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Commit 3105b86a defined numabalancing_enabled to control the enabling
and disabling of automatic NUMA balancing, but it is never used.

I believe the intention was to use this in place of
sched_feat_numa(NUMA).

Currently, if SCHED_DEBUG is not defined, sched_feat_numa(NUMA) will
never be changed from the initial "false".

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
---
 kernel/sched/fair.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c61a614..fc11c2f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -813,7 +813,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
 
-	if (!sched_feat_numa(NUMA))
+	if (!numabalancing_enabled)
 		return;
 
 	/* FIXME: Allocate task-specific structure for placement policy here */
@@ -5751,7 +5751,7 @@ static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
 		entity_tick(cfs_rq, se, queued);
 	}
 
-	if (sched_feat_numa(NUMA))
+	if (numabalancing_enabled)
 		task_tick_numa(rq, curr);
 
 	update_rq_runnable_avg(rq, 1);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
