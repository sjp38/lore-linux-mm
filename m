Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8C66B00D7
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 17:13:19 -0500 (EST)
Date: Mon, 5 Jan 2009 14:13:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-Id: <20090105141313.a4abd475.akpm@linux-foundation.org>
In-Reply-To: <20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com>
References: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081231110816.5f80e265@psychotron.englab.brq.redhat.com>
	<20081231213705.1293.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090103175913.GA21180@redhat.com>
	<2f11576a0901031313u791d7dcex94b927cc56026e40@mail.gmail.com>
	<20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jiri Pirko <jpirko@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, linux-kernel@vger.kernel.org, hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Jan 2009 16:32:04 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> Changelog
> v2 -> v3
>   - in k_getrusage() use (inherited) sig->maxrss value in case of
>     RUSAGE_THREAD

The patch which you sent was mysteriously truncated - the kernel/sys.c hunk
is partly missing.  So I took that bit from the earlier version of the patch.

Please check that the below is still identical to your version 3.


diff -puN fs/exec.c~getrusage-fill-ru_maxrss-value fs/exec.c
--- a/fs/exec.c~getrusage-fill-ru_maxrss-value
+++ a/fs/exec.c
@@ -864,6 +864,13 @@ static int de_thread(struct task_struct 
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
 
diff -puN include/linux/sched.h~getrusage-fill-ru_maxrss-value include/linux/sched.h
--- a/include/linux/sched.h~getrusage-fill-ru_maxrss-value
+++ a/include/linux/sched.h
@@ -560,6 +560,7 @@ struct signal_struct {
 	unsigned long nvcsw, nivcsw, cnvcsw, cnivcsw;
 	unsigned long min_flt, maj_flt, cmin_flt, cmaj_flt;
 	unsigned long inblock, oublock, cinblock, coublock;
+	unsigned long maxrss, cmaxrss;
 	struct task_io_accounting ioac;
 
 	/*
diff -puN kernel/exit.c~getrusage-fill-ru_maxrss-value kernel/exit.c
--- a/kernel/exit.c~getrusage-fill-ru_maxrss-value
+++ a/kernel/exit.c
@@ -1053,6 +1053,12 @@ NORET_TYPE void do_exit(long code)
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
@@ -1296,6 +1302,7 @@ static int wait_task_zombie(struct task_
 		struct signal_struct *psig;
 		struct signal_struct *sig;
 		struct task_cputime cputime;
+		unsigned long maxrss;
 
 		/*
 		 * The resource counters for the group leader are in its
@@ -1347,6 +1354,9 @@ static int wait_task_zombie(struct task_
 		psig->coublock +=
 			task_io_get_oublock(p) +
 			sig->oublock + sig->coublock;
+		maxrss = max(sig->maxrss, sig->cmaxrss);
+		if (psig->cmaxrss < maxrss)
+			psig->cmaxrss = maxrss;
 		task_io_accounting_add(&psig->ioac, &p->ioac);
 		task_io_accounting_add(&psig->ioac, &sig->ioac);
 		spin_unlock_irq(&p->parent->sighand->siglock);
diff -puN kernel/fork.c~getrusage-fill-ru_maxrss-value kernel/fork.c
--- a/kernel/fork.c~getrusage-fill-ru_maxrss-value
+++ a/kernel/fork.c
@@ -851,6 +851,7 @@ static int copy_signal(unsigned long clo
 	sig->nvcsw = sig->nivcsw = sig->cnvcsw = sig->cnivcsw = 0;
 	sig->min_flt = sig->maj_flt = sig->cmin_flt = sig->cmaj_flt = 0;
 	sig->inblock = sig->oublock = sig->cinblock = sig->coublock = 0;
+	sig->maxrss = sig->cmaxrss = 0;
 	task_io_accounting_init(&sig->ioac);
 	taskstats_tgid_init(sig);
 
diff -puN kernel/sys.c~getrusage-fill-ru_maxrss-value kernel/sys.c
--- a/kernel/sys.c~getrusage-fill-ru_maxrss-value
+++ a/kernel/sys.c
@@ -1676,6 +1676,18 @@ static void k_getrusage(struct task_stru
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
+	r->ru_maxrss <<= PAGE_SHIFT - 10;
 }
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
