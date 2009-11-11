Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C3B3A6B0062
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:02:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB329Tx015848
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 12:02:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CFE9C45DE51
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:02:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4A3B45DE52
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:02:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 54C89EF8002
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:02:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB70D1DB803E
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 12:02:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v3
In-Reply-To: <alpine.DEB.2.00.0911101841480.11083@chino.kir.corp.google.com>
References: <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911101841480.11083@chino.kir.corp.google.com>
Message-Id: <20091111115217.FD56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 12:02:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Index: mm-test-kernel/drivers/char/sysrq.c
> > ===================================================================
> > --- mm-test-kernel.orig/drivers/char/sysrq.c
> > +++ mm-test-kernel/drivers/char/sysrq.c
> > @@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
> >  
> >  static void moom_callback(struct work_struct *ignored)
> >  {
> > -	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
> > +	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
> >  }
> >  
> >  static DECLARE_WORK(moom_work, moom_callback);
> > Index: mm-test-kernel/mm/oom_kill.c
> > ===================================================================
> > --- mm-test-kernel.orig/mm/oom_kill.c
> > +++ mm-test-kernel/mm/oom_kill.c
> > @@ -196,27 +196,45 @@ unsigned long badness(struct task_struct
> >  /*
> >   * Determine the type of allocation constraint.
> >   */
> > +#ifdef CONFIG_NUMA
> >  static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> > -						    gfp_t gfp_mask)
> > +				    gfp_t gfp_mask, nodemask_t *nodemask)
> 
> We should probably remove the inline specifier, there's only one caller 
> currently and if additional ones were added in the future this function 
> should probably not be replicated.

Good catch.


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
> > + 	 * feature. mempolicy is an only user of nodemask here.
> > + 	 */
> > +	if (nodemask) {
> > +		nodemask_t mask;
> > +		/* check mempolicy's nodemask contains all N_HIGH_MEMORY */
> > +		nodes_and(mask, *nodemask, node_states[N_HIGH_MEMORY]);
> > +		if (!nodes_equal(mask, node_states[N_HIGH_MEMORY]))
> > +			return CONSTRAINT_MEMORY_POLICY;
> > +	}
> 
> Although a nodemask_t was previously allocated on the stack, we should 
> probably change this to use NODEMASK_ALLOC() for kernels with higher 
> CONFIG_NODES_SHIFT since allocations can happen very deep into the stack.

No. NODEMASK_ALLOC() is crap. we should remove it. 
btw, CPUMASK_ALLOC was already removed.


> There should be a way around that, however.  Shouldn't
> 
> 	if (nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
> 		return CONSTRAINT_MEMORY_POLICY;
> 
> be sufficient?

Is this safe on memory hotplug case?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
