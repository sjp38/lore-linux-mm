Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1006C440860
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:23:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s102so15717149ioe.14
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:23:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k77si2226962itb.115.2017.07.12.05.23.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 05:23:26 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170710141428.GL19185@dhcp22.suse.cz>
	<201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
	<20170711134900.GD11936@dhcp22.suse.cz>
	<201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
	<20170712085431.GD28912@dhcp22.suse.cz>
In-Reply-To: <20170712085431.GD28912@dhcp22.suse.cz>
Message-Id: <201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
Date: Wed, 12 Jul 2017 21:23:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> On Wed 12-07-17 07:06:11, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 11-07-17 22:10:36, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> [...]
> > > > > warn_alloc is just yet-another-user of printk. We might have many
> > > > > others...
> > > >
> > > > warn_alloc() is different from other users of printk() that printk() is called
> > > > as long as oom_lock is already held by somebody else processing console_unlock().
> > >
> > > So what exactly prevents any other caller of printk interfering while
> > > the oom is ongoing?
> >
> > Other callers of printk() are not doing silly things like "while(1) printk();".
>
> They can still print a lot. There have been reports of one printk source
> pushing an unrelated context to print way too much.

Which source is that?

Legitimate printk() users might do

  for (i = 0; i < 1000; i++)
    printk();

but they do not do

  while (1)
    for (i = 0; i < 1000; i++)
      printk();

.

>
> > They don't call printk() until something completes (e.g. some operation returned
> > an error code) or they do throttling. Only watchdog calls printk() without waiting
> > for something to complete (because watchdog is there in order to warn that something
> > might be wrong). But watchdog is calling printk() carefully not to cause flooding
> > (e.g. khungtaskd sleeps enough) and not to cause lockups (e.g. khungtaskd calls
> > rcu_lock_break()).
>
> Look at hard/soft lockup detector and how it can cause flood of printks.

Lockup detector is legitimate because it is there to warn that somebody is
continuously consuming CPU time. Lockup detector might do

  for (i = 0; i < 1000; i++)
    printk();

but does not do

  while (1)
    for (i = 0; i < 1000; i++)
      printk();

because lockup detector waits for enough interval.

  while (1) {
    for (i = 0; i < 1000; i++)
      printk();
    schedule_timeout_killable(HZ * 60);
  }

>
> > As far as I can observe, only warn_alloc() for watchdog trivially
> > causes flooding and lockups.
>
> warn_alloc prints a single line + dump_stack for each stalling allocation and
> show_mem once per second. That doesn't sound overly crazy to me.
> Sure we can have many stalling tasks under certain conditions (most of
> them quite unrealistic) and then we can print a lot. I do not see an
> easy way out of it without losing information about stalls and I guess
> we want to know about them otherwise we will have much harder time to
> debug stalls.

Printing just one line per every second can lead to lockup, for
the condition to escape the "for (;;)" loop in console_unlock() is

                if (console_seq == log_next_seq)
                        break;

when cond_resched() in that loop slept for more than one second due to
SCHED_IDLE priority.

Currently preempt_disable()/preempt_enable_no_resched() (or equivalent)
is the only available countermeasure for minimizing interference like

    for (i = 0; i < 1000; i++)
      printk();

. If prink() allows per printk context (shown below) flag which allows printk()
users to force printk() not to try to print immediately (i.e. declare that
use deferred printing (maybe offloaded to the printk-kthread)), lockups by
cond_resched() from console_unlock() from printk() from out_of_memory() will be
avoided.

----------
static unsigned long printk_context(void)
{
    /*
     * Assume that we can use lower 2 bits for flags, as with
     * __mutex_owner() does.
     */
    unsigned long context = (unsigned long) current;

    /* Both bits set means processing NMI context. */
    if (in_nmi())
        context |= 3;
    /* Only next-LSB set means processing hard IRQ context. */
    else if (in_irq())
        context |= 2;
    /* Only LSB set means processing soft IRQ context. */
    else if (in_serving_softirq())
        context |= 1;
    /*
     * Neither bits set means processing task context,
     * though still might be non sleepable context.
     */
    return context;
}
----------

Of course given that such flag is introduced and you accept setting/clearing
such flag inside out_of_memory()...

>
> Sure we can tune this a bit and e.g. do not dump stacks of tasks which
> have already printed their backtrace as it couldn't have changed.  But
> this doesn't change anything in principle.
>
> [...]
> > > > The OOM killer is not permitted to wait for __GFP_DIRECT_RECLAIM allocations
> > > > directly/indirectly (because it will cause recursion deadlock). Thus, even if
> > > > some code path needs to sleep for some reason, that code path is not permitted to
> > > > wait for __GFP_DIRECT_RECLAIM allocations directly/indirectly. Anyway, I can
> > > > propose scattering preempt_disable()/preempt_enable_no_resched() around printk()
> > > > rather than whole oom_kill_process(). You will just reject it as you have rejected
> > > > in the past.
> > >
> > > because you are trying to address a problem at a wrong layer. If there
> > > is absolutely no way around it and printk is unfixable then we really
> > > need a printk variant which will make sure that no excessive waiting
> > > will be involved. Then we can replace all printk in the oom path with
> > > this special printk.
> >
> > Writing data faster than readers can read is wrong, especially when
> > writers deprive readers of CPU time to read.
>
> Yes this is not good but only printk knows the congestion.

warn_alloc() callers can wait for oom_lock, for somebody which is holding
oom_lock should be making progress for warn_alloc() callers.

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */

What I'm pointing out is that this comment becomes false if there are
multiple threads doing the same thing.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..5cd845a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3259,11 +3259,21 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
     *did_some_progress = 0;
 
     /*
-     * Acquire the oom lock.  If that fails, somebody else is
-     * making progress for us.
+     * Acquire the oom lock. If that fails, retry after giving the owner of
+     * the oom lock a chance to make progress, by taking a short sleep.
+     * But when retrying, skip direct reclaim/compaction in order to give
+     * the owner of the oom lock as much CPU time as possible, for the
+     * owner of the oom lock might be a SCHED_IDLE priority thread.
+     * When 10+ !SCHED_IDLE priority threads do direct reclaim/compaction
+     * on a CPU which the owner of the oom lock (a SCHED_IDLE priority
+     * thread) can run, it is possible that all CPU time yielded by the
+     * short sleep is wasted for direct reclaim/compaction and the owner of
+     * the oom lock fails to make progress for 60+ seconds due to lack of
+     * CPU time (i.e. falls into an OOM livelock situation where the OOM
+     * killer cannot send SIGKILL).
      */
     if (!mutex_trylock(&oom_lock)) {
-        *did_some_progress = 1;
+        *did_some_progress = -1;
         schedule_timeout_uninterruptible(1);
         return NULL;
     }
@@ -3770,6 +3780,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
     unsigned long alloc_start = jiffies;
     unsigned int stall_timeout = 10 * HZ;
     unsigned int cpuset_mems_cookie;
+    bool skip_direct_reclaim = false;
 
     /*
      * In the slowpath, we sanity check order to avoid ever trying to
@@ -3906,6 +3917,9 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
         stall_timeout += 10 * HZ;
     }
 
+    if (skip_direct_reclaim)
+        goto wait_for_oom_killer;
+
     /* Avoid recursion of direct reclaim */
     if (current->flags & PF_MEMALLOC)
         goto nopage;
@@ -3955,6 +3969,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
         goto retry_cpuset;
 
     /* Reclaim has failed us, start killing things */
+wait_for_oom_killer:
     page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
     if (page)
         goto got_pg;
@@ -3968,6 +3983,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
     /* Retry as long as the OOM killer is making progress */
     if (did_some_progress) {
         no_progress_loops = 0;
+        skip_direct_reclaim = did_some_progress == -1;
         goto retry;
     }
 
----------

>
> [...]
> > > As I've said out_of_memory is an expensive operation and as such it has
> > > to be preemptible. Addressing this would require quite some work.
> >
> > But calling out_of_memory() with SCHED_IDLE priority makes overall allocations
> > far more expensive. If you want to keep out_of_memory() preemptible, you should
> > make sure that out_of_memory() is executed with !SCHED_IDLE priority. Offloading to
> > a dedicated kernel thread like oom_reaper will do it.
>
> You do realize that the whole page allocator is not priority aware and
> a low priority task can starve a higher priority task already in the
> reclaim path. Is this ideal? Absolutely no but let's be realistic, this
> has never been a priority and it would require a lot of heavy lifting.

Then why do you complain

  No, seriously! Just think about what you are proposing. You are stalling
  and now you will stall _random_ tasks even more.

? We cannot make the whole page allocator priority aware within a few years.
Then, avoiding possibility of lockups for now makes sense until you fix it.

> The OOM is the most cold path in the whole allocation stack and focusing
> solely on it while claiming something take a minute or two longer is
> just not going to attract a lot of attention.

Who said that "a minute or two"? We can make the stalls effectively "forever", for
delay caused by

  while (1)
    cond_resched();

interference in __alloc_pages_slowpath() (this is what I demonstrated by
disabling warn_alloc()) gets longer as number of threads doing that busy loop
increases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
