Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CD7756B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 09:58:24 -0400 (EDT)
Date: Thu, 16 Aug 2012 14:58:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 1/2] cma: remove __reclaim_pages
Message-ID: <20120816135817.GS4177@suse.de>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
 <1344934627-8473-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1344934627-8473-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 14, 2012 at 05:57:06PM +0900, Minchan Kim wrote:
> Now cma reclaims too many pages by __reclaim_pages which says
> following as
> 
>         * Reclaim enough pages to make sure that contiguous allocation
>         * will not starve the system.
> 
> Starve? What does it starve the system? The function which allocate
> free page for migration target would wake up kswapd and do direct reclaim
> if needed during migration so system doesn't starve.
> 

I thought this patch was overkill at the time it was introduced but
didn't have a concrete reason to reject it when I commented on it
https://lkml.org/lkml/2012/1/30/136 . Marek did want this and followed
up with "contiguous allocations should have higher priority than others"
which I took to mean that he was also ok with excessive reclaim.

> Let remove __reclaim_pages and related function and fields.
> 

That should be one patch and I don't object to it being removed as such
but it's Marek's call.

> I modified split_free_page slightly because I removed __reclaim_pages,
> isolate_freepages_range can fail by split_free_page's watermark check.
> It's very critical in CMA because it ends up failing alloc_contig_range.
> 

This is a big change and should have been in a patch on its
own. split_free_page checks watermarks because if the watermarks are
not obeyed a zone can become fully allocated. This can cause a system to
livelock under certain circumstances if a page cannot be allocated and a
free page is required before other pages can be freed.

> I think we don't need the check in case of CMA because CMA allocates
> free pages by alloc_pages, not isolate_freepages_block in migrate_pages
> so watermark is already checked in alloc_pages.

It uses alloc_pages when migrating pages out of the CMA area but note
that it uses isolate_freepages_block when allocating the CMA buffer when
alloc_contig_range calls isolate_freepages_range

isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
{
	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
               isolated = isolate_freepages_block(pfn, block_end_pfn,
                                                   &freelist, true);
	}
	map_pages(&freelist);
}

so the actual CMA allocation itself is not using alloc_pages. By removing
the watermark check you allow the CMA to breach watermarks and puts the
system at risk of livelock.

I'm not keen on the split_free_page() change at all.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
