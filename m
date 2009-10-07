Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A77996B005D
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 16:09:46 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n97K9bhv023444
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 21:09:37 +0100
Received: from pxi27 (pxi27.prod.google.com [10.243.27.27])
	by wpaz13.hot.corp.google.com with ESMTP id n97K9Y5h028557
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 13:09:34 -0700
Received: by pxi27 with SMTP id 27so4944761pxi.22
        for <linux-mm@kvack.org>; Wed, 07 Oct 2009 13:09:33 -0700 (PDT)
Date: Wed, 7 Oct 2009 13:09:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/11] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <1254933058.4483.223.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910071254290.1928@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031802.22576.46384.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910062002440.3099@chino.kir.corp.google.com>
 <1254933058.4483.223.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 7 Oct 2009, Lee Schermerhorn wrote:

> > > Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> > > ===================================================================
> > > --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
> > > +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-02 21:22:04.000000000 -0400
> > > @@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
> > >  	return NULL;
> > >  }
> > >  
> > > -static ssize_t nr_hugepages_show(struct kobject *kobj,
> > > +static ssize_t nr_hugepages_show_common(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > >  	struct hstate *h = kobj_to_hstate(kobj);
> > >  	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> > >  }
> > > -static ssize_t nr_hugepages_store(struct kobject *kobj,
> > > -		struct kobj_attribute *attr, const char *buf, size_t count)
> > > +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> > > +			struct kobject *kobj, struct kobj_attribute *attr,
> > > +			const char *buf, size_t len)
> > >  {
> > >  	int err;
> > > -	unsigned long input;
> > > +	unsigned long count;
> > >  	struct hstate *h = kobj_to_hstate(kobj);
> > > +	NODEMASK_ALLOC(nodemask, nodes_allowed);
> > >  
> > 
> > In the two places you do NODEMASK_ALLOC(), here and 
> > hugetlb_sysctl_handler(), you'll need to check that nodes_allowed is 
> > non-NULL since it's possible that kmalloc() will return NULL for 
> > CONFIG_NODES_SHIFT > 8.
> > 
> > In such a case, it's probably sufficient to simply set nodes_allowed to 
> > node_states[N_HIGH_MEMORY] so that we can still free hugepages when we're 
> > oom, a common memory freeing tactic.
> > 
> > You could do that by simply returning false from 
> > init_nodemask_of_mempolicy() if !nodes_allowed since NODEMASK_FREE() can 
> > take a NULL pointer, but it may be easier to factor that logic into your 
> > conditional below:
> > 
> > > -	err = strict_strtoul(buf, 10, &input);
> > > +	err = strict_strtoul(buf, 10, &count);
> > >  	if (err)
> > >  		return 0;
> > >  
> > > -	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
> > > +	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
> > > +		NODEMASK_FREE(nodes_allowed);
> > > +		nodes_allowed = &node_online_map;
> > > +	}
> > > +	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
> > >
> > 
> > You can get away with just testing !nodes_allowed here since the stack 
> > allocation variation of NODEMASK_ALLOC() is such that nodes_allowed will 
> > always be an initialized pointer pointing to _nodes_allowed so you won't 
> > have an uninitialized warning.
> > 
> > Once that's done, you can get rid of the check for a NULL nodes_allowed in 
> > try_to_free_low() from patch 2 since it will always be valid in 
> > set_max_huge_pages().
> 
> 
> OK.  already removed the NULL check from try_to_free_low().  And I made
> the change to init_nodemask_of_mempolicy to return false on NULL mask.
> 
> I'm not completely happy with dropping back to default behavior
> [node_online_map here, replaced with node_states[N_HIGH_MEMORY] in
> subsequent patch] on failure to allocate nodes_allowed.  We only do the
> NODEMASK_ALLOC when we've come in from either nr_hugepages_mempolicy or
> a per node attribute [subsequent patch], so I'm not sure that ignoring
> the mempolicy, if any, or the specified node id, is a good thing here.
> Not silently, at least.  I haven't addressed this, yet.  We can submit
> an incremental patch.  Thoughts?
> 

Hmm, it's debatable since the NODEMASK_ALLOC() slab allocation is 
GFP_KERNEL which would cause direct reclaim (and perhaps even the oom 
killer) to free memory.  If the oom killer were invoked, current would 
probably even be killed because of how the oom killer works for 
CONSTRAINT_MEMORY_POLICY.  So the end result is that the pages would 
eventually be freed because current would get access to memory reserves 
via TIF_MEMDIE but would die immediately after returning.  It was nice of 
current to sacrifice itself like that.

Unfortunately, I think the long term solution is that NODEMASK_ALLOC() is 
going to require a gfp parameter to pass to kmalloc() and in this case we 
should union __GFP_NORETRY.  Then, if nodes_allowed can't be allocated I 
think it would be better to simply return -ENOMEM to userspace so it can 
either reduce the number of global hugepages or free memory in another 
way.  (There might be a caveat where the user's mempolicy already includes 
all online nodes and they use nr_hugepages_mempolicy where they couldn't 
free hugepages because of -ENOMEM but could via nr_hugepages, but I don't 
think you need to address that.)

The worst case allocation is probably 512 bytes for CONFIG_NODES_SHIFT of 
12 so I don't think using __GFP_NORETRY here is going to be that 
ridiculous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
