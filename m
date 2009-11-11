Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD106B0088
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:14:35 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id nAB3EWtG022969
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 19:14:32 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by spaceape10.eur.corp.google.com with ESMTP id nAB3ESxN004426
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 19:14:29 -0800
Received: by pzk2 with SMTP id 2so471930pzk.26
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 19:14:28 -0800 (PST)
Date: Tue, 10 Nov 2009 19:14:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v3
In-Reply-To: <20091111115217.FD56.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911101908180.14549@chino.kir.corp.google.com>
References: <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911101841480.11083@chino.kir.corp.google.com> <20091111115217.FD56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:

> > >  {
> > > -#ifdef CONFIG_NUMA
> > >  	struct zone *zone;
> > >  	struct zoneref *z;
> > >  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > > -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> > > +	int ret = CONSTRAINT_NONE;
> > >  
> > > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > > -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> > > -			node_clear(zone_to_nid(zone), nodes);
> > > -		else
> > > +	/*
> > > + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> > > + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> > > + 	 * feature. mempolicy is an only user of nodemask here.
> > > + 	 */
> > > +	if (nodemask) {
> > > +		nodemask_t mask;
> > > +		/* check mempolicy's nodemask contains all N_HIGH_MEMORY */
> > > +		nodes_and(mask, *nodemask, node_states[N_HIGH_MEMORY]);
> > > +		if (!nodes_equal(mask, node_states[N_HIGH_MEMORY]))
> > > +			return CONSTRAINT_MEMORY_POLICY;
> > > +	}
> > 
> > Although a nodemask_t was previously allocated on the stack, we should 
> > probably change this to use NODEMASK_ALLOC() for kernels with higher 
> > CONFIG_NODES_SHIFT since allocations can happen very deep into the stack.
> 
> No. NODEMASK_ALLOC() is crap. we should remove it. 

I've booted 1K node systems and have found it to be helpful to ensure that 
the stack will not overflow especially in areas where we normally are deep 
already, such as in the page allocator.

> btw, CPUMASK_ALLOC was already removed.

I don't remember CPUMASK_ALLOC() actually being merged.  I know the 
comment exists in nodemask.h, but I don't recall any CPUMASK_ALLOC() users 
in the tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
