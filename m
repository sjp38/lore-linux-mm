Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBA516B01F0
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:57:59 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p5M0vvN3024375
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:57:57 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by kpbe20.cbf.corp.google.com with ESMTP id p5M0vuvU010066
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:57:56 -0700
Received: by pve37 with SMTP id 37so279606pve.21
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:57:55 -0700 (PDT)
Date: Tue, 21 Jun 2011 17:57:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: remove references to old badness() function
Message-ID: <alpine.DEB.2.00.1106211756580.4454@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

The badness() function in the oom killer was renamed to oom_badness() in
a63d83f427fb ("oom: badness heuristic rewrite") since it is a globally
exported function for clarity.

The prototype for the old function still existed in linux/oom.h, so
remove it.  There are no existing users.

Also fixes documentation and comment references to badness() and adjusts
them accordingly.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/ABI/obsolete/proc-pid-oom_adj |    2 +-
 Documentation/feature-removal-schedule.txt  |    2 +-
 include/linux/oom.h                         |    4 ----
 mm/oom_kill.c                               |    2 +-
 4 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/Documentation/ABI/obsolete/proc-pid-oom_adj b/Documentation/ABI/obsolete/proc-pid-oom_adj
--- a/Documentation/ABI/obsolete/proc-pid-oom_adj
+++ b/Documentation/ABI/obsolete/proc-pid-oom_adj
@@ -14,7 +14,7 @@ Why:	/proc/<pid>/oom_adj allows userspace to influence the oom killer's
 
 	A much more powerful interface, /proc/<pid>/oom_score_adj, was
 	introduced with the oom killer rewrite that allows users to increase or
-	decrease the badness() score linearly.  This interface will replace
+	decrease the badness score linearly.  This interface will replace
 	/proc/<pid>/oom_adj.
 
 	A warning will be emitted to the kernel log if an application uses this
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -184,7 +184,7 @@ Why:	/proc/<pid>/oom_adj allows userspace to influence the oom killer's
 
 	A much more powerful interface, /proc/<pid>/oom_score_adj, was
 	introduced with the oom killer rewrite that allows users to increase or
-	decrease the badness() score linearly.  This interface will replace
+	decrease the badness score linearly.  This interface will replace
 	/proc/<pid>/oom_adj.
 
 	A warning will be emitted to the kernel log if an application uses this
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -64,10 +64,6 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
-/* The badness from the OOM killer */
-extern unsigned long badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long uptime);
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -488,7 +488,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest badness() score is sacrificed for its
+	 * the one with the highest oom_badness() score is sacrificed for its
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
