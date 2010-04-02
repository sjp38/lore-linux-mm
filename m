Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FF966B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:34:44 -0400 (EDT)
Date: Fri, 2 Apr 2010 20:32:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH -mm 3/4] oom: introduce find_lock_task_mm() to fix !mm
	false positives
Message-ID: <20100402183242.GD31723@redhat.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402183057.GA31723@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

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
---

 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |   39 +++++++++++++++++++++------------------
 2 files changed, 22 insertions(+), 19 deletions(-)

--- MM/include/linux/oom.h~3_FIX_MM_CHECKS	2010-03-31 17:47:14.000000000 +0200
+++ MM/include/linux/oom.h	2010-04-02 19:14:05.000000000 +0200
@@ -40,7 +40,7 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
-extern unsigned int oom_badness(struct task_struct *p,
+extern int oom_badness(struct task_struct *p,
 			unsigned long totalpages, unsigned long uptime);
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
--- MM/mm/oom_kill.c~3_FIX_MM_CHECKS	2010-04-02 18:58:37.000000000 +0200
+++ MM/mm/oom_kill.c	2010-04-02 19:55:46.000000000 +0200
@@ -69,6 +69,19 @@ static bool has_intersects_mems_allowed(
 	return false;
 }
 
+static struct task_struct *find_lock_task_mm(struct task_struct *p)
+{
+	struct task_struct *t = p;
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
@@ -139,10 +152,9 @@ static unsigned long oom_forkbomb_penalt
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom conditions.
  */
-unsigned int oom_badness(struct task_struct *p, unsigned long totalpages,
+int oom_badness(struct task_struct *p, unsigned long totalpages,
 							unsigned long uptime)
 {
-	struct mm_struct *mm;
 	int points;
 
 	/*
@@ -159,19 +171,15 @@ unsigned int oom_badness(struct task_str
 	if (p->flags & PF_OOM_ORIGIN)
 		return 1000;
 
-	task_lock(p);
-	mm = p->mm;
-	if (!mm) {
-		task_unlock(p);
-		return 0;
-	}
-
+	p = find_lock_task_mm(p);
+	if (!p)
+		return -1;
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
 	 */
-	points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
-			totalpages;
+	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) *
+			1000 / totalpages;
 	task_unlock(p);
 	points += oom_forkbomb_penalty(p);
 
@@ -288,7 +296,7 @@ static struct task_struct *select_bad_pr
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	for_each_process(p) {
-		unsigned int points;
+		int points;
 
 		/* skip the init task and kthreads */
 		if (is_global_init(p) || (p->flags & PF_KTHREAD))
@@ -330,16 +338,11 @@ static struct task_struct *select_bad_pr
 			*ppoints = 1000;
 		}
 
-		/*
-		 * skip the tasks which have already released their mm.
-		 */
-		if (!p->mm)
-			continue;
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 
 		points = oom_badness(p, totalpages, uptime.tv_sec);
-		if (points > *ppoints || !chosen) {
+		if (points >= 0 && (points > *ppoints || !chosen)) {
 			chosen = p;
 			*ppoints = points;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
