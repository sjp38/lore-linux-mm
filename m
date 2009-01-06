Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 100476B00DF
	for <linux-mm@kvack.org>; Tue,  6 Jan 2009 04:48:58 -0500 (EST)
Date: Tue, 6 Jan 2009 10:48:39 +0100
From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-ID: <20090106104839.78eb07d1@psychotron.englab.brq.redhat.com>
In-Reply-To: <20090105141313.a4abd475.akpm@linux-foundation.org>
References: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081231110816.5f80e265@psychotron.englab.brq.redhat.com>
	<20081231213705.1293.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090103175913.GA21180@redhat.com>
	<2f11576a0901031313u791d7dcex94b927cc56026e40@mail.gmail.com>
	<20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com>
	<20090105141313.a4abd475.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, linux-kernel@vger.kernel.org, hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Jan 2009 14:13:13 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 5 Jan 2009 16:32:04 +0100
> Jiri Pirko <jpirko@redhat.com> wrote:
> 
> > Changelog
> > v2 -> v3
> >   - in k_getrusage() use (inherited) sig->maxrss value in case of
> >     RUSAGE_THREAD
> 
> The patch which you sent was mysteriously truncated - the kernel/sys.c hunk
> is partly missing.  So I took that bit from the earlier version of the patch.
Sorry for this. I should probably toss this Claws into the garbage can :/
> 
> Please check that the below is still identical to your version 3.
Nope - the tail is different. - Sending the patch again. Please use
the changelog text from previous send.
Thanks Andrew and again sorry for problems.


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/exec.c             |    7 +++++++
 include/linux/sched.h |    1 +
 kernel/exit.c         |   10 ++++++++++
 kernel/fork.c         |    1 +
 kernel/sys.c          |   17 +++++++++++++++++
 5 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 3ef9cf9..b939ef5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -867,6 +867,13 @@ static int de_thread(struct task_struct *tsk)
 	sig->notify_count = 0;
 
 no_thread_group:
+	if (current->mm) {
+		unsigned long hiwater_rss = get_mm_hiwater_rss(current->mm);
+
+		if (sig->maxrss < hiwater_rss)
+			sig->maxrss = hiwater_rss;
+	}
+
 	exit_itimers(sig);
 	flush_itimer_signals();
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ea41513..62a0f45 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -560,6 +560,7 @@ struct signal_struct {
 	unsigned long nvcsw, nivcsw, cnvcsw, cnivcsw;
 	unsigned long min_flt, maj_flt, cmin_flt, cmaj_flt;
 	unsigned long inblock, oublock, cinblock, coublock;
+	unsigned long maxrss, cmaxrss;
 	struct task_io_accounting ioac;
 
 	/*
diff --git a/kernel/exit.c b/kernel/exit.c
index 1a8c22f..5c0d601 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1060,6 +1060,12 @@ NORET_TYPE void do_exit(long code)
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
 		exit_itimers(tsk->signal);
+		if (tsk->mm) {
+			unsigned long hiwater_rss = get_mm_hiwater_rss(tsk->mm);
+
+			if (tsk->signal->maxrss < hiwater_rss)
+				tsk->signal->maxrss = hiwater_rss;
+		}
 	}
 	acct_collect(code, group_dead);
 	if (group_dead)
@@ -1303,6 +1309,7 @@ static int wait_task_zombie(struct task_struct *p, int options,
 		struct signal_struct *psig;
 		struct signal_struct *sig;
 		struct task_cputime cputime;
+		unsigned long maxrss;
 
 		/*
 		 * The resource counters for the group leader are in its
@@ -1354,6 +1361,9 @@ static int wait_task_zombie(struct task_struct *p, int options,
 		psig->coublock +=
 			task_io_get_oublock(p) +
 			sig->oublock + sig->coublock;
+		maxrss = max(sig->maxrss, sig->cmaxrss);
+		if (psig->cmaxrss < maxrss)
+			psig->cmaxrss = maxrss;
 		task_io_accounting_add(&psig->ioac, &p->ioac);
 		task_io_accounting_add(&psig->ioac, &sig->ioac);
 		spin_unlock_irq(&p->parent->sighand->siglock);
diff --git a/kernel/fork.c b/kernel/fork.c
index 43cbf30..35bec65 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -846,6 +846,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sig->nvcsw = sig->nivcsw = sig->cnvcsw = sig->cnivcsw = 0;
 	sig->min_flt = sig->maj_flt = sig->cmin_flt = sig->cmaj_flt = 0;
 	sig->inblock = sig->oublock = sig->cinblock = sig->coublock = 0;
+	sig->maxrss = sig->cmaxrss = 0;
 	task_io_accounting_init(&sig->ioac);
 	taskstats_tgid_init(sig);
 
diff --git a/kernel/sys.c b/kernel/sys.c
index d356d79..f5ca281 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1622,12 +1622,14 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 	unsigned long flags;
 	cputime_t utime, stime;
 	struct task_cputime cputime;
+	unsigned long maxrss = 0;
 
 	memset((char *) r, 0, sizeof *r);
 	utime = stime = cputime_zero;
 
 	if (who == RUSAGE_THREAD) {
 		accumulate_thread_rusage(p, r);
+		maxrss = p->signal->maxrss;
 		goto out;
 	}
 
@@ -1645,6 +1647,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt = p->signal->cmaj_flt;
 			r->ru_inblock = p->signal->cinblock;
 			r->ru_oublock = p->signal->coublock;
+			maxrss = p->signal->cmaxrss;
 
 			if (who == RUSAGE_CHILDREN)
 				break;
@@ -1659,6 +1662,8 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt += p->signal->maj_flt;
 			r->ru_inblock += p->signal->inblock;
 			r->ru_oublock += p->signal->oublock;
+			if (maxrss < p->signal->maxrss)
+				maxrss = p->signal->maxrss;
 			t = p;
 			do {
 				accumulate_thread_rusage(t, r);
@@ -1674,6 +1679,18 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 out:
 	cputime_to_timeval(utime, &r->ru_utime);
 	cputime_to_timeval(stime, &r->ru_stime);
+
+	if (who != RUSAGE_CHILDREN) {
+		struct mm_struct *mm = get_task_mm(p);
+		if (mm) {
+			unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
+
+			if (maxrss < hiwater_rss)
+				maxrss = hiwater_rss;
+			mmput(mm);
+		}
+	}
+	r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */
 }
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru)
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
