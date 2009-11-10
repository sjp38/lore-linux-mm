Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CBA6C6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 02:27:35 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA7RXvl006037
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Nov 2009 16:27:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 333FD45DE51
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:27:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 11FF545DE4F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:27:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E790A1DB8038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:27:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9184E1DB803C
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:27:29 +0900 (JST)
Date: Tue, 10 Nov 2009 16:24:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v2
Message-Id: <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091110162121.361B.A69D9226@jp.fujitsu.com>
References: <20091104170944.cef988c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20091106090202.dc2472b3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110162121.361B.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009 16:24:22 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
> > +++ mmotm-2.6.32-Nov2/mm/oom_kill.c
> > @@ -196,27 +196,40 @@ unsigned long badness(struct task_struct
> >  /*
> >   * Determine the type of allocation constraint.
> >   */
> > +#ifdef CONFIG_NUMA
> >  static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> > -						    gfp_t gfp_mask)
> > +				    gfp_t gfp_mask, nodemask_t *nodemask)
> >  {
> > -#ifdef CONFIG_NUMA
> >  	struct zone *zone;
> >  	struct zoneref *z;
> >  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> > +	int ret = CONSTRAINT_NONE;
> >  
> > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> > -			node_clear(zone_to_nid(zone), nodes);
> > -		else
> > +	/*
> > + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> > + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> > + 	 * feature. Then, only mempolicy use this nodemask.
> > + 	 */
> > +	if (nodemask && nodes_equal(*nodemask, node_states[N_HIGH_MEMORY]))
> > +		ret = CONSTRAINT_MEMORY_POLICY;
> 
> !nodes_equal() ?
> 
yes. will fix.

> 
> > +
> > +	/* Check this allocation failure is caused by cpuset's wall function */
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > +			high_zoneidx, nodemask)
> > +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> >  			return CONSTRAINT_CPUSET;
> 
> If cpuset and MPOL_BIND are both used, Probably CONSTRAINT_MEMORY_POLICY is
> better choice.
> 

No. this memory allocation is failed by limitation of cpuset's alloc mask.
Not from mempolicy.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
