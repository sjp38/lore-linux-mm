Date: Tue, 18 Mar 2008 14:34:38 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [5/18] Expand the hugetlbfs sysctls to handle arrays for all hstates
Message-ID: <20080318143438.GE23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015818.E30041B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015818.E30041B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> - I didn't bother with hugetlb_shm_group and treat_as_movable,
> these are still single global.

I cannot imagine why either of those would be per-pool anyway.
Potentially shm_group could become a per-mount value which is both
outside the scope of this patchset and not per-pool so unsuitable for
hstate. 

> - Also improve error propagation for the sysctl handlers a bit
> 
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  include/linux/hugetlb.h |    5 +++--
>  kernel/sysctl.c         |    2 +-
>  mm/hugetlb.c            |   43 +++++++++++++++++++++++++++++++------------
>  3 files changed, 35 insertions(+), 15 deletions(-)
> 
> Index: linux/include/linux/hugetlb.h
> ===================================================================
> --- linux.orig/include/linux/hugetlb.h
> +++ linux/include/linux/hugetlb.h
> @@ -32,8 +32,6 @@ int hugetlb_fault(struct mm_struct *mm, 
>  int hugetlb_reserve_pages(struct inode *inode, long from, long to);
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  
> -extern unsigned long max_huge_pages;
> -extern unsigned long sysctl_overcommit_huge_pages;
>  extern unsigned long hugepages_treat_as_movable;
>  extern const unsigned long hugetlb_zero, hugetlb_infinity;
>  extern int sysctl_hugetlb_shm_group;
> @@ -258,6 +256,9 @@ static inline unsigned huge_page_shift(s
>  	return h->order + PAGE_SHIFT;
>  }
>  
> +extern unsigned long max_huge_pages[HUGE_MAX_HSTATE];
> +extern unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];

Any particular reason for moving them?

Also, offhand it's not super-clear why max_huge_pages is not part of
hstate as we only expect one hstate per pagesize anyway.

> +
>  #else
>  struct hstate {};
>  #define hstate_file(f) NULL
> Index: linux/kernel/sysctl.c
> ===================================================================
> --- linux.orig/kernel/sysctl.c
> +++ linux/kernel/sysctl.c
> @@ -935,7 +935,7 @@ static struct ctl_table vm_table[] = {
>  	 {
>  		.procname	= "nr_hugepages",
>  		.data		= &max_huge_pages,
> -		.maxlen		= sizeof(unsigned long),
> +		.maxlen 	= sizeof(max_huge_pages),
>  		.mode		= 0644,
>  		.proc_handler	= &hugetlb_sysctl_handler,
>  		.extra1		= (void *)&hugetlb_zero,
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -22,8 +22,8 @@
>  #include "internal.h"
>  
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> -unsigned long max_huge_pages;
> -unsigned long sysctl_overcommit_huge_pages;
> +unsigned long max_huge_pages[HUGE_MAX_HSTATE];
> +unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
>  
> @@ -496,11 +496,11 @@ static int __init hugetlb_init_hstate(st
>  
>  	h->hugetlb_next_nid = first_node(node_online_map);
>  
> -	for (i = 0; i < max_huge_pages; ++i) {
> +	for (i = 0; i < max_huge_pages[h - hstates]; ++i) {
>  		if (!alloc_fresh_huge_page(h))
>  			break;
>  	}
> -	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> +	max_huge_pages[h - hstates] = h->free_huge_pages = h->nr_huge_pages = i;
>  

hmm ok, it looks a little weird to be working out h - hstates multiple times
in a loop when it is invariant but functionally, it's fine.

>  	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
>  			h->free_huge_pages,
> @@ -531,8 +531,9 @@ void __init huge_add_hstate(unsigned ord
>  
>  static int __init hugetlb_setup(char *s)
>  {
> -	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
> -		max_huge_pages = 0;
> +	unsigned long *mhp = &max_huge_pages[parsed_hstate - hstates];

This looks like we are assuming there is only ever one other
parsed_hstate. For the purposes of what you aim to achieve in this set,
it's not important but a comment over parsed_hstate about this
assumption is probably necessary.

> +	if (sscanf(s, "%lu", mhp) <= 0)
> +		*mhp = 0;
>  	return 1;
>  }
>  __setup("hugepages=", hugetlb_setup);
> @@ -584,10 +585,12 @@ static inline void try_to_free_low(unsig
>  #endif
>  
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> -static unsigned long set_max_huge_pages(unsigned long count)
> +static unsigned long
> +set_max_huge_pages(struct hstate *h, unsigned long count, int *err)
>  {
>  	unsigned long min_count, ret;
> -	struct hstate *h = &global_hstate;
> +
> +	*err = 0;
>  

What is updating err to anything else in set_max_huge_pages()?

>  	/*
>  	 * Increase the pool size
> @@ -659,8 +662,20 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  			   struct file *file, void __user *buffer,
>  			   size_t *length, loff_t *ppos)
>  {
> -	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> -	max_huge_pages = set_max_huge_pages(max_huge_pages);
> +	int err = 0;
> +	struct hstate *h;
> +	int i;
> +	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> +	if (err)
> +		return err;
> +	i = 0;
> +	for_each_hstate (h) {
> +		max_huge_pages[i] = set_max_huge_pages(h, max_huge_pages[i],
> +							&err);

hmm, this is saying when I write 10 to nr_hugepages, I am asking for 10
2MB pages and 10 1GB pages potentially. Is that what you want?

> +		if (err)
> +			return err;

I'm failing to see how the error handling is improved when
set_max_huge_pages() is not updating err. Maybe it happens in another
patch.

> +		i++;
> +	}
>  	return 0;
>  }
>  
> @@ -680,10 +695,14 @@ int hugetlb_overcommit_handler(struct ct
>  			struct file *file, void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h;
> +	int i = 0;
>  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
>  	spin_lock(&hugetlb_lock);
> -	h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
> +	for_each_hstate (h) {
> +		h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages[i];
> +		i++;
> +	}

Similar to the other sysctl here, the overcommit value is being set for
all the huge page sizes.

>  	spin_unlock(&hugetlb_lock);
>  	return 0;
>  }
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
