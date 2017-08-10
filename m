Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4249D6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:10:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so5136005pge.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:10:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a2si4381660plt.8.2017.08.10.05.10.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 05:10:47 -0700 (PDT)
Subject: Re: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp>
	<20170807060243.GA32434@dhcp22.suse.cz>
	<201708080214.v782EoDD084315@www262.sakura.ne.jp>
	<20170810113400.GO23863@dhcp22.suse.cz>
In-Reply-To: <20170810113400.GO23863@dhcp22.suse.cz>
Message-Id: <201708102110.CAB48416.JSMFVHLOtOOFFQ@I-love.SAKURA.ne.jp>
Date: Thu, 10 Aug 2017 21:10:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 08-08-17 11:14:50, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > > > by allowing MMF_OOM_SKIP to race.
> > > > > 
> > > > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > > > 
> > > > Yes, it is really important. Needlessly selecting even one OOM victim is
> > > > a pain which is difficult to explain to and persuade some of customers.
> > > 
> > > How is this any different from a race with a task exiting an releasing
> > > some memory after we have crossed the point of no return and will kill
> > > something?
> > 
> > I'm not complaining about an exiting task releasing some memory after we have
> > crossed the point of no return.
> > 
> > What I'm saying is that we can postpone "the point of no return" if we ignore
> > MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
> > thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
> > once." thread). These are race conditions we can avoid without crystal ball.
> 
> If those races are really that common than we can handle them even
> without "try once more" tricks. Really this is just an ugly hack. If you
> really care then make sure that we always try to allocate from memory
> reserves before going down the oom path. In other words, try to find a
> robust solution rather than tweaks around a problem.

Since your "mm, oom: allow oom reaper to race with exit_mmap" patch removes
oom_lock serialization from the OOM reaper, possibility of calling out_of_memory()
due to successful mutex_trylock(&oom_lock) would increase when the OOM reaper set
MMF_OOM_SKIP quickly.

What if task_is_oom_victim(current) became true and MMF_OOM_SKIP was set
on current->mm between after __gfp_pfmemalloc_flags() returned 0 and before
out_of_memory() is called (due to successful mutex_trylock(&oom_lock)) ?

Excuse me? Are you suggesting to try memory reserves before
task_is_oom_victim(current) becomes true?

> 
> [...]
> > > Yes that is possible. Once you are in the shrinker land then you have to
> > > count with everything. And if you want to imply that
> > > get_page_from_freelist inside __alloc_pages_may_oom may lockup while
> > > holding the oom_lock then you might be right but I haven't checked that
> > > too deeply. It might be very well possible that the node reclaim bails
> > > out early when we are under OOM.
> > 
> > Yes, I worry that get_page_from_freelist() with oom_lock held might lockup.
> > 
> > If we are about to invoke the OOM killer for the first time, it is likely that
> > __node_reclaim() finds nothing to reclaim and will bail out immediately. But if
> > we are about to invoke the OOM killer again, it is possible that small amount of
> > memory was reclaimed by the OOM killer/reaper, and all reclaimed memory was assigned
> > to things which __node_reclaim() will find and try to reclaim, and any thread which
> > took oom_lock will call __node_reclaim() and __node_reclaim() find something
> > reclaimable if __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation is involved.
> > 
> > We should consider such situation volatile (i.e. should not make assumption that
> > get_page_from_freelist() with oom_lock held shall bail out immediately) if shrinkers
> > which (directly or indirectly) involve __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> > allocation are permitted.
> 
> Well, I think you are so focused on details that you most probably miss
> a large picture here. Just think about the purpose of the node reclaim.
> It is there to _prefer_ local allocations than go to a distant NUMA
> node. So rather than speculating about details maybe it makes sense to
> consider whether it actually makes any sense to even try to node reclaim
> when we are OOM. In other words why to do an additional reclaim when we
> just found out that all reclaim attempts have failed...

Below is what I will propose if there is possibility of lockup.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index be5bd60..718b2e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3271,9 +3271,11 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure.
+	 * we're still under heavy pressure. But make sure that this reclaim
+	 * attempt shall not involve __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
+	 * allocation which will never fail due to oom_lock already held.
 	 */
-	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
+	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) & ~__GFP_DIRECT_RECLAIM, order,
 					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
