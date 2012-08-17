Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4B2376B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 21:05:49 -0400 (EDT)
Date: Fri, 17 Aug 2012 10:05:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 1/2] cma: remove __reclaim_pages
Message-ID: <20120817010547.GA3061@bbox>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
 <1344934627-8473-2-git-send-email-minchan@kernel.org>
 <20120816135817.GS4177@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816135817.GS4177@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Mel,

On Thu, Aug 16, 2012 at 02:58:18PM +0100, Mel Gorman wrote:
> On Tue, Aug 14, 2012 at 05:57:06PM +0900, Minchan Kim wrote:
> > Now cma reclaims too many pages by __reclaim_pages which says
> > following as
> > 
> >         * Reclaim enough pages to make sure that contiguous allocation
> >         * will not starve the system.
> > 
> > Starve? What does it starve the system? The function which allocate
> > free page for migration target would wake up kswapd and do direct reclaim
> > if needed during migration so system doesn't starve.
> > 
> 
> I thought this patch was overkill at the time it was introduced but
> didn't have a concrete reason to reject it when I commented on it
> https://lkml.org/lkml/2012/1/30/136 . Marek did want this and followed
> up with "contiguous allocations should have higher priority than others"
> which I took to mean that he was also ok with excessive reclaim.

I think OOM kill to background applications is more appropriate than
big latency of foreground(ex, Camera app) application in your mobile phone.
In other words, excessive reclaim is *really* bad which elapsed 8sec
in my test as worst case. :(

> 
> > Let remove __reclaim_pages and related function and fields.
> > 
> 
> That should be one patch and I don't object to it being removed as such
> but it's Marek's call.

Marek. Any thought?

> 
> > I modified split_free_page slightly because I removed __reclaim_pages,
> > isolate_freepages_range can fail by split_free_page's watermark check.
> > It's very critical in CMA because it ends up failing alloc_contig_range.
> > 
> 
> This is a big change and should have been in a patch on its
> own. split_free_page checks watermarks because if the watermarks are
> not obeyed a zone can become fully allocated. This can cause a system to
> livelock under certain circumstances if a page cannot be allocated and a
> free page is required before other pages can be freed.
> 
> > I think we don't need the check in case of CMA because CMA allocates
> > free pages by alloc_pages, not isolate_freepages_block in migrate_pages
> > so watermark is already checked in alloc_pages.
> 
> It uses alloc_pages when migrating pages out of the CMA area but note
> that it uses isolate_freepages_block when allocating the CMA buffer when
> alloc_contig_range calls isolate_freepages_range
> 
> isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
> {
> 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
>                isolated = isolate_freepages_block(pfn, block_end_pfn,
>                                                    &freelist, true);
> 	}
> 	map_pages(&freelist);
> }
> 
> so the actual CMA allocation itself is not using alloc_pages. By removing
> the watermark check you allow the CMA to breach watermarks and puts the
> system at risk of livelock.

Fair enough. I will look into that.
Thanks, Mel.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
