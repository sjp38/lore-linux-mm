Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HKW7sD010522
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:32:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HKU5Qr242396
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:30:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HKU5AH027913
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:30:05 -0400
Subject: Re: [PATCH] [10/18] Factor out new huge page preparation code into
	separate function
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317015824.074A31B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <20080317015824.074A31B41E0@basil.firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 15:31:53 -0500
Message-Id: <1205785913.10849.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
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

We do not usually preface functions in mm/hugetlb.c with "huge" and the
name you have chosen doesn't seem that clear to me anyway.  Could we
rename it to prep_new_huge_page() or something similar?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
