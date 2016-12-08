Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73AF96B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 06:48:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so643664305pfb.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 03:48:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g33si28484013plb.310.2016.12.08.03.48.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 03:48:31 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20161207081555.GB17136@dhcp22.suse.cz>
	<201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
	<5c3ddf50-ca19-2cae-a3ce-b10eafe8363c@suse.cz>
In-Reply-To: <5c3ddf50-ca19-2cae-a3ce-b10eafe8363c@suse.cz>
Message-Id: <201612082000.FBB00003.FFMQSVHJOFLOtO@I-love.SAKURA.ne.jp>
Date: Thu, 8 Dec 2016 20:00:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, mhocko@suse.com
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, aarcange@redhat.com, david@fromorbit.com, sergey.senozhatsky@gmail.com, akpm@linux-foundation.org

Cc'ing people involved in commit dc56401fc9f25e8f ("mm: oom_kill: simplify
OOM killer locking") and Sergey as printk() expert. Topic started from
http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

Vlastimil Babka wrote:
> > May I? Something like below? With patch below, the OOM killer can send
> > SIGKILL smoothly and printk() can report smoothly (the frequency of
> > "** XXX printk messages dropped **" messages is significantly reduced).
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2c6d5f6..ee0105b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> >  	 * Acquire the oom lock.  If that fails, somebody else is
> >  	 * making progress for us.
> >  	 */
> 
> The comment above could use some updating then. Although maybe "somebody 
> killed us" is also technically "making progress for us" :)

I think we can update the comment. But since __GFP_KILLABLE does not exist,
SIGKILL is pending does not imply that current thread will make progress by
leaving the retry loop immediately. Therefore,

> 
> > -	if (!mutex_trylock(&oom_lock)) {
> > +	if (mutex_lock_killable(&oom_lock)) {
> >  		*did_some_progress = 1;
> >  		schedule_timeout_uninterruptible(1);
> 
> I think if we get here, it means somebody killed us, so we should not do 
> this uninterruptible sleep anymore? (maybe also the caller could need 
> some check to expedite the kill?).
> 
> >  		return NULL;

I guess we should still sleep.

----------------------------------------
>From f294e5f53524d3b055857d35aa6f3dc16cf20d86 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 8 Dec 2016 09:27:18 +0900
Subject: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.

If the OOM killer is invoked when many threads are looping inside the
page allocator, it is possible that the OOM killer is blocked for
unbounded period due to preemption and/or printk() with oom_lock held.

----------
[ 2802.635229] Killed process 7267 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[ 2802.644296] oom_reaper: reaped process 7267 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2802.650237] Out of memory: Kill process 7268 (a.out) score 999 or sacrifice child
[ 2803.653052] Killed process 7268 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[ 2804.426183] oom_reaper: reaped process 7268 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2804.432524] Out of memory: Kill process 7269 (a.out) score 999 or sacrifice child
[ 2805.349380] a.out: page allocation stalls for 10047ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[ 2805.349383] CPU: 2 PID: 7243 Comm: a.out Not tainted 4.9.0-rc8 #62
(...snipped...)
[ 3540.977499]           a.out  7269     22716.893359      5272   120
[ 3540.977499]         0.000000      1447.601063         0.000000
[ 3540.977499]  0 0
[ 3540.977500]  /autogroup-155
----------

The problem triggered by preemption existed before commit 63f53dea0c98
("mm: warn about allocations which stall for too long"). But that commit
made the problem also triggerable by printk() because currently printk()
tries to flush printk log buffer ( https://lwn.net/Articles/705938/ ).

  Thread-1

    __alloc_pages_slowpath() {
      __alloc_pages_may_oom() {
        mutex_trylock(&oom_lock); // succeeds
        out_of_memory() {
          oom_kill_process() {
             pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n", ...);
             do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
             pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n", ...);
          }
        }
        mutex_unlock(&oom_lock);
      }
      // retry allocation due to did_some_progress == 1.
    }

  Thread-2

    __alloc_pages_slowpath() {
      __alloc_pages_may_oom() {
        mutex_trylock(&oom_lock); // fails and returns
      }
      // retry allocation due to did_some_progress == 1.
      warn_alloc() {
        pr_warn(gfp_mask, "page allocation stalls for %ums, order:%u", ...);
      }
    }

Theread-1 was trying to flush printk log buffer by printk() from
oom_kill_process() with oom_lock held. Thread-2 was appending to printk
log buffer by printk() from warn_alloc() because Thread-2 cannot hold
oom_lock held by Thread-1. As a result, this formed an AB-BA livelock.

Although warn_alloc() calls printk() aggressively enough to livelock is
problematic, at least we can say that it is wasteful to spend CPU time for
pointless "direct reclaim and warn_alloc()" calls when waiting for the OOM
killer to send SIGKILL. Therefore, this patch replaces mutex_trylock()
with mutex_lock_killable().

Replacing mutex_trylock() with mutex_lock_killable() should be safe, for
if somebody by error called __alloc_pages_may_oom() with oom_lock held,
it will livelock because did_some_progress will be set to 1 despite
mutex_trylock() failure.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..6c43d8e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3037,12 +3037,16 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
+	 * Give the OOM killer enough CPU time for sending SIGKILL.
+	 * Do not return without a short sleep unless TIF_MEMDIE is set, for
+	 * currently tsk_is_oom_victim(current) == true does not make
+	 * gfp_pfmemalloc_allowed() == true via TIF_MEMDIE until
+	 * mark_oom_victim(current) is called.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
+		if (!test_thread_flag(TIF_MEMDIE))
+			schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
