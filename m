Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 480566B027F
	for <linux-mm@kvack.org>; Thu, 24 May 2018 21:18:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c82-v6so3037642itg.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 18:18:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e31-v6si21210577ioi.41.2018.05.24.18.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 18:18:05 -0700 (PDT)
Message-Id: <201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
Subject: Re: [PATCH] mm,oom: Don't call =?ISO-2022-JP?B?c2NoZWR1bGVfdGltZW91dF9r?=
 =?ISO-2022-JP?B?aWxsYWJsZSgpIHdpdGggb29tX2xvY2sgaGVsZC4=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 25 May 2018 10:17:42 +0900
References: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp> <20180524115017.GE20441@dhcp22.suse.cz>
In-Reply-To: <20180524115017.GE20441@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Thu 24-05-18 19:51:24, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Look. I am fed up with this discussion. You are fiddling with the code
> > > and moving hacks around with a lot of hand waving. Rahter than trying to
> > > look at the underlying problem. Your patch completely ignores PREEMPT as
> > > I've mentioned in previous versions.
> > 
> > I'm not ignoring PREEMPT. To fix this OOM lockup problem properly, as much
> > efforts as fixing Spectre/Meltdown problems will be required. This patch is
> > a mitigation for regression introduced by fixing CVE-2018-1000200. Nothing
> > is good with deferring this patch.
> > 
> > > I would be OK with removing the sleep from the out_of_memory path based
> > > on your argumentation that we have a _proper_ synchronization with the
> > > exit path now.
> > 
> > Such attempt should be made in a separate patch.
> > 
> > You suggested removing this sleep from my patch without realizing that
> > we need explicit schedule_timeout_*() for PF_WQ_WORKER threads.
> 
> And that sleep is in should_reclaim_retry. If that is not sufficient it
> should be addressed rather than spilling more of that crud all over the
> place.

Then, please show me (by writing a patch yourself) how to tell whether
we should sleep there. What I can come up is shown below.

-@@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
-       /* Retry as long as the OOM killer is making progress */
-       if (did_some_progress) {
-               no_progress_loops = 0;
-+              /*
-+               * This schedule_timeout_*() serves as a guaranteed sleep for
-+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
-+               */
-+              if (!tsk_is_oom_victim(current))
-+                      schedule_timeout_uninterruptible(1);
-               goto retry;
-       }
+@@ -3927,6 +3926,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+               (*no_progress_loops)++;

+       /*
++       * We do a short sleep here if the OOM killer/reaper/victims are
++       * holding oom_lock, in order to try to give them some CPU resources
++       * for releasing memory.
++       */
++      if (mutex_is_locked(&oom_lock) && !tsk_is_oom_victim(current))
++              schedule_timeout_uninterruptible(1);
++
++      /*
+        * Make sure we converge to OOM if we cannot make any progress
+        * several times in the row.
+        */

As far as I know, whether a domain which the current thread belongs to is
already OOM is not known as of should_reclaim_retry(). Therefore, sleeping
there can become a pointless delay if the domain which the current thread
belongs to and the domain which the owner of oom_lock (it can be a random
thread inside out_of_memory() or exit_mmap()) belongs to differs.

But you insist sleeping there means that you don't care about such
pointless delay?
