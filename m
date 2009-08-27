Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 86CFC6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:52:08 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090827102338.GC21183@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825101906.GB4427@csn.ul.ie>
	 <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
	 <20090826101122.GD10955@csn.ul.ie>
	 <1251309843.4409.48.camel@useless.americas.hpqcorp.net>
	 <20090827102338.GC21183@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 27 Aug 2009 12:52:10 -0400
Message-Id: <1251391930.4374.89.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-08-27 at 11:23 +0100, Mel Gorman wrote:
> On Wed, Aug 26, 2009 at 02:04:03PM -0400, Lee Schermerhorn wrote:
> > <SNIP>
> > This revised patch also removes the include of hugetlb.h from node.h.
> > 
> > Lee
> > 
> > ---
> > 
> > PATCH 5/6 hugetlb:  register per node hugepages attributes
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
> > V4:  Fix issues raised by Mel Gorman:
> >      + add !NUMA versions of hugetlb_[un]register_node()
> >      + rename 'hi' to 'i' in kobj_to_node_hstate()
> >      + rename (count, input) to (len, count) in nr_hugepages_store()
> >      + moved per node hugepages_kobj and hstate_kobjs[] from the
> >        struct node [sysdev] to hugetlb.c private arrays.
> >      + changed registration mechanism so that hugetlbfs [a module]
> >        register its attributes registration callbacks with the node
> >        driver, eliminating the dependency between the node driver
> >        and hugetlbfs.  From it's init func, hugetlbfs will register
> >        all on-line nodes' hugepage sysfs attributes along with
> >        hugetlbfs' attributes register/unregister functions.  The
> >        node driver will use these functions to [un]register nodes
> >        with hugetlbfs on node hot-plug.
> >      + replaced hugetlb.c private "nodes_allowed_from_node()" with
> >        generic "alloc_nodemask_of_node()".
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
> > Calling set_max_huge_pages() with no node indicates a change to
> > global hstate parameters.  In this case, any non-default task
> > mempolicy will be used to generate the nodes_allowed mask.  A
> > valid node id indicates an update to that node's hstate 
> > parameters, and the count argument specifies the target count
> > for the specified node.  From this info, we compute the target
> > global count for the hstate and construct a nodes_allowed node
> > mask contain only the specified node.
> > 
> > Setting the node specific nr_hugepages via the per node attribute
> > effectively ignores any task mempolicy or cpuset constraints.
> > 
<snip>
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/drivers/base/node.c
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/drivers/base/node.c	2009-08-26 12:37:03.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/drivers/base/node.c	2009-08-26 13:01:54.000000000 -0400
> > @@ -177,6 +177,31 @@ static ssize_t node_read_distance(struct
> >  }
> >  static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
> >  
> > +/*
> > + * hugetlbfs per node attributes registration interface
> > + */
> > +NODE_REGISTRATION_FUNC __hugetlb_register_node;
> > +NODE_REGISTRATION_FUNC __hugetlb_unregister_node;
> > +
> > +static inline void hugetlb_register_node(struct node *node)
> > +{
> > +	if (__hugetlb_register_node)
> > +		__hugetlb_register_node(node);
> > +}
> > +
> > +static inline void hugetlb_unregister_node(struct node *node)
> > +{
> > +	if (__hugetlb_unregister_node)
> > +		__hugetlb_unregister_node(node);
> > +}
> > +
> > +void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
> > +                                  NODE_REGISTRATION_FUNC unregister)
> > +{
> > +	__hugetlb_register_node   = doregister;
> > +	__hugetlb_unregister_node = unregister;
> > +}
> > +
> >  
> 
> I think I get this. Basically, you want to avoid the functions being
> called too early before sysfs is initialised and still work with hotplug
> later. So early in boot, no registeration happens. sysfs and hugetlbfs
> get initialised and at that point, these hooks become active, all nodes
> registered and hotplug later continues to work.
> 
> Is that accurate? Can it get a comment?

Yes, you got it, and yes, I'll add a comment.  I had explained it in the
patch description [V4], but that's not too useful to someone coming
along later...

<snip>

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
> 
> alloc_nodemask_of_node() isn't defined anywhere.


Well, that's because the patch that defines it is in a message that I
meant to send before this one.  I see it's in my Drafts folder.  I'll
attach that patch below.  I'm rebasing against the 0827 mmotm, and I'll
resend the rebased series.  However, I wanted to get your opinion of the
nodemask patch below.

<snip>
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
> 
> Ok, this looks nicer in that the dependencies between hugetlbfs and base
> node support are going the right direction.

Agreed.  I removed that "issue" from the patch description.

<snip>
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/node.h	2009-08-26 12:37:03.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/node.h	2009-08-26 12:40:19.000000000 -0400
> > @@ -28,6 +28,7 @@ struct node {
> >  
> >  struct memory_block;
> >  extern struct node node_devices[];
> > +typedef  void (*NODE_REGISTRATION_FUNC)(struct node *);
> >  
> >  extern int register_node(struct node *, int, struct node *);
> >  extern void unregister_node(struct node *node);
> > @@ -39,6 +40,8 @@ extern int unregister_cpu_under_node(uns
> >  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
> >  						int nid);
> >  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
> > +extern void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
> > +                                         NODE_REGISTRATION_FUNC unregister);
> >  #else
> >  static inline int register_one_node(int nid)
> >  {
> > @@ -65,6 +68,9 @@ static inline int unregister_mem_sect_un
> >  {
> >  	return 0;
> >  }
> > +
> > +static inline void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC do,
> > +                                                NODE_REGISTRATION_FUNC un) { }
> 
> "do" is a keyword. This won't compile on !NUMA. needs to be called
> doregister and unregister or basically anything other than "do"

Sorry.  Last minute, obviously untested, addition.  I have built the
reworked code with and without NUMA.

Here's my current "alloc_nodemask_of_node()" patch.  What do you think
about going with this? 

PATCH 4/6 - hugetlb:  introduce alloc_nodemask_of_node()

Against: 2.6.31-rc6-mmotm-090820-1918

Introduce nodemask macro to allocate a nodemask and 
initialize it to contain a single node, using existing
nodemask_of_node() macro.  Coded as a macro to avoid header
dependency hell.

This will be used to construct the huge pages "nodes_allowed"
nodemask for a single node when a persistent huge page
pool page count is modified via a per node sysfs attribute.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/nodemask.h |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h
===================================================================
--- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/nodemask.h	2009-08-27 09:16:39.000000000 -0400
+++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h	2009-08-27 09:52:21.000000000 -0400
@@ -245,18 +245,31 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+#define init_nodemask_of_nodes(mask, node)				\
+	nodes_clear(*(mask));						\
+	node_set((node), *(mask));
+
 #define nodemask_of_node(node)						\
 ({									\
 	typeof(_unused_nodemask_arg_) m;				\
 	if (sizeof(m) == sizeof(unsigned long)) {			\
 		m.bits[0] = 1UL<<(node);				\
 	} else {							\
-		nodes_clear(m);						\
-		node_set((node), m);					\
+		init_nodemask_of_nodes(&m, (node));			\
 	}								\
 	m;								\
 })
 
+#define alloc_nodemask_of_node(node)					\
+({									\
+	typeof(_unused_nodemask_arg_) *nmp;				\
+	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
+	if (nmp)							\
+		init_nodemask_of_nodes(nmp, (node));			\
+	nmp;								\
+})
+
+
 #define first_unset_node(mask) __first_unset_node(&(mask))
 static inline int __first_unset_node(const nodemask_t *maskp)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
