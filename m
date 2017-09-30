Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99A106B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 07:00:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so2969769pfj.4
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 04:00:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r83si4733839pfb.602.2017.09.30.04.00.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 30 Sep 2017 04:00:12 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom message
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
	<201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
	<69a33b7a-afdf-d798-2e03-0c92dd94bfa6@alibaba-inc.com>
	<201709290545.HGH30269.LOVtSHFQOFJFOM@I-love.SAKURA.ne.jp>
	<1a0dd923-7b5c-e1ed-708a-5fdfe8c662dc@alibaba-inc.com>
In-Reply-To: <1a0dd923-7b5c-e1ed-708a-5fdfe8c662dc@alibaba-inc.com>
Message-Id: <201709302000.GGD86407.OOHMJFSFQLFOtV@I-love.SAKURA.ne.jp>
Date: Sat, 30 Sep 2017 20:00:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.s@alibaba-inc.com
Cc: mhocko@kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Yang Shi wrote:
> On 9/28/17 1:45 PM, Tetsuo Handa wrote:
> > Yang Shi wrote:
> >> On 9/28/17 12:57 PM, Tetsuo Handa wrote:
> >>> Yang Shi wrote:
> >>>> On 9/27/17 9:36 PM, Tetsuo Handa wrote:
> >>>>> On 2017/09/28 6:46, Yang Shi wrote:
> >>>>>> Changelog v7 -> v8:
> >>>>>> * Adopted Michal’s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
> >>>>>
> >>>>> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
> >>>>> because there are
> >>>>>
> >>>>> 	mutex_lock(&slab_mutex);
> >>>>> 	kmalloc(GFP_KERNEL);
> >>>>> 	mutex_unlock(&slab_mutex);
> >>>>>
> >>>>> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
> >>>>> introducing a risk of crash (i.e. kernel panic) for regular OOM path?
> >>>>
> >>>> I don't see the difference between regular oom path and oom path other
> >>>> than calling panic() at last.
> >>>>
> >>>> And, the slab dump may be called by panic path too, it is for both
> >>>> regular and panic path.
> >>>
> >>> Calling a function that might cause kerneloops immediately before calling panic()
> >>> would be tolerable, for the kernel will panic after all. But calling a function
> >>> that might cause kerneloops when there is no plan to call panic() is a bug.
> >>
> >> I got your point. slab_mutex is used to protect the list of all the
> >> slabs, since we are already in oom, there should be not kmem cache
> >> destroy happen during the list traverse. And, list_for_each_entry() has
> >> been replaced to list_for_each_entry_safe() to make the traverse more
> >> robust.
> > 
> > I consider that OOM event and kmem chache destroy event can run concurrently
> > because slab_mutex is not held by OOM event (and unfortunately cannot be held
> > due to possibility of deadlock) in order to protect the list of all the slabs.
> > 
> > I don't think replacing list_for_each_entry() with list_for_each_entry_safe()
> > makes the traverse more robust, for list_for_each_entry_safe() does not defer
> > freeing of memory used by list element. Rather, replacing list_for_each_entry()
> > with list_for_each_entry_rcu() (and making relevant changes such as
> > rcu_read_lock()/rcu_read_unlock()/synchronize_rcu()) will make the traverse safe.
> 
> I'm not sure if rcu could satisfy this case. rcu just can protect  
> slab_caches_to_rcu_destroy list, which is used by SLAB_TYPESAFE_BY_RCU  
> slabs.

I'm not sure why you are talking about SLAB_TYPESAFE_BY_RCU.
What I meant is that

  Upon registration:

    // do initialize/setup stuff here
    synchronize_rcu(); // <= for dump_unreclaimable_slab()
    list_add_rcu(&kmem_cache->list, &slab_caches);

  Upon unregistration:

    list_del_rcu(&kmem_cache->list);
    synchronize_rcu(); // <= for dump_unreclaimable_slab()
    // do finalize/cleanup stuff here

then (if my understanding is correct)

	rcu_read_lock();
	list_for_each_entry_rcu(s, &slab_caches, list) {
		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
			continue;

		memset(&sinfo, 0, sizeof(sinfo));
		get_slabinfo(s, &sinfo);

		if (sinfo.num_objs > 0)
			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
				(sinfo.active_objs * s->size) / 1024,
				(sinfo.num_objs * s->size) / 1024);
	}
	rcu_read_unlock();

will make dump_unreclaimable_slab() safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
