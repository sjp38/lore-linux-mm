Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEDC6B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 02:12:58 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so10269545pad.41
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 23:12:57 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ra6si1966965pab.43.2014.09.24.23.12.56
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 23:12:57 -0700 (PDT)
Date: Thu, 25 Sep 2014 15:13:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH v3 1/4] mm/page_alloc: fix incorrect isolation
 behavior by rechecking migratetype
Message-ID: <20140925061331.GA23558@js1304-P5Q-DELUXE>
References: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1409040498-10148-2-git-send-email-iamjoonsoo.kim@lge.com>
 <540D6961.8060209@suse.cz>
 <20140915023106.GD2676@js1304-P5Q-DELUXE>
 <5422C772.3080700@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5422C772.3080700@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 03:30:26PM +0200, Vlastimil Babka wrote:
> On 09/15/2014 04:31 AM, Joonsoo Kim wrote:
> >On Mon, Sep 08, 2014 at 10:31:29AM +0200, Vlastimil Babka wrote:
> >>On 08/26/2014 10:08 AM, Joonsoo Kim wrote:
> >>
> >>>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>>index f86023b..51e0d13 100644
> >>>--- a/mm/page_alloc.c
> >>>+++ b/mm/page_alloc.c
> >>>@@ -740,9 +740,15 @@ static void free_one_page(struct zone *zone,
> >>>  	if (nr_scanned)
> >>>  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> >>>
> >>>+	if (unlikely(has_isolate_pageblock(zone))) {
> >>>+		migratetype = get_pfnblock_migratetype(page, pfn);
> >>>+		if (is_migrate_isolate(migratetype))
> >>>+			goto skip_counting;
> >>>+	}
> >>>+	__mod_zone_freepage_state(zone, 1 << order, migratetype);
> >>>+
> >>>+skip_counting:
> >>
> >>Here, wouldn't a simple 'else __mod_zone_freepage_state...' look
> >>better than goto + label? (same for the following 2 patches). Or
> >>does that generate worse code?
> >
> >To remove goto label, we need two __mod_zone_freepage_state() like
> >as below. On my system, it doesn't generate worse code, but, I am not
> >sure that this is true if more logic would be added. I think that
> >goto + label is better.
> 
> Oh right, I missed that. It's a bit subtle, but I don't see a nicer
> solution right now.
> 
> >+	if (unlikely(has_isolate_pageblock(zone))) {
> >+		migratetype = get_pfnblock_migratetype(page, pfn);
> >+               if (!is_migrate_isolate(migratetype))
> >+                       __mod_zone_freepage_state(zone, 1 << order, migratetype);
> >+       } else {
> >+               __mod_zone_freepage_state(zone, 1 << order, migratetype);
> >         }
> >
> 
> Yeah that would be uglier I guess.
> 
> >Anyway, What do you think which one is better, either v2 or v3? Still, v3? :)
> 
> Yeah v3 is much better than v1 was, and better for backporting than
> v2. The changelogs also look quite clear. The overhead shouldn't be
> bad with the per-zone flag guarding get_pfnblock_migratetype.

Okay. I will go this way. :)

> 
> I'm just not sure about patch 4 and potentially leaving unmerged
> budies behind. How would it look if instead we made sure isolation
> works on whole MAX_ORDER blocks instead?
> 

If alloc_contig_range() succeed, and later, free_contig_range() is
called for free, there would be no leaving unmerged buddies.
If we fail on alloc_contig_range(), we can get unmerged buddies, but,
that's rare case and it's not big matter because normally we don't
want to allocate page with MAXORDER-1. We mostly want to allocate page
with pageblock_order at maximum. After some split and merging of freepage,
freepage could be MAXORDER-1 page again so that's not real issue, IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
