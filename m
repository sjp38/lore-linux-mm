Date: Tue, 18 Mar 2008 15:42:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [7/18] Abstract out the NUMA node round robin code into a separate function
Message-ID: <20080318154209.GG23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015820.ECC861B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015820.ECC861B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> Need this as a separate function for a future patch.
> 
> No behaviour change.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Maybe if you moved this beside patch 1, they could both be tested in
isolation as a fairly reasonable cleanup that does not alter
functionality? Not a big deal.

> 
> ---
>  mm/hugetlb.c |   37 ++++++++++++++++++++++---------------
>  1 file changed, 22 insertions(+), 15 deletions(-)
> 
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -219,6 +219,27 @@ static struct page *alloc_fresh_huge_pag
>  	return page;
>  }
>  
> +/*
> + * Use a helper variable to find the next node and then
> + * copy it back to hugetlb_next_nid afterwards:
> + * otherwise there's a window in which a racer might
> + * pass invalid nid MAX_NUMNODES to alloc_pages_node.
> + * But we don't need to use a spin_lock here: it really
> + * doesn't matter if occasionally a racer chooses the
> + * same nid as we do.  Move nid forward in the mask even
> + * if we just successfully allocated a hugepage so that
> + * the next caller gets hugepages on the next node.
> + */
> +static int huge_next_node(struct hstate *h)
> +{
> +	int next_nid;
> +	next_nid = next_node(h->hugetlb_next_nid, node_online_map);
> +	if (next_nid == MAX_NUMNODES)
> +		next_nid = first_node(node_online_map);
> +	h->hugetlb_next_nid = next_nid;
> +	return next_nid;
> +}
> +
>  static int alloc_fresh_huge_page(struct hstate *h)
>  {
>  	struct page *page;
> @@ -232,21 +253,7 @@ static int alloc_fresh_huge_page(struct 
>  		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
>  		if (page)
>  			ret = 1;
> -		/*
> -		 * Use a helper variable to find the next node and then
> -		 * copy it back to hugetlb_next_nid afterwards:
> -		 * otherwise there's a window in which a racer might
> -		 * pass invalid nid MAX_NUMNODES to alloc_pages_node.
> -		 * But we don't need to use a spin_lock here: it really
> -		 * doesn't matter if occasionally a racer chooses the
> -		 * same nid as we do.  Move nid forward in the mask even
> -		 * if we just successfully allocated a hugepage so that
> -		 * the next caller gets hugepages on the next node.
> -		 */
> -		next_nid = next_node(h->hugetlb_next_nid, node_online_map);
> -		if (next_nid == MAX_NUMNODES)
> -			next_nid = first_node(node_online_map);
> -		h->hugetlb_next_nid = next_nid;
> +		next_nid = huge_next_node(h);

hmm, I'm not seeing where next_nid gets declared locally here as it
should have been removed in an earlier patch. Maybe it's reintroduced
later but if you do reshuffle the patchset so that the cleanups can be
merged on their own, it'll show up in a compile test.

>  	} while (!page && h->hugetlb_next_nid != start_nid);
>  
>  	return ret;
> 

Other than the possible gotcha with next_nid declared locally, the move
seems fine.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
