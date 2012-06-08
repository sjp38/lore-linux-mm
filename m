Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E55E16B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 08:20:05 -0400 (EDT)
Date: Fri, 8 Jun 2012 14:18:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at
	exit/exec
Message-ID: <20120608121816.GA23147@redhat.com>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com> <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com> <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <20120608010520.GA25317@x4> <CA+55aFwuA3ex+XXW+TzOee8ax0g1NK9Mm5F3nYtY1m6YtvUFhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwuA3ex+XXW+TzOee8ax0g1NK9Mm5F3nYtY1m6YtvUFhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, khlebnikov@openvz.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, stable@vger.kernel.org

On 06/07, Linus Torvalds wrote:
>
> It does totally insane things in xacct_add_tsk(). You can't call
> "sync_mm_rss(mm)" on somebody elses mm,

Damn, I am stupid. Yes, I forgot about fill_stats_for_pid().
And I didn't bother to look at get_task_mm() which clearly
shows that this tsk can be !current.

We can add the "p == current" check as Hugh suggested.

But,

> Doing it
> *anywhere* where mm is not clearly "current->mm" is wrong.

Agreed.

How about v2? It adds sync_mm_rss() into taskstats_exit(). Note
that it preserves the "tsk->mm != NULL" check we currently have.
I think it should be removed (see the changelog), but even if I
am right I'd prefer to do this in a separate patch.

------------------------------------------------------------------------------
Subject: [PATCH] correctly synchronize rss-counters at exit/exec

A simplified version of Konstantin Khlebnikov's patch.

do_exit() and exec_mmap() call sync_mm_rss() before mm_release()
does put_user(clear_child_tid) which can update task->rss_stat
and thus make mm->rss_stat inconsistent. This triggers the "BUG:"
printk in check_mm().

- Move the final sync_mm_rss() from do_exit() to exit_mm(), and
  change exec_mmap() to call sync_mm_rss() after mm_release() to
  make check_mm() happy.

  Perhaps we should simply move it into mm_release() and call it
  unconditionally to catch the "task->rss_stat != 0 && !task->mm"
  bugs.

- Since taskstats_exit() is called before exit_mm(), add another
  sync_mm_rss() into taskstats_exit() for xacct_add_tsk() who
  actually uses rss_stat. As Linus pointed out, it is not sane
  to move it into xacct_add_tsk().

  Probably we should also shift acct_update_integrals(), and
  "tsk->mm != NULL" check looks equally unneeded.

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Tested-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/exec.c          |    2 +-
 kernel/exit.c      |    5 ++---
 kernel/taskstats.c |    2 ++
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index a79786a..da27b91 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -819,10 +819,10 @@ static int exec_mmap(struct mm_struct *mm)
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
-	sync_mm_rss(old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
+		sync_mm_rss(old_mm);
 		/*
 		 * Make sure that if there is a core dump in progress
 		 * for the old mm, we get out and die instead of going
diff --git a/kernel/exit.c b/kernel/exit.c
index 0e40041..38c4a91 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -655,6 +655,8 @@ static void exit_mm(struct task_struct * tsk)
 	mm_release(tsk, mm);
 	if (!mm)
 		return;
+
+	sync_mm_rss(mm);
 	/*
 	 * Serialize with any possible pending coredump.
 	 * We must hold mmap_sem around checking core_state
@@ -966,9 +968,6 @@ void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-	/* sync mm's RSS info before statistics gathering */
-	if (tsk->mm)
-		sync_mm_rss(tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index e660464..55d1103 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -630,6 +630,8 @@ void taskstats_exit(struct task_struct *tsk, int group_dead)
 	if (!stats)
 		goto err;
 
+	if (tsk->mm)
+		sync_mm_rss(tsk->mm);
 	fill_stats(tsk, stats);
 
 	/*
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
