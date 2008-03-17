Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HKDifg023047
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:13:44 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HKDitK222190
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:13:44 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HKDh4f027718
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:13:43 -0600
Subject: Re: [PATCH] [1/18] Convert hugeltlb.c over to pass global state
	around in a structure
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317015814.CF71C1B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <20080317015814.CF71C1B41E0@basil.firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 15:15:31 -0500
Message-Id: <1205784931.10849.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

I didn't see anything fundamentally wrong with this... In fact it is
looking really nice notwithstanding the minor nits below.

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
> Large, but rather mechanical patch that converts most of the hugetlb.c
> globals into structure members and passes them around.
> 
> Right now there is only a single global hstate structure, but 
> most of the infrastructure to extend it is there.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
<snip>
> @@ -117,23 +113,24 @@ static struct page *dequeue_huge_page_vm
>  	return page;
>  }
> 
> -static void update_and_free_page(struct page *page)
> +static void update_and_free_page(struct hstate *h, struct page *page)
>  {
>  	int i;
> -	nr_huge_pages--;
> -	nr_huge_pages_node[page_to_nid(page)]--;
> -	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
> +	h->nr_huge_pages--;
> +	h->nr_huge_pages_node[page_to_nid(page)]--;
> +	for (i = 0; i < (1 << huge_page_order(h)); i++) {
>  		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
>  				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
>  				1 << PG_private | 1<< PG_writeback);
>  	}

Could you define a macro for (1 << huge_page_order(h))?  It is used at
least 4 times.  How about something like pages_per_huge_page(h) or
something?  I think that would convey the meaning more clearly.

<snip>

> @@ -190,18 +187,18 @@ static int adjust_pool_surplus(int delta
>  	return ret;
>  }
> 
> -static struct page *alloc_fresh_huge_page_node(int nid)
> +static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
> 
>  	page = alloc_pages_node(nid,
>  		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
> -		HUGETLB_PAGE_ORDER);
> +			huge_page_order(h));

Whitespace?

<snip>

> @@ -272,17 +270,17 @@ static struct page *alloc_buddy_huge_pag
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

Whitespace?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
