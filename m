Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D695E6B0269
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 21:52:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 2so62685088pfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:52:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z8si11493249pac.112.2016.09.28.18.52.22
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 18:52:23 -0700 (PDT)
Date: Thu, 29 Sep 2016 11:00:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160929020050.GD29250@js1304-P5Q-DELUXE>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <20160928020347.GA21129@cmpxchg.org>
 <20160928080953.GA20312@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928080953.GA20312@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, dsmythies@telus.net, linux-mm@kvack.org

On Wed, Sep 28, 2016 at 11:09:53AM +0300, Vladimir Davydov wrote:
> On Tue, Sep 27, 2016 at 10:03:47PM -0400, Johannes Weiner wrote:
> > [CC Vladimir]
> > 
> > These are the delayed memcg cache allocations, where in a fresh memcg
> > that doesn't have per-memcg caches yet, every accounted allocation
> > schedules a kmalloc work item in __memcg_schedule_kmem_cache_create()
> > until the cache is finally available. It looks like those can be many
> > more than the number of slab caches in existence, if there is a storm
> > of slab allocations before the workers get a chance to run.
> > 
> > Vladimir, what do you think of embedding the work item into the
> > memcg_cache_array? That way we make sure we have exactly one work per
> > cache and not an unbounded number of them. The downside of course is
> > that we'd have to keep these things around as long as the memcg is in
> > existence, but that's the only place I can think of that allows us to
> > serialize this.
> 
> We could set the entry of the root_cache->memcg_params.memcg_caches
> array corresponding to the cache being created to a special value, say
> (void*)1, and skip scheduling cache creation work on kmalloc if the
> caller sees it. I'm not sure it's really worth it though, because
> work_struct isn't that big (at least, in comparison with the cache
> itself) to avoid embedding it at all costs.

Hello, Johannes and Vladimir.

I'm not familiar with memcg so have a question about this solution.
This solution will solve the current issue but if burst memcg creation
happens, similar issue would happen again. My understanding is correct?

I think that the other cause of the problem is that we call
synchronize_sched() which is rather slow with holding a slab_mutex and
it blocks further kmem_cache creation. Should we fix that, too?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
