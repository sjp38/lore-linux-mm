Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4426B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 15:40:51 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n7RJeo6v004623
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 20:40:50 +0100
Received: from wa-out-1112.google.com (wafj32.prod.google.com [10.114.186.32])
	by wpaz33.hot.corp.google.com with ESMTP id n7RJelqt013440
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:40:47 -0700
Received: by wa-out-1112.google.com with SMTP id j32so303549waf.29
        for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:40:47 -0700 (PDT)
Date: Thu, 27 Aug 2009 12:40:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <1251233347.16229.0.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0908271236190.14815@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192752.10317.96125.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0908250126280.23660@chino.kir.corp.google.com>
 <1251233347.16229.0.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Lee Schermerhorn wrote:

> > > Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c
> > > ===================================================================
> > > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/hugetlb.c	2009-08-24 12:12:50.000000000 -0400
> > > +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c	2009-08-24 12:12:53.000000000 -0400
> > > @@ -1257,10 +1257,13 @@ static int adjust_pool_surplus(struct hs
> > >  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> > >  {
> > >  	unsigned long min_count, ret;
> > > +	nodemask_t *nodes_allowed;
> > >  
> > >  	if (h->order >= MAX_ORDER)
> > >  		return h->max_huge_pages;
> > >  
> > 
> > Why can't you simply do this?
> > 
> > 	struct mempolicy *pol = NULL;
> > 	nodemask_t *nodes_allowed = &node_online_map;
> > 
> > 	local_irq_disable();
> > 	pol = current->mempolicy;
> > 	mpol_get(pol);
> > 	local_irq_enable();
> > 	if (pol) {
> > 		switch (pol->mode) {
> > 		case MPOL_BIND:
> > 		case MPOL_INTERLEAVE:
> > 			nodes_allowed = pol->v.nodes;
> > 			break;
> > 		case MPOL_PREFERRED:
> > 			... use NODEMASK_SCRATCH() ...
> > 		default:
> > 			BUG();
> > 		}
> > 	}
> > 	mpol_put(pol);
> > 
> > and then use nodes_allowed throughout set_max_huge_pages()?
> 
> 
> Well, I do use nodes_allowed [pointer] throughout set_max_huge_pages().

Yeah, the above code would all be in set_max_huge_pages() and 
huge_mpol_nodes_allowed() would be removed.

> NODEMASK_SCRATCH() didn't exist when I wrote this, and I can't be sure
> it will return a kmalloc()'d nodemask, which I need because a NULL
> nodemask pointer means "all online nodes" [really all nodes with memory,
> I suppose] and I need a pointer to kmalloc()'d nodemask to return from
> huge_mpol_nodes_allowed().  I want to keep the access to the internals
> of mempolicy in mempolicy.[ch], thus the call out to
> huge_mpol_nodes_allowed(), instead of open coding it.

Ok, so you could add a mempolicy.c helper function that returns
nodemask_t * and either points to mpol->v.nodes for most cases after 
getting a reference on mpol with mpol_get() or points to a dynamically 
allocated NODEMASK_ALLOC() on a nodemask created for MPOL_PREFERRED.

This works nicely because either way you still have a reference to mpol, 
so you'll need to call into a mpol_nodemask_free() function which can use 
the same switch statement:

	void mpol_nodemask_free(struct mempolicy *mpol,
				struct nodemask_t *nodes_allowed)
	{
		switch (mpol->mode) {
		case MPOL_PREFERRED:
			kfree(nodes_allowed);
			break;
		default:
			break;
		}
		mpol_put(mpol);
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
