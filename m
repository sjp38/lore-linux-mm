Date: Tue, 18 Mar 2008 16:02:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [10/18] Factor out new huge page preparation code into separate function
Message-ID: <20080318160215.GI23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015824.074A31B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015824.074A31B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> Needed to avoid code duplication in follow up patches.
> 
> This happens to fix a minor bug. When alloc_bootmem_node returns
> a fallback node on a different node than passed the old code
> would have put it into the free lists of the wrong node.
> Now it would end up in the freelist of the correct node.
> 

It fixes a real bug for sure. It may be possible with that bug to leak
pages onto a linked list with bogus counters.

Possibly another candidate patch to move to the start of the series so
they can be merged and tested separetly?

> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  mm/hugetlb.c |   21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -200,6 +200,17 @@ static int adjust_pool_surplus(struct hs
>  	return ret;
>  }
>  
> +static void huge_new_page(struct hstate *h, struct page *page)
> +{

prep_new_huge_page() as it has a similar responsibility to
prep_new_page() ? Just at a glance, huge_new_page() implies to me that
it calls alloc_pages_node() 

> +	unsigned nid = pfn_to_nid(page_to_pfn(page));
> +	set_compound_page_dtor(page, free_huge_page);
> +	spin_lock(&hugetlb_lock);
> +	h->nr_huge_pages++;
> +	h->nr_huge_pages_node[nid]++;
> +	spin_unlock(&hugetlb_lock);
> +	put_page(page); /* free it into the hugepage allocator */
> +}
> +
>  static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
> @@ -207,14 +218,8 @@ static struct page *alloc_fresh_huge_pag
>  	page = alloc_pages_node(nid,
>  		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
>  			huge_page_order(h));
> -	if (page) {
> -		set_compound_page_dtor(page, free_huge_page);
> -		spin_lock(&hugetlb_lock);
> -		h->nr_huge_pages++;
> -		h->nr_huge_pages_node[nid]++;
> -		spin_unlock(&hugetlb_lock);
> -		put_page(page); /* free it into the hugepage allocator */
> -	}
> +	if (page)
> +		huge_new_page(h, page);
>  
>  	return page;
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
