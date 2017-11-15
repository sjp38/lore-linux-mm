Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD716B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:51:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 4so12450854wrt.8
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:51:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si2990029edc.14.2017.11.15.03.51.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 03:51:45 -0800 (PST)
Date: Wed, 15 Nov 2017 12:51:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171115115143.yh4xl43w3iteqh35@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
 <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-11-17 19:58:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 14-11-17 06:37:42, Tetsuo Handa wrote:
> > > When shrinker_rwsem was introduced, it was assumed that
> > > register_shrinker()/unregister_shrinker() are really unlikely paths
> > > which are called during initialization and tear down. But nowadays,
> > > register_shrinker()/unregister_shrinker() might be called regularly.
> > 
> > Please provide some examples. I know your other patch mentions the
> > usecase but I guess the two patches should be just squashed together.
> 
> They were squashed together in a draft version at
> http://lkml.kernel.org/r/2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp .
> Since Shakeel suggested me to post the patch for others to review without
> parallel register/unregister and SHRINKER_PERMANENT, but I thought that
> parallel register/unregister is still helpful (described below), I posted
> as two patches.
> 
> > 
> > > This patch prepares for allowing parallel registration/unregistration
> > > of shrinkers.
> > > 
> > > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > > do_shrink_slab() call will not impact so much.
> > > 
> > > This patch uses polling loop with short sleep for unregister_shrinker()
> > > rather than wait_on_atomic_t(), for we can save reader's cost (plain
> > > atomic_dec() compared to atomic_dec_and_test()), we can expect that
> > > do_shrink_slab() of unregistering shrinker likely returns shortly, and
> > > we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> > > shrinker unexpectedly took so long.
> > 
> > I would use wait_event_interruptible in the remove path rather than the
> > short sleep loop which is just too ugly. The shrinker walk would then
> > just wake_up the sleeper when the ref. count drops to 0. Two
> > synchronize_rcu is quite ugly as well, but I was not able to simplify
> > them. I will keep thinking. It just sucks how we cannot follow the
> > standard rcu list with dynamically allocated structure pattern here.
> 
> I think that Minchan's approach depends on how
> 
>   In our production, we have observed that the job loader gets stuck for
>   10s of seconds while doing mount operation. It turns out that it was
>   stuck in register_shrinker() and some unrelated job was under memory
>   pressure and spending time in shrink_slab(). Our machines have a lot
>   of shrinkers registered and jobs under memory pressure has to traverse
>   all of those memcg-aware shrinkers and do affect unrelated jobs which
>   want to register their own shrinkers.
> 
> is interpreted. If there were 100000 shrinkers and each do_shrink_slab() call
> took 1 millisecond, aborting the iteration as soon as rwsem_is_contended() would
> help a lot. But if there were 10 shrinkers and each do_shrink_slab() call took
> 10 seconds, aborting the iteration as soon as rwsem_is_contended() would help
> less. Or, there might be some specific shrinker where its do_shrink_slab() call
> takes 100 seconds. In that case, checking rwsem_is_contended() is too lazy.

I hope we do not have any shrinker to each that much time. They are not
supposed to... But the reality screws our intentions quite often so I
cannot really tell nobody is doing crazy stuff. Anyway, I think starting
simpler make sense here. We will see later.

> Since it is possible for a local unpriviledged user to lockup the system at least
> due to mute_trylock(&oom_lock) versus (printk() or schedule_timeout_killable(1)),
> I suggest completely eliminating scheduling priority problem (i.e. a very low
> scheduling priority thread might take 100 seconds inside some do_shrink_slab()
> call) by not relying on an assumption of shortly returning from do_shrink_slab().
> My first patch + my second patch will eliminate relying on such assumption, and
> avoid potential khungtaskd warnings.

It doesn't, because the priority issues will be still there when anybody
can preempt your shrinker for extensive amount of time. So no you are
not fixing the problem. You are merely make it less probable and limited
only to the removed shrinker. You still do not have any control over
what happens while that shrinker is executed, though.

Anyway, I do not claim your patch is a wrong approach. It is just quite
complex and maybe unnecessarily so for most workloads. Therefore going
with a simpler solution should be preferred until we see it
insufficient.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
