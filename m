Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B88196B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 12:31:04 -0400 (EDT)
Subject: Re: [PATCH 4/11] hugetlb:  derive huge pages nodes allowed from
 task mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0910062002440.3099@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
	 <20091006031802.22576.46384.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0910062002440.3099@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 07 Oct 2009 12:30:58 -0400
Message-Id: <1254933058.4483.223.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-06 at 20:26 -0700, David Rientjes wrote:
> On Mon, 5 Oct 2009, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/mm/mempolicy.c	2009-09-30 12:48:45.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c	2009-09-30 12:48:46.000000000 -0400
> > @@ -1564,6 +1564,53 @@ struct zonelist *huge_zonelist(struct vm
> >  	}
> >  	return zl;
> >  }
> > +
> > +/*
> > + * init_nodemask_of_mempolicy
> > + *
> > + * If the current task's mempolicy is "default" [NULL], return 'false'
> > + * to indicate * default policy.  Otherwise, extract the policy nodemask
> > + * for 'bind' * or 'interleave' policy into the argument nodemask, or
> > + * initialize the argument nodemask to contain the single node for
> > + * 'preferred' or * 'local' policy and return 'true' to indicate presence
> > + * of non-default mempolicy.
> > + *
> 
> Looks like some mangling of the comment, there's spurious '*' throughout.

Fixed.  

<snip>
> > Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-02 21:22:04.000000000 -0400
> > @@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
> >  	return NULL;
> >  }
> >  
> > -static ssize_t nr_hugepages_show(struct kobject *kobj,
> > +static ssize_t nr_hugepages_show_common(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> >  	struct hstate *h = kobj_to_hstate(kobj);
> >  	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> >  }
> > -static ssize_t nr_hugepages_store(struct kobject *kobj,
> > -		struct kobj_attribute *attr, const char *buf, size_t count)
> > +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> > +			struct kobject *kobj, struct kobj_attribute *attr,
> > +			const char *buf, size_t len)
> >  {
> >  	int err;
> > -	unsigned long input;
> > +	unsigned long count;
> >  	struct hstate *h = kobj_to_hstate(kobj);
> > +	NODEMASK_ALLOC(nodemask, nodes_allowed);
> >  
> 
> In the two places you do NODEMASK_ALLOC(), here and 
> hugetlb_sysctl_handler(), you'll need to check that nodes_allowed is 
> non-NULL since it's possible that kmalloc() will return NULL for 
> CONFIG_NODES_SHIFT > 8.
> 
> In such a case, it's probably sufficient to simply set nodes_allowed to 
> node_states[N_HIGH_MEMORY] so that we can still free hugepages when we're 
> oom, a common memory freeing tactic.
> 
> You could do that by simply returning false from 
> init_nodemask_of_mempolicy() if !nodes_allowed since NODEMASK_FREE() can 
> take a NULL pointer, but it may be easier to factor that logic into your 
> conditional below:
> 
> > -	err = strict_strtoul(buf, 10, &input);
> > +	err = strict_strtoul(buf, 10, &count);
> >  	if (err)
> >  		return 0;
> >  
> > -	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
> > +	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
> > +		NODEMASK_FREE(nodes_allowed);
> > +		nodes_allowed = &node_online_map;
> > +	}
> > +	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
> >
> 
> You can get away with just testing !nodes_allowed here since the stack 
> allocation variation of NODEMASK_ALLOC() is such that nodes_allowed will 
> always be an initialized pointer pointing to _nodes_allowed so you won't 
> have an uninitialized warning.
> 
> Once that's done, you can get rid of the check for a NULL nodes_allowed in 
> try_to_free_low() from patch 2 since it will always be valid in 
> set_max_huge_pages().


OK.  already removed the NULL check from try_to_free_low().  And I made
the change to init_nodemask_of_mempolicy to return false on NULL mask.

I'm not completely happy with dropping back to default behavior
[node_online_map here, replaced with node_states[N_HIGH_MEMORY] in
subsequent patch] on failure to allocate nodes_allowed.  We only do the
NODEMASK_ALLOC when we've come in from either nr_hugepages_mempolicy or
a per node attribute [subsequent patch], so I'm not sure that ignoring
the mempolicy, if any, or the specified node id, is a good thing here.
Not silently, at least.  I haven't addressed this, yet.  We can submit
an incremental patch.  Thoughts?

Note that these chunks will get reworked in the subsequent patch that
adds the per node attributes.  I'll need to handle this there, as well.

> 
> > -	return count;
> > +	if (nodes_allowed != &node_online_map)
> > +		NODEMASK_FREE(nodes_allowed);
> > +
> > +	return len;
> > +}
> > +
<snip>
> > Index: linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/kernel/sysctl.c	2009-09-30 12:48:45.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c	2009-09-30 12:48:46.000000000 -0400
> > @@ -1164,7 +1164,7 @@ static struct ctl_table vm_table[] = {
> >  		.extra2		= &one_hundred,
> >  	},
> >  #ifdef CONFIG_HUGETLB_PAGE
> > -	 {
> > +	{
> >  		.procname	= "nr_hugepages",
> >  		.data		= NULL,
> >  		.maxlen		= sizeof(unsigned long),
> > @@ -1172,7 +1172,19 @@ static struct ctl_table vm_table[] = {
> >  		.proc_handler	= &hugetlb_sysctl_handler,
> >  		.extra1		= (void *)&hugetlb_zero,
> >  		.extra2		= (void *)&hugetlb_infinity,
> > -	 },
> > +	},
> > +#ifdef CONFIG_NUMA
> > +	{
> > +	       .ctl_name       = CTL_UNNUMBERED,
> > +	       .procname       = "nr_hugepages_mempolicy",
> > +	       .data           = NULL,
> > +	       .maxlen         = sizeof(unsigned long),
> > +	       .mode           = 0644,
> > +	       .proc_handler   = &hugetlb_mempolicy_sysctl_handler,
> > +	       .extra1	 = (void *)&hugetlb_zero,
> > +	       .extra2	 = (void *)&hugetlb_infinity,
> > +	},
> > +#endif
> >  	 {
> >  		.ctl_name	= VM_HUGETLB_GROUP,
> >  		.procname	= "hugetlb_shm_group",
> > 
> 
> There's some whitespace damage in the nr_hugepages_mempolicy hunk, it 
> needs tabs instead of spaces for alignment.

Fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
