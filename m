Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A84886B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 23:26:12 -0400 (EDT)
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id n973Q8qa002064
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 20:26:08 -0700
Received: from pxi27 (pxi27.prod.google.com [10.243.27.27])
	by zps77.corp.google.com with ESMTP id n973Q5pO027379
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 20:26:06 -0700
Received: by pxi27 with SMTP id 27so4262494pxi.22
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 20:26:05 -0700 (PDT)
Date: Tue, 6 Oct 2009 20:26:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/11] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <20091006031802.22576.46384.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910062002440.3099@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031802.22576.46384.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/mempolicy.c	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c	2009-09-30 12:48:46.000000000 -0400
> @@ -1564,6 +1564,53 @@ struct zonelist *huge_zonelist(struct vm
>  	}
>  	return zl;
>  }
> +
> +/*
> + * init_nodemask_of_mempolicy
> + *
> + * If the current task's mempolicy is "default" [NULL], return 'false'
> + * to indicate * default policy.  Otherwise, extract the policy nodemask
> + * for 'bind' * or 'interleave' policy into the argument nodemask, or
> + * initialize the argument nodemask to contain the single node for
> + * 'preferred' or * 'local' policy and return 'true' to indicate presence
> + * of non-default mempolicy.
> + *

Looks like some mangling of the comment, there's spurious '*' throughout.

> + * We don't bother with reference counting the mempolicy [mpol_get/put]
> + * because the current task is examining it's own mempolicy and a task's
> + * mempolicy is only ever changed by the task itself.
> + *
> + * N.B., it is the caller's responsibility to free a returned nodemask.
> + */
> +bool init_nodemask_of_mempolicy(nodemask_t *mask)
> +{
> +	struct mempolicy *mempolicy;
> +	int nid;
> +
> +	if (!current->mempolicy)
> +		return false;
> +
> +	mempolicy = current->mempolicy;
> +	switch (mempolicy->mode) {
> +	case MPOL_PREFERRED:
> +		if (mempolicy->flags & MPOL_F_LOCAL)
> +			nid = numa_node_id();
> +		else
> +			nid = mempolicy->v.preferred_node;
> +		init_nodemask_of_node(mask, nid);
> +		break;
> +
> +	case MPOL_BIND:
> +		/* Fall through */
> +	case MPOL_INTERLEAVE:
> +		*mask =  mempolicy->v.nodes;
> +		break;
> +
> +	default:
> +		BUG();
> +	}
> +
> +	return true;
> +}
>  #endif
>  
>  /* Allocate a page in interleaved policy.
> Index: linux-2.6.31-mmotm-090925-1435/include/linux/mempolicy.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/mempolicy.h	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/include/linux/mempolicy.h	2009-09-30 12:48:46.000000000 -0400
> @@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
> +extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
>  	return node_zonelist(0, gfp_flags);
>  }
>  
> +static inline bool init_nodemask_of_mempolicy(nodemask_t *m) { return false; }
> +
>  static inline int do_migrate_pages(struct mm_struct *mm,
>  			const nodemask_t *from_nodes,
>  			const nodemask_t *to_nodes, int flags)
> Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-02 21:22:04.000000000 -0400
> @@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
>  	return NULL;
>  }
>  
> -static ssize_t nr_hugepages_show(struct kobject *kobj,
> +static ssize_t nr_hugepages_show_common(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
>  	struct hstate *h = kobj_to_hstate(kobj);
>  	return sprintf(buf, "%lu\n", h->nr_huge_pages);
>  }
> -static ssize_t nr_hugepages_store(struct kobject *kobj,
> -		struct kobj_attribute *attr, const char *buf, size_t count)
> +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> +			struct kobject *kobj, struct kobj_attribute *attr,
> +			const char *buf, size_t len)
>  {
>  	int err;
> -	unsigned long input;
> +	unsigned long count;
>  	struct hstate *h = kobj_to_hstate(kobj);
> +	NODEMASK_ALLOC(nodemask, nodes_allowed);
>  

In the two places you do NODEMASK_ALLOC(), here and 
hugetlb_sysctl_handler(), you'll need to check that nodes_allowed is 
non-NULL since it's possible that kmalloc() will return NULL for 
CONFIG_NODES_SHIFT > 8.

In such a case, it's probably sufficient to simply set nodes_allowed to 
node_states[N_HIGH_MEMORY] so that we can still free hugepages when we're 
oom, a common memory freeing tactic.

You could do that by simply returning false from 
init_nodemask_of_mempolicy() if !nodes_allowed since NODEMASK_FREE() can 
take a NULL pointer, but it may be easier to factor that logic into your 
conditional below:

> -	err = strict_strtoul(buf, 10, &input);
> +	err = strict_strtoul(buf, 10, &count);
>  	if (err)
>  		return 0;
>  
> -	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
> +	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
> +		NODEMASK_FREE(nodes_allowed);
> +		nodes_allowed = &node_online_map;
> +	}
> +	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>

You can get away with just testing !nodes_allowed here since the stack 
allocation variation of NODEMASK_ALLOC() is such that nodes_allowed will 
always be an initialized pointer pointing to _nodes_allowed so you won't 
have an uninitialized warning.

Once that's done, you can get rid of the check for a NULL nodes_allowed in 
try_to_free_low() from patch 2 since it will always be valid in 
set_max_huge_pages().

> -	return count;
> +	if (nodes_allowed != &node_online_map)
> +		NODEMASK_FREE(nodes_allowed);
> +
> +	return len;
> +}
> +
> +static ssize_t nr_hugepages_show(struct kobject *kobj,
> +				       struct kobj_attribute *attr, char *buf)
> +{
> +	return nr_hugepages_show_common(kobj, attr, buf);
> +}
> +
> +static ssize_t nr_hugepages_store(struct kobject *kobj,
> +	       struct kobj_attribute *attr, const char *buf, size_t len)
> +{
> +	return nr_hugepages_store_common(false, kobj, attr, buf, len);
>  }
>  HSTATE_ATTR(nr_hugepages);
>  
> +#ifdef CONFIG_NUMA
> +
> +/*
> + * hstate attribute for optionally mempolicy-based constraint on persistent
> + * huge page alloc/free.
> + */
> +static ssize_t nr_hugepages_mempolicy_show(struct kobject *kobj,
> +				       struct kobj_attribute *attr, char *buf)
> +{
> +	return nr_hugepages_show_common(kobj, attr, buf);
> +}
> +
> +static ssize_t nr_hugepages_mempolicy_store(struct kobject *kobj,
> +	       struct kobj_attribute *attr, const char *buf, size_t len)
> +{
> +	return nr_hugepages_store_common(true, kobj, attr, buf, len);
> +}
> +HSTATE_ATTR(nr_hugepages_mempolicy);
> +#endif
> +
> +
>  static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
> @@ -1412,6 +1454,9 @@ static struct attribute *hstate_attrs[]
>  	&free_hugepages_attr.attr,
>  	&resv_hugepages_attr.attr,
>  	&surplus_hugepages_attr.attr,
> +#ifdef CONFIG_NUMA
> +	&nr_hugepages_mempolicy_attr.attr,
> +#endif
>  	NULL,
>  };
>  
> @@ -1578,9 +1623,9 @@ static unsigned int cpuset_mems_nr(unsig
>  }
>  
>  #ifdef CONFIG_SYSCTL
> -int hugetlb_sysctl_handler(struct ctl_table *table, int write,
> -			   void __user *buffer,
> -			   size_t *length, loff_t *ppos)
> +static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
> +			 struct ctl_table *table, int write,
> +			 void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	struct hstate *h = &default_hstate;
>  	unsigned long tmp;
> @@ -1592,13 +1637,39 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  	table->maxlen = sizeof(unsigned long);
>  	proc_doulongvec_minmax(table, write, buffer, length, ppos);
>  
> -	if (write)
> -		h->max_huge_pages = set_max_huge_pages(h, tmp,
> -							&node_online_map);
> +	if (write) {
> +		NODEMASK_ALLOC(nodemask, nodes_allowed);
> +		if (!(obey_mempolicy &&
> +			       init_nodemask_of_mempolicy(nodes_allowed))) {
> +			NODEMASK_FREE(nodes_allowed);
> +			nodes_allowed = &node_states[N_HIGH_MEMORY];
> +		}
> +		h->max_huge_pages = set_max_huge_pages(h, tmp, nodes_allowed);
> +
> +		if (nodes_allowed != &node_states[N_HIGH_MEMORY])
> +			NODEMASK_FREE(nodes_allowed);
> +	}
>  
>  	return 0;
>  }
>  
> +int hugetlb_sysctl_handler(struct ctl_table *table, int write,
> +			  void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +
> +	return hugetlb_sysctl_handler_common(false, table, write,
> +							buffer, length, ppos);
> +}
> +
> +#ifdef CONFIG_NUMA
> +int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
> +			  void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	return hugetlb_sysctl_handler_common(true, table, write,
> +							buffer, length, ppos);
> +}
> +#endif /* CONFIG_NUMA */
> +
>  int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
>  			void __user *buffer,
>  			size_t *length, loff_t *ppos)
> Index: linux-2.6.31-mmotm-090925-1435/include/linux/hugetlb.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/hugetlb.h	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/include/linux/hugetlb.h	2009-09-30 12:48:46.000000000 -0400
> @@ -23,6 +23,12 @@ void reset_vma_resv_huge_pages(struct vm
>  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> +
> +#ifdef CONFIG_NUMA
> +int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
> +					void __user *, size_t *, loff_t *);
> +#endif
> +
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
>  int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
>  			struct page **, struct vm_area_struct **,
> Index: linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/kernel/sysctl.c	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c	2009-09-30 12:48:46.000000000 -0400
> @@ -1164,7 +1164,7 @@ static struct ctl_table vm_table[] = {
>  		.extra2		= &one_hundred,
>  	},
>  #ifdef CONFIG_HUGETLB_PAGE
> -	 {
> +	{
>  		.procname	= "nr_hugepages",
>  		.data		= NULL,
>  		.maxlen		= sizeof(unsigned long),
> @@ -1172,7 +1172,19 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler	= &hugetlb_sysctl_handler,
>  		.extra1		= (void *)&hugetlb_zero,
>  		.extra2		= (void *)&hugetlb_infinity,
> -	 },
> +	},
> +#ifdef CONFIG_NUMA
> +	{
> +	       .ctl_name       = CTL_UNNUMBERED,
> +	       .procname       = "nr_hugepages_mempolicy",
> +	       .data           = NULL,
> +	       .maxlen         = sizeof(unsigned long),
> +	       .mode           = 0644,
> +	       .proc_handler   = &hugetlb_mempolicy_sysctl_handler,
> +	       .extra1	 = (void *)&hugetlb_zero,
> +	       .extra2	 = (void *)&hugetlb_infinity,
> +	},
> +#endif
>  	 {
>  		.ctl_name	= VM_HUGETLB_GROUP,
>  		.procname	= "hugetlb_shm_group",
> 

There's some whitespace damage in the nr_hugepages_mempolicy hunk, it 
needs tabs instead of spaces for alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
