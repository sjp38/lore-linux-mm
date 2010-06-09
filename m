Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2CA6B01D7
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:27 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o593xMWF002413
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:22 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe15.cbf.corp.google.com with ESMTP id o593xKhl023162
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:21 -0700
Received: by pwi9 with SMTP id 9so615743pwi.30
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:20 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 3/6] oom: add has_intersects_mems_allowed UMA variant
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082057580.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

has_intersects_mems_allowed() shall always return true for machines
without CONFIG_NUMA since filtering tasks by either cpuset mems or
mempolicy nodes is unnecessary on such machines.

While we're here, fix the comment to make it conform to kerneldoc style.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -36,10 +36,15 @@ int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 
-/*
- * Do all threads of the target process overlap our allowed nodes?
+#ifdef CONFIG_NUMA
+/**
+ * has_intersects_mems_allowed() - check task eligiblity for kill
  * @tsk: task struct of which task to consider
  * @mask: nodemask passed to page allocator for mempolicy ooms
+ *
+ * Task eligibility is determined by whether or not a candidate task, @tsk,
+ * shares the same mempolicy nodes as current if it is bound by such a policy
+ * and whether or not it has the same set of allowed cpuset nodes.
  */
 static bool has_intersects_mems_allowed(struct task_struct *tsk,
 					const nodemask_t *mask)
@@ -68,6 +73,13 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 	} while (tsk != start);
 	return false;
 }
+#else
+static bool has_intersects_mems_allowed(struct task_struct *tsk,
+					const nodemask_t *mask)
+{
+	return true;
+}
+#endif /* CONFIG_NUMA */
 
 static struct task_struct *find_lock_task_mm(struct task_struct *p)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
