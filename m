Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 13 of 24] simplify oom heuristics
Message-Id: <cd70d64570b9add8072f.1187786940@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID cd70d64570b9add8072f7abe952b34fe57c60086
# Parent  1473d573b9ba8a913bafa42da2cac5dcca274204
simplify oom heuristics

Over time somebody had the good idea to remove the rcvd_sigterm points,
this removes more of them. The selected task should be the one that if
we don't kill, it will turn the system oom again sooner than later.
These informations tell us nothing about which task is best to kill so
they should be removed.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,7 +53,7 @@ static unsigned long last_tif_memdie_jif
 
 unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
-	unsigned long points, cpu_time, run_time, s;
+	unsigned long points;
 	struct mm_struct *mm;
 	struct task_struct *child;
 
@@ -94,26 +94,6 @@ unsigned long badness(struct task_struct
 			points += child->mm->total_vm/2 + 1;
 		task_unlock(child);
 	}
-
-	/*
-	 * CPU time is in tens of seconds and run time is in thousands
-         * of seconds. There is no particular reason for this other than
-         * that it turned out to work very well in practice.
-	 */
-	cpu_time = (cputime_to_jiffies(p->utime) + cputime_to_jiffies(p->stime))
-		>> (SHIFT_HZ + 3);
-
-	if (uptime >= p->start_time.tv_sec)
-		run_time = (uptime - p->start_time.tv_sec) >> 10;
-	else
-		run_time = 0;
-
-	s = int_sqrt(cpu_time);
-	if (s)
-		points /= s;
-	s = int_sqrt(int_sqrt(run_time));
-	if (s)
-		points /= s;
 
 	/*
 	 * Niced processes are most likely less important, so double

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
