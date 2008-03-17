Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HKJk7m014812
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:19:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HKKvRS159902
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:20:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HKKvmS009898
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:20:57 -0600
Subject: Re: [PATCH] [2/18] Add basic support for more than one hstate in
	hugetlbfs
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317015815.D43991B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <20080317015815.D43991B41E0@basil.firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 20:22:44 +0000
Message-Id: <1205785364.10849.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
> - Convert hstates to an array
> - Add a first default entry covering the standard huge page size
> - Add functions for architectures to register new hstates
> - Add basic iterators over hstates
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
<snip>
> @@ -497,11 +501,34 @@ static int __init hugetlb_init(void)
>  			break;
>  	}
>  	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> -	printk("Total HugeTLB memory allocated, %ld\n", h->free_huge_pages);
> +
> +	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
> +			h->free_huge_pages,
> +			1 << (h->order + PAGE_SHIFT - 20));
>  	return 0;
>  }

I'd like to avoid assuming the huge page size is some multiple of MB.
PowerPC will have a 64KB huge page.  Granted, you do fix this in a later
patch, so as long as the whole series goes together this shouldn't cause
a problem.

> +
> +static int __init hugetlb_init(void)
> +{
> +	if (HPAGE_SHIFT == 0)
> +		return 0;
> +	return hugetlb_init_hstate(&global_hstate);
> +}
>  module_init(hugetlb_init);
> 
> +/* Should be called on processing a hugepagesz=... option */
> +void __init huge_add_hstate(unsigned order)
> +{
> +	struct hstate *h;
> +	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
> +	BUG_ON(order <= HPAGE_SHIFT - PAGE_SHIFT);
> +	h = &hstates[max_hstate++];
> +	h->order = order;
> +	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
> +	hugetlb_init_hstate(h);
> +	parsed_hstate = h;
> +}

Since mask can always be derived from order, is there a reason we don't
always calculate it?  I guess it boils down to storage cost vs.
calculation cost and I don't feel too strongly either way.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
