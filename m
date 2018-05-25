Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6BED6B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 06:57:45 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u137-v6so4222236itc.4
        for <linux-mm@kvack.org>; Fri, 25 May 2018 03:57:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g187-v6si6465167itd.128.2018.05.25.03.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 03:57:44 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
	<20180524115017.GE20441@dhcp22.suse.cz>
	<201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
	<20180525083118.GI11881@dhcp22.suse.cz>
In-Reply-To: <20180525083118.GI11881@dhcp22.suse.cz>
Message-Id: <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
Date: Fri, 25 May 2018 19:57:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 25-05-18 10:17:42, Tetsuo Handa wrote:
> > Then, please show me (by writing a patch yourself) how to tell whether
> > we should sleep there. What I can come up is shown below.
> > 
> > -@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > -       /* Retry as long as the OOM killer is making progress */
> > -       if (did_some_progress) {
> > -               no_progress_loops = 0;
> > -+              /*
> > -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> > -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > -+               */
> > -+              if (!tsk_is_oom_victim(current))
> > -+                      schedule_timeout_uninterruptible(1);
> > -               goto retry;
> > -       }
> > +@@ -3927,6 +3926,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > +               (*no_progress_loops)++;
> > 
> > +       /*
> > ++       * We do a short sleep here if the OOM killer/reaper/victims are
> > ++       * holding oom_lock, in order to try to give them some CPU resources
> > ++       * for releasing memory.
> > ++       */
> > ++      if (mutex_is_locked(&oom_lock) && !tsk_is_oom_victim(current))
> > ++              schedule_timeout_uninterruptible(1);
> > ++
> > ++      /*
> > +        * Make sure we converge to OOM if we cannot make any progress
> > +        * several times in the row.
> > +        */
> > 
> > As far as I know, whether a domain which the current thread belongs to is
> > already OOM is not known as of should_reclaim_retry(). Therefore, sleeping
> > there can become a pointless delay if the domain which the current thread
> > belongs to and the domain which the owner of oom_lock (it can be a random
> > thread inside out_of_memory() or exit_mmap()) belongs to differs.
> > 
> > But you insist sleeping there means that you don't care about such
> > pointless delay?
> 
> What is wrong with the folliwing? should_reclaim_retry should be a
> natural reschedule point. PF_WQ_WORKER is a special case which needs a
> stronger rescheduling policy. Doing that unconditionally seems more
> straightforward than depending on a zone being a good candidate for a
> further reclaim.

Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?
My concern is that cond_resched() might be a too short sleep to give
enough CPU resources to the owner of the oom_lock.

#ifndef CONFIG_PREEMPT
extern int _cond_resched(void);
#else
static inline int _cond_resched(void) { return 0; }
#endif

#ifndef CONFIG_PREEMPT
int __sched _cond_resched(void)
{
	if (should_resched(0)) {
		preempt_schedule_common();
		return 1;
	}
	rcu_all_qs();
	return 0;
}
EXPORT_SYMBOL(_cond_resched);
#endif

#define cond_resched() ({                       \
        ___might_sleep(__FILE__, __LINE__, 0);  \
        _cond_resched();                        \
})

How do you prove that cond_resched() is an appropriate replacement for
schedule_timeout_killable(1) in out_of_memory() and
schedule_timeout_uninterruptible(1) in __alloc_pages_may_oom() ?
