Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D36526B003D
	for <linux-mm@kvack.org>; Sun,  5 Apr 2009 04:48:42 -0400 (EDT)
Date: Sun, 5 Apr 2009 10:49:04 +0200
From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-ID: <20090405084902.GA4411@psychotron.englab.brq.redhat.com>
References: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081231110816.5f80e265@psychotron.englab.brq.redhat.com> <20081231213705.1293.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090103175913.GA21180@redhat.com> <2f11576a0901031313u791d7dcex94b927cc56026e40@mail.gmail.com> <20090105163204.3ec9ff10@psychotron.englab.brq.redhat.com> <20090105141313.a4abd475.akpm@linux-foundation.org> <20090106104839.78eb07d1@psychotron.englab.brq.redhat.com> <20090402134738.43d87cb7.akpm@linux-foundation.org> <20090402211336.GB4076@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090402211336.GB4076@elte.hu>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, hugh@veritas.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

(resend, repetitive patterns put into an inline function - not using max macro
 because it's was decided not to use it in previous conversation)

From: Jiri Pirko <jpirko@redhat.com>

Make ->ru_maxrss value in struct rusage filled accordingly to rss hiwater
mark.  This struct is filled as a parameter to getrusage syscall. 
->ru_maxrss value is set to KBs which is the way it is done in BSD
systems.  /usr/bin/time (gnu time) application converts ->ru_maxrss to KBs
which seems to be incorrect behavior.  Maintainer of this util was
notified by me with the patch which corrects it and cc'ed.

To make this happen we extend struct signal_struct by two fields.  The
first one is ->maxrss which we use to store rss hiwater of the task.  The
second one is ->cmaxrss which we use to store highest rss hiwater of all
task childs.  These values are used in k_getrusage() to actually fill
->ru_maxrss.  k_getrusage() uses current rss hiwater value directly if mm
struct exists.

Note:
exec() clear mm->hiwater_rss, but doesn't clear sig->maxrss.
it is intetionally behavior. *BSD getrusage have exec() inheriting.

Test progmam and test case
===========================

getrusage.c
====
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <signal.h>

static void consume(int mega)
{
	size_t sz = mega * 1024 * 1024;
	void *ptr;

	ptr = malloc(sz);
	memset(ptr, 0, sz);
	usleep(1);  /* BSD rusage statics need to sleep 1 tick */
}

static void show_rusage(char *prefix)
{
	int err, err2;
	struct rusage rusage_self;
	struct rusage rusage_children;

	printf("%s: ", prefix);
	err = getrusage(RUSAGE_SELF, &rusage_self);
	if (!err)
		printf("self %ld ", rusage_self.ru_maxrss);
	err2 = getrusage(RUSAGE_CHILDREN, &rusage_children);
	if (!err2)
		printf("children %ld ", rusage_children.ru_maxrss);

	printf("\n");
}

int main(int argc, char** argv)
{
	int status;
	int c;
	int need_sleep_before_wait = 0;
	int consume_large_memory_at_first = 0;
	int create_child_at_first = 0;
	int sigign = 0;
	int create_child_before_exec = 0;
	int after_fork_test = 0;

	while ((c = getopt(argc, argv, "ceflsz")) != -1) {
		switch (c) {
		case 'c':
			create_child_at_first = 1;
			break;
		case 'e':
			create_child_before_exec = 1;
			break;
		case 'f':
			after_fork_test = 1;
			break;
		case 'l':
			consume_large_memory_at_first = 1;
			break;
		case 's':
			sigign = 1;
			break;
		case 'z':
			need_sleep_before_wait = 1;
			break;
		default:
			break;
		}
	}

	if (consume_large_memory_at_first)
		consume(100);

	if (create_child_at_first)
		system("./child -q");

	if (sigign)
		signal(SIGCHLD, SIG_IGN);

	if (fork()) {
		usleep(1);
		if (need_sleep_before_wait)
			sleep(3); /* children become zombie */
		show_rusage("pre_wait");
		wait(&status);
		show_rusage("post_wait");
	} else {
		usleep(1);
		show_rusage("fork");

		if (after_fork_test) {
			consume(30);
			show_rusage("fork2");
		}
		if (create_child_before_exec) {
			system("./child -lq");
			usleep(1);
			show_rusage("fork3");
		}

		execl("./child", "child", 0);
		exit(0);
	}

	return 0;
}

child.c
====
#include <sys/types.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>

static void consume(int mega)
{
	size_t sz = mega * 1024 * 1024;
	void *ptr;

	ptr = malloc(sz);
	memset(ptr, 0, sz);
	usleep(1);  /* BSD rusage statics need to sleep 1 tick */
}

static void show_rusage(char *prefix)
{
	int err, err2;
	struct rusage rusage_self;
	struct rusage rusage_children;

	printf("%s: ", prefix);
	err = getrusage(RUSAGE_SELF, &rusage_self);
	if (!err)
		printf("self %ld ", rusage_self.ru_maxrss);
	err2 = getrusage(RUSAGE_CHILDREN, &rusage_children);
	if (!err2)
		printf("children %ld ", rusage_children.ru_maxrss);

	printf("\n");

}

int main(int argc, char** argv)
{
	int status;
	int c;
	int silent = 0;
	int light_weight = 0;

	while ((c = getopt(argc, argv, "lq")) != -1) {
		switch (c) {
		case 'l':
			light_weight = 1;
			break;
		case 'q':
			silent = 1;
			break;
		default:
			break;
		}
	}

	if (!silent)
		show_rusage("exec");

	if (fork()) {
		if (light_weight)
			consume(400);
		else
			consume(700);
		wait(&status);
	} else {
		if (light_weight)
			consume(600);
		else
			consume(900);

		exit(0);
	}

	return 0;
}

testcase
========

1. inherit fork?

   test way:
   	% ./getrusage -lc

   bsd result:
   	fork line is "fork: self 0 children 0".

   	-> rusage sholdn't be inherit by fork.
	   (both RUSAGE_SELF and RUSAGE_CHILDREN)

2. inherit exec?

   test way:
   	% ./getrusage -lce

   bsd result:
   	fork3: self 103204 children 60000
	exec: self 103204 children 60000

   	fork3 and exec line are the same.

   	-> rusage shold be inherit by exec.
	   (both RUSAGE_SELF and RUSAGE_CHILDREN)

3. getrusage(RUSAGE_CHILDREN) collect grandchild statics?

   test way:
   	% ./getrusage

   bsd result:
   	post_wait line is about "post_wait: self 0 children 90000".

	-> RUSAGE_CHILDREN can collect grandchild.

4. zombie, but not waited children collect or not?

   test way:
   	% ./getrusage -z

   bsd result:
   	pre_wait line is "pre_wait: self 0 children 0".

	-> zombie child process (not waited-for child process)
	   isn't accounted.

5. SIG_IGN collect or not

   test way:
   	% ./getrusage -s

   bsd result:
   	post_wait line is "post_wait: self 0 children 0".

	-> if SIGCHLD is ignored, children isn't accounted.

6. fork and malloc
   test way:
   	% ./getrusage -lcf

   bsd result:
   	fork line is "fork: self 0 children 0".
   	fork2 line is about "fork: self 130000 children 0".

   	-> rusage sholdn't be inherit by fork.
	   (both RUSAGE_SELF and RUSAGE_CHILDREN)
	   but additional memory cunsumption cause right
	   maxrss calculation.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
CC: Ingo Molnar <mingo@elte.hu>
---

 fs/exec.c             |    3 +++
 include/linux/sched.h |   10 ++++++++++
 kernel/exit.c         |    6 ++++++
 kernel/fork.c         |    1 +
 kernel/sys.c          |   14 ++++++++++++++
 5 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 052a961..ddf6d1b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -872,6 +872,9 @@ static int de_thread(struct task_struct *tsk)
 	sig->notify_count = 0;
 
 no_thread_group:
+	if (current->mm)
+		setmax_mm_hiwater_rss(&sig->maxrss, current->mm);
+
 	exit_itimers(sig);
 	flush_itimer_signals();
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9da5aa0..f138651 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -397,6 +397,15 @@ static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
 	return max(mm->hiwater_rss, get_mm_rss(mm));
 }
 
+static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
+					 struct mm_struct *mm)
+{
+	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
+
+	if (*maxrss < hiwater_rss)
+		*maxrss = hiwater_rss;
+}
+
 static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
 {
 	return max(mm->hiwater_vm, mm->total_vm);
@@ -567,6 +576,7 @@ struct signal_struct {
 	unsigned long nvcsw, nivcsw, cnvcsw, cnivcsw;
 	unsigned long min_flt, maj_flt, cmin_flt, cmaj_flt;
 	unsigned long inblock, oublock, cinblock, coublock;
+	unsigned long maxrss, cmaxrss;
 	struct task_io_accounting ioac;
 
 	/*
diff --git a/kernel/exit.c b/kernel/exit.c
index 6686ed1..39600f6 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -943,6 +943,8 @@ NORET_TYPE void do_exit(long code)
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
 		exit_itimers(tsk->signal);
+		if (tsk->mm)
+			setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm);
 	}
 	acct_collect(code, group_dead);
 	if (group_dead)
@@ -1188,6 +1190,7 @@ static int wait_task_zombie(struct task_struct *p, int options,
 		struct signal_struct *psig;
 		struct signal_struct *sig;
 		struct task_cputime cputime;
+		unsigned long maxrss;
 
 		/*
 		 * The resource counters for the group leader are in its
@@ -1239,6 +1242,9 @@ static int wait_task_zombie(struct task_struct *p, int options,
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
index 660c2b8..70b3a55 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -848,6 +848,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sig->nvcsw = sig->nivcsw = sig->cnvcsw = sig->cnivcsw = 0;
 	sig->min_flt = sig->maj_flt = sig->cmin_flt = sig->cmaj_flt = 0;
 	sig->inblock = sig->oublock = sig->cinblock = sig->coublock = 0;
+	sig->maxrss = sig->cmaxrss = 0;
 	task_io_accounting_init(&sig->ioac);
 	sig->sum_sched_runtime = 0;
 	taskstats_tgid_init(sig);
diff --git a/kernel/sys.c b/kernel/sys.c
index 51dbb55..45611b0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1626,6 +1626,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 	unsigned long flags;
 	cputime_t utime, stime;
 	struct task_cputime cputime;
+	unsigned long maxrss = 0;
 
 	memset((char *) r, 0, sizeof *r);
 	utime = stime = cputime_zero;
@@ -1634,6 +1635,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 		utime = task_utime(current);
 		stime = task_stime(current);
 		accumulate_thread_rusage(p, r);
+		maxrss = p->signal->maxrss;
 		goto out;
 	}
 
@@ -1651,6 +1653,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt = p->signal->cmaj_flt;
 			r->ru_inblock = p->signal->cinblock;
 			r->ru_oublock = p->signal->coublock;
+			maxrss = p->signal->cmaxrss;
 
 			if (who == RUSAGE_CHILDREN)
 				break;
@@ -1665,6 +1668,8 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt += p->signal->maj_flt;
 			r->ru_inblock += p->signal->inblock;
 			r->ru_oublock += p->signal->oublock;
+			if (maxrss < p->signal->maxrss)
+				maxrss = p->signal->maxrss;
 			t = p;
 			do {
 				accumulate_thread_rusage(t, r);
@@ -1680,6 +1685,15 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 out:
 	cputime_to_timeval(utime, &r->ru_utime);
 	cputime_to_timeval(stime, &r->ru_stime);
+
+	if (who != RUSAGE_CHILDREN) {
+		struct mm_struct *mm = get_task_mm(p);
+		if (mm) {
+			setmax_mm_hiwater_rss(&maxrss, mm);
+			mmput(mm);
+		}
+	}
+	r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */
 }
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
