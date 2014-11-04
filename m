Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 35B926B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 19:42:41 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so13322572pab.13
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 16:42:40 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id o9si16671475pdn.5.2014.11.03.16.42.38
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 16:42:39 -0800 (PST)
Date: Tue, 4 Nov 2014 09:44:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 2/4] mm/page_alloc: add freepage on isolate pageblock
 to correct buddy list
Message-ID: <20141104004421.GD8412@js1304-P5Q-DELUXE>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1414740330-4086-3-git-send-email-iamjoonsoo.kim@lge.com>
 <54573B3B.4070500@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54573B3B.4070500@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Nov 03, 2014 at 05:22:19PM +0900, Heesub Shin wrote:
> Hello,
> 
> On 10/31/2014 04:25 PM, Joonsoo Kim wrote:
> >In free_pcppages_bulk(), we use cached migratetype of freepage
> >to determine type of buddy list where freepage will be added.
> >This information is stored when freepage is added to pcp list, so
> >if isolation of pageblock of this freepage begins after storing,
> >this cached information could be stale. In other words, it has
> >original migratetype rather than MIGRATE_ISOLATE.
> >
> >There are two problems caused by this stale information. One is that
> >we can't keep these freepages from being allocated. Although this
> >pageblock is isolated, freepage will be added to normal buddy list
> >so that it could be allocated without any restriction. And the other
> >problem is incorrect freepage accounting. Freepages on isolate pageblock
> >should not be counted for number of freepage.
> >
> >Following is the code snippet in free_pcppages_bulk().
> >
> >/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> >__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> >trace_mm_page_pcpu_drain(page, 0, mt);
> >if (likely(!is_migrate_isolate_page(page))) {
> >	__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
> >	if (is_migrate_cma(mt))
> >		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
> >}
> >
> >As you can see above snippet, current code already handle second problem,
> >incorrect freepage accounting, by re-fetching pageblock migratetype
> >through is_migrate_isolate_page(page). But, because this re-fetched
> >information isn't used for __free_one_page(), first problem would not be
> >solved. This patch try to solve this situation to re-fetch pageblock
> >migratetype before __free_one_page() and to use it for __free_one_page().
> >
> >In addition to move up position of this re-fetch, this patch use
> >optimization technique, re-fetching migratetype only if there is
> >isolate pageblock. Pageblock isolation is rare event, so we can
> >avoid re-fetching in common case with this optimization.
> >
> >This patch also correct migratetype of the tracepoint output.
> >
> >Cc: <stable@vger.kernel.org>
> >Acked-by: Minchan Kim <minchan@kernel.org>
> >Acked-by: Michal Nazarewicz <mina86@mina86.com>
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/page_alloc.c |   13 ++++++++-----
> >  1 file changed, 8 insertions(+), 5 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index f7a867e..6df23fe 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -725,14 +725,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			/* must delete as __free_one_page list manipulates */
> >  			list_del(&page->lru);
> >  			mt = get_freepage_migratetype(page);
> >+			if (unlikely(has_isolate_pageblock(zone))) {
> 
> How about adding an additional check for 'mt == MIGRATE_MOVABLE'
> here? Then, most of get_pageblock_migratetype() calls could be
> avoided while the isolation is in progress. I am not sure this is
> the case on memory offlining. How do you think?

Hello,

Isolation could be invoked to other migratetype pageblock. You can
reference has_unmovable_pages() in page_alloc.c. So, additional check
'mt == MIGRATE_MOVABLE' should not be inserted.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
