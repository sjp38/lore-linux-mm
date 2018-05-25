Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E21E16B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 04:31:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63-v6so2505341pfl.12
        for <linux-mm@kvack.org>; Fri, 25 May 2018 01:31:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2-v6si24281697plk.433.2018.05.25.01.31.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 01:31:23 -0700 (PDT)
Date: Fri, 25 May 2018 10:31:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180525083118.GI11881@dhcp22.suse.cz>
References: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
 <20180524115017.GE20441@dhcp22.suse.cz>
 <201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri 25-05-18 10:17:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 24-05-18 19:51:24, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > Look. I am fed up with this discussion. You are fiddling with the code
> > > > and moving hacks around with a lot of hand waving. Rahter than trying to
> > > > look at the underlying problem. Your patch completely ignores PREEMPT as
> > > > I've mentioned in previous versions.
> > > 
> > > I'm not ignoring PREEMPT. To fix this OOM lockup problem properly, as much
> > > efforts as fixing Spectre/Meltdown problems will be required. This patch is
> > > a mitigation for regression introduced by fixing CVE-2018-1000200. Nothing
> > > is good with deferring this patch.
> > > 
> > > > I would be OK with removing the sleep from the out_of_memory path based
> > > > on your argumentation that we have a _proper_ synchronization with the
> > > > exit path now.
> > > 
> > > Such attempt should be made in a separate patch.
> > > 
> > > You suggested removing this sleep from my patch without realizing that
> > > we need explicit schedule_timeout_*() for PF_WQ_WORKER threads.
> > 
> > And that sleep is in should_reclaim_retry. If that is not sufficient it
> > should be addressed rather than spilling more of that crud all over the
> > place.
> 
> Then, please show me (by writing a patch yourself) how to tell whether
> we should sleep there. What I can come up is shown below.
> 
> -@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> -       /* Retry as long as the OOM killer is making progress */
> -       if (did_some_progress) {
> -               no_progress_loops = 0;
> -+              /*
> -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> -+               */
> -+              if (!tsk_is_oom_victim(current))
> -+                      schedule_timeout_uninterruptible(1);
> -               goto retry;
> -       }
> +@@ -3927,6 +3926,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> +               (*no_progress_loops)++;
> 
> +       /*
> ++       * We do a short sleep here if the OOM killer/reaper/victims are
> ++       * holding oom_lock, in order to try to give them some CPU resources
> ++       * for releasing memory.
> ++       */
> ++      if (mutex_is_locked(&oom_lock) && !tsk_is_oom_victim(current))
> ++              schedule_timeout_uninterruptible(1);
> ++
> ++      /*
> +        * Make sure we converge to OOM if we cannot make any progress
> +        * several times in the row.
> +        */
> 
> As far as I know, whether a domain which the current thread belongs to is
> already OOM is not known as of should_reclaim_retry(). Therefore, sleeping
> there can become a pointless delay if the domain which the current thread
> belongs to and the domain which the owner of oom_lock (it can be a random
> thread inside out_of_memory() or exit_mmap()) belongs to differs.
> 
> But you insist sleeping there means that you don't care about such
> pointless delay?

What is wrong with the folliwing? should_reclaim_retry should be a
natural reschedule point. PF_WQ_WORKER is a special case which needs a
stronger rescheduling policy. Doing that unconditionally seems more
straightforward than depending on a zone being a good candidate for a
further reclaim.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c6f4008ea55..b01b19d3d596 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3925,6 +3925,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3988,25 +3989,26 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 				}
 			}
 
-			/*
-			 * Memory allocation/reclaim might be called from a WQ
-			 * context and the current implementation of the WQ
-			 * concurrency control doesn't recognize that
-			 * a particular WQ is congested if the worker thread is
-			 * looping without ever sleeping. Therefore we have to
-			 * do a short sleep here rather than calling
-			 * cond_resched().
-			 */
-			if (current->flags & PF_WQ_WORKER)
-				schedule_timeout_uninterruptible(1);
-			else
-				cond_resched();
-
-			return true;
+			ret = true;
+			goto out;
 		}
 	}
 
-	return false;
+out:
+	/*
+	 * Memory allocation/reclaim might be called from a WQ
+	 * context and the current implementation of the WQ
+	 * concurrency control doesn't recognize that
+	 * a particular WQ is congested if the worker thread is
+	 * looping without ever sleeping. Therefore we have to
+	 * do a short sleep here rather than calling
+	 * cond_resched().
+	 */
+	if (current->flags & PF_WQ_WORKER)
+		schedule_timeout_uninterruptible(1);
+	else
+		cond_resched();
+	return ret;
 }
 
 static inline bool
-- 
Michal Hocko
SUSE Labs
