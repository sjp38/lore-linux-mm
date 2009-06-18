Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A1A216B005A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 05:16:52 -0400 (EDT)
Date: Thu, 18 Jun 2009 10:17:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] Add nodes_allowed members to hugepages hstate
	struct
Message-ID: <20090618091713.GA14903@csn.ul.ie>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090616135253.25248.96346.sendpatchset@lts-notebook> <20090617133541.GH28529@csn.ul.ie> <1245260296.6235.81.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245260296.6235.81.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 01:38:16PM -0400, Lee Schermerhorn wrote:
> On Wed, 2009-06-17 at 14:35 +0100, Mel Gorman wrote:
> > On Tue, Jun 16, 2009 at 09:52:53AM -0400, Lee Schermerhorn wrote:
> > > [PATCH 2/5] add nodes_allowed members to hugepages hstate struct
> > > 
> > > Against:  17may09 mmotm
> > > 
> > > This patch adds a nodes_allowed nodemask_t pointer and a
> > > __nodes_allowed nodemask_t to the hstate struct for constraining
> > > fresh hugepage allocations.  It then adds sysfs attributes and
> > > boot command line options to set and [for sysfs attributes] query
> > > the allowed nodes mask.
> > > 
> > > A separate patch will hook up this nodes_allowed mask/pointer to
> > > fresh huge page allocation and promoting of surplus pages to
> > > persistent.  Another patch will add a 'sysctl' hugepages_nodes_allowed
> > > to /proc/sys/vm.
> > > 
> > > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > 
> > >  include/linux/hugetlb.h |    2 +
> > >  mm/hugetlb.c            |   86 ++++++++++++++++++++++++++++++++++++++++++++++++
> > >  2 files changed, 88 insertions(+)
> > > 
> > > Index: linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h
> > > ===================================================================
> > > --- linux-2.6.30-rc8-mmotm-090603-1633.orig/include/linux/hugetlb.h	2009-06-04 12:59:31.000000000 -0400
> > > +++ linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h	2009-06-04 12:59:32.000000000 -0400
> > > @@ -193,6 +193,8 @@ struct hstate {
> > >  	unsigned long resv_huge_pages;
> > >  	unsigned long surplus_huge_pages;
> > >  	unsigned long nr_overcommit_huge_pages;
> > > +	nodemask_t *nodes_allowed;
> > > +	nodemask_t __nodes_allowed;
> > 
> > Can you add a comment as to why a nodemask pointer and a nodemask itself
> > with very similar field names are both needed?
> 
> Hmmm, thought I did that.  Guess I just thought about doing it :(.
> 
> It's sort of tied up with why I want to use "all" rather than a literal
> node mask to specify allocation [attempts] across all nodes.  The
> default and current behavior is to use the node_online_mask.  My
> understanding is that this tracks node hot add/remove, and I wanted to
> preserve that behavior by pointing at node_online_mask directly, in the
> default and nodes_allowed=all cases.
> 

Good point, I had not considered node hot add/remove. Any chance you
could kmalloc() the nodes_allowed() when the mask is set? It just feels
remarkably untidy to have two nodes_allowed like this, particularly as
the __nodes_allowed will not be used in the majority of cases.

> 
> > 
> > >  	struct list_head hugepage_freelists[MAX_NUMNODES];
> > >  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> > >  	unsigned int free_huge_pages_node[MAX_NUMNODES];
> > > Index: linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c
> > > ===================================================================
> > > --- linux-2.6.30-rc8-mmotm-090603-1633.orig/mm/hugetlb.c	2009-06-04 12:59:31.000000000 -0400
> > > +++ linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c	2009-06-04 12:59:32.000000000 -0400
> > > @@ -40,6 +40,9 @@ __initdata LIST_HEAD(huge_boot_pages);
> > >  static struct hstate * __initdata parsed_hstate;
> > >  static unsigned long __initdata default_hstate_max_huge_pages;
> > >  static unsigned long __initdata default_hstate_size;
> > > +static struct hstate __initdata default_boot_hstate = {
> > > +	.nodes_allowed = &node_online_map,
> > > +};
> > >  
> > >  #define for_each_hstate(h) \
> > >  	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
> > > @@ -1102,6 +1105,9 @@ static void __init hugetlb_init_hstates(
> > >  	struct hstate *h;
> > >  
> > >  	for_each_hstate(h) {
> > > +		if (!h->nodes_allowed)
> > > +			h->nodes_allowed = &node_online_map;
> > > +
> > 
> > The reasoning for two nodes_allowed would appear to be to allow nodes_allowed
> > to be some predefined mash or a hstate-private mask. As the mask has to exist
> > anyway, can you not just copy it in rather than having a pointer and a mask?
> > 
> > It would make the check below as to whether all nodes allowed or not a bit
> > more expensive but it's not a big deal.
> 
> but, it wouldn't track node hot add/remove.  I suppose we could add
> handlers to fix up the hstates, but that seemed unnecessary work.
> 

Right.

> My thinking was that allocation of persistent hugepages [as opposed to
> overcommitted/surplus h.p.] is an administrative action and, thus, not a
> fast path.  Also, I didn't envision [my myopia, perhaps] a large number
> of hstates, so I didn't think the extra pointer per hstate was a big
> burden.
> 

It's not a big memory burden, it just seems untidy and there are a lot
of untidy anomolies in hugetlbfs as it is. While I'm far from innocent,
I hate to see it getting even odder looking :)

> > 
> > >  		/* oversize hugepages were init'ed in early boot */
> > >  		if (h->order < MAX_ORDER)
> > >  			hugetlb_hstate_alloc_pages(h);
> > > @@ -1335,6 +1341,62 @@ static ssize_t nr_overcommit_hugepages_s
> > >  }
> > >  HSTATE_ATTR(nr_overcommit_hugepages);
> > >  
> > > +static ssize_t nodes_allowed_show(struct kobject *kobj,
> > > +					struct kobj_attribute *attr, char *buf)
> > > +{
> > > +	struct hstate *h = kobj_to_hstate(kobj);
> > > +	int len = 3;
> > > +
> > > +	if (h->nodes_allowed == &node_online_map)
> > > +		strcpy(buf, "all");
> > > +	else
> > > +		len = nodelist_scnprintf(buf, PAGE_SIZE,
> > > +					*h->nodes_allowed);
> > > +
> > > +	if (len)
> > > +		buf[len++] = '\n';
> > > +
> > 
> > buf doesn't get NULL terminated.
> 
> Ah, OK.  Not sure what I was using as an example here.  Maybe I thunk
> that up all on my own...
> 
> > 
> > > +	return len;
> > > +}
> > 
> > Can print_nodes_state() be extended a little to print "all" and then shared
> > with here?
> 
> Well, I don't know that we'd want to see "all" for the sysfs "online"
> nodes attribute.  Some might not find this too informative.  Of course,
> even for huge pages nodes allowed, it's not all that informative, but
> IMO fits the usage.  One can always look at the sysfs online nodes
> attribute to see what "all" means for nodes_allowed.  Couldn't do that
> if we changed print_nodes_state().  I guess we could add a flag to
> indicate whether we wanted "all" or the actual nodemask.  And, we have
> to make print_nodes_state() visible.  Do you think that would be worth
> while?  
> 

I see your point. Maybe, maybe not. The suggestion was due to the bugs in
the new version than anything else. I figured it would be easier to get one
version right than have multiple slightly different versions. How attached
are you to having "all" printed? There is an arguement for having nodemasks
reported via sysfs all looking the same

> > 
> > > +
> > > +static int set_hstate_nodes_allowed(struct hstate *h, const char *buf,
> > > +					bool lock)
> > > +{
> > > +	nodemask_t nodes_allowed;
> > > +	int ret = 1;
> > > +	bool all = !strncasecmp(buf, "all", 3);
> > > +
> > > +	if (!all)
> > > +		ret = !nodelist_parse(buf, nodes_allowed);
> > > +	if (ret) {
> > > +		if (lock)
> > > +			spin_lock(&hugetlb_lock);
> > > +
> > 
> > ick.
> > 
> > Convention for something like this is to have set_hstate_nodes_allowed
> > that takes a spinlock and __set_hstate_nodes_allowed that is the
> > lock-free version and call as appropriate. Can the same be done here?
> 
> Sorry.  Yeah, I can do that. 
> 
> > 
> > For that matter, does taking spinlocks from __setup() break that you
> > avoid taking it in that case?
> 
> I wasn't sure, but noticed that we weren't locking in the boot path for,
> e.g., [nr_]hugepages, so I avoided it here.  I suppose I can just test
> whether or not it breaks and, if not, just lock.
> 

A lack of locking in the bootpath is more likely due to laziness than with
any problems taking the locks.

> > 
> > > +		if (all) {
> > > +			h->nodes_allowed = &node_online_map;
> > > +		} else {
> > > +			h->__nodes_allowed = nodes_allowed;
> > > +			h->nodes_allowed = &h->__nodes_allowed;
> > > +		}
> > > +
> > > +		if (lock)
> > > +			spin_unlock(&hugetlb_lock);
> > > +	}
> > > +	return ret;
> > > +}
> > > +
> > > +static ssize_t nodes_allowed_store(struct kobject *kobj,
> > > +		struct kobj_attribute *attr, const char *buf, size_t count)
> > > +{
> > > +	struct hstate *h = kobj_to_hstate(kobj);
> > > +
> > > +	if (set_hstate_nodes_allowed(h, buf, 1))
> > > +		return count;
> > > +	else
> > > +		return 0;
> > > +}
> > > +HSTATE_ATTR(nodes_allowed);
> > > +
> > >  static ssize_t free_hugepages_show(struct kobject *kobj,
> > >  					struct kobj_attribute *attr, char *buf)
> > >  {
> > > @@ -1362,6 +1424,7 @@ HSTATE_ATTR_RO(surplus_hugepages);
> > >  static struct attribute *hstate_attrs[] = {
> > >  	&nr_hugepages_attr.attr,
> > >  	&nr_overcommit_hugepages_attr.attr,
> > > +	&nodes_allowed_attr.attr,
> > >  	&free_hugepages_attr.attr,
> > >  	&resv_hugepages_attr.attr,
> > >  	&surplus_hugepages_attr.attr,
> > > @@ -1436,6 +1499,13 @@ static int __init hugetlb_init(void)
> > >  	if (default_hstate_max_huge_pages)
> > >  		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
> > >  
> > > +	if (default_boot_hstate.nodes_allowed != &node_online_map) {
> > > +		default_hstate.__nodes_allowed =
> > > +					default_boot_hstate.__nodes_allowed;
> > > +		default_hstate.nodes_allowed =
> > > +					&default_hstate.__nodes_allowed;
> > > +	}
> > > +
> > >  	hugetlb_init_hstates();
> > >  
> > >  	gather_bootmem_prealloc();
> > > @@ -1471,6 +1541,7 @@ void __init hugetlb_add_hstate(unsigned 
> > >  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
> > >  					huge_page_size(h)/1024);
> > >  
> > > +	h->nodes_allowed = &node_online_map;
> > >  	parsed_hstate = h;
> > >  }
> > >  
> > > @@ -1518,6 +1589,21 @@ static int __init hugetlb_default_setup(
> > >  }
> > >  __setup("default_hugepagesz=", hugetlb_default_setup);
> > >  
> > > +static int __init hugetlb_nodes_allowed_setup(char *s)
> > > +{
> > > +	struct hstate *h = &default_boot_hstate;
> > > +
> > > +	/*
> > > +	 * max_hstate means we've parsed a hugepagesz= parameter, so
> > > +	 * use the [most recently] parsed_hstate.  Else use default.
> > > +	 */
> > > +	if (max_hstate)
> > > +		h = parsed_hstate;
> > > +
> > > +	return set_hstate_nodes_allowed(h, s, 0);
> > > +}
> > > +__setup("hugepages_nodes_allowed=", hugetlb_nodes_allowed_setup);
> > > +
> > >  static unsigned int cpuset_mems_nr(unsigned int *array)
> > >  {
> > >  	int node;
> > > 
> > 
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
