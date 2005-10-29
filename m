Message-ID: <4362DF80.3060802@yahoo.com.au>
Date: Sat, 29 Oct 2005 12:33:36 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>
In-Reply-To: <20051028183326.A28611@unix-os.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rohit, Seth" <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit, Seth wrote:
> the only changes in this clean up are:
> 

Looking good. I imagine it must be good for icache.
Man, the page allocator somehow turned unreadable since I last
looked at it! We will want this patch.

> 	1- remove the initial direct reclaim logic
> 	2- GFP_HIGH pages are allowed to go little below low watermark sooner

I don't think #2 is any good. The reason we don't check GFP_HIGH on
the first time round is because we simply want to kick kswapd at its
normal watermark - ie. it doesn't matter what kind of allocation this
is, kswapd should start at the same time no matter what.

If you don't do this, then a GFP_HIGH allocator can allocate right
down to its limit before it kicks kswapd, then it either will fail or
will have to do direct reclaim.

I would be inclined to simply add a int gfp_high argument to
get_page_from_freelist, which would also somewhat match zone_watermark_ok.

> 	3- Search for free pages unconditionally after direct reclaim
> 
> I've not added the logic of looking into PCPs first in this rev of patch.  I will send a
> seperate patch for adding that support (needing extra logic for NUMA).
> 
> 	Signed-off-by: Rohit Seth <rohit.seth@intel.com>
> 

One other comment below:

> +
> +static struct page *
> +get_page_from_freelist(unsigned int __nocast gfp_mask, unsigned int order, 
> +			struct zone **zones, int can_try_harder)
> +{
> +	struct zone *z;
> +	struct page *page = NULL;
> +	int classzone_idx = zone_idx(zones[0]);
> +	int i;
> +
> +	/*
> +	 * Go through the zonelist once, looking for a zone with enough free.
> +	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> +	 */
> +	for (i = 0; (z = zones[i]) != NULL; i++) {
> +		if (!cpuset_zone_allowed(z, gfp_mask))
> +			continue;
> +
> +		if ((can_try_harder >= 0) && 
> +			(!zone_watermark_ok(z, order, z->pages_low,
> +				       classzone_idx, can_try_harder, 
> +				       gfp_mask & __GFP_HIGH)))
> +			continue;
> +
> +		page = buffered_rmqueue(z, order, gfp_mask, 1);
> +		if (page) 
> +			break;
> +	}
> +	return page;
> +}

[snip]

> @@ -968,7 +931,7 @@
>  	}
>  	return NULL;
>  got_pg:
> -	zone_statistics(zonelist, z);
> +	zone_statistics(zonelist, page_zone(page));
>  	return page;

How about moving the zone_statistics up into the 'if (page)'
test of get_page_from_freelist? This way we don't have to
evaluate page_zone().

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
