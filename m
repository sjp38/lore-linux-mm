Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 650876B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:58:26 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id e142so5677249oih.5
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 02:58:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 38si4625035otx.463.2017.11.15.02.58.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 02:58:24 -0800 (PST)
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
In-Reply-To: <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
Message-Id: <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
Date: Wed, 15 Nov 2017 19:58:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 14-11-17 06:37:42, Tetsuo Handa wrote:
> > When shrinker_rwsem was introduced, it was assumed that
> > register_shrinker()/unregister_shrinker() are really unlikely paths
> > which are called during initialization and tear down. But nowadays,
> > register_shrinker()/unregister_shrinker() might be called regularly.
> 
> Please provide some examples. I know your other patch mentions the
> usecase but I guess the two patches should be just squashed together.

They were squashed together in a draft version at
http://lkml.kernel.org/r/2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp .
Since Shakeel suggested me to post the patch for others to review without
parallel register/unregister and SHRINKER_PERMANENT, but I thought that
parallel register/unregister is still helpful (described below), I posted
as two patches.

> 
> > This patch prepares for allowing parallel registration/unregistration
> > of shrinkers.
> > 
> > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > do_shrink_slab() call will not impact so much.
> > 
> > This patch uses polling loop with short sleep for unregister_shrinker()
> > rather than wait_on_atomic_t(), for we can save reader's cost (plain
> > atomic_dec() compared to atomic_dec_and_test()), we can expect that
> > do_shrink_slab() of unregistering shrinker likely returns shortly, and
> > we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> > shrinker unexpectedly took so long.
> 
> I would use wait_event_interruptible in the remove path rather than the
> short sleep loop which is just too ugly. The shrinker walk would then
> just wake_up the sleeper when the ref. count drops to 0. Two
> synchronize_rcu is quite ugly as well, but I was not able to simplify
> them. I will keep thinking. It just sucks how we cannot follow the
> standard rcu list with dynamically allocated structure pattern here.

I think that Minchan's approach depends on how

  In our production, we have observed that the job loader gets stuck for
  10s of seconds while doing mount operation. It turns out that it was
  stuck in register_shrinker() and some unrelated job was under memory
  pressure and spending time in shrink_slab(). Our machines have a lot
  of shrinkers registered and jobs under memory pressure has to traverse
  all of those memcg-aware shrinkers and do affect unrelated jobs which
  want to register their own shrinkers.

is interpreted. If there were 100000 shrinkers and each do_shrink_slab() call
took 1 millisecond, aborting the iteration as soon as rwsem_is_contended() would
help a lot. But if there were 10 shrinkers and each do_shrink_slab() call took
10 seconds, aborting the iteration as soon as rwsem_is_contended() would help
less. Or, there might be some specific shrinker where its do_shrink_slab() call
takes 100 seconds. In that case, checking rwsem_is_contended() is too lazy.

Since it is possible for a local unpriviledged user to lockup the system at least
due to mute_trylock(&oom_lock) versus (printk() or schedule_timeout_killable(1)),
I suggest completely eliminating scheduling priority problem (i.e. a very low
scheduling priority thread might take 100 seconds inside some do_shrink_slab()
call) by not relying on an assumption of shortly returning from do_shrink_slab().
My first patch + my second patch will eliminate relying on such assumption, and
avoid potential khungtaskd warnings.

>  
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  include/linux/shrinker.h |  3 ++-
> >  mm/vmscan.c              | 41 +++++++++++++++++++----------------------
> >  2 files changed, 21 insertions(+), 23 deletions(-)
> > 
> > diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> > index 388ff29..333a1d0 100644
> > --- a/include/linux/shrinker.h
> > +++ b/include/linux/shrinker.h
> > @@ -62,9 +62,10 @@ struct shrinker {
> >  
> >  	int seeks;	/* seeks to recreate an obj */
> >  	long batch;	/* reclaim batch size, 0 = default */
> > -	unsigned long flags;
> > +	unsigned int flags;
> 
> Why?

In Shakeel's first version, it tried to keep structure size intact on
x86_64 architecture. Actually currently only two flags are defined.

> 
> >  
> >  	/* These are for internal use */
> > +	atomic_t nr_active;
> >  	struct list_head list;
> >  	/* objs pending delete, per node */
> >  	atomic_long_t *nr_deferred;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 1c1bc95..c8996e8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -157,7 +157,7 @@ struct scan_control {
> >  unsigned long vm_total_pages;
> >  
> >  static LIST_HEAD(shrinker_list);
> > -static DECLARE_RWSEM(shrinker_rwsem);
> > +static DEFINE_MUTEX(shrinker_lock);
> >  
> >  #ifdef CONFIG_MEMCG
> >  static bool global_reclaim(struct scan_control *sc)
> > @@ -285,9 +285,10 @@ int register_shrinker(struct shrinker *shrinker)
> >  	if (!shrinker->nr_deferred)
> >  		return -ENOMEM;
> >  
> > -	down_write(&shrinker_rwsem);
> > -	list_add_tail(&shrinker->list, &shrinker_list);
> > -	up_write(&shrinker_rwsem);
> > +	atomic_set(&shrinker->nr_active, 0);
> 
> I would expect ref counter to be 1 and either remove path dec it down to
> 0 or the racing walker would. In any case that is when
> unregister_shrinker can continue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
