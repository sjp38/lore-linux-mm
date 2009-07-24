Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6A626B008C
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 19:10:19 -0400 (EDT)
Date: Fri, 24 Jul 2009 16:09:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090724160936.a3b8ad29.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<1247679064.4089.26.camel@useless.americas.hpqcorp.net>
	<alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
	<alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Jul 2009 15:51:51 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 16 Jul 2009, David Rientjes wrote:
> 
> > numactl --interleave=all simply passes a nodemask with all bits set, so if 
> > cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
> > then mpol_set_nodemask() doesn't mask them off.
> > 
> > Seems like we could handle this strictly in mempolicies without worrying 
> > about top_cpuset like in the following?
> > ---
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -194,6 +194,7 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
> >  static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
> >  {
> >  	nodemask_t cpuset_context_nmask;
> > +	nodemask_t mems_allowed;
> >  	int ret;
> >  
> >  	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
> > @@ -201,20 +202,21 @@ static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
> >  		return 0;
> >  
> >  	VM_BUG_ON(!nodes);
> > +	nodes_and(mems_allowed, cpuset_current_mems_allowed,
> > +				node_states[N_HIGH_MEMORY]);
> >  	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
> >  		nodes = NULL;	/* explicit local allocation */
> >  	else {
> >  		if (pol->flags & MPOL_F_RELATIVE_NODES)
> >  			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
> > -					       &cpuset_current_mems_allowed);
> > +					       &mems_allowed);
> >  		else
> >  			nodes_and(cpuset_context_nmask, *nodes,
> > -				  cpuset_current_mems_allowed);
> > +				  mems_allowed);
> >  		if (mpol_store_user_nodemask(pol))
> >  			pol->w.user_nodemask = *nodes;
> >  		else
> > -			pol->w.cpuset_mems_allowed =
> > -						cpuset_current_mems_allowed;
> > +			pol->w.cpuset_mems_allowed = mems_allowed;
> >  	}
> >  
> >  	ret = mpol_ops[pol->mode].create(pol,
> > 
> 
> Should this patch be added to 2.6.31-rc4 to prevent the kernel panic while 
> hotplug notifiers are being added to mempolicies?

afaik we don't have a final patch for this.  I asked Motohiro-san about
this and he's proposing that we revert the offending change (which one
was it?) if nothing gets fixed soon - the original author is on a
lengthy vacation.


If we _do_ have a patch then can we start again?  Someone send out the patch
and let's take a look at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
