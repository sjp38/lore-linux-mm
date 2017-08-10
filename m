Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 753286B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:34:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 92so666491wra.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:34:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si4673541wmi.205.2017.08.10.04.34.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 04:34:02 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:34:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170810113400.GO23863@dhcp22.suse.cz>
References: <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp>
 <20170807060243.GA32434@dhcp22.suse.cz>
 <201708080214.v782EoDD084315@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708080214.v782EoDD084315@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penguin-kernel@i-love.sakura.ne.jp
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Tue 08-08-17 11:14:50, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > > > > > > So, how can we verify the above race a real problem?
> > > > > > 
> > > > > > Try to simulate a _real_ workload and see whether we kill more tasks
> > > > > > than necessary. 
> > > > > 
> > > > > Whether it is a _real_ workload or not cannot become an answer.
> > > > > 
> > > > > If somebody is trying to allocate hundreds/thousands of pages after memory of
> > > > > an OOM victim was reaped, avoiding this race window makes no sense; next OOM
> > > > > victim will be selected anyway. But if somebody is trying to allocate only one
> > > > > page and then is planning to release a lot of memory, avoiding this race window
> > > > > can save somebody from being OOM-killed needlessly. This race window depends on
> > > > > what the threads are about to do, not whether the workload is natural or
> > > > > artificial.
> > > > 
> > > > And with a desparate lack of crystal ball we cannot do much about that
> > > > really.
> > > > 
> > > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > > by allowing MMF_OOM_SKIP to race.
> > > > 
> > > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > > 
> > > Yes, it is really important. Needlessly selecting even one OOM victim is
> > > a pain which is difficult to explain to and persuade some of customers.
> > 
> > How is this any different from a race with a task exiting an releasing
> > some memory after we have crossed the point of no return and will kill
> > something?
> 
> I'm not complaining about an exiting task releasing some memory after we have
> crossed the point of no return.
> 
> What I'm saying is that we can postpone "the point of no return" if we ignore
> MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
> thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
> once." thread). These are race conditions we can avoid without crystal ball.

If those races are really that common than we can handle them even
without "try once more" tricks. Really this is just an ugly hack. If you
really care then make sure that we always try to allocate from memory
reserves before going down the oom path. In other words, try to find a
robust solution rather than tweaks around a problem.

[...]
> > Yes that is possible. Once you are in the shrinker land then you have to
> > count with everything. And if you want to imply that
> > get_page_from_freelist inside __alloc_pages_may_oom may lockup while
> > holding the oom_lock then you might be right but I haven't checked that
> > too deeply. It might be very well possible that the node reclaim bails
> > out early when we are under OOM.
> 
> Yes, I worry that get_page_from_freelist() with oom_lock held might lockup.
> 
> If we are about to invoke the OOM killer for the first time, it is likely that
> __node_reclaim() finds nothing to reclaim and will bail out immediately. But if
> we are about to invoke the OOM killer again, it is possible that small amount of
> memory was reclaimed by the OOM killer/reaper, and all reclaimed memory was assigned
> to things which __node_reclaim() will find and try to reclaim, and any thread which
> took oom_lock will call __node_reclaim() and __node_reclaim() find something
> reclaimable if __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation is involved.
> 
> We should consider such situation volatile (i.e. should not make assumption that
> get_page_from_freelist() with oom_lock held shall bail out immediately) if shrinkers
> which (directly or indirectly) involve __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> allocation are permitted.

Well, I think you are so focused on details that you most probably miss
a large picture here. Just think about the purpose of the node reclaim.
It is there to _prefer_ local allocations than go to a distant NUMA
node. So rather than speculating about details maybe it makes sense to
consider whether it actually makes any sense to even try to node reclaim
when we are OOM. In other words why to do an additional reclaim when we
just found out that all reclaim attempts have failed...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
