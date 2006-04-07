Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel7.hp.com (Postfix) with ESMTP id 156EC343A3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:39:59 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id E4218AD24
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:39:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id A5F81138E3A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:39:58 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22880-09 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:39:56 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 23914138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:39:56 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 6/9] AutoPage Migration - V0.2 - hook
	sched migrate to memory migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:41:20 -0400
Message-Id: <1144442480.5198.64.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 6/9 hook sched migrate to memory migration

Add check for internode migration to scheduler -- in most places
where a new cpu is assigned via set_task_cpu().  If MIGRATION is
configured, and auto-migration is enabled [and this is a
user space task], the check will set "migration pending" for the
task if the destination cpu is on a different node from the last
cpu to which the task was assigned.  Migration of affected pages
[those with default policy] will occur when the task returns to
user space.

V0.2:
	only check/notify task of internode migration in migrate_task()
	if not in exec() path.  Walking task address space and unmapping
	pages is probably a waste of time in this case.  Note, however,
	that we won't give the task a chance to pull any resident text
	or library pages local to itself.  If we ever support replication
	or more agressive migration, we can fix this.

	Thanks to Kamezawa Hiroyoki for pointing out this potential
	optimization.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm1/kernel/sched.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/kernel/sched.c	2006-04-05 10:14:36.000000000 -0400
+++ linux-2.6.17-rc1-mm1/kernel/sched.c	2006-04-05 10:16:13.000000000 -0400
@@ -52,8 +52,9 @@
 #include <linux/acct.h>
 #include <linux/kprobes.h>
 #include <linux/kgdb.h>
-#include <asm/tlb.h>
+#include <linux/auto-migrate.h>
 
+#include <asm/tlb.h>
 #include <asm/unistd.h>
 
 /*
@@ -1028,7 +1029,8 @@ typedef struct {
  * The task's runqueue lock must be held.
  * Returns true if you have to wait for migration thread.
  */
-static int migrate_task(task_t *p, int dest_cpu, migration_req_t *req)
+static int migrate_task(task_t *p, int dest_cpu, migration_req_t *req,
+			int execing)
 {
 	runqueue_t *rq = task_rq(p);
 
@@ -1037,6 +1039,8 @@ static int migrate_task(task_t *p, int d
 	 * it is sufficient to simply update the task's cpu field.
 	 */
 	if (!p->array && !task_running(rq, p)) {
+		if (!execing)
+			check_internode_migration(p, dest_cpu);
 		set_task_cpu(p, dest_cpu);
 		return 0;
 	}
@@ -1432,6 +1436,7 @@ static int try_to_wake_up(task_t *p, uns
 out_set_cpu:
 	new_cpu = wake_idle(new_cpu, p);
 	if (new_cpu != cpu) {
+		check_internode_migration(p, new_cpu);
 		set_task_cpu(p, new_cpu);
 		task_rq_unlock(rq, &flags);
 		/* might preempt at this point */
@@ -1944,7 +1949,7 @@ static void sched_migrate_task(task_t *p
 		goto out;
 
 	/* force the process onto the specified CPU */
-	if (migrate_task(p, dest_cpu, &req)) {
+	if (migrate_task(p, dest_cpu, &req, 1)) {
 		/* Need to wait for migration thread (might exit: take ref). */
 		struct task_struct *mt = rq->migration_thread;
 		get_task_struct(mt);
@@ -1981,6 +1986,7 @@ void pull_task(runqueue_t *src_rq, prio_
 {
 	dequeue_task(p, src_array);
 	dec_nr_running(p, src_rq);
+	check_internode_migration(p, this_cpu);
 	set_task_cpu(p, this_cpu);
 	inc_nr_running(p, this_rq);
 	enqueue_task(p, this_array);
@@ -4721,7 +4727,7 @@ int set_cpus_allowed(task_t *p, cpumask_
 	if (cpu_isset(task_cpu(p), new_mask))
 		goto out;
 
-	if (migrate_task(p, any_online_cpu(new_mask), &req)) {
+	if (migrate_task(p, any_online_cpu(new_mask), &req, 0)) {
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
@@ -4763,6 +4769,7 @@ static void __migrate_task(struct task_s
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
