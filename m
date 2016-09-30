Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF4A6B0069
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 15:58:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m80so38267463lfi.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 12:58:39 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id n125si511500lfd.278.2016.09.30.12.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 12:58:37 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id s64so6442432lfs.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 12:58:37 -0700 (PDT)
Date: Fri, 30 Sep 2016 22:58:33 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160930195833.GC20312@esperanza>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <20160928020347.GA21129@cmpxchg.org>
 <20160928080953.GA20312@esperanza>
 <20160929020050.GD29250@js1304-P5Q-DELUXE>
 <20160929134550.GB20312@esperanza>
 <20160930081940.GA3606@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160930081940.GA3606@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, dsmythies@telus.net, linux-mm@kvack.org

On Fri, Sep 30, 2016 at 05:19:41PM +0900, Joonsoo Kim wrote:
> On Thu, Sep 29, 2016 at 04:45:50PM +0300, Vladimir Davydov wrote:
> > On Thu, Sep 29, 2016 at 11:00:50AM +0900, Joonsoo Kim wrote:
> > > On Wed, Sep 28, 2016 at 11:09:53AM +0300, Vladimir Davydov wrote:
> > > > On Tue, Sep 27, 2016 at 10:03:47PM -0400, Johannes Weiner wrote:
> > > > > [CC Vladimir]
> > > > > 
> > > > > These are the delayed memcg cache allocations, where in a fresh memcg
> > > > > that doesn't have per-memcg caches yet, every accounted allocation
> > > > > schedules a kmalloc work item in __memcg_schedule_kmem_cache_create()
> > > > > until the cache is finally available. It looks like those can be many
> > > > > more than the number of slab caches in existence, if there is a storm
> > > > > of slab allocations before the workers get a chance to run.
> > > > > 
> > > > > Vladimir, what do you think of embedding the work item into the
> > > > > memcg_cache_array? That way we make sure we have exactly one work per
> > > > > cache and not an unbounded number of them. The downside of course is
> > > > > that we'd have to keep these things around as long as the memcg is in
> > > > > existence, but that's the only place I can think of that allows us to
> > > > > serialize this.
> > > > 
> > > > We could set the entry of the root_cache->memcg_params.memcg_caches
> > > > array corresponding to the cache being created to a special value, say
> > > > (void*)1, and skip scheduling cache creation work on kmalloc if the
> > > > caller sees it. I'm not sure it's really worth it though, because
> > > > work_struct isn't that big (at least, in comparison with the cache
> > > > itself) to avoid embedding it at all costs.
> > > 
> > > Hello, Johannes and Vladimir.
> > > 
> > > I'm not familiar with memcg so have a question about this solution.
> > > This solution will solve the current issue but if burst memcg creation
> > > happens, similar issue would happen again. My understanding is correct?
> > 
> > Yes, I think you're right - embedding the work_struct responsible for
> > cache creation in kmem_cache struct won't help if a thousand of
> > different cgroups call kmem_cache_alloc() simultaneously for a cache
> > they haven't used yet.
> > 
> > Come to think of it, we could fix the issue by simply introducing a
> > special single-threaded workqueue used exclusively for cache creation
> > works - cache creation is done mostly under the slab_mutex, anyway. This
> > way, we wouldn't have to keep those used-once work_structs for the whole
> > kmem_cache life time.
> > 
> > > 
> > > I think that the other cause of the problem is that we call
> > > synchronize_sched() which is rather slow with holding a slab_mutex and
> > > it blocks further kmem_cache creation. Should we fix that, too?
> > 
> > Well, the patch you posted looks pretty obvious and it helps the
> > reporter, so personally I don't see any reason for not applying it.
> 
> Oops... I forgot to mention why I asked that.
> 
> There is another report that similar problem also happens in SLUB. In there,
> synchronize_sched() is called in cache shrinking path with holding the
> slab_mutex. I guess that it blocks further kmem_cache creation.
> 
> If we uses special single-threaded workqueue, number of kworker would
> be limited but kmem_cache creation will be delayed for a long time in
> burst memcg creation/destroy scenario.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=172991
> 
> Do we need to remove synchronize_sched() in SLUB and find other
> solution?

Yeah, you're right. We'd better do something about this
synchronize_sched(). I think moving it out of the slab_mutex and calling
it once for all caches in memcg_deactivate_kmem_caches() would resolve
the issue. I'll post the patches tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
