Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 278B36B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:34:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f19-v6so14576987plr.23
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:34:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t192si3868277pgb.595.2018.04.04.07.34.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 07:34:50 -0700 (PDT)
Date: Wed, 4 Apr 2018 16:34:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: Use cgroup_rstat for event accounting
Message-ID: <20180404143447.GJ6312@dhcp22.suse.cz>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
 <20180404140855.GA28966@cmpxchg.org>
 <20180404141850.GC28966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404141850.GC28966@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed 04-04-18 10:18:50, Johannes Weiner wrote:
> On Wed, Apr 04, 2018 at 10:08:55AM -0400, Johannes Weiner wrote:
> > On Sat, Mar 24, 2018 at 09:08:59AM -0700, Tejun Heo wrote:
> > > @@ -91,6 +91,9 @@ struct mem_cgroup_stat_cpu {
> > >  	unsigned long events[MEMCG_NR_EVENTS];
> > >  	unsigned long nr_page_events;
> > >  	unsigned long targets[MEM_CGROUP_NTARGETS];
> > > +
> > > +	/* for cgroup rstat delta calculation */
> > > +	unsigned long last_events[MEMCG_NR_EVENTS];
> > >  };
> > >  
> > >  struct mem_cgroup_reclaim_iter {
> > > @@ -233,7 +236,11 @@ struct mem_cgroup {
> > >  
> > >  	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
> > >  	atomic_long_t		stat[MEMCG_NR_STAT];
> > > -	atomic_long_t		events[MEMCG_NR_EVENTS];
> > > +
> > > +	/* events is managed by cgroup rstat */
> > > +	unsigned long long	events[MEMCG_NR_EVENTS];	/* local */
> > > +	unsigned long long	tree_events[MEMCG_NR_EVENTS];	/* subtree */
> > > +	unsigned long long	pending_events[MEMCG_NR_EVENTS];/* propagation */
> > 
> > The lazy updates are neat, but I'm a little concerned at the memory
> > footprint. On a 64-cpu machine for example, this adds close to 9000
> > words to struct mem_cgroup. And we really only need the accuracy for
> > the 4 cgroup items in memory.events, not all VM events and stats.
> > 
> > Why not restrict the patch to those? It would also get rid of the
> > weird sharing between VM and cgroup enums.
> 
> In fact, I wonder if we need per-cpuness for MEMCG_LOW, MEMCG_HIGH
> etc. in the first place. They describe super high-level reclaim and
> OOM events, so they're not nearly as hot as other VM events and
> stats. We could probably just have a per-memcg array of atomics.

Agreed!

-- 
Michal Hocko
SUSE Labs
