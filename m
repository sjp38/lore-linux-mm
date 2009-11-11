Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C20C26B007E
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:23:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB3Njsl015874
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 12:23:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8435E45DE55
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:23:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D46945DE57
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:23:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3972E38004
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:23:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9674EE3800B
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:23:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v3
In-Reply-To: <alpine.DEB.2.00.0911101908180.14549@chino.kir.corp.google.com>
References: <20091111115217.FD56.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911101908180.14549@chino.kir.corp.google.com>
Message-Id: <20091111121958.FD59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 12:23:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:
> 
> > > >  {
> > > > -#ifdef CONFIG_NUMA
> > > >  	struct zone *zone;
> > > >  	struct zoneref *z;
> > > >  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > > > -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> > > > +	int ret = CONSTRAINT_NONE;
> > > >  
> > > > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > > > -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> > > > -			node_clear(zone_to_nid(zone), nodes);
> > > > -		else
> > > > +	/*
> > > > + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> > > > + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> > > > + 	 * feature. mempolicy is an only user of nodemask here.
> > > > + 	 */
> > > > +	if (nodemask) {
> > > > +		nodemask_t mask;
> > > > +		/* check mempolicy's nodemask contains all N_HIGH_MEMORY */
> > > > +		nodes_and(mask, *nodemask, node_states[N_HIGH_MEMORY]);
> > > > +		if (!nodes_equal(mask, node_states[N_HIGH_MEMORY]))
> > > > +			return CONSTRAINT_MEMORY_POLICY;
> > > > +	}
> > > 
> > > Although a nodemask_t was previously allocated on the stack, we should 
> > > probably change this to use NODEMASK_ALLOC() for kernels with higher 
> > > CONFIG_NODES_SHIFT since allocations can happen very deep into the stack.
> > 
> > No. NODEMASK_ALLOC() is crap. we should remove it. 
> 
> I've booted 1K node systems and have found it to be helpful to ensure that 
> the stack will not overflow especially in areas where we normally are deep 
> already, such as in the page allocator.

Linux doesn't support 1K nodes. (and only SGI huge machine use 512 nodes)

At least, NODEMASK_ALLOC should make more cleaner interface. current one
and struct nodemask_scratch are pretty ugly.


> > btw, CPUMASK_ALLOC was already removed.
> 
> I don't remember CPUMASK_ALLOC() actually being merged.  I know the 
> comment exists in nodemask.h, but I don't recall any CPUMASK_ALLOC() users 
> in the tree.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
