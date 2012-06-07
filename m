Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AB74E6B006C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 09:20:39 -0400 (EDT)
Date: Thu, 7 Jun 2012 15:18:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
	val:-59
Message-ID: <20120607131848.GA19076@redhat.com>
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com> <4FC52F17.20709@openvz.org> <20120530171158.GA8614@redhat.com> <4FD05F75.1050108@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD05F75.1050108@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/07, Konstantin Khlebnikov wrote:
>
> Oleg Nesterov wrote:
>>
>> I'll write the changelog and send the patch tomorrow.
>
> Ding! Week is over, or I missed something? )

Pong ;)

I have sent the patch on May 31, see
http://marc.info/?l=linux-kernel&m=133848759505805
Also attached below, just in case.

Initiallly I sent 2 patches, see
http://marc.info/?l=linux-kernel&m=133848784705941
but 2/2 (your patch) was already merged.

-------------------------------------------------------------------------------
[PATCH] correctly synchronize rss-counters at exit/exec

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
  sync_mm_rss() into xacct_add_tsk() who actually uses rss_stat.

  Probably we should also shift acct_update_integrals().

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Tested-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/exec.c       |    2 +-
 kernel/exit.c   |    5 ++---
 kernel/tsacct.c |    1 +
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 52c9e2f..e49e3c2 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -823,10 +823,10 @@ static int exec_mmap(struct mm_struct *mm)
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
index ab972a7..b3a84b5 100644
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
@@ -965,9 +967,6 @@ void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-	/* sync mm's RSS info before statistics gathering */
-	if (tsk->mm)
-		sync_mm_rss(tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
diff --git a/kernel/tsacct.c b/kernel/tsacct.c
index 23b4d78..a64ee90 100644
--- a/kernel/tsacct.c
+++ b/kernel/tsacct.c
@@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *stats, struct task_struct *p)
 	stats->virtmem = p->acct_vm_mem1 * PAGE_SIZE / MB;
 	mm = get_task_mm(p);
 	if (mm) {
+		sync_mm_rss(mm);
 		/* adjust to KB unit */
 		stats->hiwater_rss   = get_mm_hiwater_rss(mm) * PAGE_SIZE / KB;
 		stats->hiwater_vm    = get_mm_hiwater_vm(mm)  * PAGE_SIZE / KB;
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
