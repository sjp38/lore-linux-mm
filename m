Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 07CCF6B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 20:14:52 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id z10so4765873pdj.10
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 17:14:52 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ii1si11072618pac.155.2014.08.31.17.14.50
        for <linux-mm@kvack.org>;
        Sun, 31 Aug 2014 17:14:52 -0700 (PDT)
Date: Mon, 1 Sep 2014 09:15:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH v3 4/4] mm/page_alloc: restrict max order of merging
 on isolated pageblock
Message-ID: <20140901001525.GC25599@js1304-P5Q-DELUXE>
References: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1409040498-10148-5-git-send-email-iamjoonsoo.kim@lge.com>
 <20140829165244.GA27127@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140829165244.GA27127@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 29, 2014 at 12:52:44PM -0400, Naoya Horiguchi wrote:
> Hi Joonsoo,
> 
> On Tue, Aug 26, 2014 at 05:08:18PM +0900, Joonsoo Kim wrote:
> > Current pageblock isolation logic could isolate each pageblock
> > individually. This causes freepage accounting problem if freepage with
> > pageblock order on isolate pageblock is merged with other freepage on
> > normal pageblock. We can prevent merging by restricting max order of
> > merging to pageblock order if freepage is on isolate pageblock.
> > 
> > Side-effect of this change is that there could be non-merged buddy
> > freepage even if finishing pageblock isolation, because undoing pageblock
> > isolation is just to move freepage from isolate buddy list to normal buddy
> > list rather than to consider merging. But, I think it doesn't matter
> > because 1) almost allocation request are for equal or below pageblock
> > order, 2) caller of pageblock isolation will use this freepage so
> > freepage will split in any case and 3) merge would happen soon after
> > some alloc/free on this and buddy pageblock.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/page_alloc.c |   15 ++++++++++++---
> >  1 file changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 809bfd3..8ba9fb0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -570,6 +570,7 @@ static inline void __free_one_page(struct page *page,
> >  	unsigned long combined_idx;
> >  	unsigned long uninitialized_var(buddy_idx);
> >  	struct page *buddy;
> > +	int max_order = MAX_ORDER;
> >  
> >  	VM_BUG_ON(!zone_is_initialized(zone));
> >  
> > @@ -580,18 +581,26 @@ static inline void __free_one_page(struct page *page,
> >  	VM_BUG_ON(migratetype == -1);
> >  	if (unlikely(has_isolate_pageblock(zone))) {
> >  		migratetype = get_pfnblock_migratetype(page, pfn);
> > -		if (is_migrate_isolate(migratetype))
> > +		if (is_migrate_isolate(migratetype)) {
> > +			/*
> > +			 * We restrict max order of merging to prevent merge
> > +			 * between freepages on isolate pageblock and normal
> > +			 * pageblock. Without this, pageblock isolation
> > +			 * could cause incorrect freepage accounting.
> > +			 */
> > +			max_order = pageblock_order + 1;
> 
> When pageblock_order >= max_order, order in the while loop below could
> go beyond MAX_ORDER - 1. Or does it never happen?

Yes, you are right. Will fix it in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
