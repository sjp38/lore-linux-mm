Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PHca1e009198
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:38:36 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PHcZvc177086
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 11:38:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PHcZWO031073
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 11:38:35 -0600
Date: Fri, 25 Apr 2008 10:38:27 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080425173827.GC9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.162027000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:07 +1000], npiggin@suse.de wrote:
> Add basic support for more than one hstate in hugetlbfs
> 
> - Convert hstates to an array
> - Add a first default entry covering the standard huge page size
> - Add functions for architectures to register new hstates
> - Add basic iterators over hstates
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/hugetlb.h |   11 ++++
>  mm/hugetlb.c            |  112 +++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 97 insertions(+), 26 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -27,7 +27,17 @@ unsigned long sysctl_overcommit_huge_pag
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
> 
> -struct hstate global_hstate;
> +static int max_hstate = 0;
> +
> +static unsigned long default_hstate_resv = 0;

Unnecessary initializations (and whitespace)?

What's the purpose of default_hstate_resv? Isn't it basically just
replacing max_huge_pages? "resv" has a very special meaning in
hugetlb.c, can another name be chosen?

> +struct hstate hstates[HUGE_MAX_HSTATE];
> +
> +/* for command line parsing */
> +struct hstate *parsed_hstate __initdata = NULL;

Unnecessary initialization (checkpatch caught the first two, not this
one). Should this be static? Isn't __initdata traditionally put closer
to the front of the line?

> +#define for_each_hstate(h) \
> +	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
> 
>  /*
>   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> @@ -128,9 +138,19 @@ static void update_and_free_page(struct 
>  	__free_pages(page, huge_page_order(h));
>  }
> 
> +struct hstate *size_to_hstate(unsigned long size)
> +{
> +	struct hstate *h;
> +	for_each_hstate (h) {

Extraneous space?

> +		if (huge_page_size(h) == size)
> +			return h;
> +	}
> +	return NULL;
> +}

Might become annoying if we add many hugepagesizes, but I guess we'll
never have enough to really matter. Just don't want to have to worry
about this loop for performance reasons when only one hugepage size is
in use? Would it make sense to cache the last value used? Probably
overkill for now.

>  static void free_huge_page(struct page *page)
>  {
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = size_to_hstate(PAGE_SIZE << compound_order(page));

Perhaps this could be made a static inline function?

static inline page_hstate(struct page *page)
{
	return size_to_hstate(PAGE_SIZE << compound_order(page))
}

I guess I haven't checked yet if it's used anywhere else, but it makes
things a little clearer, perhaps?

And this is only needed to be done actually for the destructor case?
Technically, we have the hstate already in the set_max_huge_pages()
path? Might be worth a cleanup down-the-road.

>  	int nid = page_to_nid(page);
>  	struct address_space *mapping;
> 
> @@ -495,38 +515,80 @@ static struct page *alloc_huge_page(stru
>  	return page;
>  }
> 
> -static int __init hugetlb_init(void)
> +static void __init hugetlb_init_hstate(struct hstate *h)

Could this perhaps be named hugetlb_init_one_hstate()? Makes it harder
for me to go cross-eyed as I go between the functions :)

<snip>

> +static void __init report_hugepages(void)
> +{
> +	struct hstate *h;
> +
> +	for_each_hstate(h) {
> +		printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
> +				h->free_huge_pages,
> +				1 << (h->order + PAGE_SHIFT - 20));

This will need to be changed for 64K hugepages (which already exist in
mainline). Perhaps we need a hugepage_units() function :)

<snip>

> +/* Should be called on processing a hugepagesz=... option */
> +void __init huge_add_hstate(unsigned order)
> +{
> +	struct hstate *h;
> +	if (size_to_hstate(PAGE_SIZE << order)) {
> +		printk("hugepagesz= specified twice, ignoring\n");

Needs a KERN_ level.

And did we decide whether specifying hugepagesz= multiple times is ok,
or not?

> +		return;
> +	}
> +	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
> +	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
> +	h = &hstates[max_hstate++];
> +	h->order = order;
> +	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
> +	hugetlb_init_hstate(h);
> +	parsed_hstate = h;
> +}
> +
>  static int __init hugetlb_setup(char *s)
>  {
> -	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
> -		max_huge_pages = 0;
> +	if (sscanf(s, "%lu", &default_hstate_resv) <= 0)
> +		default_hstate_resv = 0;
>  	return 1;
>  }
>  __setup("hugepages=", hugetlb_setup);
> @@ -544,28 +606,27 @@ static unsigned int cpuset_mems_nr(unsig
> 
>  #ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(unsigned long count)
> +static void try_to_free_low(struct hstate *h, unsigned long count)
>  {
> -	struct hstate *h = &global_hstate;
>  	int i;
> 
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
>  		struct list_head *freel = &h->hugepage_freelists[i];
>  		list_for_each_entry_safe(page, next, freel, lru) {
> -			if (count >= nr_huge_pages)
> +			if (count >= h->nr_huge_pages)
>  				return;
>  			if (PageHighMem(page))
>  				continue;
>  			list_del(&page->lru);
> -			update_and_free_page(page);
> +			update_and_free_page(h, page);
>  			h->free_huge_pages--;
>  			h->free_huge_pages_node[page_to_nid(page)]--;
>  		}
>  	}
>  }
>  #else
> -static inline void try_to_free_low(unsigned long count)
> +static inline void try_to_free_low(struct hstate *h, unsigned long count)
>  {
>  }
>  #endif
> @@ -625,7 +686,7 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
>  	min_count = max(count, min_count);
> -	try_to_free_low(min_count);
> +	try_to_free_low(h, min_count);
>  	while (min_count < persistent_huge_pages(h)) {
>  		struct page *page = dequeue_huge_page(h);
>  		if (!page)
> @@ -648,6 +709,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  {
>  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
>  	max_huge_pages = set_max_huge_pages(max_huge_pages);
> +	global_hstate.max_huge_pages = max_huge_pages;

So this implies the sysctl still only controls the singe state? Perhaps
it would be better if this patch made set_max_huge_pages() take an
hstate? Also, this seems to be the only place where max_huge_pages is
still used, so can't you just do:

global_hstate.max_huge_pages = set_max_huge_pages(max_huge_pages); ?

<snip>

> @@ -1296,7 +1358,7 @@ out:
>  int hugetlb_reserve_pages(struct inode *inode, long from, long to)
>  {
>  	long ret, chg;
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = hstate_inode(inode);
> 
>  	chg = region_chg(&inode->i_mapping->private_list, from, to);
>  	if (chg < 0)
> @@ -1315,7 +1377,7 @@ int hugetlb_reserve_pages(struct inode *
> 
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  {
> -	struct hstate *h = &global_hstate;
> +	struct hstate *h = hstate_inode(inode);

Couldn't both of these changes have been made in the previous patch?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
