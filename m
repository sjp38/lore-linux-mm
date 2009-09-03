Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B378E6B005C
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 17:02:10 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n83L24qC021780
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 22:02:05 +0100
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by zps75.corp.google.com with ESMTP id n83L14KS005523
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 14:02:02 -0700
Received: by pxi8 with SMTP id 8so189036pxi.9
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 14:02:02 -0700 (PDT)
Date: Thu, 3 Sep 2009 14:02:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
In-Reply-To: <1252010485.6029.180.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909031350030.30662@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160344.11080.20255.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031241160.24821@chino.kir.corp.google.com>
 <1252010485.6029.180.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Lee Schermerhorn wrote:

> > > @@ -1451,17 +1507,143 @@ static void __init hugetlb_sysfs_init(vo
> > >  		return;
> > >  
> > >  	for_each_hstate(h) {
> > > -		err = hugetlb_sysfs_add_hstate(h);
> > > +		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
> > > +					 hstate_kobjs, &hstate_attr_group);
> > >  		if (err)
> > >  			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
> > >  								h->name);
> > >  	}
> > >  }
> > >  
> > > +#ifdef CONFIG_NUMA
> > > +
> > > +struct node_hstate {
> > > +	struct kobject		*hugepages_kobj;
> > > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> > > +};
> > > +struct node_hstate node_hstates[MAX_NUMNODES];
> > > +
> > > +static struct attribute *per_node_hstate_attrs[] = {
> > > +	&nr_hugepages_attr.attr,
> > > +	&free_hugepages_attr.attr,
> > > +	&surplus_hugepages_attr.attr,
> > > +	NULL,
> > > +};
> > > +
> > > +static struct attribute_group per_node_hstate_attr_group = {
> > > +	.attrs = per_node_hstate_attrs,
> > > +};
> > > +
> > > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		struct node_hstate *nhs = &node_hstates[nid];
> > > +		int i;
> > > +		for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > > +			if (nhs->hstate_kobjs[i] == kobj) {
> > > +				if (nidp)
> > > +					*nidp = nid;
> > > +				return &hstates[i];
> > > +			}
> > > +	}
> > > +
> > > +	BUG();
> > > +	return NULL;
> > > +}
> > > +
> > > +void hugetlb_unregister_node(struct node *node)
> > > +{
> > > +	struct hstate *h;
> > > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > > +
> > > +	if (!nhs->hugepages_kobj)
> > > +		return;
> > > +
> > > +	for_each_hstate(h)
> > > +		if (nhs->hstate_kobjs[h - hstates]) {
> > > +			kobject_put(nhs->hstate_kobjs[h - hstates]);
> > > +			nhs->hstate_kobjs[h - hstates] = NULL;
> > > +		}
> > > +
> > > +	kobject_put(nhs->hugepages_kobj);
> > > +	nhs->hugepages_kobj = NULL;
> > > +}
> > > +
> > > +static void hugetlb_unregister_all_nodes(void)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++)
> > > +		hugetlb_unregister_node(&node_devices[nid]);
> > > +
> > > +	register_hugetlbfs_with_node(NULL, NULL);
> > > +}
> > > +
> > > +void hugetlb_register_node(struct node *node)
> > > +{
> > > +	struct hstate *h;
> > > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > > +	int err;
> > > +
> > > +	if (nhs->hugepages_kobj)
> > > +		return;		/* already allocated */
> > > +
> > > +	nhs->hugepages_kobj = kobject_create_and_add("hugepages",
> > > +							&node->sysdev.kobj);
> > > +	if (!nhs->hugepages_kobj)
> > > +		return;
> > > +
> > > +	for_each_hstate(h) {
> > > +		err = hugetlb_sysfs_add_hstate(h, nhs->hugepages_kobj,
> > > +						nhs->hstate_kobjs,
> > > +						&per_node_hstate_attr_group);
> > > +		if (err) {
> > > +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> > > +					" for node %d\n",
> > > +						h->name, node->sysdev.id);
> > 
> > Maybe add `err' to the printk so we know whether it was an -ENOMEM 
> > condition or sysfs problem?
> 
> Just the raw negative number?
> 

Sure.  I'm making the assumption that the printk is actually necessary in 
the first place, which is rather unorthodox for functions that can 
otherwise silently recover by unregistering the attribute.  Using the 
printk implies you want to know about the failure, yet additional 
debugging would be necessary to even identify what the failure was without 
printing the errno.

> > 
> > > +			hugetlb_unregister_node(node);
> > > +			break;
> > > +		}
> > > +	}
> > > +}
> > > +
> > > +static void hugetlb_register_all_nodes(void)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > 
> > Don't you want to do this for all nodes in N_HIGH_MEMORY?  I don't think 
> > we should be adding attributes for memoryless nodes.
> 
> 
> Well, I wondered about that.  The persistent huge page allocation code
> is careful to skip over nodes where it can't allow a huge page there,
> whether or not the node has [any] memory.  So, it's safe to leave it
> this way.

It's safe, but it seems inconsistent to allow hugepage attributes to 
appear in /sys/devices/node/node* for nodes that have no memory.

> And, I was worried about the interaction with memory hotplug,
> as separate from node hotplug.  The current code handles node hot plug,
> bug I wasn't sure about memory hot-plug within a node.

If memory hotplug doesn't update nodes_state[N_HIGH_MEMORY] then there are 
plenty of other users that will currently fail as well.

> I.e., would the
> node driver get called to register the attributes in this case?

Not without a MEM_ONLINE notifier.

> Maybe
> that case doesn't exist, so I don't have to worry about it.   I think
> this is somewhat similar to the top cpuset mems_allowed being set to all
> possible to cover any subsequently added nodes/memory.
> 

That's because the page allocator's zonelists won't try to allocate from a 
memoryless node and the only hook into the cpuset code in that path is to 
check whether a nid is set in cpuset_current_mems_allowed.  It's quite 
different from providing per-node allocation and freeing mechanisms for 
pages on nodes without memory like this approach.

> > > Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h
> > > ===================================================================
> > > --- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/numa.h	2009-08-28 09:21:17.000000000 -0400
> > > +++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h	2009-08-28 09:21:31.000000000 -0400
> > > @@ -10,4 +10,6 @@
> > >  
> > >  #define MAX_NUMNODES    (1 << NODES_SHIFT)
> > >  
> > > +#define NO_NODEID_SPECIFIED	(-1)
> > > +
> > >  #endif /* _LINUX_NUMA_H */
> > 
> > Hmm, so we already have NUMA_NO_NODE in the ia64 and x86_64 code and 
> > NID_INVAL in the ACPI code, both of which are defined to -1.  Maybe rename 
> > your addition here in favor of NUMA_NO_NODE, remove it from the ia64 and 
> > x86 arch headers, and convert the ACPI code?
> 
> OK, replacing 'NO_NODEID_SPECIFIED' with 'NUMA_NO_NODE,' works w/o
> decending into header dependency hell.  The symbol is already visible in
> hugetlb.c  I'll fix that.

NUMA_NO_NODE may be visible in hugetlb.c for ia64 and x86, but probably 
not for other architectures so it should be moved to include/linux/numa.h.

> But, ACPI?  Not today, thanks :).

Darn :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
