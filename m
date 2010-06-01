Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9D96B01E1
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:19:14 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o517JDif026513
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:13 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by kpbe11.cbf.corp.google.com with ESMTP id o517J8aV023435
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:11 -0700
Received: by pwj10 with SMTP id 10so2382525pwj.7
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:19:11 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:19:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 15/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010017090.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>

Almost all ->mm == NUL checks in oom_kill.c are wrong.

The current code assumes that the task without ->mm has already
released its memory and ignores the process. However this is not
necessarily true when this process is multithreaded, other live
sub-threads can use this ->mm.

- Remove the "if (!p->mm)" check in select_bad_process(), it is
  just wrong.

- Add the new helper, find_lock_task_mm(), which finds the live
  thread which uses the memory and takes task_lock() to pin ->mm

- change oom_badness() to use this helper instead of just checking
  ->mm != NULL.

- As David pointed out, select_bad_process() must never choose the
  task without ->mm, but no matter what oom_badness() returns the
  task can be chosen if nothing else has been found yet.

  Change oom_badness() to return int, change it to return -1 if
  find_lock_task_mm() fails, and change select_bad_process() to
  check points >= 0.

Note! This patch is not enough, we need more changes.

	- oom_badness() was fixed, but oom_kill_task() still ignores
	  the task without ->mm

	- oom_forkbomb_penalty() should use find_lock_task_mm() too,
	  and it also needs other changes to actually find the first
	  first-descendant children

This will be addressed later.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -95,6 +95,20 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 	return false;
 }
 
+static struct task_struct *find_lock_task_mm(struct task_struct *p)
+{
+	struct task_struct *t = p;
+
+	do {
+		task_lock(t);
+		if (likely(t->mm))
+			return t;
+		task_unlock(t);
+	} while_each_thread(p, t);
+
+	return NULL;
+}
+
 /*
  * Tasks that fork a very large number of children with seperate address spaces
  * may be the result of a bug, user error, malicious applications, or even those
@@ -164,7 +178,6 @@ static unsigned long oom_forkbomb_penalty(struct task_struct *tsk)
  */
 unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 {
-	struct mm_struct *mm;
 	int points;
 
 	/*
@@ -181,12 +194,9 @@ unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 	if (p->flags & PF_OOM_ORIGIN)
 		return 1000;
 
-	task_lock(p);
-	mm = p->mm;
-	if (!mm) {
-		task_unlock(p);
+	p = find_lock_task_mm(p);
+	if (!p)
 		return 0;
-	}
 
 	/*
 	 * The memory controller may have a limit of 0 bytes, so avoid a divide
@@ -199,8 +209,8 @@ unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
 	 */
-	points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
-			totalpages;
+	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) *
+			1000 / totalpages;
 	task_unlock(p);
 	points += oom_forkbomb_penalty(p);
 
@@ -357,17 +367,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			*ppoints = 1000;
 		}
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
-		if (!p->mm)
-			continue;
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			continue;
-
 		points = oom_badness(p, totalpages);
-		if (points > *ppoints || !chosen) {
+		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
