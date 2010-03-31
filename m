Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E98A86B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:49:21 -0400 (EDT)
Date: Wed, 31 Mar 2010 22:47:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100331204718.GD11635@redhat.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331175836.GA11635@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/31, Oleg Nesterov wrote:
>
> OK, but I guess this !p->mm check is still wrong for the same reason.
> In fact I do not understand why it is needed in select_bad_process()
> right before oom_badness() which checks ->mm too (and this check is
> equally wrong).

Probably something like the patch below makes sense. Note that
"skip kernel threads" logic is wrong too, we should check PF_KTHREAD.
Probably it is better to check it in select_bad_process() instead,
near is_global_init().

The new helper, find_lock_task_mm(), should be used by
oom_forkbomb_penalty() too.

dump_tasks() doesn't need it, it does do_each_thread(). Cough,
__out_of_memory() and out_of_memory() call it without tasklist.
We are going to panic() anyway, but still.

Oleg.

--- x/mm/oom_kill.c
+++ x/mm/oom_kill.c
@@ -129,6 +129,19 @@ static unsigned long oom_forkbomb_penalt
 				(child_rss / sysctl_oom_forkbomb_thres) : 0;
 }
 
+static find_lock_task_mm(struct task_struct *p)
+{
+	struct task_struct *t = p;
+	do {
+		task_lock(t);
+		if (likely(t->mm && !(t->flags & PF_KTHREAD)))
+			return t;
+		task_unlock(t);
+	} while_each_thred(p, t);
+
+	return NULL;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -159,13 +172,9 @@ unsigned int oom_badness(struct task_str
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
-
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
@@ -330,12 +339,6 @@ static struct task_struct *select_bad_pr
 			*ppoints = 1000;
 		}
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
-		if (!p->mm)
-			continue;
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
