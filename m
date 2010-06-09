Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9EB6B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:32 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o593xTE8002690
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:29 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by hpaq2.eem.corp.google.com with ESMTP id o593xIes006983
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:28 -0700
Received: by pzk30 with SMTP id 30so4749714pzk.6
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:27 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 5/6] oom: sacrifice child with highest badness score for
 parent fix
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082058260.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Elaborate on the comment in oom_kill_process() so it's clear why a
killable child with a different mm is sacrificied for its parent.

At the same time, rename auto variable `c' to "child" and move "cpoints"
inside the list_for_each_entry() loop with a more descriptive name as
akpm suggests.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -440,7 +440,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    const char *message)
 {
 	struct task_struct *victim = p;
-	struct task_struct *c;
+	struct task_struct *child;
 	struct task_struct *t = p;
 	unsigned long victim_points = 0;
 	struct timespec uptime;
@@ -462,22 +462,27 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
-	/* Try to sacrifice the worst child first */
+	/*
+	 * If any of p's children has a different mm and is eligible for kill,
+	 * the one with the highest badness() score is sacrificed for its
+	 * parent.  This attempts to lose the minimal amount of work done while
+	 * still freeing memory.
+	 */
 	do_posix_clock_monotonic_gettime(&uptime);
 	do {
-		unsigned long cpoints;
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned long child_points;
 
-		list_for_each_entry(c, &t->children, sibling) {
-			if (c->mm == p->mm)
+			if (child->mm == p->mm)
 				continue;
-			if (mem && !task_in_mem_cgroup(c, mem))
+			if (mem && !task_in_mem_cgroup(child, mem))
 				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
-			cpoints = badness(c, uptime.tv_sec);
-			if (cpoints > victim_points) {
-				victim = c;
-				victim_points = cpoints;
+			child_points = badness(child, uptime.tv_sec);
+			if (child_points > victim_points) {
+				victim = child;
+				victim_points = child_points;
 			}
 		}
 	} while_each_thread(p, t);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
