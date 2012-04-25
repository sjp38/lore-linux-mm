Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 054836B0083
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 16:01:26 -0400 (EDT)
Date: Wed, 25 Apr 2012 13:01:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: set task exit code before complete_vfork_done()
Message-Id: <20120425130124.50ba066b.akpm@linux-foundation.org>
In-Reply-To: <20120420204129.GA8034@redhat.com>
References: <20120409200336.8368.63793.stgit@zurg>
	<20120412080948.26401.23572.stgit@zurg>
	<20120412235446.GA4815@redhat.com>
	<20120420175934.GA31905@redhat.com>
	<4F91B7AF.8040203@openvz.org>
	<20120420204129.GA8034@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 20 Apr 2012 22:41:29 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> >> IOW, what do you think about the trivial patch below? Uncompiled,
> >> untested, probably incomplete. acct_update_integrals() looks
> >> suspicious too.
> >
> > what a mess! =)
> 
> Thanks ;)
> 
> But it is much, much simpler than your patches, don't you agree?

<taps his foot>

Here's what we currently have:

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: mm: correctly synchronize rss-counters at exit/exec

mm->rss_stat counters have per-task delta: task->rss_stat.  Before
changing task->mm pointer the kernel must flush this delta with
sync_mm_rss().

do_exit() already calls sync_mm_rss() to flush the rss-counters before
committing the rss statistics into task->signal->maxrss, taskstats, audit
and other stuff.  Unfortunately the kernel does this before calling
mm_release(), which can call put_user() for processing
task->clear_child_tid.  So at this point we can trigger page-faults and
task->rss_stat becomes non-zero again.  As a result mm->rss_stat becomes
inconsistent and check_mm() will print something like this:

| BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
| BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1

This patch moves sync_mm_rss() into mm_release(), and moves mm_release()
out of do_exit() and calls it earlier.  After mm_release() there should be
no pagefaults.

[akpm@linux-foundation.org: tweak comment]
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/exec.c     |    1 -
 kernel/exit.c |   13 ++++++++-----
 kernel/fork.c |    8 ++++++++
 3 files changed, 16 insertions(+), 6 deletions(-)

diff -puN fs/exec.c~mm-correctly-synchronize-rss-counters-at-exit-exec fs/exec.c
--- a/fs/exec.c~mm-correctly-synchronize-rss-counters-at-exit-exec
+++ a/fs/exec.c
@@ -823,7 +823,6 @@ static int exec_mmap(struct mm_struct *m
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
-	sync_mm_rss(old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
diff -puN kernel/exit.c~mm-correctly-synchronize-rss-counters-at-exit-exec kernel/exit.c
--- a/kernel/exit.c~mm-correctly-synchronize-rss-counters-at-exit-exec
+++ a/kernel/exit.c
@@ -423,6 +423,7 @@ void daemonize(const char *name, ...)
 	 * user space pages.  We don't need them, and if we didn't close them
 	 * they would be locked into memory.
 	 */
+	mm_release(current, current->mm);
 	exit_mm(current);
 	/*
 	 * We don't want to get frozen, in case system-wide hibernation
@@ -640,7 +641,6 @@ static void exit_mm(struct task_struct *
 	struct mm_struct *mm = tsk->mm;
 	struct core_state *core_state;
 
-	mm_release(tsk, mm);
 	if (!mm)
 		return;
 	/*
@@ -959,9 +959,13 @@ void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-	/* sync mm's RSS info before statistics gathering */
-	if (tsk->mm)
-		sync_mm_rss(tsk->mm);
+
+	/* Set exit_code before complete_vfork_done() in mm_release() */
+	tsk->exit_code = code;
+
+	/* Release mm and sync mm's RSS info before statistics gathering */
+	mm_release(tsk, tsk->mm);
+
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
@@ -974,7 +978,6 @@ void do_exit(long code)
 		tty_audit_exit();
 	audit_free(tsk);
 
-	tsk->exit_code = code;
 	taskstats_exit(tsk, group_dead);
 
 	exit_mm(tsk);
diff -puN kernel/fork.c~mm-correctly-synchronize-rss-counters-at-exit-exec kernel/fork.c
--- a/kernel/fork.c~mm-correctly-synchronize-rss-counters-at-exit-exec
+++ a/kernel/fork.c
@@ -782,6 +782,14 @@ void mm_release(struct task_struct *tsk,
 		}
 		tsk->clear_child_tid = NULL;
 	}
+
+	/*
+	 * Final rss-counter synchronization. After this point there must be
+	 * no pagefaults into this mm from the current context.  Otherwise
+	 * mm->rss_stat will be inconsistent.
+	 */
+	if (mm)
+		sync_mm_rss(mm);
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
