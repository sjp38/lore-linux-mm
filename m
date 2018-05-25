Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4BB16B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 07:42:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i11-v6so3959475wre.16
        for <linux-mm@kvack.org>; Fri, 25 May 2018 04:42:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24-v6si2162609edc.97.2018.05.25.04.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 04:42:16 -0700 (PDT)
Date: Fri, 25 May 2018 13:42:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180525114213.GJ11881@dhcp22.suse.cz>
References: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
 <20180524115017.GE20441@dhcp22.suse.cz>
 <201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
 <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri 25-05-18 19:57:32, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 25-05-18 10:17:42, Tetsuo Handa wrote:
> > > Then, please show me (by writing a patch yourself) how to tell whether
> > > we should sleep there. What I can come up is shown below.
> > > 
> > > -@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > -       /* Retry as long as the OOM killer is making progress */
> > > -       if (did_some_progress) {
> > > -               no_progress_loops = 0;
> > > -+              /*
> > > -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> > > -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > > -+               */
> > > -+              if (!tsk_is_oom_victim(current))
> > > -+                      schedule_timeout_uninterruptible(1);
> > > -               goto retry;
> > > -       }
> > > +@@ -3927,6 +3926,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > +               (*no_progress_loops)++;
> > > 
> > > +       /*
> > > ++       * We do a short sleep here if the OOM killer/reaper/victims are
> > > ++       * holding oom_lock, in order to try to give them some CPU resources
> > > ++       * for releasing memory.
> > > ++       */
> > > ++      if (mutex_is_locked(&oom_lock) && !tsk_is_oom_victim(current))
> > > ++              schedule_timeout_uninterruptible(1);
> > > ++
> > > ++      /*
> > > +        * Make sure we converge to OOM if we cannot make any progress
> > > +        * several times in the row.
> > > +        */
> > > 
> > > As far as I know, whether a domain which the current thread belongs to is
> > > already OOM is not known as of should_reclaim_retry(). Therefore, sleeping
> > > there can become a pointless delay if the domain which the current thread
> > > belongs to and the domain which the owner of oom_lock (it can be a random
> > > thread inside out_of_memory() or exit_mmap()) belongs to differs.
> > > 
> > > But you insist sleeping there means that you don't care about such
> > > pointless delay?
> > 
> > What is wrong with the folliwing? should_reclaim_retry should be a
> > natural reschedule point. PF_WQ_WORKER is a special case which needs a
> > stronger rescheduling policy. Doing that unconditionally seems more
> > straightforward than depending on a zone being a good candidate for a
> > further reclaim.
> 
> Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?

Re-read what I've said.
-- 
Michal Hocko
SUSE Labs
