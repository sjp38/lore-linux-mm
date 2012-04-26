Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8FDA96B004D
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 04:16:35 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M320000EUX5ZG@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Apr 2012 09:15:05 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M32008CSUZLLH@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Apr 2012 09:16:33 +0100 (BST)
Date: Thu, 26 Apr 2012 10:13:08 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v2] mm: compaction: handle incorrect Unmovable type
 pageblocks
In-reply-to: <4F974B68.4050209@kernel.org>
Message-id: <201204261013.08877.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
References: <201204241405.07596.b.zolnierkie@samsung.com>
 <4F974B68.4050209@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Wednesday 25 April 2012 02:55:04 Minchan Kim wrote:
> On 04/24/2012 09:05 PM, Bartlomiej Zolnierkiewicz wrote:
> 
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH v2] mm: compaction: handle incorrect Unmovable type pageblocks
> > 
> > When Unmovable pages are freed from Unmovable type pageblock
> > (and some Movable type pages are left in it) the type of
> > the pageblock remains unchanged and therefore the pageblock
> > cannot be used as a migration target during compaction.
> > 
> > Fix it by:
> > 
> > * Adding enum compaction_type (COMPACTION_ASYNC_PARTIAL,
> >   COMPACTION_ASYNC_FULL and COMPACTION_SYNC) and then converting
> >   sync field in struct compact_control to use it.
> > 
> > * Scanning the Unmovable pageblocks (during COMPACTION_ASYNC_FULL
> >   and COMPACTION_SYNC compactions) and building a count based on
> >   finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
> >   If all pages within the Unmovable pageblock are in one of those
> >   three sets change the whole pageblock type to Movable.
> > 
> > 
> > My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> > which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> > - allocate 120000 pages for kernel's usage
> > - free every second page (60000 pages) of memory just allocated
> > - allocate and use 60000 pages from user space
> > - free remaining 60000 pages of kernel memory
> > (now we have fragmented memory occupied mostly by user space pages)
> > - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> > 
> > The results:
> > - with compaction disabled I get 11 successful allocations
> > - with compaction enabled - 14 successful allocations
> > - with this patch I'm able to get all 100 successful allocations
> 
> 
> Cool! but I worry a bit that it's real workload but my first feeling is
> patch itself isn't complicated so it's valuable.
> 
> Shouldn't we add some vmstat like compact_blocks_rescued?

I don't know whether it is really important to know it so I left
it alone for now.  The rest of the your comments were applied to
v3 version of the patch (posted in separate mail).

Thank you for reviewing my patch.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
