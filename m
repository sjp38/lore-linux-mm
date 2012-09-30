Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0B5F56B006C
	for <linux-mm@kvack.org>; Sun, 30 Sep 2012 04:24:08 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so3934254pad.14
        for <linux-mm@kvack.org>; Sun, 30 Sep 2012 01:24:08 -0700 (PDT)
Date: Sun, 30 Sep 2012 17:23:58 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120930082358.GG10383@mtj.dyndns.org>
References: <50635B9D.8020205@parallels.com>
 <20120926195648.GA20342@google.com>
 <50635F46.7000700@parallels.com>
 <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
 <20120927120806.GA29104@dhcp22.suse.cz>
 <20120927143300.GA4251@mtj.dyndns.org>
 <20120927144307.GH3429@suse.de>
 <20120927145802.GC4251@mtj.dyndns.org>
 <50649B4C.8000208@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50649B4C.8000208@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Thu, Sep 27, 2012 at 10:30:36PM +0400, Glauber Costa wrote:
> > But that happens only when pages enter and leave slab and if it still
> > is significant, we can try to further optimize charging.  Given that
> > this is only for cases where memcg is already in use and we provide a
> > switch to disable it globally, I really don't think this warrants
> > implementing fully hierarchy configuration.
> 
> Not totally true. We still have to match every allocation to the right
> cache, and that is actually our heaviest hit, responsible for the 2, 3 %
> we're seeing when this is enabled. It is the kind of path so hot that
> people frown upon branches being added, so I don't think we'll ever get
> this close to being free.

Sure, depening on workload, any addition to alloc/free could be
noticeable.  I don't know.  I'll write more about it when replying to
Michal's message.  BTW, __memcg_kmem_get_cache() does seem a bit
heavy.  I wonder whether indexing from cache side would make it
cheaper?  e.g. something like the following.

	kmem_cache *__memcg_kmem_get_cache(cachep, gfp)
	{
		struct kmem_cache *c;

		c = cachep->memcg_params->caches[percpu_read(kmemcg_slab_idx)];
		if (likely(c))
			return c;
		/* try to create and then fall back to cachep */
	}

where kmemcg_slab_idx is updated from sched notifier (or maybe add and
use current->kmemcg_slab_idx?).  You would still need __GFP_* and
in_interrupt() tests but current->mm and PF_KTHREAD tests can be
rolled into index selection.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
