Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 391036B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 01:26:32 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id nAB6QR81003674
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 06:26:27 GMT
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by wpaz1.hot.corp.google.com with ESMTP id nAB6QOIH016397
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:26:24 -0800
Received: by pxi10 with SMTP id 10so615095pxi.33
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:26:23 -0800 (PST)
Date: Tue, 10 Nov 2009 22:26:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.1
In-Reply-To: <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
 <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com> <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:

> > > Index: mm-test-kernel/mm/oom_kill.c
> > > ===================================================================
> > > --- mm-test-kernel.orig/mm/oom_kill.c
> > > +++ mm-test-kernel/mm/oom_kill.c
> > > @@ -196,27 +196,47 @@ unsigned long badness(struct task_struct
> > >  /*
> > >   * Determine the type of allocation constraint.
> > >   */
> > > -static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> > > -						    gfp_t gfp_mask)
> > > -{
> > >  #ifdef CONFIG_NUMA
> > > +static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> > > +				    gfp_t gfp_mask, nodemask_t *nodemask)
> > > +{
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
> > > -			return CONSTRAINT_CPUSET;
> > > +	/*
> > > +	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
> > > + 	 * to kill current.We have to random task kill in this case.
> > > + 	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
> > > + 	 */
> > > +	if (gfp_mask & __GPF_THISNODE)
> > > +		return ret;
> > >  
> > 
> > That shouldn't compile.
> > 
> Why ?
> 

Even when I pointed it out, you still didn't bother to try compiling it?  
You need s/GPF/GFP, it stands for "get free pages."

You can also eliminate the ret variable, it's not doing anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
