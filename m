Received: from taynzmail03.nz-tay.cpqcorp.net (relay.wipro.tcpn.com [16.47.4.103])
	by atlrel7.hp.com (Postfix) with ESMTP id 07D1239A04
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:52:34 -0500 (EST)
Received: from anw.zk3.dec.com (alpha.zk3.dec.com [16.140.128.4])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id BCEDC63DD
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:52:34 -0500 (EST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 6/8 hook sched migrate to
	memory migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:52:15 -0500
Message-Id: <1142020335.5204.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 6/8 hook sched migrate to memory migration

Add check for internode migration to scheduler -- in most places
where a new cpu is assigned via set_task_cpu().  If MIGRATION is
configured, and sched_migrate_memory is enabled [and this is a
user space task], the check will set "migration pending" for the
task if the destination cpu is on a different cpu from the last
cpu to which the task was assigned.  Migration of affected pages
[those with default policy] will occur when the task returns to
user space.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git11/kernel/sched.c
===================================================================
--- linux-2.6.16-rc5-git11.orig/kernel/sched.c	2006-03-08 15:44:30.000000000 -0500
+++ linux-2.6.16-rc5-git11/kernel/sched.c	2006-03-08 16:39:42.000000000 -0500
@@ -52,6 +52,7 @@
 #include <asm/tlb.h>
 
 #include <asm/unistd.h>
+#include <linux/auto-migrate.h>
 
 /*
  * Convert user-nice values [ -20 ... 0 ... 19 ]
@@ -880,6 +881,7 @@ static int migrate_task(task_t *p, int d
 	 * it is sufficient to simply update the task's cpu field.
 	 */
 	if (!p->array && !task_running(rq, p)) {
+		check_internode_migration(p, dest_cpu);
 		set_task_cpu(p, dest_cpu);
 		return 0;
 	}
@@ -1260,6 +1262,7 @@ static int try_to_wake_up(task_t *p, uns
 out_set_cpu:
 	new_cpu = wake_idle(new_cpu, p);
 	if (new_cpu != cpu) {
+		check_internode_migration(p, new_cpu);
 		set_task_cpu(p, new_cpu);
 		task_rq_unlock(rq, &flags);
 		/* might preempt at this point */
@@ -1778,6 +1781,7 @@ void pull_task(runqueue_t *src_rq, prio_
 {
 	dequeue_task(p, src_array);
 	src_rq->nr_running--;
+	check_internode_migration(p, this_cpu);
 	set_task_cpu(p, this_cpu);
 	this_rq->nr_running++;
 	enqueue_task(p, this_array);
@@ -4452,6 +4456,7 @@ static void __migrate_task(struct task_s
 	if (!cpu_isset(dest_cpu, p->cpus_allowed))
 		goto out;
 
+	check_internode_migration(p, dest_cpu);
 	set_task_cpu(p, dest_cpu);
 	if (p->array) {
 		/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
