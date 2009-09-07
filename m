Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8C7A06B0092
	for <linux-mm@kvack.org>; Sun,  6 Sep 2009 22:58:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n872wcHj007943
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 7 Sep 2009 11:58:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66CD745DE6F
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 11:58:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34CC645DE6E
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 11:58:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DDB50E18003
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 11:58:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 78FBCE18002
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 11:58:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <20090618095705.99D2.A69D9226@jp.fujitsu.com>
References: <20090617132118.ef839ad7.akpm@linux-foundation.org> <20090618095705.99D2.A69D9226@jp.fujitsu.com>
Message-Id: <20090907115430.6C16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Sep 2009 11:58:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh@veritas.com>, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> > On Mon, 6 Apr 2009 08:22:07 +0100 (BST)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > > On Mon, 6 Apr 2009, KOSAKI Motohiro wrote:
> > > > 
> > > > > I'm worrying particularly about the fork/exec issue you highlight.
> > > > > You're exemplary in providing your test programs, but there's a big
> > > > > omission: you don't mention that the first test, "./getrusage -lc",
> > > > > gives a very different result on Linux than you say it does on BSD -
> > > > > you say the BSD fork line is "fork: self 0 children 0", whereas
> > > > > I find my Linux fork line is "fork: self 102636 children 0".
> > > > 
> > > > FreeBSD update rusage at tick updating point. (I think all bsd do that)
> > > > Then, bsd displaing 0 is bsd's problem :)
> > > 
> > > Ah, thank you.
> > > 
> > > > 
> > > > Do I must change test program?
> > > 
> > > Apparently somebody needs to, please; though it appears to be already
> > > well supplied with usleep(1)s - maybe they needed to be usleep(2)s?
> > > 
> > > And then change results shown in the changelog, and check conclusions
> > > drawn from them (if BSD is behaving as we do, it should still show
> > > maxrss not inherited over fork, but less obviously - the number goes
> > > down slightly, because the history is lost, but nowhere near to zero).
> > > 
> > 
> > afaik none of this happened, so I have the patch on hold.
> 
> Grr, my fault.
> I recognize it. sorry.

I've finished my long pending homework ;)

Andrew, can you please replace following patch with getrusage-fill-ru_maxrss-value.patch
and getrusage-fill-ru_maxrss-value-update.patch?



ChangeLog
 ===============================
  o Merge getrusage-fill-ru_maxrss-value.patch and getrusage-fill-ru_maxrss-value-update.patch
  o rewrote test programs (older version hit FreeBSD bug and it obfuscate testcase intention, thanks Hugh)


========================================================
From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] getrusage: fill ru_maxrss value

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

test programs
========================================================

getrusage.c
-----------
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
 #include <sys/mman.h>

 #include "common.h"

 #define err(str) perror(str), exit(1)

int main(int argc, char** argv)
{
	int status;

	printf("allocate 100MB\n");
	consume(100);

	printf("testcase1: fork inherit? \n");
	printf("  expect: initial.self ~= child.self\n");
	show_rusage("initial");
	if (__fork()) {
		wait(&status);
	} else {
		show_rusage("fork child");
		_exit(0);
	}
	printf("\n");

	printf("testcase2: fork inherit? (cont.) \n");
	printf("  expect: initial.children ~= 100MB, but child.children = 0\n");
	show_rusage("initial");
	if (__fork()) {
		wait(&status);
	} else {
		show_rusage("child");
		_exit(0);
	}
	printf("\n");

	printf("testcase3: fork + malloc \n");
	printf("  expect: child.self ~= initial.self + 50MB\n");
	show_rusage("initial");
	if (__fork()) {
		wait(&status);
	} else {
		printf("allocate +50MB\n");
		consume(50);
		show_rusage("fork child");
		_exit(0);
	}
	printf("\n");

	printf("testcase4: grandchild maxrss\n");
	printf("  expect: post_wait.children ~= 300MB\n");
	show_rusage("initial");
	if (__fork()) {
		wait(&status);
		show_rusage("post_wait");
	} else {
		system("./child -n 0 -g 300");
		_exit(0);
	}
	printf("\n");

	printf("testcase5: zombie\n");
	printf("  expect: pre_wait ~= initial, IOW the zombie process is not accounted.\n");
	printf("          post_wait ~= 400MB, IOW wait() collect child's max_rss. \n");
	show_rusage("initial");
	if (__fork()) {
		sleep(1); /* children become zombie */
		show_rusage("pre_wait");
		wait(&status);
		show_rusage("post_wait");
	} else {
		system("./child -n 400");
		_exit(0);
	}
	printf("\n");

	printf("testcase6: SIG_IGN\n");
	printf("  expect: initial ~= after_zombie (child's 500MB alloc should be ignored).\n");
	show_rusage("initial");
	signal(SIGCHLD, SIG_IGN);
	if (__fork()) {
		sleep(1); /* children become zombie */
		show_rusage("after_zombie");
	} else {
		system("./child -n 500");
		_exit(0);
	}
	printf("\n");
	signal(SIGCHLD, SIG_DFL);

	printf("testcase7: exec (without fork) \n");
	printf("  expect: initial ~= exec \n");
	show_rusage("initial");
	execl("./child", "child", "-v", NULL);

	return 0;
}

child.c
------------------------
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

 #include "common.h"

int main(int argc, char** argv)
{
	int status;
	int c;
	long consume_size = 0;
	long grandchild_consume_size = 0;
	int show = 0;

	while ((c = getopt(argc, argv, "n:g:v")) != -1) {
		switch (c) {
		case 'n':
			consume_size = atol(optarg);
			break;
		case 'v':
			show = 1;
			break;
		case 'g':

			grandchild_consume_size = atol(optarg);
			break;
		default:
			break;
		}
	}

	if (show)
		show_rusage("exec");

	if (consume_size) {
		printf("child alloc %ldMB\n", consume_size);
		consume(consume_size);
	}

	if (grandchild_consume_size) {
		if (fork()) {
			wait(&status);
		} else {
			printf("grandchild alloc %ldMB\n", grandchild_consume_size);
			consume(grandchild_consume_size);

			exit(0);
		}
	}

	return 0;
}

common.c
--------------------
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
 #include <sys/mman.h>

 #include "common.h"
 #define err(str) perror(str), exit(1)

void show_rusage(char *prefix)
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

/* Some buggy OS need this worthless CPU waste. */
void make_pagefault(void)
{
	void *addr;
	int size = getpagesize();
	int i;

	for (i=0; i<1000; i++) {
		addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
		if (addr == MAP_FAILED)
			err("make_pagefault");
		memset(addr, 0, size);
		munmap(addr, size);
	}
}

void consume(int mega)
{
    	size_t sz = mega * 1024 * 1024;
    	void *ptr;

    	ptr = malloc(sz);
    	memset(ptr, 0, sz);
	make_pagefault();
}

pid_t __fork(void)
{
	pid_t pid;

	pid = fork();
	make_pagefault();

	return pid;
}

common.h
----------------------
void show_rusage(char *prefix);
void make_pagefault(void);
void consume(int mega);
pid_t __fork(void);

FreeBSD result (expected result)
========================================================
allocate 100MB
testcase1: fork inherit?
  expect: initial.self ~= child.self
initial: self 103492 children 0
fork child: self 103540 children 0

testcase2: fork inherit? (cont.)
  expect: initial.children ~= 100MB, but child.children = 0
initial: self 103540 children 103540
child: self 103564 children 0

testcase3: fork + malloc
  expect: child.self ~= initial.self + 50MB
initial: self 103564 children 103564
allocate +50MB
fork child: self 154860 children 0

testcase4: grandchild maxrss
  expect: post_wait.children ~= 300MB
initial: self 103564 children 154860
grandchild alloc 300MB
post_wait: self 103564 children 308720

testcase5: zombie
  expect: pre_wait ~= initial, IOW the zombie process is not accounted.
          post_wait ~= 400MB, IOW wait() collect child's max_rss.
initial: self 103564 children 308720
child alloc 400MB
pre_wait: self 103564 children 308720
post_wait: self 103564 children 411312

testcase6: SIG_IGN
  expect: initial ~= after_zombie (child's 500MB alloc should be ignored).
initial: self 103564 children 411312
child alloc 500MB
after_zombie: self 103624 children 411312

testcase7: exec (without fork)
  expect: initial ~= exec
initial: self 103624 children 411312
exec: self 103624 children 411312

Linux result (actual test result)
========================================================
allocate 100MB
testcase1: fork inherit?
  expect: initial.self ~= child.self
initial: self 102848 children 0
fork child: self 102572 children 0

testcase2: fork inherit? (cont.)
  expect: initial.children ~= 100MB, but child.children = 0
initial: self 102876 children 102644
child: self 102572 children 0

testcase3: fork + malloc
  expect: child.self ~= initial.self + 50MB
initial: self 102876 children 102644
allocate +50MB
fork child: self 153804 children 0

testcase4: grandchild maxrss
  expect: post_wait.children ~= 300MB
initial: self 102876 children 153864
grandchild alloc 300MB
post_wait: self 102876 children 307536

testcase5: zombie
  expect: pre_wait ~= initial, IOW the zombie process is not accounted.
          post_wait ~= 400MB, IOW wait() collect child's max_rss.
initial: self 102876 children 307536
child alloc 400MB
pre_wait: self 102876 children 307536
post_wait: self 102876 children 410076

testcase6: SIG_IGN
  expect: initial ~= after_zombie (child's 500MB alloc should be ignored).
initial: self 102876 children 410076
child alloc 500MB
after_zombie: self 102880 children 410076

testcase7: exec (without fork)
  expect: initial ~= exec
initial: self 102880 children 410076
exec: self 102880 children 410076

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 fs/exec.c             |    3 +++
 include/linux/sched.h |   10 ++++++++++
 kernel/exit.c         |    6 ++++++
 kernel/fork.c         |    1 +
 kernel/sys.c          |   14 ++++++++++++++
 5 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index e51e7c2..a231af6 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -849,6 +849,9 @@ static int de_thread(struct task_struct *tsk)
 	sig->notify_count = 0;
 
 no_thread_group:
+	if (current->mm)
+		setmax_mm_hiwater_rss(&sig->maxrss, current->mm);
+
 	exit_itimers(sig);
 	flush_itimer_signals();
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 27da112..3a2ef73 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -426,6 +426,15 @@ static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
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
@@ -637,6 +646,7 @@ struct signal_struct {
 	unsigned long nvcsw, nivcsw, cnvcsw, cnivcsw;
 	unsigned long min_flt, maj_flt, cmin_flt, cmaj_flt;
 	unsigned long inblock, oublock, cinblock, coublock;
+	unsigned long maxrss, cmaxrss;
 	struct task_io_accounting ioac;
 
 	/*
diff --git a/kernel/exit.c b/kernel/exit.c
index 2d273fd..18735bc 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -948,6 +948,8 @@ NORET_TYPE void do_exit(long code)
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
 		exit_itimers(tsk->signal);
+		if (tsk->mm)
+			setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm);
 	}
 	acct_collect(code, group_dead);
 	if (group_dead)
@@ -1203,6 +1205,7 @@ static int wait_task_zombie(struct wait_opts *wo, struct task_struct *p)
 	if (likely(!traced) && likely(!task_detached(p))) {
 		struct signal_struct *psig;
 		struct signal_struct *sig;
+		unsigned long maxrss;
 
 		/*
 		 * The resource counters for the group leader are in its
@@ -1251,6 +1254,9 @@ static int wait_task_zombie(struct wait_opts *wo, struct task_struct *p)
 		psig->coublock +=
 			task_io_get_oublock(p) +
 			sig->oublock + sig->coublock;
+		maxrss = max(sig->maxrss, sig->cmaxrss);
+		if (psig->cmaxrss < maxrss)
+			psig->cmaxrss = maxrss;
 		task_io_accounting_add(&psig->ioac, &p->ioac);
 		task_io_accounting_add(&psig->ioac, &sig->ioac);
 		spin_unlock_irq(&p->real_parent->sighand->siglock);
diff --git a/kernel/fork.c b/kernel/fork.c
index fdc6467..58cd45a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -889,6 +889,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sig->nvcsw = sig->nivcsw = sig->cnvcsw = sig->cnivcsw = 0;
 	sig->min_flt = sig->maj_flt = sig->cmin_flt = sig->cmaj_flt = 0;
 	sig->inblock = sig->oublock = sig->cinblock = sig->coublock = 0;
+	sig->maxrss = sig->cmaxrss = 0;
 	task_io_accounting_init(&sig->ioac);
 	sig->sum_sched_runtime = 0;
 	taskstats_tgid_init(sig);
diff --git a/kernel/sys.c b/kernel/sys.c
index 41e02ef..a7e36b6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1338,6 +1338,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 	unsigned long flags;
 	cputime_t utime, stime;
 	struct task_cputime cputime;
+	unsigned long maxrss = 0;
 
 	memset((char *) r, 0, sizeof *r);
 	utime = stime = cputime_zero;
@@ -1346,6 +1347,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 		utime = task_utime(current);
 		stime = task_stime(current);
 		accumulate_thread_rusage(p, r);
+		maxrss = p->signal->maxrss;
 		goto out;
 	}
 
@@ -1363,6 +1365,7 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt = p->signal->cmaj_flt;
 			r->ru_inblock = p->signal->cinblock;
 			r->ru_oublock = p->signal->coublock;
+			maxrss = p->signal->cmaxrss;
 
 			if (who == RUSAGE_CHILDREN)
 				break;
@@ -1377,6 +1380,8 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 			r->ru_majflt += p->signal->maj_flt;
 			r->ru_inblock += p->signal->inblock;
 			r->ru_oublock += p->signal->oublock;
+			if (maxrss < p->signal->maxrss)
+				maxrss = p->signal->maxrss;
 			t = p;
 			do {
 				accumulate_thread_rusage(t, r);
@@ -1392,6 +1397,15 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
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
1.6.0.6





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
