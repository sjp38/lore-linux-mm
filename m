Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F7506B022A
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 10:25:45 -0400 (EDT)
Date: Mon, 5 Apr 2010 16:23:34 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH -mm] oom: select_bad_process: never choose tasks with
	badness == 0
Message-ID: <20100405142334.GA31074@redhat.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402183057.GA31723@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is the David's patch rediffed agains the recent changes in -mm.

As David pointed out, we should fix select_bad_process() which currently
always selects the first process which was not filtered out before
oom_badness(), no matter what oom_badness() returns.

Change the code to ignore the process if oom_badness() returns 0, this
matters Documentation/filesystems/proc.txt and this merely looks better.

This also allows us to do more cleanups:

	- no need to check OOM_SCORE_ADJ_MIN in select_bad_process(),
	  oom_badness() returns 0 in this case.

	- oom_badness() can simply return 0 instead of -1 if the task
	  has no ->mm.

	  Now we can make it "unsigned" again, the signness and the
	  special "points >= 0" in select_bad_process() was added to
	  preserve the current behaviour.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/oom.h |    3 ++-
 mm/oom_kill.c       |   11 ++++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

--- MM/include/linux/oom.h~5_BADNESS_DONT_RET_NEGATIVE	2010-04-05 15:39:21.000000000 +0200
+++ MM/include/linux/oom.h	2010-04-05 15:44:49.000000000 +0200
@@ -40,7 +40,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
-extern int oom_badness(struct task_struct *p, unsigned long totalpages);
+extern unsigned int oom_badness(struct task_struct *p,
+					unsigned long totalpages);
 extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
--- MM/mm/oom_kill.c~5_BADNESS_DONT_RET_NEGATIVE	2010-04-05 15:39:21.000000000 +0200
+++ MM/mm/oom_kill.c	2010-04-05 16:09:58.000000000 +0200
@@ -153,7 +153,7 @@ static unsigned long oom_forkbomb_penalt
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom conditions.
  */
-int oom_badness(struct task_struct *p, unsigned long totalpages)
+unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 {
 	int points;
 
@@ -173,7 +173,7 @@ int oom_badness(struct task_struct *p, u
 
 	p = find_lock_task_mm(p);
 	if (!p)
-		return -1;
+		return 0;
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
@@ -294,7 +294,7 @@ static struct task_struct *select_bad_pr
 	*ppoints = 0;
 
 	for_each_process(p) {
-		int points;
+		unsigned int points;
 
 		/* skip the init task and kthreads */
 		if (is_global_init(p) || (p->flags & PF_KTHREAD))
@@ -336,11 +336,8 @@ static struct task_struct *select_bad_pr
 			*ppoints = 1000;
 		}
 
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			continue;
-
 		points = oom_badness(p, totalpages);
-		if (points >= 0 && (points > *ppoints || !chosen)) {
+		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
