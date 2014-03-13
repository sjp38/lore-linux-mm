Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EE56B6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:05:16 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so4044088wiw.12
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:05:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ap4si1700770wjc.64.2014.03.13.08.05.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 08:05:15 -0700 (PDT)
Date: Thu, 13 Mar 2014 15:05:12 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH v2] mm/page_alloc: fix freeing of MIGRATE_RESERVE
 migratetype pages
Message-ID: <20140313150512.GR10663@suse.de>
References: <42197912.c6v2hLDCey@amdc1032>
 <20140313142540.GQ10663@suse.de>
 <3661570.lSOEkVGv4G@amdc1032>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3661570.lSOEkVGv4G@amdc1032>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 13, 2014 at 03:37:46PM +0100, Bartlomiej Zolnierkiewicz wrote:
> On Thursday, March 13, 2014 02:25:40 PM Mel Gorman wrote:
> > On Fri, Feb 14, 2014 at 07:34:17PM +0100, Bartlomiej Zolnierkiewicz wrote:
> > > Pages allocated from MIGRATE_RESERVE migratetype pageblocks
> > > are not freed back to MIGRATE_RESERVE migratetype free
> > > lists in free_pcppages_bulk()->__free_one_page() if we got
> > > to free_pcppages_bulk() through drain_[zone_]pages().
> > > The freeing through free_hot_cold_page() is okay because
> > > freepage migratetype is set to pageblock migratetype before
> > > calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
> > > migratetype end up on the free lists of other migratetype
> > > whole Reserved pageblock may be later changed to the other
> > > migratetype in __rmqueue_fallback() and it will be never
> > > changed back to be a Reserved pageblock.  Fix the issue by
> > > preserving freepage migratetype as a pageblock migratetype
> > > (instead of overriding it to the requested migratetype)
> > > for MIGRATE_RESERVE migratetype pages in rmqueue_bulk().
> > > 
> > > The problem was introduced in v2.6.31 by commit ed0ae21
> > > ("page allocator: do not call get_pageblock_migratetype()
> > > more than necessary").
> > > 
> > > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Hugh Dickins <hughd@google.com>
> > 
> > It's a pity about the unconditional pageblock lookup in that path but I
> > didn't see a better way around it so
> > 
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Thanks but does that mean that v3 should be abandoned:
> 
> 	https://lkml.org/lkml/2014/3/6/365
> 

Bah, no. v3 looks better. I was going through the vast pile of mail marked
unread and thought it must be the latest version if it was still "new"
and didn't search linux-mm. I was obviously thinking more clearly when I
saw v2 the first time.

Sorry for the confusion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
