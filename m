Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 126FD6B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:42:41 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n98KgbT9009917
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 21:42:37 +0100
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by spaceape11.eur.corp.google.com with ESMTP id n98KfKBC026800
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:42:35 -0700
Received: by pzk11 with SMTP id 11so4570173pzk.14
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:42:34 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:42:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 7/12] hugetlb:  add per node hstate attributes
In-Reply-To: <20091008162539.23192.3642.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162539.23192.3642.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-10-07 12:31:59.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-07 12:32:01.000000000 -0400
> @@ -24,6 +24,7 @@
>  #include <asm/io.h>
>  
>  #include <linux/hugetlb.h>
> +#include <linux/node.h>
>  #include "internal.h"
>  
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> @@ -1320,39 +1321,71 @@ out:
>  static struct kobject *hugepages_kobj;
>  static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
>  
> -static struct hstate *kobj_to_hstate(struct kobject *kobj)
> +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp);
> +
> +static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
>  {
>  	int i;
> +
>  	for (i = 0; i < HUGE_MAX_HSTATE; i++)
> -		if (hstate_kobjs[i] == kobj)
> +		if (hstate_kobjs[i] == kobj) {
> +			if (nidp)
> +				*nidp = NUMA_NO_NODE;
>  			return &hstates[i];
> -	BUG();
> -	return NULL;
> +		}
> +
> +	return kobj_to_node_hstate(kobj, nidp);
>  }
>  
>  static ssize_t nr_hugepages_show_common(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> -	struct hstate *h = kobj_to_hstate(kobj);
> -	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> +	struct hstate *h;
> +	unsigned long nr_huge_pages;
> +	int nid;
> +
> +	h = kobj_to_hstate(kobj, &nid);
> +	if (nid == NUMA_NO_NODE)
> +		nr_huge_pages = h->nr_huge_pages;
> +	else
> +		nr_huge_pages = h->nr_huge_pages_node[nid];
> +
> +	return sprintf(buf, "%lu\n", nr_huge_pages);
>  }
>  static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  			struct kobject *kobj, struct kobj_attribute *attr,
>  			const char *buf, size_t len)
>  {
>  	int err;
> +	int nid;
>  	unsigned long count;
> -	struct hstate *h = kobj_to_hstate(kobj);
> +	struct hstate *h;
>  	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
>  
>  	err = strict_strtoul(buf, 10, &count);
>  	if (err)
>  		return 0;
>  
> -	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
> -		NODEMASK_FREE(nodes_allowed);
> -		nodes_allowed = &node_online_map;
> -	}
> +	h = kobj_to_hstate(kobj, &nid);
> +	if (nid == NUMA_NO_NODE) {
> +		/*
> +		 * global hstate attribute
> +		 */
> +		if (!(obey_mempolicy &&
> +				init_nodemask_of_mempolicy(nodes_allowed))) {
> +			NODEMASK_FREE(nodes_allowed);
> +			nodes_allowed = &node_states[N_HIGH_MEMORY];
> +		}
> +	} else if (nodes_allowed) {
> +		/*
> +		 * per node hstate attribute: adjust count to global,
> +		 * but restrict alloc/free to the specified node.
> +		 */
> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		init_nodemask_of_node(nodes_allowed, nid);
> +	} else
> +		nodes_allowed = &node_states[N_HIGH_MEMORY];
> +
>  	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>  
>  	if (nodes_allowed != &node_online_map)
> @@ -1398,7 +1431,7 @@ HSTATE_ATTR(nr_hugepages_mempolicy);
>  static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> -	struct hstate *h = kobj_to_hstate(kobj);
> +	struct hstate *h = kobj_to_hstate(kobj, NULL);
>  	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
>  }
>  static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
> @@ -1406,7 +1439,7 @@ static ssize_t nr_overcommit_hugepages_s
>  {
>  	int err;
>  	unsigned long input;
> -	struct hstate *h = kobj_to_hstate(kobj);
> +	struct hstate *h = kobj_to_hstate(kobj, NULL);
>  
>  	err = strict_strtoul(buf, 10, &input);
>  	if (err)
> @@ -1423,15 +1456,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
>  static ssize_t free_hugepages_show(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> -	struct hstate *h = kobj_to_hstate(kobj);
> -	return sprintf(buf, "%lu\n", h->free_huge_pages);
> +	struct hstate *h;
> +	unsigned long free_huge_pages;
> +	int nid;
> +
> +	h = kobj_to_hstate(kobj, &nid);
> +	if (nid == NUMA_NO_NODE)
> +		free_huge_pages = h->free_huge_pages;
> +	else
> +		free_huge_pages = h->free_huge_pages_node[nid];
> +
> +	return sprintf(buf, "%lu\n", free_huge_pages);
>  }
>  HSTATE_ATTR_RO(free_hugepages);
>  
>  static ssize_t resv_hugepages_show(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> -	struct hstate *h = kobj_to_hstate(kobj);
> +	struct hstate *h = kobj_to_hstate(kobj, NULL);
>  	return sprintf(buf, "%lu\n", h->resv_huge_pages);
>  }
>  HSTATE_ATTR_RO(resv_hugepages);
> @@ -1439,8 +1481,17 @@ HSTATE_ATTR_RO(resv_hugepages);
>  static ssize_t surplus_hugepages_show(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> -	struct hstate *h = kobj_to_hstate(kobj);
> -	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
> +	struct hstate *h;
> +	unsigned long surplus_huge_pages;
> +	int nid;
> +
> +	h = kobj_to_hstate(kobj, &nid);
> +	if (nid == NUMA_NO_NODE)
> +		surplus_huge_pages = h->surplus_huge_pages;
> +	else
> +		surplus_huge_pages = h->surplus_huge_pages_node[nid];
> +
> +	return sprintf(buf, "%lu\n", surplus_huge_pages);
>  }
>  HSTATE_ATTR_RO(surplus_hugepages);
>  
> @@ -1460,19 +1511,21 @@ static struct attribute_group hstate_att
>  	.attrs = hstate_attrs,
>  };
>  
> -static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
> +static int __init hugetlb_sysfs_add_hstate(struct hstate *h,
> +				struct kobject *parent,
> +				struct kobject **hstate_kobjs,
> +				struct attribute_group *hstate_attr_group)
>  {
>  	int retval;
> +	int hi = h - hstates;
>  
> -	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name,
> -							hugepages_kobj);
> -	if (!hstate_kobjs[h - hstates])
> +	hstate_kobjs[hi] = kobject_create_and_add(h->name, parent);
> +	if (!hstate_kobjs[hi])
>  		return -ENOMEM;
>  
> -	retval = sysfs_create_group(hstate_kobjs[h - hstates],
> -							&hstate_attr_group);
> +	retval = sysfs_create_group(hstate_kobjs[hi], hstate_attr_group);
>  	if (retval)
> -		kobject_put(hstate_kobjs[h - hstates]);
> +		kobject_put(hstate_kobjs[hi]);
>  
>  	return retval;
>  }
> @@ -1487,17 +1540,184 @@ static void __init hugetlb_sysfs_init(vo
>  		return;
>  
>  	for_each_hstate(h) {
> -		err = hugetlb_sysfs_add_hstate(h);
> +		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
> +					 hstate_kobjs, &hstate_attr_group);
>  		if (err)
>  			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
>  								h->name);
>  	}
>  }
>  
> +#ifdef CONFIG_NUMA
> +
> +/*
> + * node_hstate/s - associate per node hstate attributes, via their kobjects,
> + * with node sysdevs in node_devices[] using a parallel array.  The array
> + * index of a node sysdev or _hstate == node id.
> + * This is here to avoid any static dependency of the node sysdev driver, in
> + * the base kernel, on the hugetlb module.
> + */
> +struct node_hstate {
> +	struct kobject		*hugepages_kobj;
> +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> +};
> +struct node_hstate node_hstates[MAX_NUMNODES];
> +
> +/*
> + * A subset of global hstate attributes for node sysdevs
> + */
> +static struct attribute *per_node_hstate_attrs[] = {
> +	&nr_hugepages_attr.attr,
> +	&free_hugepages_attr.attr,
> +	&surplus_hugepages_attr.attr,
> +	NULL,
> +};
> +
> +static struct attribute_group per_node_hstate_attr_group = {
> +	.attrs = per_node_hstate_attrs,
> +};
> +
> +/*
> + * kobj_to_node_hstate - lookup global hstate for node sysdev hstate attr kobj.
> + * Returns node id via non-NULL nidp.
> + */
> +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> +{
> +	int nid;
> +
> +	for (nid = 0; nid < nr_node_ids; nid++) {

I previously asked if this should use for_each_node_mask() instead?

> +		struct node_hstate *nhs = &node_hstates[nid];
> +		int i;
> +		for (i = 0; i < HUGE_MAX_HSTATE; i++)
> +			if (nhs->hstate_kobjs[i] == kobj) {
> +				if (nidp)
> +					*nidp = nid;
> +				return &hstates[i];
> +			}
> +	}
> +
> +	BUG();
> +	return NULL;
> +}
> +
> +/*
> + * Unregister hstate attributes from a single node sysdev.
> + * No-op if no hstate attributes attached.
> + */
> +void hugetlb_unregister_node(struct node *node)
> +{
> +	struct hstate *h;
> +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> +
> +	if (!nhs->hugepages_kobj)
> +		return;
> +
> +	for_each_hstate(h)
> +		if (nhs->hstate_kobjs[h - hstates]) {
> +			kobject_put(nhs->hstate_kobjs[h - hstates]);
> +			nhs->hstate_kobjs[h - hstates] = NULL;
> +		}
> +
> +	kobject_put(nhs->hugepages_kobj);
> +	nhs->hugepages_kobj = NULL;
> +}
> +
> +/*
> + * hugetlb module exit:  unregister hstate attributes from node sysdevs
> + * that have them.
> + */
> +static void hugetlb_unregister_all_nodes(void)
> +{
> +	int nid;
> +
> +	/*
> +	 * disable node sysdev registrations.
> +	 */
> +	register_hugetlbfs_with_node(NULL, NULL);
> +
> +	/*
> +	 * remove hstate attributes from any nodes that have them.
> +	 */
> +	for (nid = 0; nid < nr_node_ids; nid++)
> +		hugetlb_unregister_node(&node_devices[nid]);
> +}
> +
> +/*
> + * Register hstate attributes for a single node sysdev.
> + * No-op if attributes already registered.
> + */
> +void hugetlb_register_node(struct node *node)
> +{
> +	struct hstate *h;
> +	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
> +	int err;
> +
> +	if (nhs->hugepages_kobj)
> +		return;		/* already allocated */
> +
> +	nhs->hugepages_kobj = kobject_create_and_add("hugepages",
> +							&node->sysdev.kobj);
> +	if (!nhs->hugepages_kobj)
> +		return;
> +
> +	for_each_hstate(h) {
> +		err = hugetlb_sysfs_add_hstate(h, nhs->hugepages_kobj,
> +						nhs->hstate_kobjs,
> +						&per_node_hstate_attr_group);
> +		if (err) {
> +			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
> +					" for node %d\n",
> +						h->name, node->sysdev.id);
> +			hugetlb_unregister_node(node);
> +			break;
> +		}
> +	}
> +}
> +
> +/*
> + * hugetlb init time:  register hstate attributes for all registered
> + * node sysdevs.  All on-line nodes should have registered their
> + * associated sysdev by the time the hugetlb module initializes.
> + */
> +static void hugetlb_register_all_nodes(void)
> +{
> +	int nid;
> +
> +	for (nid = 0; nid < nr_node_ids; nid++) {
> +		struct node *node = &node_devices[nid];
> +		if (node->sysdev.id == nid)
> +			hugetlb_register_node(node);
> +	}

This looks like another use of for_each_node_mask over N_HIGH_MEMORY.  I 
previously asked if the check for node->sysdev.id == nid is still 
necessary at this point?

> +
> +	/*
> +	 * Let the node sysdev driver know we're here so it can
> +	 * [un]register hstate attributes on node hotplug.
> +	 */
> +	register_hugetlbfs_with_node(hugetlb_register_node,
> +				     hugetlb_unregister_node);
> +}
> +#else	/* !CONFIG_NUMA */
> +
> +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> +{
> +	BUG();
> +	if (nidp)
> +		*nidp = -1;
> +	return NULL;
> +}
> +
> +static void hugetlb_unregister_all_nodes(void) { }
> +
> +static void hugetlb_register_all_nodes(void) { }
> +
> +#endif
> +
>  static void __exit hugetlb_exit(void)
>  {
>  	struct hstate *h;
>  
> +	hugetlb_unregister_all_nodes();
> +
>  	for_each_hstate(h) {
>  		kobject_put(hstate_kobjs[h - hstates]);
>  	}
> @@ -1532,6 +1752,8 @@ static int __init hugetlb_init(void)
>  
>  	hugetlb_sysfs_init();
>  
> +	hugetlb_register_all_nodes();
> +
>  	return 0;
>  }
>  module_init(hugetlb_init);
> Index: linux-2.6.31-mmotm-090925-1435/include/linux/node.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/node.h	2009-10-07 12:31:51.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/include/linux/node.h	2009-10-07 12:32:01.000000000 -0400
> @@ -28,6 +28,7 @@ struct node {
>  
>  struct memory_block;
>  extern struct node node_devices[];
> +typedef  void (*node_registration_func_t)(struct node *);
>  
>  extern int register_node(struct node *, int, struct node *);
>  extern void unregister_node(struct node *node);

I previously suggested against the typedef unless this functionality (node 
hotplug notifiers) becomes more generic outside of the hugetlb use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
