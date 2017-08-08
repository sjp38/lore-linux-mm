Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29E606B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 22:15:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so21879942pgy.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 19:15:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 198si124112pgg.676.2017.08.07.19.15.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 19:15:07 -0700 (PDT)
Message-Id: <201708080214.v782EoDD084315@www262.sakura.ne.jp>
Subject: Re: Re: [PATCH] =?ISO-2022-JP?B?b29tX3JlYXBlcjogY2xvc2UgcmFjZSB3aXRob3V0?=
 =?ISO-2022-JP?B?IHVzaW5nIG9vbV9sb2Nr?=
From: penguin-kernel@i-love.sakura.ne.jp
MIME-Version: 1.0
Date: Tue, 08 Aug 2017 11:14:50 +0900
References: <201708051002.FGG87553.QtFFFMVJOSOOHL@I-love.SAKURA.ne.jp> <20170807060243.GA32434@dhcp22.suse.cz>
In-Reply-To: <20170807060243.GA32434@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Sun 23-07-17 09:41:50, Tetsuo Handa wrote:
> > > > > > So, how can we verify the above race a real problem?
> > > > > 
> > > > > Try to simulate a _real_ workload and see whether we kill more tasks
> > > > > than necessary. 
> > > > 
> > > > Whether it is a _real_ workload or not cannot become an answer.
> > > > 
> > > > If somebody is trying to allocate hundreds/thousands of pages after memory of
> > > > an OOM victim was reaped, avoiding this race window makes no sense; next OOM
> > > > victim will be selected anyway. But if somebody is trying to allocate only one
> > > > page and then is planning to release a lot of memory, avoiding this race window
> > > > can save somebody from being OOM-killed needlessly. This race window depends on
> > > > what the threads are about to do, not whether the workload is natural or
> > > > artificial.
> > > 
> > > And with a desparate lack of crystal ball we cannot do much about that
> > > really.
> > > 
> > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > by allowing MMF_OOM_SKIP to race.
> > > 
> > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > 
> > Yes, it is really important. Needlessly selecting even one OOM victim is
> > a pain which is difficult to explain to and persuade some of customers.
> 
> How is this any different from a race with a task exiting an releasing
> some memory after we have crossed the point of no return and will kill
> something?

I'm not complaining about an exiting task releasing some memory after we have
crossed the point of no return.

What I'm saying is that we can postpone "the point of no return" if we ignore
MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
once." thread). These are race conditions we can avoid without crystal ball.

I don't like leaving MMF_OOM_SKIP race window open which we can reduce to "an
exiting task releasing some memory after we have crossed the point of no return."
if we ignore MMF_OOM_SKIP for once.

> 
> > > Isn't it sufficient to see that we kill too many tasks and then debug it
> > > further once something hits that?
> > 
> > It is not sufficient.
> > 
> > > 
> > > [...]
> > > > Is it guaranteed that __node_reclaim() never (even indirectly) waits for
> > > > __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation?
> > > 
> > > this is a direct reclaim which can go down to slab shrinkers with all
> > > the usual fun...
> > 
> > Excuse me, but does that mean "Yes, it is" ?
> > 
> > As far as I checked, most shrinkers use non-scheduling operations other than
> > cond_resched(). But some shrinkers use lock_page()/down_write() etc. I worry
> > that such shrinkers might wait for __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> > memory allocation (i.e. "No, it isn't").
> 
> Yes that is possible. Once you are in the shrinker land then you have to
> count with everything. And if you want to imply that
> get_page_from_freelist inside __alloc_pages_may_oom may lockup while
> holding the oom_lock then you might be right but I haven't checked that
> too deeply. It might be very well possible that the node reclaim bails
> out early when we are under OOM.

Yes, I worry that get_page_from_freelist() with oom_lock held might lockup.

If we are about to invoke the OOM killer for the first time, it is likely that
__node_reclaim() finds nothing to reclaim and will bail out immediately. But if
we are about to invoke the OOM killer again, it is possible that small amount of
memory was reclaimed by the OOM killer/reaper, and all reclaimed memory was assigned
to things which __node_reclaim() will find and try to reclaim, and any thread which
took oom_lock will call __node_reclaim() and __node_reclaim() find something
reclaimable if __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation is involved.

We should consider such situation volatile (i.e. should not make assumption that
get_page_from_freelist() with oom_lock held shall bail out immediately) if shrinkers
which (directly or indirectly) involve __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
allocation are permitted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
