Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 929E86B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 11:13:08 -0400 (EDT)
Subject: Re: [PATCH 7/12] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
	 <20091008162539.23192.3642.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Fri, 09 Oct 2009 09:49:58 -0400
Message-Id: <1255096198.14370.65.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-10-08 at 13:42 -0700, David Rientjes wrote:
> On Thu, 8 Oct 2009, Lee Schermerhorn wrote:
> 
<snip>
> > +static struct attribute_group per_node_hstate_attr_group = {
> > +	.attrs = per_node_hstate_attrs,
> > +};
> > +
> > +/*
> > + * kobj_to_node_hstate - lookup global hstate for node sysdev hstate attr kobj.
> > + * Returns node id via non-NULL nidp.
> > + */
> > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> 
> I previously asked if this should use for_each_node_mask() instead?

sorry, missed this comment [and one at end] in my prev response.  Too
much multi-tasking.

This also could interate over a node mask for consistency, I think.
Again, current version works because we're looking for node sysdev based
on a per node attribute kobj.  We only add the attributes to nodes with
memory.  So, we're potentially visiting a few more nodes than necessary
on some platforms.  Shouldn't be a performance issue.  

> 
> > +		struct node_hstate *nhs = &node_hstates[nid];
> > +		int i;
> > +		for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > +			if (nhs->hstate_kobjs[i] == kobj) {
> > +				if (nidp)
> > +					*nidp = nid;
> > +				return &hstates[i];
> > +			}
> > +	}
> > +
> > +	BUG();
> > +	return NULL;
> > +}
> > +
<snip>
> > +
> > +/*
> > + * hugetlb init time:  register hstate attributes for all registered
> > + * node sysdevs.  All on-line nodes should have registered their
> > + * associated sysdev by the time the hugetlb module initializes.
> > + */
> > +static void hugetlb_register_all_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > +		struct node *node = &node_devices[nid];
> > +		if (node->sysdev.id == nid)
> > +			hugetlb_register_node(node);
> > +	}
> 
> This looks like another use of for_each_node_mask over N_HIGH_MEMORY.  I 
> previously asked if the check for node->sysdev.id == nid is still 
> necessary at this point?

already answered this.
> 
> > +
> > +	/*
> > +	 * Let the node sysdev driver know we're here so it can
> > +	 * [un]register hstate attributes on node hotplug.
> > +	 */
> > +	register_hugetlbfs_with_node(hugetlb_register_node,
> > +				     hugetlb_unregister_node);
> > +}
> > +#else	/* !CONFIG_NUMA */


> > Index: linux-2.6.31-mmotm-090925-1435/include/linux/node.h
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/node.h	2009-10-07 12:31:51.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/include/linux/node.h	2009-10-07 12:32:01.000000000 -0400
> > @@ -28,6 +28,7 @@ struct node {
> >  
> >  struct memory_block;
> >  extern struct node node_devices[];
> > +typedef  void (*node_registration_func_t)(struct node *);
> >  
> >  extern int register_node(struct node *, int, struct node *);
> >  extern void unregister_node(struct node *node);
> 
> I previously suggested against the typedef unless this functionality (node 
> hotplug notifiers) becomes more generic outside of the hugetlb use case.

I'd like to keep it.  I've read the CodingStyle and I know it argues
against typedefs, but the strongest prohibition is against [pointers to]
structs whose members could be reasonable accessed.  I don't think I
violate that.  And, this does allow the registration function
definitions that take the func pointer as an argument to show up in
cscope.  I find that useful.  Wish they all did [func defs with func
args show up in cscope, that is].  But, if you and others feel strongly
about this, I suppose we can rip it out.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
