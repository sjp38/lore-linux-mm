Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35E5B28025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 04:09:58 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so32839286lfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:09:58 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id i132si3166833lfd.367.2016.09.28.01.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 01:09:56 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s29so2909676lfg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:09:56 -0700 (PDT)
Date: Wed, 28 Sep 2016 11:09:53 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160928080953.GA20312@esperanza>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <20160928020347.GA21129@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928020347.GA21129@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, bugzilla-daemon@bugzilla.kernel.org, dsmythies@telus.net, linux-mm@kvack.org

On Tue, Sep 27, 2016 at 10:03:47PM -0400, Johannes Weiner wrote:
> [CC Vladimir]
> 
> These are the delayed memcg cache allocations, where in a fresh memcg
> that doesn't have per-memcg caches yet, every accounted allocation
> schedules a kmalloc work item in __memcg_schedule_kmem_cache_create()
> until the cache is finally available. It looks like those can be many
> more than the number of slab caches in existence, if there is a storm
> of slab allocations before the workers get a chance to run.
> 
> Vladimir, what do you think of embedding the work item into the
> memcg_cache_array? That way we make sure we have exactly one work per
> cache and not an unbounded number of them. The downside of course is
> that we'd have to keep these things around as long as the memcg is in
> existence, but that's the only place I can think of that allows us to
> serialize this.

We could set the entry of the root_cache->memcg_params.memcg_caches
array corresponding to the cache being created to a special value, say
(void*)1, and skip scheduling cache creation work on kmalloc if the
caller sees it. I'm not sure it's really worth it though, because
work_struct isn't that big (at least, in comparison with the cache
itself) to avoid embedding it at all costs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
