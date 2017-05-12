Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9368A6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:42:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so13056028wmh.0
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:42:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h52si4109379ede.134.2017.05.12.09.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 09:42:20 -0700 (PDT)
Date: Fri, 12 May 2017 12:42:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
Message-ID: <20170512164206.GA22367@cmpxchg.org>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
 <1494555922.21563.1.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494555922.21563.1.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 12, 2017 at 12:25:22PM +1000, Balbir Singh wrote:
> On Thu, 2017-05-11 at 20:16 +0100, Roman Gushchin wrote:
> > The meaning of each value is the same as for global counters,
> > available using /proc/vmstat.
> > 
> > Also, for consistency, rename mem_cgroup_count_vm_event() to
> > count_memcg_event_mm().
> > 
> 
> I still prefer the mem_cgroup_count_vm_event() name, or memcg_count_vm_event(),
> the namespace upfront makes it easier to parse where to look for the the
> implementation and also grep. In any case the rename should be independent
> patch, but I don't like the name you've proposed.

The memory controller is no longer a tacked-on feature to the VM - the
entire reclaim path is designed around cgroups at this point. The
namespacing is just cumbersome and doesn't add add any value, IMO.

This name is also more consistent with the stats interface, where we
use nodes, zones, memcgs all equally to describe scopes/containers:

inc_node_state(), inc_zone_state(), inc_memcg_state()

> > @@ -357,6 +357,17 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
> >  }
> >  struct mem_cgroup *mem_cgroup_from_id(unsigned short id);
> >  
> > +static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)
> 
> mem_cgroup_from_lruvec()?

This name is consistent with other lruvec accessors such as
lruvec_pgdat() and lruvec_lru_size() etc.

> > @@ -1741,11 +1748,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  
> >  	spin_lock_irq(&pgdat->lru_lock);
> >  
> > -	if (global_reclaim(sc)) {
> > -		if (current_is_kswapd())
> > +	if (current_is_kswapd()) {
> > +		if (global_reclaim(sc))
> >  			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
> > -		else
> > +		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
> > +				   nr_reclaimed);
> 
> Has the else gone missing? What happens if it's global_reclaim(), do
> we still account the count in memcg?
> 
> > +	} else {
> > +		if (global_reclaim(sc))
> >  			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
> > +		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
> > +				   nr_reclaimed);
> 
> It sounds like memcg accumlates both global and memcg reclaim driver
> counts -- is this what we want?

Yes.

Consider a fully containerized system that is using only memory.low
and thus exclusively global reclaim to enforce the partitioning, NOT
artificial limits and limit reclaim. In this case, we still want to
know how much reclaim activity each group is experiencing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
