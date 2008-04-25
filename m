Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PHEAGw027635
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:14:10 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PHEAJB253662
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:14:10 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PHDx47010747
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:14:00 -0400
Date: Fri, 25 Apr 2008 10:13:46 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 04/18] hugetlb: modular state
Message-ID: <20080425171346.GB9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.054070000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.054070000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:06 +1000], npiggin@suse.de wrote:
> Large, but rather mechanical patch that converts most of the hugetlb.c
> globals into structure members and passes them around.
> 
> Right now there is only a single global hstate structure, but most of
> the infrastructure to extend it is there.

While going through the patches as I apply them to 2.6.25-mm1 (as none
will apply cleanly so far :), I have a few comments. I like this patch
overall.

> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c

<snip>

> +struct hstate global_hstate;

One thing I noticed throughout is that it's sort of inconsistent where a
hstate is passed to a function and where it's locally determined in
functions. It seems like we should obtain the hstate as early as
possible and just pass the pointer down as needed ... except in those
contexts that we don't control the caller, of course. That seems to be
more flexible than the way this patch does it, especially given that the
whole thing is a series that immediately extends this infrastructure to
multiple hugepage sizes. That would seem to, at least, make the
follow-on patches easier to follow.

> 
>  /*
>   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
>   */
>  static DEFINE_SPINLOCK(hugetlb_lock);

Not sure if this makes sense or not, but would it be useful to make the
lock be per-hstate? It is designed to protect the counters and the
freelists, but those are per-hstate, right? Would need heavy testing,
but might be useful for varying apps both trying to use different size
hugepages simultaneously?

<snip>

> @@ -98,18 +93,19 @@ static struct page *dequeue_huge_page_vm
>  	struct zonelist *zonelist = huge_zonelist(vma, address,
>  					htlb_alloc_mask, &mpol);
>  	struct zone **z;
> +	struct hstate *h = hstate_vma(vma);

Why not make dequeue_huge_page_vma() take an hstate too? All the callers
have the vma, which means they can do this call themselves ... makes
more for a more consistent API between the two dequeue_ variants.

<snip>

>  static void free_huge_page(struct page *page)
>  {
> +	struct hstate *h = &global_hstate;
>  	int nid = page_to_nid(page);
>  	struct address_space *mapping;

Similarly, the only caller of free_huge_page has already figured out the
hstate to use (even if there is only one) -- why not pass it down here?

Oh here it might be because free_huge_page is used as the destructor --
perhaps add a comment?

<snip>

> -static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> -						unsigned long address)
> +static struct page *alloc_buddy_huge_page(struct hstate *h,
> +					  struct vm_area_struct *vma,
> +					  unsigned long address)
>  {
>  	struct page *page;
>  	unsigned int nid;
> @@ -277,17 +275,17 @@ static struct page *alloc_buddy_huge_pag
>  	 * per-node value is checked there.
>  	 */
>  	spin_lock(&hugetlb_lock);
> -	if (surplus_huge_pages >= nr_overcommit_huge_pages) {
> +	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
>  		spin_unlock(&hugetlb_lock);
>  		return NULL;
>  	} else {
> -		nr_huge_pages++;
> -		surplus_huge_pages++;
> +		h->nr_huge_pages++;
> +		h->surplus_huge_pages++;
>  	}
>  	spin_unlock(&hugetlb_lock);
> 
>  	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
> -					HUGETLB_PAGE_ORDER);
> +			   huge_page_order(h));

Nit: odd indentation?

<snip>

> @@ -539,19 +546,21 @@ static unsigned int cpuset_mems_nr(unsig
>  #ifdef CONFIG_HIGHMEM
>  static void try_to_free_low(unsigned long count)
>  {

Shouldn't this just take an hstate as a parameter?

> +	struct hstate *h = &global_hstate;
>  	int i;
> 
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
> -		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
> +		struct list_head *freel = &h->hugepage_freelists[i];
> +		list_for_each_entry_safe(page, next, freel, lru) {

Was this does just to make the line shorter? Just want to make sure I'm
not missing something.

<snip>

>  int hugetlb_report_meminfo(char *buf)
>  {
> +	struct hstate *h = &global_hstate;
>  	return sprintf(buf,
>  			"HugePages_Total: %5lu\n"
>  			"HugePages_Free:  %5lu\n"
>  			"HugePages_Rsvd:  %5lu\n"
>  			"HugePages_Surp:  %5lu\n"
>  			"Hugepagesize:    %5lu kB\n",
> -			nr_huge_pages,
> -			free_huge_pages,
> -			resv_huge_pages,
> -			surplus_huge_pages,
> -			HPAGE_SIZE/1024);
> +			h->nr_huge_pages,
> +			h->free_huge_pages,
> +			h->resv_huge_pages,
> +			h->surplus_huge_pages,
> +			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));

"- 10"? I think this should be easier to get at then this? Oh I guess
it's to get it into kilobytes... Seems kind of odd, but I guess it's
fine.

<snip>

> Index: linux-2.6/include/linux/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/linux/hugetlb.h
> +++ linux-2.6/include/linux/hugetlb.h
> @@ -40,7 +40,7 @@ extern int sysctl_hugetlb_shm_group;
> 
>  /* arch callbacks */
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz);
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
>  int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
>  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
> @@ -95,7 +95,6 @@ pte_t huge_ptep_get_and_clear(struct mm_
>  #else
>  void hugetlb_prefault_arch_hook(struct mm_struct *mm);
>  #endif
> -

Unrelated whitespace change?

>  #else /* !CONFIG_HUGETLB_PAGE */
> 
>  static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> @@ -169,8 +168,6 @@ struct file *hugetlb_file_setup(const ch
>  int hugetlb_get_quota(struct address_space *mapping, long delta);
>  void hugetlb_put_quota(struct address_space *mapping, long delta);
> 
> -#define BLOCKS_PER_HUGEPAGE	(HPAGE_SIZE / 512)
> -

Rather than deleting this and then putting the similar calculation in
the two callers, perhaps use an inline to calculate it and call that in
the two places you change?

>  static inline int is_file_hugepages(struct file *file)
>  {
>  	if (file->f_op == &hugetlbfs_file_operations)
> @@ -199,4 +196,71 @@ unsigned long hugetlb_get_unmapped_area(
>  					unsigned long flags);
>  #endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
> 
> +#ifdef CONFIG_HUGETLB_PAGE

Why another block of HUGETLB_PAGE? Shouldn't this go at the end of the
other one? And the !HUGETLB_PAGE within the corresponding #else?

> +
> +/* Defines one hugetlb page size */
> +struct hstate {
> +	int hugetlb_next_nid;
> +	unsigned int order;

Which is actually a shift, too, right? So why not just call it that? No
function should be direclty accessing these members, so the function
name indicates how the shift is being used?

> +	unsigned long mask;
> +	unsigned long max_huge_pages;
> +	unsigned long nr_huge_pages;
> +	unsigned long free_huge_pages;
> +	unsigned long resv_huge_pages;
> +	unsigned long surplus_huge_pages;
> +	unsigned long nr_overcommit_huge_pages;
> +	struct list_head hugepage_freelists[MAX_NUMNODES];
> +	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> +	unsigned int free_huge_pages_node[MAX_NUMNODES];
> +	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> +};
> +
> +extern struct hstate global_hstate;
> +
> +static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> +{
> +	return &global_hstate;
> +}

After having looked at this functions while reviewing, it does seem like
it might be more intuitive to ready vma_hstate ("vma's hstate") rather
than hstate_vma ("hstate's vma"?). But your call.

<snip>

> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c
> +++ linux-2.6/mm/mempolicy.c
> @@ -1295,7 +1295,8 @@ struct zonelist *huge_zonelist(struct vm
>  	if (pol->policy == MPOL_INTERLEAVE) {
>  		unsigned nid;
> 
> -		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> +		nid = interleave_nid(pol, vma, addr,
> +					huge_page_shift(hstate_vma(vma)));
>  		if (unlikely(pol != &default_policy &&
>  				pol != current->mempolicy))
>  			__mpol_free(pol);	/* finished with pol */
> @@ -1944,9 +1945,12 @@ static void check_huge_range(struct vm_a
>  {
>  	unsigned long addr;
>  	struct page *page;
> +	struct hstate *h = hstate_vma(vma);
> +	unsigned sz = huge_page_size(h);

This should be unsigned long?

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
