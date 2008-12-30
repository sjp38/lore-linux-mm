Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D3E666B0047
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 06:15:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBUBFY5o008277
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Dec 2008 20:15:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E2545DD76
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 20:15:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A826445DD70
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 20:15:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2267D1DB8041
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 20:15:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C295E1DB803C
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 20:15:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-Id: <20081230201052.128B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Dec 2008 20:15:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>, Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

Oleg, Jiri, this is my getrusage testcase and proposal patch.
Could you please review it?



Changes Jiris's last version
  - At wait_task_zombie(), parent process doesn't only collect child maxrss,
    but also cmaxrss.
  - ru_maxrss inherit at exec()
  - style fixes.

Applied after: introduce-get_mm_hiwater_xxx-fix-taskstats-hiwater_xxx-accounting.patch
==
From: Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH for -mm] getrusage: fill ru_maxrss value

This patch makes ->ru_maxrss value in struct rusage filled accordingly to
rss hiwater mark. This struct is filled as a parameter to
getrusage syscall. ->ru_maxrss value is set to KBs which is the way it
is done in BSD systems. /usr/bin/time (gnu time) application converts
->ru_maxrss to KBs which seems to be incorrect behavior. Maintainer of
this util was notified by me with the patch which corrects it and cc'ed.

To make this happen we extend struct signal_struct by two fields. The
first one is ->maxrss which we use to store rss hiwater of the task. The
second one is ->cmaxrss which we use to store highest rss hiwater of all
task childs. These values are used in k_getrusage() to actually fill
->ru_maxrss. k_getrusage() uses current rss hiwater value directly
if mm struct exists.

Note:
exec() clear mm->hiwater_rss, but doesn't clear sig->maxrss.
it is intetionally behavior. *BSD getrusage have exec() inheriting.


Test progmam and test case
===========================

getrusage.c
----
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
----
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
==================
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
---
 fs/exec.c             |    5 +++++
 include/linux/sched.h |    1 +
 kernel/exit.c         |    6 ++++++
 kernel/fork.c         |    1 +
 kernel/sys.c          |   15 +++++++++++++++
 5 files changed, 28 insertions(+)

Index: b/include/linux/sched.h
===================================================================
--- a/include/linux/sched.h	2008-12-29 23:27:59.000000000 +0900
+++ b/include/linux/sched.h	2008-12-30 03:25:23.000000000 +0900
@@ -562,6 +562,7 @@ struct signal_struct {
 	unsigned long nvcsw, nivcsw, cnvcsw, cnivcsw;
 	unsigned long min_flt, maj_flt, cmin_flt, cmaj_flt;
 	unsigned long inblock, oublock, cinblock, coublock;
+	unsigned long maxrss, cmaxrss;
 	struct task_io_accounting ioac;
 
 	/*
Index: b/kernel/exit.c
===================================================================
--- a/kernel/exit.c	2008-12-29 23:27:59.000000000 +0900
+++ b/kernel/exit.c	2008-12-30 17:35:51.000000000 +0900
@@ -1053,6 +1053,10 @@ NORET_TYPE void do_exit(long code)
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
 		exit_itimers(tsk->signal);
+		if (tsk->mm) {
+			unsigned long maxrss = get_mm_hiwater_rss(tsk->mm);
+			tsk->signal->maxrss = max(maxrss, tsk->signal->maxrss);
+		}
 	}
 	acct_collect(code, group_dead);
 	if (group_dead)
@@ -1349,6 +1353,8 @@ static int wait_task_zombie(struct task_
 		psig->coublock +=
 			task_io_get_oublock(p) +
 			sig->oublock + sig->coublock;
+		psig->cmaxrss = max(max(sig->maxrss, sig->cmaxrss),
+				    psig->cmaxrss);
 		task_io_accounting_add(&psig->ioac, &p->ioac);
 		task_io_accounting_add(&psig->ioac, &sig->ioac);
 		spin_unlock_irq(&p->parent->sighand->siglock);
Index: b/kernel/fork.c
===================================================================
--- a/kernel/fork.c	2008-12-25 08:26:37.000000000 +0900
+++ b/kernel/fork.c	2008-12-30 03:48:09.000000000 +0900
@@ -849,6 +849,7 @@ static int copy_signal(unsigned long clo
 	sig->nvcsw = sig->nivcsw = sig->cnvcsw = sig->cnivcsw = 0;
 	sig->min_flt = sig->maj_flt = sig->cmin_flt = sig->cmaj_flt = 0;
 	sig->inblock = sig->oublock = sig->cinblock = sig->coublock = 0;
+	sig->maxrss = sig->cmaxrss = 0;
 	task_io_accounting_init(&sig->ioac);
 	taskstats_tgid_init(sig);
 
Index: b/kernel/sys.c
===================================================================
--- a/kernel/sys.c	2008-12-25 08:26:37.000000000 +0900
+++ b/kernel/sys.c	2008-12-30 04:04:18.000000000 +0900
@@ -1569,6 +1569,7 @@ static void k_getrusage(struct task_stru
 			r->ru_majflt = p->signal->cmaj_flt;
 			r->ru_inblock = p->signal->cinblock;
 			r->ru_oublock = p->signal->coublock;
+			r->ru_maxrss = p->signal->cmaxrss;
 
 			if (who == RUSAGE_CHILDREN)
 				break;
@@ -1583,6 +1584,8 @@ static void k_getrusage(struct task_stru
 			r->ru_majflt += p->signal->maj_flt;
 			r->ru_inblock += p->signal->inblock;
 			r->ru_oublock += p->signal->oublock;
+			if (r->ru_maxrss < p->signal->maxrss)
+				r->ru_maxrss = p->signal->maxrss;
 			t = p;
 			do {
 				accumulate_thread_rusage(t, r);
@@ -1598,6 +1601,18 @@ static void k_getrusage(struct task_stru
 out:
 	cputime_to_timeval(utime, &r->ru_utime);
 	cputime_to_timeval(stime, &r->ru_stime);
+
+	if (who != RUSAGE_CHILDREN) {
+		struct mm_struct *mm = get_task_mm(p);
+		if (mm) {
+			unsigned long maxrss = get_mm_hiwater_rss(mm);
+
+			if (r->ru_maxrss < maxrss)
+				r->ru_maxrss = maxrss;
+			mmput(mm);
+		}
+	}
+	r->ru_maxrss <<= PAGE_SHIFT - 10;
 }
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru)
Index: b/fs/exec.c
===================================================================
--- a/fs/exec.c	2008-12-25 08:26:37.000000000 +0900
+++ b/fs/exec.c	2008-12-30 17:42:32.000000000 +0900
@@ -774,6 +774,7 @@ static int de_thread(struct task_struct 
 	spinlock_t *lock = &oldsighand->siglock;
 	struct task_struct *leader = NULL;
 	int count;
+	unsigned long maxrss = 0;
 
 	if (thread_group_empty(tsk))
 		goto no_thread_group;
@@ -870,6 +871,10 @@ static int de_thread(struct task_struct 
 	sig->notify_count = 0;
 
 no_thread_group:
+	if (current->mm)
+		maxrss = get_mm_hiwater_rss(current->mm);
+	sig->maxrss = max(sig->maxrss, maxrss);
+
 	exit_itimers(sig);
 	flush_itimer_signals();
 	if (leader)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
