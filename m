Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 110AD6B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:59:42 -0400 (EDT)
Date: Thu, 28 Jun 2012 13:59:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
Message-Id: <20120628135940.2c26ada9.akpm@linux-foundation.org>
In-Reply-To: <20120628135520.0c48b066@annuminas.surriel.com>
References: <20120628135520.0c48b066@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, jaschut@sandia.gov, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com

On Thu, 28 Jun 2012 13:55:20 -0400
Rik van Riel <riel@redhat.com> wrote:

> Order > 0 compaction stops when enough free pages of the correct
> page order have been coalesced. When doing subsequent higher order
> allocations, it is possible for compaction to be invoked many times.
> 
> However, the compaction code always starts out looking for things to
> compact at the start of the zone, and for free pages to compact things
> to at the end of the zone.
> 
> This can cause quadratic behaviour, with isolate_freepages starting
> at the end of the zone each time, even though previous invocations
> of the compaction code already filled up all free memory on that end
> of the zone.
> 
> This can cause isolate_freepages to take enormous amounts of CPU
> with certain workloads on larger memory systems.
> 
> The obvious solution is to have isolate_freepages remember where
> it left off last time, and continue at that point the next time
> it gets invoked for an order > 0 compaction. This could cause
> compaction to fail if cc->free_pfn and cc->migrate_pfn are close
> together initially, in that case we restart from the end of the
> zone and try once more.
> 
> Forced full (order == -1) compactions are left alone.

Is there a quality of service impact here?  Newly-compactable pages
at lower pfns than compact_cached_free_pfn will now get missed, leading
to a form of fragmentation?

> @@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		if (isolated)
>  			high_pfn = max(high_pfn, pfn);
> +		if (cc->order > 0)
> +			zone->compact_cached_free_pfn = high_pfn;

Is high_pfn guaranteed to be aligned to pageblock_nr_pages here?  I
assume so, if lots of code in other places is correct but it's
unobvious from reading this function.

>  	}
>  
>  	/* split_free_page does not map the pages */
>
> ...
>
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -118,8 +118,10 @@ struct compact_control {
>  	unsigned long nr_freepages;	/* Number of isolated free pages */
>  	unsigned long nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long free_pfn;		/* isolate_freepages search base */
> +	unsigned long start_free_pfn;	/* where we started the search */
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>  	bool sync;			/* Synchronous migration */
> +	bool wrapped;			/* Last round for order>0 compaction */

This comment is incomprehensible :(

>  
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
