Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1CD26B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 16:42:44 -0400 (EDT)
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909031241160.24821@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
	 <20090828160344.11080.20255.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0909031241160.24821@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 16:41:25 -0400
Message-Id: <1252010485.6029.180.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-03 at 12:52 -0700, David Rientjes wrote:
> On Fri, 28 Aug 2009, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/hugetlb.c	2009-08-28 09:21:28.000000000 -0400
> > +++ linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c	2009-08-28 09:21:31.000000000 -0400
> > @@ -24,6 +24,7 @@
> >  #include <asm/io.h>
> >  
> >  #include <linux/hugetlb.h>
> > +#include <linux/node.h>
> >  #include "internal.h"
> >  
> >  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> > @@ -1245,7 +1246,8 @@ static int adjust_pool_surplus(struct hs
> >  }
> >  
> >  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> > -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> > +static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> > +								int nid)
> >  {
> >  	unsigned long min_count, ret;
> >  	nodemask_t *nodes_allowed;
> > @@ -1253,7 +1255,21 @@ static unsigned long set_max_huge_pages(
> >  	if (h->order >= MAX_ORDER)
> >  		return h->max_huge_pages;
> >  
> > -	nodes_allowed = huge_mpol_nodes_allowed();
> > +	if (nid == NO_NODEID_SPECIFIED)
> > +		nodes_allowed = huge_mpol_nodes_allowed();
> > +	else {
> > +		/*
> > +		 * incoming 'count' is for node 'nid' only, so
> > +		 * adjust count to global, but restrict alloc/free
> > +		 * to the specified node.
> > +		 */
> > +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> > +		nodes_allowed = alloc_nodemask_of_node(nid);
> > +		if (!nodes_allowed)
> > +			printk(KERN_WARNING "%s unable to allocate allowed "
> > +			       "nodes mask for huge page allocation/free.  "
> > +			       "Falling back to default.\n", current->comm);
> > +	}
> >  
> >  	/*
> >  	 * Increase the pool size
> > @@ -1329,51 +1345,71 @@ out:
> >  static struct kobject *hugepages_kobj;
> >  static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
> >  
> > -static struct hstate *kobj_to_hstate(struct kobject *kobj)
> > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp);
> > +
> > +static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
> >  {
> >  	int i;
> > +
> >  	for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > -		if (hstate_kobjs[i] == kobj)
> > +		if (hstate_kobjs[i] == kobj) {
> > +			if (nidp)
> > +				*nidp = NO_NODEID_SPECIFIED;
> >  			return &hstates[i];
> > -	BUG();
> > -	return NULL;
> > +		}
> > +
> > +	return kobj_to_node_hstate(kobj, nidp);
> >  }
> >  
> >  static ssize_t nr_hugepages_show(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > -	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> > +	struct hstate *h;
> > +	unsigned long nr_huge_pages;
> > +	int nid;
> > +
> > +	h = kobj_to_hstate(kobj, &nid);
> > +	if (nid == NO_NODEID_SPECIFIED)
> > +		nr_huge_pages = h->nr_huge_pages;
> > +	else
> > +		nr_huge_pages = h->nr_huge_pages_node[nid];
> > +
> > +	return sprintf(buf, "%lu\n", nr_huge_pages);
> >  }
> > +
> >  static ssize_t nr_hugepages_store(struct kobject *kobj,
> > -		struct kobj_attribute *attr, const char *buf, size_t count)
> > +		struct kobj_attribute *attr, const char *buf, size_t len)
> >  {
> > +	unsigned long count;
> > +	struct hstate *h;
> > +	int nid;
> >  	int err;
> > -	unsigned long input;
> > -	struct hstate *h = kobj_to_hstate(kobj);
> >  
> > -	err = strict_strtoul(buf, 10, &input);
> > +	err = strict_strtoul(buf, 10, &count);
> >  	if (err)
> >  		return 0;
> >  
> > -	h->max_huge_pages = set_max_huge_pages(h, input);
> > +	h = kobj_to_hstate(kobj, &nid);
> > +	h->max_huge_pages = set_max_huge_pages(h, count, nid);
> >  
> > -	return count;
> > +	return len;
> >  }
> >  HSTATE_ATTR(nr_hugepages);
> >  
> >  static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> > +
> >  	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
> >  }
> > +
> >  static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
> >  		struct kobj_attribute *attr, const char *buf, size_t count)
> >  {
> >  	int err;
> >  	unsigned long input;
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> >  
> >  	err = strict_strtoul(buf, 10, &input);
> >  	if (err)
> > @@ -1390,15 +1426,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
> >  static ssize_t free_hugepages_show(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > -	return sprintf(buf, "%lu\n", h->free_huge_pages);
> > +	struct hstate *h;
> > +	unsigned long free_huge_pages;
> > +	int nid;
> > +
> > +	h = kobj_to_hstate(kobj, &nid);
> > +	if (nid == NO_NODEID_SPECIFIED)
> > +		free_huge_pages = h->free_huge_pages;
> > +	else
> > +		free_huge_pages = h->free_huge_pages_node[nid];
> > +
> > +	return sprintf(buf, "%lu\n", free_huge_pages);
> >  }
> >  HSTATE_ATTR_RO(free_hugepages);
> >  
> >  static ssize_t resv_hugepages_show(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> >  	return sprintf(buf, "%lu\n", h->resv_huge_pages);
> >  }
> >  HSTATE_ATTR_RO(resv_hugepages);
> > @@ -1406,8 +1451,17 @@ HSTATE_ATTR_RO(resv_hugepages);
> >  static ssize_t surplus_hugepages_show(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > -	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
> > +	struct hstate *h;
> > +	unsigned long surplus_huge_pages;
> > +	int nid;
> > +
> > +	h = kobj_to_hstate(kobj, &nid);
> > +	if (nid == NO_NODEID_SPECIFIED)
> > +		surplus_huge_pages = h->surplus_huge_pages;
> > +	else
> > +		surplus_huge_pages = h->surplus_huge_pages_node[nid];
> > +
> > +	return sprintf(buf, "%lu\n", surplus_huge_pages);
> >  }
> >  HSTATE_ATTR_RO(surplus_hugepages);
> >  
> > @@ -1424,19 +1478,21 @@ static struct attribute_group hstate_att
> >  	.attrs = hstate_attrs,
> >  };
> >  
> > -static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
> > +static int __init hugetlb_sysfs_add_hstate(struct hstate *h,
> > +				struct kobject *parent,
> > +				struct kobject **hstate_kobjs,
> > +				struct attribute_group *hstate_attr_group)
> >  {
> >  	int retval;
> > +	int hi = h - hstates;
> >  
> > -	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name,
> > -							hugepages_kobj);
> > -	if (!hstate_kobjs[h - hstates])
> > +	hstate_kobjs[hi] = kobject_create_and_add(h->name, parent);
> > +	if (!hstate_kobjs[hi])
> >  		return -ENOMEM;
> >  
> > -	retval = sysfs_create_group(hstate_kobjs[h - hstates],
> > -							&hstate_attr_group);
> > +	retval = sysfs_create_group(hstate_kobjs[hi], hstate_attr_group);
> >  	if (retval)
> > -		kobject_put(hstate_kobjs[h - hstates]);
> > +		kobject_put(hstate_kobjs[hi]);
> >  
> >  	return retval;
> >  }
> > @@ -1451,17 +1507,143 @@ static void __init hugetlb_sysfs_init(vo
> >  		return;
> >  
> >  	for_each_hstate(h) {
> > -		err = hugetlb_sysfs_add_hstate(h);
> > +		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
> > +					 hstate_kobjs, &hstate_attr_group);
> >  		if (err)
> >  			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
> >  								h->name);
> >  	}
> >  }
> >  
> > +#ifdef CONFIG_NUMA
> > +
> > +struct node_hstate {
> > +	struct kobject		*hugepages_kobj;
> > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> > +};
> > +struct node_hstate node_hstates[MAX_NUMNODES];
> > +
> > +static struct attribute *per_node_hstate_attrs[] = {
> > +	&nr_hugepages_attr.attr,
> > +	&free_hugepages_attr.attr,
> > +	&surplus_hugepages_attr.attr,
> > +	NULL,
> > +};
> > +
> > +static struct attribute_group per_node_hstate_attr_group = {
> > +	.attrs = per_node_hstate_attrs,
> > +};
> > +
> > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
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
> > +void hugetlb_unregister_node(struct node *node)
> > +{
> > +	struct hstate *h;
> > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > +
> > +	if (!nhs->hugepages_kobj)
> > +		return;
> > +
> > +	for_each_hstate(h)
> > +		if (nhs->hstate_kobjs[h - hstates]) {
> > +			kobject_put(nhs->hstate_kobjs[h - hstates]);
> > +			nhs->hstate_kobjs[h - hstates] = NULL;
> > +		}
> > +
> > +	kobject_put(nhs->hugepages_kobj);
> > +	nhs->hugepages_kobj = NULL;
> > +}
> > +
> > +static void hugetlb_unregister_all_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++)
> > +		hugetlb_unregister_node(&node_devices[nid]);
> > +
> > +	register_hugetlbfs_with_node(NULL, NULL);
> > +}
> > +
> > +void hugetlb_register_node(struct node *node)
> > +{
> > +	struct hstate *h;
> > +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> > +	int err;
> > +
> > +	if (nhs->hugepages_kobj)
> > +		return;		/* already allocated */
> > +
> > +	nhs->hugepages_kobj = kobject_create_and_add("hugepages",
> > +							&node->sysdev.kobj);
> > +	if (!nhs->hugepages_kobj)
> > +		return;
> > +
> > +	for_each_hstate(h) {
> > +		err = hugetlb_sysfs_add_hstate(h, nhs->hugepages_kobj,
> > +						nhs->hstate_kobjs,
> > +						&per_node_hstate_attr_group);
> > +		if (err) {
> > +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> > +					" for node %d\n",
> > +						h->name, node->sysdev.id);
> 
> Maybe add `err' to the printk so we know whether it was an -ENOMEM 
> condition or sysfs problem?

Just the raw negative number?

> 
> > +			hugetlb_unregister_node(node);
> > +			break;
> > +		}
> > +	}
> > +}
> > +
> > +static void hugetlb_register_all_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> 
> Don't you want to do this for all nodes in N_HIGH_MEMORY?  I don't think 
> we should be adding attributes for memoryless nodes.


Well, I wondered about that.  The persistent huge page allocation code
is careful to skip over nodes where it can't allow a huge page there,
whether or not the node has [any] memory.  So, it's safe to leave it
this way.  And, I was worried about the interaction with memory hotplug,
as separate from node hotplug.  The current code handles node hot plug,
bug I wasn't sure about memory hot-plug within a node.  I.e., would the
node driver get called to register the attributes in this case?   Maybe
that case doesn't exist, so I don't have to worry about it.   I think
this is somewhat similar to the top cpuset mems_allowed being set to all
possible to cover any subsequently added nodes/memory.

It's easy to change to use node_state[N_HIGH_MEMORY], but then the
memory hotplug guys might jump in and say that, now it doesn't work for
memory hot add/remove.  I really don't want to go there...

But, I can understand the confusion about providing an explicit control
like this for a node without memory.  It is somewhat different from just
visiting all online nodes for the default mask, as hugetlb.c has always
done.
  
> 
> > +		struct node *node = &node_devices[nid];
> > +		if (node->sysdev.id == nid)
> > +			hugetlb_register_node(node);
> > +	}
> > +
> > +	register_hugetlbfs_with_node(hugetlb_register_node,
> > +                                     hugetlb_unregister_node);
> > +}
> > +#else	/* !CONFIG_NUMA */
> > +
> > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > +{
> > +	BUG();
> > +	if (nidp)
> > +		*nidp = -1;
> > +	return NULL;
> > +}
> > +
> > +static void hugetlb_unregister_all_nodes(void) { }
> > +
> > +static void hugetlb_register_all_nodes(void) { }
> > +
> > +#endif
> > +
> >  static void __exit hugetlb_exit(void)
> >  {
> >  	struct hstate *h;
> >  
> > +	hugetlb_unregister_all_nodes();
> > +
> >  	for_each_hstate(h) {
> >  		kobject_put(hstate_kobjs[h - hstates]);
> >  	}
> > @@ -1496,6 +1678,8 @@ static int __init hugetlb_init(void)
> >  
> >  	hugetlb_sysfs_init();
> >  
> > +	hugetlb_register_all_nodes();
> > +
> >  	return 0;
> >  }
> >  module_init(hugetlb_init);
> > @@ -1598,7 +1782,8 @@ int hugetlb_sysctl_handler(struct ctl_ta
> >  	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> >  
> >  	if (write)
> > -		h->max_huge_pages = set_max_huge_pages(h, tmp);
> > +		h->max_huge_pages = set_max_huge_pages(h, tmp,
> > +		                                       NO_NODEID_SPECIFIED);
> >  
> >  	return 0;
> >  }
> > Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h
> > ===================================================================
> > --- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/numa.h	2009-08-28 09:21:17.000000000 -0400
> > +++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h	2009-08-28 09:21:31.000000000 -0400
> > @@ -10,4 +10,6 @@
> >  
> >  #define MAX_NUMNODES    (1 << NODES_SHIFT)
> >  
> > +#define NO_NODEID_SPECIFIED	(-1)
> > +
> >  #endif /* _LINUX_NUMA_H */
> 
> Hmm, so we already have NUMA_NO_NODE in the ia64 and x86_64 code and 
> NID_INVAL in the ACPI code, both of which are defined to -1.  Maybe rename 
> your addition here in favor of NUMA_NO_NODE, remove it from the ia64 and 
> x86 arch headers, and convert the ACPI code?

OK, replacing 'NO_NODEID_SPECIFIED' with 'NUMA_NO_NODE,' works w/o
decending into header dependency hell.  The symbol is already visible in
hugetlb.c  I'll fix that.  But, ACPI?  Not today, thanks :).  

> 
> Thanks for doing this!

Well, we do need this, as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
