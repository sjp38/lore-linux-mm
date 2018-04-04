Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 074836B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:17:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id e15so11486741wrj.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:17:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j5si4677142edc.240.2018.04.04.07.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 07:17:32 -0700 (PDT)
Date: Wed, 4 Apr 2018 10:18:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: Use cgroup_rstat for event accounting
Message-ID: <20180404141850.GC28966@cmpxchg.org>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
 <20180404140855.GA28966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404140855.GA28966@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 04, 2018 at 10:08:55AM -0400, Johannes Weiner wrote:
> On Sat, Mar 24, 2018 at 09:08:59AM -0700, Tejun Heo wrote:
> > @@ -91,6 +91,9 @@ struct mem_cgroup_stat_cpu {
> >  	unsigned long events[MEMCG_NR_EVENTS];
> >  	unsigned long nr_page_events;
> >  	unsigned long targets[MEM_CGROUP_NTARGETS];
> > +
> > +	/* for cgroup rstat delta calculation */
> > +	unsigned long last_events[MEMCG_NR_EVENTS];
> >  };
> >  
> >  struct mem_cgroup_reclaim_iter {
> > @@ -233,7 +236,11 @@ struct mem_cgroup {
> >  
> >  	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
> >  	atomic_long_t		stat[MEMCG_NR_STAT];
> > -	atomic_long_t		events[MEMCG_NR_EVENTS];
> > +
> > +	/* events is managed by cgroup rstat */
> > +	unsigned long long	events[MEMCG_NR_EVENTS];	/* local */
> > +	unsigned long long	tree_events[MEMCG_NR_EVENTS];	/* subtree */
> > +	unsigned long long	pending_events[MEMCG_NR_EVENTS];/* propagation */
> 
> The lazy updates are neat, but I'm a little concerned at the memory
> footprint. On a 64-cpu machine for example, this adds close to 9000
> words to struct mem_cgroup. And we really only need the accuracy for
> the 4 cgroup items in memory.events, not all VM events and stats.
> 
> Why not restrict the patch to those? It would also get rid of the
> weird sharing between VM and cgroup enums.

In fact, I wonder if we need per-cpuness for MEMCG_LOW, MEMCG_HIGH
etc. in the first place. They describe super high-level reclaim and
OOM events, so they're not nearly as hot as other VM events and
stats. We could probably just have a per-memcg array of atomics.
