Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1451E6B00BF
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:56:14 -0400 (EDT)
Date: Wed, 26 Aug 2009 11:11:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
Message-ID: <20090826101122.GD10955@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192902.10317.94512.sendpatchset@localhost.localdomain> <20090825101906.GB4427@csn.ul.ie> <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 04:49:29PM -0400, Lee Schermerhorn wrote:
> > > 
> > > +static nodemask_t *nodes_allowed_from_node(int nid)
> > > +{
> > 
> > This name is a bit weird. It's creating a nodemask with just a single
> > node allowed.
> > 
> > Is there something wrong with using the existing function
> > nodemask_of_node()? If stack is the problem, prehaps there is some macro
> > magic that would allow a nodemask to be either declared on the stack or
> > kmalloc'd.
> 
> Yeah.  nodemask_of_node() creates an on-stack mask, invisibly, in a
> block nested inside the context where it's invoked.  I would be
> declaring the nodemask in the compound else clause and don't want to
> access it [via the nodes_allowed pointer] from outside of there.
> 

So, the existance of the mask on the stack is the problem. I can
understand that, they are potentially quite large.

Would it be possible to add a helper along side it like
init_nodemask_of_node() that does the same work as nodemask_of_node()
but takes a nodemask parameter? nodemask_of_node() would reuse the
init_nodemask_of_node() except it declares the nodemask on the stack.

> > 
> > > +	nodemask_t *nodes_allowed;
> > > +	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> > > +	if (!nodes_allowed) {
> > > +		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
> > > +			"for huge page allocation.\nFalling back to default.\n",
> > > +			current->comm);
> > > +	} else {
> > > +		nodes_clear(*nodes_allowed);
> > > +		node_set(nid, *nodes_allowed);
> > > +	}
> > > +	return nodes_allowed;
> > > +}
> > > +
> > >  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> > > -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> > > +static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> > > +								int nid)
> > >  {
> > >  	unsigned long min_count, ret;
> > >  	nodemask_t *nodes_allowed;
> > > @@ -1262,7 +1279,17 @@ static unsigned long set_max_huge_pages(
> > >  	if (h->order >= MAX_ORDER)
> > >  		return h->max_huge_pages;
> > >  
> > > -	nodes_allowed = huge_mpol_nodes_allowed();
> > > +	if (nid < 0)
> > > +		nodes_allowed = huge_mpol_nodes_allowed();
> > 
> > hugetlb is a bit littered with magic numbers been passed into functions.
> > Attempts have been made to clear them up as according as patches change
> > that area. Would it be possible to define something like
> > 
> > #define HUGETLB_OBEY_MEMPOLICY -1
> > 
> > for the nid here as opposed to passing in -1? I know -1 is used in the page
> > allocator functions but there it means "current node" and here it means
> > "obey mempolicies".
> 
> Well, here it means, NO_NODE_ID_SPECIFIED or, "we didn't get here via a
> per node attribute".  It means "derive nodes allowed from memory policy,
> if non-default, else use nodes_online_map" [which is not exactly the
> same as obeying memory policy].
> 
> But, I can see defining a symbolic constant such as
> NO_NODE[_ID_SPECIFIED].  I'll try next spin.
> 

That NO_NODE_ID_SPECIFIED was the underlying definition I was looking
for. It makes sense at both sites.

> > > -static struct hstate *kobj_to_hstate(struct kobject *kobj)
> > > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		struct node *node = &node_devices[nid];
> > > +		int hi;
> > > +		for (hi = 0; hi < HUGE_MAX_HSTATE; hi++)
> > 
> > Does that hi mean hello, high, nid or hstate_idx?
> > 
> > hstate_idx would appear to be the appropriate name here.
> 
> Or just plain 'i', like in the following, pre-existing function?
> 

Whichever suits you best. If hstate_idx is really what it is, I see no
harm in using it but 'i' is an index and I'd sooner recognise that than
the less meaningful "hi".

> > 
> > > +			if (node->hstate_kobjs[hi] == kobj) {
> > > +				if (nidp)
> > > +					*nidp = nid;
> > > +				return &hstates[hi];
> > > +			}
> > > +	}
> > 
> > Ok.... so, there is a struct node array for the sysdev and this patch adds
> > references to the "hugepages" directory kobject and the subdirectories for
> > each page size. We walk all the objects until we find a match. Obviously,
> > this adds a dependency of base node support on hugetlbfs which feels backwards
> > and you call that out in your leader.
> > 
> > Can this be the other way around? i.e. The struct hstate has an array of
> > kobjects arranged by nid that is filled in when the node is registered?
> > There will only be one kobject-per-pagesize-per-node so it seems like it
> > would work. I confess, I haven't prototyped this to be 100% sure.
> 
> This will take a bit longer to sort out.  I do want to change the
> registration, tho', so that hugetlb.c registers it's single node
> register/unregister functions with base/node.c to remove the source
> level dependency in that direction.  node.c will only register nodes on
> hot plug as it's initialized too early, relative to hugetlb.c to
> register them at init time.   This should break the call dependency of
> base/node.c on the hugetlb module.
> 
> As far as moving the per node attributes' kobjects to the hugetlb global
> hstate arrays...  Have to think about that.  I agree that it would be
> nice to remove the source level [header] dependency.
> 

FWIW, I see no problem with the mempolicy stuff going ahead separately from
this patch after the few relatively minor cleanups highlighted in the thread
and tackling this patch as a separate cycle. It's up to you really.

> > 
> > > +
> > > +	BUG();
> > > +	return NULL;
> > > +}
> > > +
> > > +static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
> > >  {
> > >  	int i;
> > > +
> > >  	for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > > -		if (hstate_kobjs[i] == kobj)
> > > +		if (hstate_kobjs[i] == kobj) {
> > > +			if (nidp)
> > > +				*nidp = -1;
> > >  			return &hstates[i];
> > > -	BUG();
> > > -	return NULL;
> > > +		}
> > > +
> > > +	return kobj_to_node_hstate(kobj, nidp);
> > >  }
> > >  
> > >  static ssize_t nr_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > -	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> > > +	struct hstate *h;
> > > +	unsigned long nr_huge_pages;
> > > +	int nid;
> > > +
> > > +	h = kobj_to_hstate(kobj, &nid);
> > > +	if (nid < 0)
> > > +		nr_huge_pages = h->nr_huge_pages;
> > 
> > Here is another magic number except it means something slightly
> > different. It means NR_GLOBAL_HUGEPAGES or something similar. It would
> > be nice if these different special nid values could be named, preferably
> > collapsed to being one "core" thing.
> 
> Again, it means "NO NODE ID specified" [via per node attribute].  Again,
> I'll address this with a single constant.
> 
> > 
> > > +	else
> > > +		nr_huge_pages = h->nr_huge_pages_node[nid];
> > > +
> > > +	return sprintf(buf, "%lu\n", nr_huge_pages);
> > >  }
> > > +
> > >  static ssize_t nr_hugepages_store(struct kobject *kobj,
> > >  		struct kobj_attribute *attr, const char *buf, size_t count)
> > >  {
> > > -	int err;
> > >  	unsigned long input;
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > +	struct hstate *h;
> > > +	int nid;
> > > +	int err;
> > >  
> > >  	err = strict_strtoul(buf, 10, &input);
> > >  	if (err)
> > >  		return 0;
> > >  
> > > -	h->max_huge_pages = set_max_huge_pages(h, input);
> > 
> > "input" is a bit meaningless. The function you are passing to calls this
> > parameter "count". Can you match the naming please? Otherwise, I might
> > guess that this is a "delta" which occurs elsewhere in the hugetlb code.
> 
> I guess I can change that.  It's the pre-exiting name, and 'count' was
> already used.  Guess I can change 'count' to 'len' and 'input' to
> 'count'

Makes sense.

> > 
> > > +	h = kobj_to_hstate(kobj, &nid);
> > > +	h->max_huge_pages = set_max_huge_pages(h, input, nid);
> > >  
> > >  	return count;
> > >  }
> > > @@ -1374,15 +1436,17 @@ HSTATE_ATTR(nr_hugepages);
> > >  static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> > > +
> > >  	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
> > >  }
> > > +
> > >  static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
> > >  		struct kobj_attribute *attr, const char *buf, size_t count)
> > >  {
> > >  	int err;
> > >  	unsigned long input;
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> > >  
> > >  	err = strict_strtoul(buf, 10, &input);
> > >  	if (err)
> > > @@ -1399,15 +1463,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
> > >  static ssize_t free_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > -	return sprintf(buf, "%lu\n", h->free_huge_pages);
> > > +	struct hstate *h;
> > > +	unsigned long free_huge_pages;
> > > +	int nid;
> > > +
> > > +	h = kobj_to_hstate(kobj, &nid);
> > > +	if (nid < 0)
> > > +		free_huge_pages = h->free_huge_pages;
> > > +	else
> > > +		free_huge_pages = h->free_huge_pages_node[nid];
> > > +
> > > +	return sprintf(buf, "%lu\n", free_huge_pages);
> > >  }
> > >  HSTATE_ATTR_RO(free_hugepages);
> > >  
> > >  static ssize_t resv_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > +	struct hstate *h = kobj_to_hstate(kobj, NULL);
> > >  	return sprintf(buf, "%lu\n", h->resv_huge_pages);
> > >  }
> > >  HSTATE_ATTR_RO(resv_hugepages);
> > > @@ -1415,8 +1488,17 @@ HSTATE_ATTR_RO(resv_hugepages);
> > >  static ssize_t surplus_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > > -	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
> > > +	struct hstate *h;
> > > +	unsigned long surplus_huge_pages;
> > > +	int nid;
> > > +
> > > +	h = kobj_to_hstate(kobj, &nid);
> > > +	if (nid < 0)
> > > +		surplus_huge_pages = h->surplus_huge_pages;
> > > +	else
> > > +		surplus_huge_pages = h->surplus_huge_pages_node[nid];
> > > +
> > > +	return sprintf(buf, "%lu\n", surplus_huge_pages);
> > >  }
> > >  HSTATE_ATTR_RO(surplus_hugepages);
> > >  
> > > @@ -1433,19 +1515,21 @@ static struct attribute_group hstate_att
> > >  	.attrs = hstate_attrs,
> > >  };
> > >  
> > > -static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
> > > +static int __init hugetlb_sysfs_add_hstate(struct hstate *h,
> > > +				struct kobject *parent,
> > > +				struct kobject **hstate_kobjs,
> > > +				struct attribute_group *hstate_attr_group)
> > >  {
> > >  	int retval;
> > > +	int hi = h - hstates;
> > >  
> > > -	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name,
> > > -							hugepages_kobj);
> > > -	if (!hstate_kobjs[h - hstates])
> > > +	hstate_kobjs[hi] = kobject_create_and_add(h->name, parent);
> > > +	if (!hstate_kobjs[hi])
> > >  		return -ENOMEM;
> > >  
> > > -	retval = sysfs_create_group(hstate_kobjs[h - hstates],
> > > -							&hstate_attr_group);
> > > +	retval = sysfs_create_group(hstate_kobjs[hi], hstate_attr_group);
> > >  	if (retval)
> > > -		kobject_put(hstate_kobjs[h - hstates]);
> > > +		kobject_put(hstate_kobjs[hi]);
> > >  
> > >  	return retval;
> > >  }
> > > @@ -1460,17 +1544,90 @@ static void __init hugetlb_sysfs_init(vo
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
> > > +
> > > +void hugetlb_unregister_node(struct node *node)
> > > +{
> > > +	struct hstate *h;
> > > +
> > > +	for_each_hstate(h) {
> > > +		kobject_put(node->hstate_kobjs[h - hstates]);
> > > +		node->hstate_kobjs[h - hstates] = NULL;
> > > +	}
> > > +
> > > +	kobject_put(node->hugepages_kobj);
> > > +	node->hugepages_kobj = NULL;
> > > +}
> > > +
> > > +static void hugetlb_unregister_all_nodes(void)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++)
> > > +		hugetlb_unregister_node(&node_devices[nid]);
> > > +}
> > > +
> > > +void hugetlb_register_node(struct node *node)
> > > +{
> > > +	struct hstate *h;
> > > +	int err;
> > > +
> > > +	if (!hugepages_kobj)
> > > +		return;		/* too early */
> > > +
> > > +	node->hugepages_kobj = kobject_create_and_add("hugepages",
> > > +							&node->sysdev.kobj);
> > > +	if (!node->hugepages_kobj)
> > > +		return;
> > > +
> > > +	for_each_hstate(h) {
> > > +		err = hugetlb_sysfs_add_hstate(h, node->hugepages_kobj,
> > > +						node->hstate_kobjs,
> > > +						&per_node_hstate_attr_group);
> > > +		if (err)
> > > +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> > > +					" for node %d\n",
> > > +						h->name, node->sysdev.id);
> > > +	}
> > > +}
> > > +
> > > +static void hugetlb_register_all_nodes(void)
> > > +{
> > > +	int nid;
> > > +
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		struct node *node = &node_devices[nid];
> > > +		if (node->sysdev.id == nid && !node->hugepages_kobj)
> > > +			hugetlb_register_node(node);
> > > +	}
> > > +}
> > > +#endif
> > > +
> > >  static void __exit hugetlb_exit(void)
> > >  {
> > >  	struct hstate *h;
> > >  
> > > +	hugetlb_unregister_all_nodes();
> > > +
> > >  	for_each_hstate(h) {
> > >  		kobject_put(hstate_kobjs[h - hstates]);
> > >  	}
> > > @@ -1505,6 +1662,8 @@ static int __init hugetlb_init(void)
> > >  
> > >  	hugetlb_sysfs_init();
> > >  
> > > +	hugetlb_register_all_nodes();
> > > +
> > >  	return 0;
> > >  }
> > >  module_init(hugetlb_init);
> > > @@ -1607,7 +1766,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
> > >  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> > >  
> > >  	if (write)
> > > -		h->max_huge_pages = set_max_huge_pages(h, tmp);
> > > +		h->max_huge_pages = set_max_huge_pages(h, tmp, -1);
> > >  
> > >  	return 0;
> > >  }
> > > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h
> > > ===================================================================
> > > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/node.h	2009-08-24 12:12:44.000000000 -0400
> > > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h	2009-08-24 12:12:56.000000000 -0400
> > > @@ -21,9 +21,12 @@
> > >  
> > >  #include <linux/sysdev.h>
> > >  #include <linux/cpumask.h>
> > > +#include <linux/hugetlb.h>
> > >  
> > >  struct node {
> > >  	struct sys_device	sysdev;
> > > +	struct kobject		*hugepages_kobj;
> > > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> > >  };
> > >  
> > >  struct memory_block;
> > > 
> > 
> > I'm not against this idea and think it can work side-by-side with the memory
> > policies. I believe it does need a bit more cleaning up before merging
> > though. I also wasn't able to test this yet due to various build and
> > deploy issues.
> 
> OK.  I'll do the cleanup.   I have tested this atop the mempolicy
> version by working around the build issues that I thought were just
> temporary glitches in the mmotm series.  In my [limited] experience, one
> can interleave numactl+hugeadm with setting values via the per node
> attributes and it does the right thing.  No heavy testing with racing
> tasks, tho'.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
