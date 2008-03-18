Date: Tue, 18 Mar 2008 14:11:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [4/18] Add basic support for more than one hstate in hugetlbfs
Message-ID: <20080318141140.GD23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015817.DE00E1B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015817.DE00E1B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Missing leader and the subject is misleading as to what the patch is
doing. Am assuming this is an accident.

On (17/03/08 02:58), Andi Kleen didst pronounce:
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  mm/hugetlb.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -550,26 +550,33 @@ static unsigned int cpuset_mems_nr(unsig
>  
>  #ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(unsigned long count)
> +static void do_try_to_free_low(struct hstate *h, unsigned long count)
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
> +
> +static void try_to_free_low(unsigned long count)
> +{
> +	struct hstate *h;
> +	for_each_hstate (h) {
> +		do_try_to_free_low(h, count);
> +	}
> +}

hmm, so this is freeing 'count' pages from all pools. I doubt that's what
you really want to be doing here. If someone if using the proc entries to
shrink a pool size, I imagine they want to shrink X pages of size Y from a
single pool, not shrink X pages from all pools.

What am I missing?

>  #else
>  static inline void try_to_free_low(unsigned long count)
>  {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
