Message-ID: <4762C677.5040708@rtr.ca>
Date: Fri, 14 Dec 2007 13:07:51 -0500
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: [PATCH] fix page_alloc for larger I/O segments (improved)
References: <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca> <4761CE88.9070406@rtr.ca> <20071213163726.3bb601fa.akpm@linux-foundation.org> <4761D160.7060603@rtr.ca> <4761D279.6050500@rtr.ca> <20071214174236.GA28613@csn.ul.ie>
In-Reply-To: <20071214174236.GA28613@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On (13/12/07 19:46), Mark Lord didst pronounce:
>> "Improved version", more similar to the 2.6.23 code:
>>
>> Fix page allocator to give better chance of larger contiguous segments 
>> (again).
>>
>> Signed-off-by: Mark Lord <mlord@pobox.com
> 
> Regrettably this interferes with anti-fragmentation because the "next" page
> on the list on return from rmqueue_bulk is not guaranteed to be of the right
> mobility type. I fixed it as an additional patch but it adds additional cost
> that should not be necessary and it's visible in microbenchmark results on
> at least one machine.
> 
> The following patch should fix the page ordering problem without incurring an
> additional cost or interfering with anti-fragmentation. However, I haven't
> anything in place yet to verify that the physical page ordering is correct
> but it makes sense. Can you verify it fixes the problem please?
> 
> It'll still be some time before I have a full set of performance results
> but initially at least, this fix seems to avoid any impact.
> 
> ======
> Subject: Fix page allocation for larger I/O segments
> 
> In some cases the IO subsystem is able to merge requests if the pages are
> adjacent in physical memory. This was achieved in the allocator by having
> expand() return pages in physically contiguous order in situations were
> a large buddy was split. However, list-based anti-fragmentation changed
> the order pages were returned in to avoid searching in buffered_rmqueue()
> for a page of the appropriate migrate type.
> 
> This patch restores behaviour of rmqueue_bulk() preserving the physical order
> of pages returned by the allocator without incurring increased search costs for
> anti-fragmentation.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  page_alloc.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc5-clean/mm/page_alloc.c linux-2.6.24-rc5-giveback-physorder-listmove/mm/page_alloc.c
> --- linux-2.6.24-rc5-clean/mm/page_alloc.c	2007-12-14 11:55:13.000000000 +0000
> +++ linux-2.6.24-rc5-giveback-physorder-listmove/mm/page_alloc.c	2007-12-14 15:33:12.000000000 +0000
> @@ -847,8 +847,19 @@ static int rmqueue_bulk(struct zone *zon
>  		struct page *page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
>  			break;
> +
> +		/*
> +		 * Split buddy pages returned by expand() are received here
> +		 * in physical page order. The page is added to the callers and
> +		 * list and the list head then moves forward. From the callers
> +		 * perspective, the linked list is ordered by page number in
> +		 * some conditions. This is useful for IO devices that can
> +		 * merge IO requests if the physical pages are ordered
> +		 * properly.
> +		 */
>  		list_add(&page->lru, list);
>  		set_page_private(page, migratetype);
> +		list = &page->lru;
>  	}
>  	spin_unlock(&zone->lock);
>  	return i;
..

That (also) works for me here, regularly generating 64KB I/O segments with SLAB.

Cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
