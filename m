Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC856B00A0
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 20:42:07 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oA30g3AP005612
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 17:42:03 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by wpaz5.hot.corp.google.com with ESMTP id oA30g1JH028958
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 17:42:01 -0700
Received: by pvc7 with SMTP id 7so21189pvc.6
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 17:42:01 -0700 (PDT)
Date: Tue, 2 Nov 2010 17:41:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] oom: fix oom_score_adj consistency with
 oom_disable_count
In-Reply-To: <alpine.DEB.2.00.1011011738200.26266@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011021741520.21871@chino.kir.corp.google.com>
References: <201010262121.o9QLLNFo016375@imap1.linux-foundation.org> <20101101024949.6074.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011738200.26266@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

p->mm->oom_disable_count tracks how many threads sharing p->mm have an
oom_score_adj value of OOM_SCORE_ADJ_MIN, which disables the oom killer
for that task.  If non-zero, p->mm->oom_disable_count indicates killing a
task sharing p->mm won't help since other threads cannot be killed and
the memory can't be freed.

oom_score_adj is a per-process value stored in p->signal->oom_score_adj,
which is protected by p->sighand->siglock.  Thus, it's necessary to take
this lock whenever the value is tested.

This patch introduces the necessary locking to ensure oom_score_adj can
be tested and/or changed with consistency.  This isn't the only locking
necessary to work with oom_score_adj: task_lock(p) must also be held or
the mm otherwise pinned in memory to ensure it doesn't change while
siglock is held.  That locking is already in place.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: cleaned up locking and fixed lockdep warnings

 For 2.6.37-rc-series.

 fs/exec.c     |   10 +++++++---
 kernel/exit.c |    8 ++++++--
 kernel/fork.c |   31 ++++++++++++++++++++++---------
 3 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -741,6 +741,7 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct * old_mm, *active_mm;
+	unsigned long flags;
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -766,9 +767,12 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
-	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-		atomic_dec(&old_mm->oom_disable_count);
-		atomic_inc(&tsk->mm->oom_disable_count);
+	if (lock_task_sighand(tsk, &flags)) {
+		if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			atomic_dec(&old_mm->oom_disable_count);
+			atomic_inc(&tsk->mm->oom_disable_count);
+		}
+		unlock_task_sighand(tsk, &flags);
 	}
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -644,6 +644,7 @@ static void exit_mm(struct task_struct * tsk)
 {
 	struct mm_struct *mm = tsk->mm;
 	struct core_state *core_state;
+	unsigned long flags;
 
 	mm_release(tsk, mm);
 	if (!mm)
@@ -688,8 +689,11 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
-	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		atomic_dec(&mm->oom_disable_count);
+	if (lock_task_sighand(tsk, &flags)) {
+		if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			atomic_dec(&mm->oom_disable_count);
+		unlock_task_sighand(tsk, &flags);
+	}
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -708,6 +708,7 @@ fail_nocontext:
 static int copy_mm(unsigned long clone_flags, struct task_struct * tsk)
 {
 	struct mm_struct * mm, *oldmm;
+	unsigned long flags;
 	int retval;
 
 	tsk->min_flt = tsk->maj_flt = 0;
@@ -743,8 +744,11 @@ good_mm:
 	/* Initializing for Swap token stuff */
 	mm->token_priority = 0;
 	mm->last_interval = 0;
-	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		atomic_inc(&mm->oom_disable_count);
+	if (lock_task_sighand(tsk, &flags)) {
+		if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			atomic_inc(&mm->oom_disable_count);
+		unlock_task_sighand(tsk, &flags);
+	}
 
 	tsk->mm = mm;
 	tsk->active_mm = mm;
@@ -1306,10 +1310,13 @@ bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
 	if (p->mm) {
-		task_lock(p);
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			atomic_dec(&p->mm->oom_disable_count);
-		task_unlock(p);
+		unsigned long flags;
+
+		if (lock_task_sighand(p, &flags)) {
+			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+				atomic_dec(&p->mm->oom_disable_count);
+			unlock_task_sighand(p, &flags);
+		}
 		mmput(p->mm);
 	}
 bad_fork_cleanup_signal:
@@ -1700,13 +1707,19 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 		}
 
 		if (new_mm) {
+			unsigned long flags;
+
 			mm = current->mm;
 			active_mm = current->active_mm;
 			current->mm = new_mm;
 			current->active_mm = new_mm;
-			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-				atomic_dec(&mm->oom_disable_count);
-				atomic_inc(&new_mm->oom_disable_count);
+			if (lock_task_sighand(current, &flags)) {
+				if (current->signal->oom_score_adj ==
+							OOM_SCORE_ADJ_MIN) {
+					atomic_dec(&mm->oom_disable_count);
+					atomic_inc(&new_mm->oom_disable_count);
+				}
+				unlock_task_sighand(current, &flags);
 			}
 			activate_mm(active_mm, new_mm);
 			new_mm = mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
