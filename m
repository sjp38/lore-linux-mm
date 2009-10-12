Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF61F6B004F
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 11:41:10 -0400 (EDT)
Subject: Re: [PATCH 7/12] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0910091511100.12760@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
	 <20091008162539.23192.3642.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com>
	 <1255096198.14370.65.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.00.0910091511100.12760@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Mon, 12 Oct 2009 11:41:04 -0400
Message-Id: <1255362064.4344.105.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-10-09 at 15:18 -0700, David Rientjes wrote:
> On Fri, 9 Oct 2009, Lee Schermerhorn wrote:
> 
> > > > +/*
> > > > + * kobj_to_node_hstate - lookup global hstate for node sysdev hstate attr kobj.
> > > > + * Returns node id via non-NULL nidp.
> > > > + */
> > > > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > > > +{
> > > > +	int nid;
> > > > +
> > > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > 
> > > I previously asked if this should use for_each_node_mask() instead?
> > 
> > sorry, missed this comment [and one at end] in my prev response.  Too
> > much multi-tasking.
> > 
> > This also could interate over a node mask for consistency, I think.
> > Again, current version works because we're looking for node sysdev based
> > on a per node attribute kobj.  We only add the attributes to nodes with
> > memory.  So, we're potentially visiting a few more nodes than necessary
> > on some platforms.  Shouldn't be a performance issue.  
> > 
> 
> Hmm, does this really work for memory hot-remove?  If all memory is 
> removed from a nid, does node_hstates[nid]->hstate_objs[] get updated 
> appropriately?  I assume we'd never pass that particular kobj to 
> kobj_to_node_hstate() anymore, but I'm wondering if the pointer would 
> remain in the hstate_kobjs[] table.

Patch 11 is intended to address this.  The hotplug notifier, added by
that patch, will call hugetlb_unregister_node() in the event all memory
is removed from a node.  hugetlb_unregister_node() NULLs out the per
node hstate_kobjs[] after freeing them.  This patch [7/12] handles node
hot-plug--as opposed to memory hot-plug that transitions the node
to/from the memoryless state.

> 
> > > > Index: linux-2.6.31-mmotm-090925-1435/include/linux/node.h
> > > > ===================================================================
> > > > --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/node.h	2009-10-07 12:31:51.000000000 -0400
> > > > +++ linux-2.6.31-mmotm-090925-1435/include/linux/node.h	2009-10-07 12:32:01.000000000 -0400
> > > > @@ -28,6 +28,7 @@ struct node {
> > > >  
> > > >  struct memory_block;
> > > >  extern struct node node_devices[];
> > > > +typedef  void (*node_registration_func_t)(struct node *);
> > > >  
> > > >  extern int register_node(struct node *, int, struct node *);
> > > >  extern void unregister_node(struct node *node);
> > > 
> > > I previously suggested against the typedef unless this functionality (node 
> > > hotplug notifiers) becomes more generic outside of the hugetlb use case.
> > 
> > I'd like to keep it.  I've read the CodingStyle and I know it argues
> > against typedefs, but the strongest prohibition is against [pointers to]
> > structs whose members could be reasonable accessed.  I don't think I
> > violate that.  And, this does allow the registration function
> > definitions that take the func pointer as an argument to show up in
> > cscope.  I find that useful.  Wish they all did [func defs with func
> > args show up in cscope, that is].  But, if you and others feel strongly
> > about this, I suppose we can rip it out.
> > 
> 
> Ok, I agree that it would be convenient if this could evolve into a 
> generic node hotplug notifier taht can be used all over the kernel.  I 
> don't see any reason why that can't happen based on the work you've done 
> in this particular patch, so I have no strong objection to it (although 
> maybe it would be better named `node_notifier_func_t' since it unregisters 
> nodes too?).

OK.  The node driver is notifying the hugetlb module of an event that
requires hstate attributes to be [un]registered via these functions.
So, either name works for me.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
