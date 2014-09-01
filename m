Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EC8496B0037
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 20:13:33 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bj1so10768378pad.4
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 17:13:33 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id td1si10539127pbc.140.2014.08.31.17.13.31
        for <linux-mm@kvack.org>;
        Sun, 31 Aug 2014 17:13:33 -0700 (PDT)
Date: Mon, 1 Sep 2014 09:14:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH v3 1/4] mm/page_alloc: fix incorrect isolation
 behavior by rechecking migratetype
Message-ID: <20140901001401.GB25599@js1304-P5Q-DELUXE>
References: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1409040498-10148-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20140829174641.GB27127@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140829174641.GB27127@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 29, 2014 at 01:46:41PM -0400, Naoya Horiguchi wrote:
> On Tue, Aug 26, 2014 at 05:08:15PM +0900, Joonsoo Kim wrote:
> > There are two paths to reach core free function of buddy allocator,
> > __free_one_page(), one is free_one_page()->__free_one_page() and the
> > other is free_hot_cold_page()->free_pcppages_bulk()->__free_one_page().
> > Each paths has race condition causing serious problems. At first, this
> > patch is focused on first type of freepath. And then, following patch
> > will solve the problem in second type of freepath.
> > 
> > In the first type of freepath, we got migratetype of freeing page without
> > holding the zone lock, so it could be racy. There are two cases of this
> > race.
> > 
> > 1. pages are added to isolate buddy list after restoring orignal
> > migratetype
> > 
> > CPU1                                   CPU2
> > 
> > get migratetype => return MIGRATE_ISOLATE
> > call free_one_page() with MIGRATE_ISOLATE
> > 
> > 				grab the zone lock
> > 				unisolate pageblock
> > 				release the zone lock
> > 
> > grab the zone lock
> > call __free_one_page() with MIGRATE_ISOLATE
> > freepage go into isolate buddy list,
> > although pageblock is already unisolated
> > 
> > This may cause two problems. One is that we can't use this page anymore
> > until next isolation attempt of this pageblock, because freepage is on
> > isolate pageblock. The other is that freepage accouting could be wrong
> > due to merging between different buddy list. Freepages on isolate buddy
> > list aren't counted as freepage, but ones on normal buddy list are counted
> > as freepage. If merge happens, buddy freepage on normal buddy list is
> > inevitably moved to isolate buddy list without any consideration of
> > freepage accouting so it could be incorrect.
> > 
> > 2. pages are added to normal buddy list while pageblock is isolated.
> > It is similar with above case.
> > 
> > This also may cause two problems. One is that we can't keep these
> > freepages from being allocated. Although this pageblock is isolated,
> > freepage would be added to normal buddy list so that it could be
> > allocated without any restriction. And the other problem is same as
> > case 1, that it, incorrect freepage accouting.
> > 
> > This race condition would be prevented by checking migratetype again
> > with holding the zone lock. Because it is somewhat heavy operation
> > and it isn't needed in common case, we want to avoid rechecking as much
> > as possible. So this patch introduce new variable, nr_isolate_pageblock
> > in struct zone to check if there is isolated pageblock.
> > With this, we can avoid to re-check migratetype in common case and do
> > it only if there is isolated pageblock. This solve above
> > mentioned problems.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/mmzone.h         |    4 ++++
> >  include/linux/page-isolation.h |    8 ++++++++
> >  mm/page_alloc.c                |   10 ++++++++--
> >  mm/page_isolation.c            |    2 ++
> >  4 files changed, 22 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 318df70..23e69f1 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -431,6 +431,10 @@ struct zone {
> >  	 */
> >  	int			nr_migrate_reserve_block;
> >  
> > +#ifdef CONFIG_MEMORY_ISOLATION
> 
> It's worth adding some comment, especially about locking?
> The patch itself looks good me.

Okay. Will do. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
