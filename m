Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PIcNKN030501
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:38:23 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PIerC0178570
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 12:40:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PIenHp002922
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 12:40:52 -0600
Date: Fri, 25 Apr 2008 11:40:41 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 13/18] hugetlb: support boot allocate different sizes
Message-ID: <20080425184041.GH9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.027712000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015431.027712000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:15 +1000], npiggin@suse.de wrote:
> 
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
> @@ -582,10 +582,13 @@ static void __init hugetlb_init_hstate(s
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

When would this be the case (the list is already init'd)?

>  	for (i = 0; i < h->max_huge_pages; ++i) {
>  		if (h->order >= MAX_ORDER) {
> @@ -594,7 +597,7 @@ static void __init hugetlb_init_hstate(s
>  		} else if (!alloc_fresh_huge_page(h))
>  			break;
>  	}
> -	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> +	h->max_huge_pages = i;

Why don't we need to set these other values anymore?

>  }
> 
>  static void __init hugetlb_init_hstates(void)
> @@ -602,7 +605,10 @@ static void __init hugetlb_init_hstates(
>  	struct hstate *h;
> 
>  	for_each_hstate(h) {
> -		hugetlb_init_hstate(h);
> +		/* oversize hugepages were init'ed in early boot */
> +		if (h->order < MAX_ORDER)
> +			hugetlb_init_hstate(h);
> +		max_huge_pages[h - hstates] = h->max_huge_pages;

So, you made max_huge_pages an array of the same size as the hstates
array, right?

So why can't we directly use h->max_huge_pagees everywhere, and *only*
touch max_huge_pages in the sysctl path.

Oh right, I have a patch to do exactly this, but haven't posted it yet
(kind of got caught between my patchset and yours and forgotten).

max_huge_pages is a confusing variable (to me)

I think it's use should be restricted to the sysctl as much as possible
(and the sysctl's should be updated to only do work if write is set).
Does that seem sane to you?

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
