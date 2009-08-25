Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 766AD6B00BC
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:49:25 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090825101906.GB4427@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825101906.GB4427@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Aug 2009 16:49:29 -0400
Message-Id: <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-25 at 11:19 +0100, Mel Gorman wrote:
> On Mon, Aug 24, 2009 at 03:29:02PM -0400, Lee Schermerhorn wrote:
> > PATCH/RFC 5/4 hugetlb:  register per node hugepages attributes
> > 
> > Against: 2.6.31-rc6-mmotm-090820-1918
> > 
> > V2:  remove dependency on kobject private bitfield.  Search
> >      global hstates then all per node hstates for kobject
> >      match in attribute show/store functions.
> > 
> > V3:  rebase atop the mempolicy-based hugepage alloc/free;
> >      use custom "nodes_allowed" to restrict alloc/free to
> >      a specific node via per node attributes.  Per node
> >      attribute overrides mempolicy.  I.e., mempolicy only
> >      applies to global attributes.
> > 
> > To demonstrate feasibility--if not advisability--of supporting
> > both mempolicy-based persistent huge page management with per
> > node "override" attributes.
> > 
> > This patch adds the per huge page size control/query attributes
> > to the per node sysdevs:
> > 
> > /sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
> > 	nr_hugepages       - r/w
> > 	free_huge_pages    - r/o
> > 	surplus_huge_pages - r/o
> > 
> > The patch attempts to re-use/share as much of the existing
> > global hstate attribute initialization and handling, and the
> > "nodes_allowed" constraint processing as possible.
> > In set_max_huge_pages(), a node id < 0 indicates a change to
> > global hstate parameters.  In this case, any non-default task
> > mempolicy will be used to generate the nodes_allowed mask.  A
> > node id > 0 indicates a node specific update and the count 
> > argument specifies the target count for the node.  From this
> > info, we compute the target global count for the hstate and
> > construct a nodes_allowed node mask contain only the specified
> > node.  Thus, setting the node specific nr_hugepages via the
> > per node attribute effectively overrides any task mempolicy.
> > 
> > 
> > Issue:  dependency of base driver [node] dependency on hugetlbfs module.
> > We want to keep all of the hstate attribute registration and handling
> > in the hugetlb module.  However, we need to call into this code to
> > register the per node hstate attributes on node hot plug.
> > 
> > With this patch:
> > 
> > (me):ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB
> > ./  ../  free_hugepages  nr_hugepages  surplus_hugepages
> > 
> > Starting from:
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:     0
> > Node 2 HugePages_Free:      0
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> > vm.nr_hugepages = 0
> > 
> > Allocate 16 persistent huge pages on node 2:
> > (me):echo 16 >/sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages
> > 
> > [Note that this is equivalent to:
> > 	numactl -m 2 hugeadmin --pool-pages-min 2M:+16
> > ]
> > 
> > Yields:
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:    16
> > Node 2 HugePages_Free:     16
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> > vm.nr_hugepages = 16
> > 
> > Global controls work as expected--reduce pool to 8 persistent huge pages:
> > (me):echo 8 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> > 
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:     8
> > Node 2 HugePages_Free:      8
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> > 
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  drivers/base/node.c     |    2 
> >  include/linux/hugetlb.h |    6 +
> >  include/linux/node.h    |    3 
> >  mm/hugetlb.c            |  213 +++++++++++++++++++++++++++++++++++++++++-------
> >  4 files changed, 197 insertions(+), 27 deletions(-)
> > 
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/drivers/base/node.c
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/drivers/base/node.c	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/drivers/base/node.c	2009-08-24 12:12:56.000000000 -0400
> > @@ -200,6 +200,7 @@ int register_node(struct node *node, int
> >  		sysdev_create_file(&node->sysdev, &attr_distance);
> >  
> >  		scan_unevictable_register_node(node);
> > +		hugetlb_register_node(node);
> >  	}
> >  	return error;
> >  }
> > @@ -220,6 +221,7 @@ void unregister_node(struct node *node)
> >  	sysdev_remove_file(&node->sysdev, &attr_distance);
> >  
> >  	scan_unevictable_unregister_node(node);
> > +	hugetlb_unregister_node(node);
> >  
> >  	sysdev_unregister(&node->sysdev);
> >  }
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/hugetlb.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/hugetlb.h	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/hugetlb.h	2009-08-24 12:12:56.000000000 -0400
> > @@ -278,6 +278,10 @@ static inline struct hstate *page_hstate
> >  	return size_to_hstate(PAGE_SIZE << compound_order(page));
> >  }
> >  
> > +struct node;
> > +extern void hugetlb_register_node(struct node *);
> > +extern void hugetlb_unregister_node(struct node *);
> > +
> >  #else
> >  struct hstate {};
> >  #define alloc_bootmem_huge_page(h) NULL
> > @@ -294,6 +298,8 @@ static inline unsigned int pages_per_hug
> >  {
> >  	return 1;
> >  }
> > +#define hugetlb_register_node(NP)
> > +#define hugetlb_unregister_node(NP)
> >  #endif
> >  
> 
> This also needs to be done for the !NUMA case. Try building without NUMA
> set and you get the following with this patch applied
> 
>   CC      mm/hugetlb.o
> mm/hugetlb.c: In function AcA?A?hugetlb_exitAcA?A?:
> mm/hugetlb.c:1629: error: implicit declaration of function AcA?A?hugetlb_unregister_all_nodesAcA?A?
> mm/hugetlb.c: In function AcA?A?hugetlb_initAcA?A?:
> mm/hugetlb.c:1665: error: implicit declaration of function AcA?A?hugetlb_register_all_nodesAcA?A?
> make[1]: *** [mm/hugetlb.o] Error 1
> make: *** [mm] Error 2

Ouch!  Sorry.  Will add stubs.

> 
> 
> >  #endif /* _LINUX_HUGETLB_H */
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/hugetlb.c	2009-08-24 12:12:53.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c	2009-08-24 12:12:56.000000000 -0400
> > @@ -24,6 +24,7 @@
> >  #include <asm/io.h>
> >  
> >  #include <linux/hugetlb.h>
> > +#include <linux/node.h>
> >  #include "internal.h"
> >  
> >  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> > @@ -1253,8 +1254,24 @@ static int adjust_pool_surplus(struct hs
> >  	return ret;
> >  }
> >  
> > +static nodemask_t *nodes_allowed_from_node(int nid)
> > +{
> 
> This name is a bit weird. It's creating a nodemask with just a single
> node allowed.
> 
> Is there something wrong with using the existing function
> nodemask_of_node()? If stack is the problem, prehaps there is some macro
> magic that would allow a nodemask to be either declared on the stack or
> kmalloc'd.

Yeah.  nodemask_of_node() creates an on-stack mask, invisibly, in a
block nested inside the context where it's invoked.  I would be
declaring the nodemask in the compound else clause and don't want to
access it [via the nodes_allowed pointer] from outside of there.

> 
> > +	nodemask_t *nodes_allowed;
> > +	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> > +	if (!nodes_allowed) {
> > +		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
> > +			"for huge page allocation.\nFalling back to default.\n",
> > +			current->comm);
> > +	} else {
> > +		nodes_clear(*nodes_allowed);
> > +		node_set(nid, *nodes_allowed);
> > +	}
> > +	return nodes_allowed;
> > +}
> > +
> >  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> > -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> > +static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> > +								int nid)
> >  {
> >  	unsigned long min_count, ret;
> >  	nodemask_t *nodes_allowed;
> > @@ -1262,7 +1279,17 @@ static unsigned long set_max_huge_pages(
> >  	if (h->order >= MAX_ORDER)
> >  		return h->max_huge_pages;
> >  
> > -	nodes_allowed = huge_mpol_nodes_allowed();
> > +	if (nid < 0)
> > +		nodes_allowed = huge_mpol_nodes_allowed();
> 
> hugetlb is a bit littered with magic numbers been passed into functions.
> Attempts have been made to clear them up as according as patches change
> that area. Would it be possible to define something like
> 
> #define HUGETLB_OBEY_MEMPOLICY -1
> 
> for the nid here as opposed to passing in -1? I know -1 is used in the page
> allocator functions but there it means "current node" and here it means
> "obey mempolicies".

Well, here it means, NO_NODE_ID_SPECIFIED or, "we didn't get here via a
per node attribute".  It means "derive nodes allowed from memory policy,
if non-default, else use nodes_online_map" [which is not exactly the
same as obeying memory policy].

But, I can see defining a symbolic constant such as
NO_NODE[_ID_SPECIFIED].  I'll try next spin.

> 
> > +	else {
> > +		/*
> > +		 * incoming 'count' is for node 'nid' only, so
> > +		 * adjust count to global, but restrict alloc/free
> > +		 * to the specified node.
> > +		 */
> > +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> > +		nodes_allowed = nodes_allowed_from_node(nid);
> > +	}
> >  
> >  	/*
> >  	 * Increase the pool size
> > @@ -1338,34 +1365,69 @@ out:
> >  static struct kobject *hugepages_kobj;
> >  static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
> >  
> > -static struct hstate *kobj_to_hstate(struct kobject *kobj)
> > +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > +		struct node *node = &node_devices[nid];
> > +		int hi;
> > +		for (hi = 0; hi < HUGE_MAX_HSTATE; hi++)
> 
> Does that hi mean hello, high, nid or hstate_idx?
> 
> hstate_idx would appear to be the appropriate name here.

Or just plain 'i', like in the following, pre-existing function?

> 
> > +			if (node->hstate_kobjs[hi] == kobj) {
> > +				if (nidp)
> > +					*nidp = nid;
> > +				return &hstates[hi];
> > +			}
> > +	}
> 
> Ok.... so, there is a struct node array for the sysdev and this patch adds
> references to the "hugepages" directory kobject and the subdirectories for
> each page size. We walk all the objects until we find a match. Obviously,
> this adds a dependency of base node support on hugetlbfs which feels backwards
> and you call that out in your leader.
> 
> Can this be the other way around? i.e. The struct hstate has an array of
> kobjects arranged by nid that is filled in when the node is registered?
> There will only be one kobject-per-pagesize-per-node so it seems like it
> would work. I confess, I haven't prototyped this to be 100% sure.

This will take a bit longer to sort out.  I do want to change the
registration, tho', so that hugetlb.c registers it's single node
register/unregister functions with base/node.c to remove the source
level dependency in that direction.  node.c will only register nodes on
hot plug as it's initialized too early, relative to hugetlb.c to
register them at init time.   This should break the call dependency of
base/node.c on the hugetlb module.

As far as moving the per node attributes' kobjects to the hugetlb global
hstate arrays...  Have to think about that.  I agree that it would be
nice to remove the source level [header] dependency.

> 
> > +
> > +	BUG();
> > +	return NULL;
> > +}
> > +
> > +static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
> >  {
> >  	int i;
> > +
> >  	for (i = 0; i < HUGE_MAX_HSTATE; i++)
> > -		if (hstate_kobjs[i] == kobj)
> > +		if (hstate_kobjs[i] == kobj) {
> > +			if (nidp)
> > +				*nidp = -1;
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
> > +	if (nid < 0)
> > +		nr_huge_pages = h->nr_huge_pages;
> 
> Here is another magic number except it means something slightly
> different. It means NR_GLOBAL_HUGEPAGES or something similar. It would
> be nice if these different special nid values could be named, preferably
> collapsed to being one "core" thing.

Again, it means "NO NODE ID specified" [via per node attribute].  Again,
I'll address this with a single constant.

> 
> > +	else
> > +		nr_huge_pages = h->nr_huge_pages_node[nid];
> > +
> > +	return sprintf(buf, "%lu\n", nr_huge_pages);
> >  }
> > +
> >  static ssize_t nr_hugepages_store(struct kobject *kobj,
> >  		struct kobj_attribute *attr, const char *buf, size_t count)
> >  {
> > -	int err;
> >  	unsigned long input;
> > -	struct hstate *h = kobj_to_hstate(kobj);
> > +	struct hstate *h;
> > +	int nid;
> > +	int err;
> >  
> >  	err = strict_strtoul(buf, 10, &input);
> >  	if (err)
> >  		return 0;
> >  
> > -	h->max_huge_pages = set_max_huge_pages(h, input);
> 
> "input" is a bit meaningless. The function you are passing to calls this
> parameter "count". Can you match the naming please? Otherwise, I might
> guess that this is a "delta" which occurs elsewhere in the hugetlb code.

I guess I can change that.  It's the pre-exiting name, and 'count' was
already used.  Guess I can change 'count' to 'len' and 'input' to
'count'
> 
> > +	h = kobj_to_hstate(kobj, &nid);
> > +	h->max_huge_pages = set_max_huge_pages(h, input, nid);
> >  
> >  	return count;
> >  }
> > @@ -1374,15 +1436,17 @@ HSTATE_ATTR(nr_hugepages);
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
> > @@ -1399,15 +1463,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
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
> > +	if (nid < 0)
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
> > @@ -1415,8 +1488,17 @@ HSTATE_ATTR_RO(resv_hugepages);
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
> > +	if (nid < 0)
> > +		surplus_huge_pages = h->surplus_huge_pages;
> > +	else
> > +		surplus_huge_pages = h->surplus_huge_pages_node[nid];
> > +
> > +	return sprintf(buf, "%lu\n", surplus_huge_pages);
> >  }
> >  HSTATE_ATTR_RO(surplus_hugepages);
> >  
> > @@ -1433,19 +1515,21 @@ static struct attribute_group hstate_att
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
> > @@ -1460,17 +1544,90 @@ static void __init hugetlb_sysfs_init(vo
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
> > +
> > +void hugetlb_unregister_node(struct node *node)
> > +{
> > +	struct hstate *h;
> > +
> > +	for_each_hstate(h) {
> > +		kobject_put(node->hstate_kobjs[h - hstates]);
> > +		node->hstate_kobjs[h - hstates] = NULL;
> > +	}
> > +
> > +	kobject_put(node->hugepages_kobj);
> > +	node->hugepages_kobj = NULL;
> > +}
> > +
> > +static void hugetlb_unregister_all_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++)
> > +		hugetlb_unregister_node(&node_devices[nid]);
> > +}
> > +
> > +void hugetlb_register_node(struct node *node)
> > +{
> > +	struct hstate *h;
> > +	int err;
> > +
> > +	if (!hugepages_kobj)
> > +		return;		/* too early */
> > +
> > +	node->hugepages_kobj = kobject_create_and_add("hugepages",
> > +							&node->sysdev.kobj);
> > +	if (!node->hugepages_kobj)
> > +		return;
> > +
> > +	for_each_hstate(h) {
> > +		err = hugetlb_sysfs_add_hstate(h, node->hugepages_kobj,
> > +						node->hstate_kobjs,
> > +						&per_node_hstate_attr_group);
> > +		if (err)
> > +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> > +					" for node %d\n",
> > +						h->name, node->sysdev.id);
> > +	}
> > +}
> > +
> > +static void hugetlb_register_all_nodes(void)
> > +{
> > +	int nid;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > +		struct node *node = &node_devices[nid];
> > +		if (node->sysdev.id == nid && !node->hugepages_kobj)
> > +			hugetlb_register_node(node);
> > +	}
> > +}
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
> > @@ -1505,6 +1662,8 @@ static int __init hugetlb_init(void)
> >  
> >  	hugetlb_sysfs_init();
> >  
> > +	hugetlb_register_all_nodes();
> > +
> >  	return 0;
> >  }
> >  module_init(hugetlb_init);
> > @@ -1607,7 +1766,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
> >  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> >  
> >  	if (write)
> > -		h->max_huge_pages = set_max_huge_pages(h, tmp);
> > +		h->max_huge_pages = set_max_huge_pages(h, tmp, -1);
> >  
> >  	return 0;
> >  }
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/node.h	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h	2009-08-24 12:12:56.000000000 -0400
> > @@ -21,9 +21,12 @@
> >  
> >  #include <linux/sysdev.h>
> >  #include <linux/cpumask.h>
> > +#include <linux/hugetlb.h>
> >  
> >  struct node {
> >  	struct sys_device	sysdev;
> > +	struct kobject		*hugepages_kobj;
> > +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> >  };
> >  
> >  struct memory_block;
> > 
> 
> I'm not against this idea and think it can work side-by-side with the memory
> policies. I believe it does need a bit more cleaning up before merging
> though. I also wasn't able to test this yet due to various build and
> deploy issues.

OK.  I'll do the cleanup.   I have tested this atop the mempolicy
version by working around the build issues that I thought were just
temporary glitches in the mmotm series.  In my [limited] experience, one
can interleave numactl+hugeadm with setting values via the per node
attributes and it does the right thing.  No heavy testing with racing
tasks, tho'.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
