Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9397F6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 16:41:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 139so2124111pfw.7
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:41:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6sor972577pfe.41.2018.03.14.13.41.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 13:41:05 -0700 (PDT)
Date: Wed, 14 Mar 2018 13:41:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, memcg: evaluate root and leaf memcgs fairly on
 oom
In-Reply-To: <20180314121700.GA20850@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.20.1803141337110.163553@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com> <20180314121700.GA20850@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Mar 2018, Roman Gushchin wrote:

> > @@ -2618,92 +2620,65 @@ static long memcg_oom_badness(struct mem_cgroup *memcg,
> >  		if (nodemask && !node_isset(nid, *nodemask))
> >  			continue;
> >  
> > -		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> > -				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> > -
> >  		pgdat = NODE_DATA(nid);
> > -		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> > -					    NR_SLAB_UNRECLAIMABLE);
> > +		if (is_root_memcg) {
> > +			points += node_page_state(pgdat, NR_ACTIVE_ANON) +
> > +				  node_page_state(pgdat, NR_INACTIVE_ANON);
> > +			points += node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
> > +		} else {
> > +			points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> > +							       LRU_ALL_ANON);
> > +			points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> > +						    NR_SLAB_UNRECLAIMABLE);
> > +		}
> >  	}
> >  
> > -	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> > -		(PAGE_SIZE / 1024);
> > -	points += memcg_page_state(memcg, MEMCG_SOCK);
> > -	points += memcg_page_state(memcg, MEMCG_SWAP);
> > -
> > +	if (is_root_memcg) {
> > +		points += global_zone_page_state(NR_KERNEL_STACK_KB) /
> > +				(PAGE_SIZE / 1024);
> > +		points += atomic_long_read(&total_sock_pages);
>                                             ^^^^^^^^^^^^^^^^
> BTW, where do we change this counter?
> 

Seems like it was dropped from the patch somehow.  It is intended to do 
atomic_long_add(nr_pages) in mem_cgroup_charge_skmem() and 
atomic_long_add(-nr_pages) mem_cgroup_uncharge_skmem().

> I also doubt that global atomic variable can work here,
> we probably need something better scaling.
> 

Why do you think an atomic_long_add() is too expensive when we're already 
disabling irqs and dong try_charge()?
