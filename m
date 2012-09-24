Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 683516B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 13:56:24 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so380070pbb.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:56:23 -0700 (PDT)
Date: Mon, 24 Sep 2012 10:56:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
Message-ID: <20120924175619.GD7694@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-7-git-send-email-glommer@parallels.com>
 <20120921183217.GH7264@google.com>
 <50601DEB.10705@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50601DEB.10705@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Mon, Sep 24, 2012 at 12:46:35PM +0400, Glauber Costa wrote:
> >> +#ifdef CONFIG_MEMCG_KMEM
> >> +	/* Slab accounting */
> >> +	struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
> >> +#endif
> > 
> > Bah, 400 entry array in struct mem_cgroup.  Can't we do something a
> > bit more flexible?
> > 
> 
> I guess. I still would like it to be an array, so we can easily access
> its fields. There are two ways around this:
> 
> 1) Do like the events mechanism and allocate this in a separate
> structure. Add a pointer chase in the access, and I don't think it helps
> much because it gets allocated anyway. But we could at least
> defer it to the time when we limit the cache.

Start at some reasonable size and then double it as usage grows?  How
many kmem_caches do we typically end up using?

> >> +	if (memcg->slabs[idx] == NULL) {
> >> +		memcg_create_cache_enqueue(memcg, cachep);
> > 
> > Do we want to wait for the work item if @gfp allows?
> > 
> 
> I tried this once, and it got complicated enough that I deemed as "not
> worth it". I honestly don't remember much of the details now, it was one
> of the first things I tried, and a bunch of time has passed. If you
> think it is absolutely worth it, I can try it again. But at the very
> best, I view this as an optimization.

I don't know.  It seems like a logical thing to try and depends on how
complex it gets.  I don't think it's a must.  The whole thing is
somewhat opportunistic after all.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
