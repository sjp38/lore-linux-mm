Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLSuoP028729
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:28:56 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLSuAb103134
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:28:56 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLSt9j008728
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:28:56 -0400
Subject: Re: [patch 12/23] hugetlb: support boot allocate different sizes
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143453.424711000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143453.424711000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:28:55 -0500
Message-Id: <1211923735.12036.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Seems nice, but what exactly is this patch for?  From reading the code
it would seem that this allows more than one >MAX_ORDER hstates to exist
and removes assumptions about their positioning withing the hstates
array?  A small patch leader would definitely clear up my confusion.

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-different-page-sizes.patch)
> Acked-by: Andrew Hastings <abh@cray.com>
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  mm/hugetlb.c |   24 +++++++++++++++++++-----
>  1 file changed, 19 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -609,10 +609,13 @@ static void __init hugetlb_init_one_hsta
>  {
>  	unsigned long i;
> 
> -	for (i = 0; i < MAX_NUMNODES; ++i)
> -		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> +	/* Don't reinitialize lists if they have been already init'ed */
> +	if (!h->hugepage_freelists[0].next) {
> +		for (i = 0; i < MAX_NUMNODES; ++i)
> +			INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> 
> -	h->hugetlb_next_nid = first_node(node_online_map);
> +		h->hugetlb_next_nid = first_node(node_online_map);
> +	}
> 
>  	for (i = 0; i < h->max_huge_pages; ++i) {
>  		if (h->order >= MAX_ORDER) {
> @@ -621,7 +624,7 @@ static void __init hugetlb_init_one_hsta
>  		} else if (!alloc_fresh_huge_page(h))
>  			break;
>  	}
> -	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> +	h->max_huge_pages = i;
>  }
> 
>  static void __init hugetlb_init_hstates(void)
> @@ -629,7 +632,10 @@ static void __init hugetlb_init_hstates(
>  	struct hstate *h;
> 
>  	for_each_hstate(h) {
> -		hugetlb_init_one_hstate(h);
> +		/* oversize hugepages were init'ed in early boot */
> +		if (h->order < MAX_ORDER)
> +			hugetlb_init_one_hstate(h);
> +		max_huge_pages[h - hstates] = h->max_huge_pages;
>  	}
>  }
> 
> @@ -692,6 +698,14 @@ static int __init hugetlb_setup(char *s)
>  	if (sscanf(s, "%lu", mhp) <= 0)
>  		*mhp = 0;
> 
> +	/*
> +	 * Global state is always initialized later in hugetlb_init.
> +	 * But we need to allocate >= MAX_ORDER hstates here early to still
> +	 * use the bootmem allocator.
> +	 */
> +	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
> +		hugetlb_init_one_hstate(parsed_hstate);
> +
>  	return 1;
>  }
>  __setup("hugepages=", hugetlb_setup);
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
