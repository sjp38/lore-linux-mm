Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8356B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 13:12:41 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id z10so2875767pdj.32
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 10:12:41 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id tg2si5675143pbc.233.2014.03.06.10.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 06 Mar 2014 10:12:40 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N21005JR192E390@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 07 Mar 2014 03:12:38 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC][PATCH v2] mm/page_alloc: fix freeing of MIGRATE_RESERVE
 migratetype pages
Date: Thu, 06 Mar 2014 19:12:24 +0100
Message-id: <1773622.n1LPhdl60W@amdc1032>
In-reply-to: <20140224085939.GE6732@suse.de>
References: <42197912.c6v2hLDCey@amdc1032> <20140224085939.GE6732@suse.de>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=iso-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Hi,

On Monday, February 24, 2014 08:59:39 AM Mel Gorman wrote:
> On Fri, Feb 14, 2014 at 07:34:17PM +0100, Bartlomiej Zolnierkiewicz wrote:
> > Pages allocated from MIGRATE_RESERVE migratetype pageblocks
> > are not freed back to MIGRATE_RESERVE migratetype free
> > lists in free_pcppages_bulk()->__free_one_page() if we got
> > to free_pcppages_bulk() through drain_[zone_]pages().
> > The freeing through free_hot_cold_page() is okay because
> > freepage migratetype is set to pageblock migratetype before
> > calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
> > migratetype end up on the free lists of other migratetype
> > whole Reserved pageblock may be later changed to the other
> > migratetype in __rmqueue_fallback() and it will be never
> > changed back to be a Reserved pageblock.  Fix the issue by
> > preserving freepage migratetype as a pageblock migratetype
> > (instead of overriding it to the requested migratetype)
> > for MIGRATE_RESERVE migratetype pages in rmqueue_bulk().
> > 
> > The problem was introduced in v2.6.31 by commit ed0ae21
> > ("page allocator: do not call get_pageblock_migratetype()
> > more than necessary").
> > 
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > ---
> > v2:
> > - updated patch description, there is no __zone_pcp_update()
> >   in newer kernels
> > 
> >  include/linux/mmzone.h |    5 +++++
> >  mm/page_alloc.c        |   10 +++++++---
> >  2 files changed, 12 insertions(+), 3 deletions(-)
> > 
> > Index: b/include/linux/mmzone.h
> > ===================================================================
> > --- a/include/linux/mmzone.h	2014-02-14 18:59:08.177837747 +0100
> > +++ b/include/linux/mmzone.h	2014-02-14 18:59:09.077837731 +0100
> > @@ -63,6 +63,11 @@ enum {
> >  	MIGRATE_TYPES
> >  };
> >  
> > +static inline bool is_migrate_reserve(int migratetype)
> > +{
> > +	return unlikely(migratetype == MIGRATE_RESERVE);
> > +}
> > +
> >  #ifdef CONFIG_CMA
> >  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> >  #else
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c	2014-02-14 18:59:08.185837746 +0100
> > +++ b/mm/page_alloc.c	2014-02-14 18:59:09.077837731 +0100
> > @@ -1174,7 +1174,7 @@ static int rmqueue_bulk(struct zone *zon
> >  			unsigned long count, struct list_head *list,
> >  			int migratetype, int cold)
> >  {
> > -	int mt = migratetype, i;
> > +	int mt, i;
> >  
> >  	spin_lock(&zone->lock);
> >  	for (i = 0; i < count; ++i) {
> > @@ -1195,9 +1195,13 @@ static int rmqueue_bulk(struct zone *zon
> >  			list_add(&page->lru, list);
> >  		else
> >  			list_add_tail(&page->lru, list);
> > +		mt = get_pageblock_migratetype(page);
> >  		if (IS_ENABLED(CONFIG_CMA)) {
> > -			mt = get_pageblock_migratetype(page);
> > -			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
> > +			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt) &&
> > +			    !is_migrate_reserve(mt))
> > +				mt = migratetype;
> > +		} else {
> > +			if (!is_migrate_reserve(mt))
> >  				mt = migratetype;
> 
> Minimally, this could be simplified because now it's an unconditional
> call to get_pageblock_migratetype.
> 
> However, it looks like this could be improved without doing that.
> __rmqueue_fallback will be called if a page of the requested migratetype
> was not found. Furthermore, if a pageblock has been stolen then the
> pages are shuffled between free lists so you should be able to modify
> this patch to
> 
> 1. have __rmqueue call set_freepage_migratetype(migratetype) if
>    __rmqueue_smallest found a page
> 2. have __rmqueue_fallback call set_freepage_migratetype(new_type)
>    when it has selected which freelist to select from.
> 
> Can you check it out as an alternative to this patch please as it would
> have much less overhead than unconditionally calling
> get_pageblock_migratetype()?

I updated the patch (please see the other mail) but besides fixing
MIGRATE_RESERVE issue I left the current code behaviour unchanged
for now - freepage migratetype is not set to new_type in
__rmqueue_fallback() as it would affect pages of other migratetypes
(i.e. MIGRATE_MOVABLE or MIGRATE_UNMVOVABLE ones).  I think that
setting freepage migratetype to new_type instead of the requested
migratetype in __rmqueue_fallback() would go beyond the scope of
current patch and I don't know whether it is desirable (I can do
an incremental patch implementing it if needed).

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
