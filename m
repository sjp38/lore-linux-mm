Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7380F6B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 10:30:51 -0400 (EDT)
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909031350030.30662@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
	 <20090828160344.11080.20255.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0909031241160.24821@chino.kir.corp.google.com>
	 <1252010485.6029.180.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.00.0909031350030.30662@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Fri, 04 Sep 2009 10:30:47 -0400
Message-Id: <1252074647.4389.46.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-03 at 14:02 -0700, David Rientjes wrote:
> On Thu, 3 Sep 2009, Lee Schermerhorn wrote:
> 
> > > > @@ -1451,17 +1507,143 @@ static void __init hugetlb_sysfs_init(vo
> > > >  		return;
> > > >  
> > > >  	for_each_hstate(h) {
> > > > -		err = hugetlb_sysfs_add_hstate(h);
> > > > +		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
> > > > +					 hstate_kobjs, &hstate_attr_group);
> > > >  		if (err)
> > > >  			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
> > > >  								h->name);
> > > >  	}
> > > >  }
> > > >  
> > > > +#ifdef CONFIG_NUMA
> > > > +
> > > > +struct node_hstate {
> > > > +	struct kobject		*hugepages_kobj;
> > > > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> > > > +};
> > > > +struct node_hstate node_hstates[MAX_NUMNODES];
> > > > +
> > > > +static struct attribute *per_node_hstate_attrs[] = {
> > > > +	&nr_hugepages_attr.attr,
> > > > +	&free_hugepages_attr.attr,
> > > > +	&surplus_hugepages_attr.attr,
> > > > +	NULL,
> > > > +};
> > > > +
> > > > +static struct attribute_group per_node_hstate_attr_group = {
> > > > +	.attrs = per_node_hstate_attrs,
> > > > +};
> > > > +
> > > > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > > > +{
> > > > +	int nid;
> > > > +
> > > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > > +		struct node_hstate *nhs = &node_hstates[nid];
> > > > +		int i;
> > > > +		for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > > > +			if (nhs->hstate_kobjs[i] == kobj) {
> > > > +				if (nidp)
> > > > +					*nidp = nid;
> > > > +				return &hstates[i];
> > > > +			}
> > > > +	}
> > > > +
> > > > +	BUG();
> > > > +	return NULL;
> > > > +}
> > > > +
> > > > +void hugetlb_unregister_node(struct node *node)
> > > > +{
> > > > +	struct hstate *h;
> > > > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > > > +
> > > > +	if (!nhs->hugepages_kobj)
> > > > +		return;
> > > > +
> > > > +	for_each_hstate(h)
> > > > +		if (nhs->hstate_kobjs[h - hstates]) {
> > > > +			kobject_put(nhs->hstate_kobjs[h - hstates]);
> > > > +			nhs->hstate_kobjs[h - hstates] = NULL;
> > > > +		}
> > > > +
> > > > +	kobject_put(nhs->hugepages_kobj);
> > > > +	nhs->hugepages_kobj = NULL;
> > > > +}
> > > > +
> > > > +static void hugetlb_unregister_all_nodes(void)
> > > > +{
> > > > +	int nid;
> > > > +
> > > > +	for (nid = 0; nid < nr_node_ids; nid++)
> > > > +		hugetlb_unregister_node(&node_devices[nid]);
> > > > +
> > > > +	register_hugetlbfs_with_node(NULL, NULL);
> > > > +}
> > > > +
> > > > +void hugetlb_register_node(struct node *node)
> > > > +{
> > > > +	struct hstate *h;
> > > > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > > > +	int err;
> > > > +
> > > > +	if (nhs->hugepages_kobj)
> > > > +		return;		/* already allocated */
> > > > +
> > > > +	nhs->hugepages_kobj = kobject_create_and_add("hugepages",
> > > > +							&node->sysdev.kobj);
> > > > +	if (!nhs->hugepages_kobj)
> > > > +		return;
> > > > +
> > > > +	for_each_hstate(h) {
> > > > +		err = hugetlb_sysfs_add_hstate(h, nhs->hugepages_kobj,
> > > > +						nhs->hstate_kobjs,
> > > > +						&per_node_hstate_attr_group);
> > > > +		if (err) {
> > > > +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> > > > +					" for node %d\n",
> > > > +						h->name, node->sysdev.id);
> > > 
> > > Maybe add `err' to the printk so we know whether it was an -ENOMEM 
> > > condition or sysfs problem?
> > 
> > Just the raw negative number?
> > 
> 
> Sure.  I'm making the assumption that the printk is actually necessary in 
> the first place, which is rather unorthodox for functions that can 
> otherwise silently recover by unregistering the attribute.  Using the 
> printk implies you want to know about the failure, yet additional 
> debugging would be necessary to even identify what the failure was without 
> printing the errno.


David:  


I'm going to leave this printk as is.  I want to keep it, because the
global hstate function issues a similar printk [w/o] error code when it
can't add a global hstate.  The original authors considered this
necessary/useful, so I'm following suit.  The -ENOMEM error is returned
by hugetlb_sysfs_add_hstate() when kobject_create_and_add().  If the
kobject creation can fail for reasons other than ENOMEM, then showing
ENOMEM in the message will sometimes be bogus.  If it can only fail due
to lack of memory, then we are adding no additional info.

more below

> 
> > > 
> > > > +			hugetlb_unregister_node(node);
> > > > +			break;
> > > > +		}
> > > > +	}
> > > > +}
> > > > +
> > > > +static void hugetlb_register_all_nodes(void)
> > > > +{
> > > > +	int nid;
> > > > +
> > > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > 
> > > Don't you want to do this for all nodes in N_HIGH_MEMORY?  I don't think 
> > > we should be adding attributes for memoryless nodes.
> > 
> > 
> > Well, I wondered about that.  The persistent huge page allocation code
> > is careful to skip over nodes where it can't allow a huge page there,
> > whether or not the node has [any] memory.  So, it's safe to leave it
> > this way.
> 
> It's safe, but it seems inconsistent to allow hugepage attributes to 
> appear in /sys/devices/node/node* for nodes that have no memory.

OK.  I'm going to change this, and replace node_online_map with
node_state[N_HIGH_MEMORY] [or whatever] as a separate patch.  That way,
if someone complains that this doesn't work for memory hot plug, someone
who understands memory hotplut can fix it or we can drop that patch.

> 
> > And, I was worried about the interaction with memory hotplug,
> > as separate from node hotplug.  The current code handles node hot plug,
> > bug I wasn't sure about memory hot-plug within a node.
> 
> If memory hotplug doesn't update nodes_state[N_HIGH_MEMORY] then there are 
> plenty of other users that will currently fail as well.
> 
> > I.e., would the
> > node driver get called to register the attributes in this case?
> 
> Not without a MEM_ONLINE notifier.

That's what I thought.  I'm not up to speed on that area, and have no
bandwidth nor interest to go there, right now.  If you think that's a
show stopper for per node attributes, we can defer this part of the
series.  But, I'd prefer to stick with current "no-op" attributes for
memoryless nodes over that alternative.

> 
> > Maybe
> > that case doesn't exist, so I don't have to worry about it.   I think
> > this is somewhat similar to the top cpuset mems_allowed being set to all
> > possible to cover any subsequently added nodes/memory.
> > 
> 
> That's because the page allocator's zonelists won't try to allocate from a 
> memoryless node and the only hook into the cpuset code in that path is to 
> check whether a nid is set in cpuset_current_mems_allowed.  It's quite 
> different from providing per-node allocation and freeing mechanisms for 
> pages on nodes without memory like this approach.

OK, we have different perspectives on this.  I'm not at all offended by
the no-op attributes.  If you're worried about safety, I can check
explicitly in the attribute handlers and bail out early for memoryless
nodes.  Then, should someone hot add memory to the node, it will start
attemping to allocate huge pages when requested.

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
