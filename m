Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1BB1B6B0083
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 13:07:39 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so15274bkw.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 10:07:37 -0700 (PDT)
Subject: [PATCH v2] mm: correctly synchronize rss-counters at exit/exec
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 10 Apr 2012 21:07:32 +0400
Message-ID: <20120410170732.18750.64274.stgit@zurg>
In-Reply-To: <20120409200336.8368.63793.stgit@zurg>
References: <20120409200336.8368.63793.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

mm->rss_stat counters have per-task delta: task->rss_stat, before changing
task->mm pointer kernel must flush this delta with help of sync_mm_rss().

do_exit() already calls sync_mm_rss() to flush rss-counters before commiting
rss-statistics into task->signal->maxrss, taskstats, audit and other stuff.
Unfortunately kernel do this before calling mm_relese(), which can call put_user()
for processing task->clear_child_tid. So at this point we can trigger page-faults
and task->rss_stat becomes non-zero again, as result mm->rss_stat becomes
inconsistent and check_mm() will print something like this:

| BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
| BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1

This patch moves sync_mm_rss() into mm_release(), and moves mm_release() out of
do_exit() and calls it earlier. After mm_release() there should be no page-faults.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 fs/exec.c     |    1 -
 kernel/exit.c |    9 +++++----
 kernel/fork.c |    8 ++++++++
 3 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index b1fd202..5be1d97 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -823,7 +823,6 @@ static int exec_mmap(struct mm_struct *mm)
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
-	sync_mm_rss(old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
diff --git a/kernel/exit.c b/kernel/exit.c
index d8bd3b42..eb12719 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -423,6 +423,7 @@ void daemonize(const char *name, ...)
 	 * user space pages.  We don't need them, and if we didn't close them
 	 * they would be locked into memory.
 	 */
+	mm_release(current, current->mm);
 	exit_mm(current);
 	/*
 	 * We don't want to get frozen, in case system-wide hibernation
@@ -640,7 +641,6 @@ static void exit_mm(struct task_struct * tsk)
 	struct mm_struct *mm = tsk->mm;
 	struct core_state *core_state;
 
-	mm_release(tsk, mm);
 	if (!mm)
 		return;
 	/*
@@ -959,9 +959,10 @@ void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-	/* sync mm's RSS info before statistics gathering */
-	if (tsk->mm)
-		sync_mm_rss(tsk->mm);
+
+	/* Release mm and sync mm's RSS info before statistics gathering */
+	mm_release(tsk, tsk->mm);
+
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
diff --git a/kernel/fork.c b/kernel/fork.c
index 54662ed..326bb5b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -751,6 +751,14 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 		}
 		tsk->clear_child_tid = NULL;
 	}
+
+	/*
+	 * Final rss-counter synchronization. After this point must be
+	 * no page-faults into this mm from current context, otherwise
+	 * mm->rss_stat will be inconsistent.
+	 */
+	if (mm)
+		sync_mm_rss(mm);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
