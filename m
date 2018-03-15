Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E16F6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:47:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g199so4751196qke.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:47:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e63si1403410qkf.275.2018.03.15.09.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 09:47:29 -0700 (PDT)
Date: Thu, 15 Mar 2018 16:46:53 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm] mm, memcg: evaluate root and leaf memcgs fairly on
 oom
Message-ID: <20180315164646.GA1853@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
 <20180314121700.GA20850@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.20.1803141337110.163553@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803141337110.163553@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 14, 2018 at 01:41:03PM -0700, David Rientjes wrote:
> On Wed, 14 Mar 2018, Roman Gushchin wrote:
> 
> > > @@ -2618,92 +2620,65 @@ static long memcg_oom_badness(struct mem_cgroup *memcg,
> > >  		if (nodemask && !node_isset(nid, *nodemask))
> > >  			continue;
> > >  
> > > -		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> > > -				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> > > -
> > >  		pgdat = NODE_DATA(nid);
> > > -		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> > > -					    NR_SLAB_UNRECLAIMABLE);
> > > +		if (is_root_memcg) {
> > > +			points += node_page_state(pgdat, NR_ACTIVE_ANON) +
> > > +				  node_page_state(pgdat, NR_INACTIVE_ANON);
> > > +			points += node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
> > > +		} else {
> > > +			points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> > > +							       LRU_ALL_ANON);
> > > +			points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> > > +						    NR_SLAB_UNRECLAIMABLE);
> > > +		}
> > >  	}
> > >  
> > > -	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> > > -		(PAGE_SIZE / 1024);
> > > -	points += memcg_page_state(memcg, MEMCG_SOCK);
> > > -	points += memcg_page_state(memcg, MEMCG_SWAP);
> > > -
> > > +	if (is_root_memcg) {
> > > +		points += global_zone_page_state(NR_KERNEL_STACK_KB) /
> > > +				(PAGE_SIZE / 1024);
> > > +		points += atomic_long_read(&total_sock_pages);
> >                                             ^^^^^^^^^^^^^^^^
> > BTW, where do we change this counter?
> > 
> 
> Seems like it was dropped from the patch somehow.  It is intended to do 
> atomic_long_add(nr_pages) in mem_cgroup_charge_skmem() and 
> atomic_long_add(-nr_pages) mem_cgroup_uncharge_skmem().
> 
> > I also doubt that global atomic variable can work here,
> > we probably need something better scaling.
> > 
> 
> Why do you think an atomic_long_add() is too expensive when we're already 
> disabling irqs and dong try_charge()?

Hard to say without having full code :)
try_charge() is batched, if you'll batch it too, it will probably work.
