Message-ID: <44607CF1.5080109@yahoo.com.au>
Date: Tue, 09 May 2006 21:28:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] zone init check and report unaligned zone boundries
References: <exportbomb.1147172704@pinky> <20060509110520.GA9634@shadowen.org>
In-Reply-To: <20060509110520.GA9634@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, Bob Picco <bob.picco@hp.com>, Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Patchset looks nice, Andy. Page allocator stuff looks fine, just
a couple of questions about the setup and alignment stuff:

Andy Whitcroft wrote:
> zone init check and report unaligned zone boundries
> 
> We have a number of strict constraints on the layout of struct
> page's for use with the buddy allocator.  One of which is that zone
> boundries must occur at MAX_ORDER page boundries.  Add a check for
> this during init.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> ---
>  include/linux/mmzone.h |    5 +++++
>  mm/page_alloc.c        |    4 ++++
>  2 files changed, 9 insertions(+)
> diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
> --- reference/include/linux/mmzone.h
> +++ current/include/linux/mmzone.h
> @@ -388,6 +388,11 @@ static inline int is_dma(struct zone *zo
>  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
>  }
>  
> +static inline unsigned long zone_boundry_align_pfn(unsigned long pfn)
> +{
> +	return pfn & ~((1 << MAX_ORDER) - 1);
> +}
> +
>  /* These two functions are used to setup the per zone pages min values */
>  struct ctl_table;
>  struct file;
> diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
> --- reference/mm/page_alloc.c
> +++ current/mm/page_alloc.c
> @@ -2078,6 +2078,10 @@ static void __init free_area_init_core(s
>  		struct zone *zone = pgdat->node_zones + j;
>  		unsigned long size, realsize;
>  
> +		if (zone_boundry_align_pfn(zone_start_pfn) != zone_start_pfn)
> +			printk(KERN_CRIT "node %d zone %s missaligned "
> +					"start pfn\n", nid, zone_names[j]);
> +


We also need to align the end of the zone I think? I think we should
try to force alignment by reducing the size here, or if that is not
possible, then panic?

If we don't either fix it or panic, then we're allowing users' machines
to run in an unstable state.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
