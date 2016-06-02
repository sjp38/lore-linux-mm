Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6166B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 22:21:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s73so32880070pfs.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 19:21:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d63si53061870pfc.180.2016.06.01.19.21.21
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 19:21:22 -0700 (PDT)
Date: Thu, 2 Jun 2016 11:22:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Why __alloc_contig_migrate_range calls migrate_prep() at first?
Message-ID: <20160602022242.GB9133@js1304-P5Q-DELUXE>
References: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
 <20160601074010.GO19976@bbox>
 <231748d4-6d9b-85d9-6796-e4625582e148@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <231748d4-6d9b-85d9-6796-e4625582e148@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@foxmail.com>
Cc: Minchan Kim <minchan@kernel.org>, akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jun 02, 2016 at 09:19:19AM +0800, Wang Sheng-Hui wrote:
> 
> 
> On 6/1/2016 3:40 PM, Minchan Kim wrote:
> > On Wed, Jun 01, 2016 at 11:42:29AM +0800, Wang Sheng-Hui wrote:
> >> Dear,
> >>
> >> Sorry to trouble you.
> >>
> >> I noticed cma_alloc would turn to  __alloc_contig_migrate_range for allocating pages.
> >> But  __alloc_contig_migrate_range calls  migrate_prep() at first, even if the requested page
> >> is single and free, lru_add_drain_all still run (called by  migrate_prep())?
> >>
> >> Image a large chunk of free contig pages for CMA, various drivers may request a single page from
> >> the CMA area, we'll get  lru_add_drain_all run for each page.
> >>
> >> Should we detect if the required pages are free before migrate_prep(), or detect at least for single 
> >> page allocation?
> > That makes sense to me.
> >
> > How about calling migrate_prep once migrate_pages fails in the first trial?
> 
> Minchan,
> 
> I tried your patch in my env, and the number of calling migrate_prep() dropped a lot.
> 
> In my case, CMA reserved 512MB, and the linux will call migrate_prep() 40~ times during bootup,
> most are single page allocation request to CMA.
> With your patch, migrate_prep() is not called for the single pages allocation requests as the free
> pages in CMA area is enough.
> 
> Will you please push the patch to upstream?

It is not correct.

migrate_prep() is called to move lru pages in lruvec to LRU. In
isolate_migratepages_range(), non LRU pages are just skipped so if
page is on the lruvec it will not be isolated and error isn't returned.
So, "if (ret) migrate_prep()" will not be called and we can't catch
the page in lruvec.

Anyway, better optimization for your case should be done in higher
level. See following patch. It removes useless pageblock isolation and migration
if possible. In fact, even we can do better than below by inroducing
alloc_contig_range() light mode that skip migrate_prep() and other high cost things
but it needs more surgery. I will revisit it soon.

Thanks.

----------->8---------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1a7f110..4af3665 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7314,6 +7314,51 @@ static unsigned long pfn_max_align_up(unsigned long pfn)
                                pageblock_nr_pages));
 }
 
+static int alloc_contig_range_fast(unsigned long start, unsigned long end, struct compact_control *cc)
+{
+       unsigned int order;
+       unsigned long outer_start, outer_end;
+       int ret = 0;
+
+       order = 0;
+       outer_start = start;
+       while (!PageBuddy(pfn_to_page(outer_start))) {
+               if (++order >= MAX_ORDER) {
+                       outer_start = start;
+                       break;
+               }
+               outer_start &= ~0UL << order;
+       }
+
+       if (outer_start != start) {
+               order = page_order(pfn_to_page(outer_start));
+
+               /*
+                * outer_start page could be small order buddy page and
+                * it doesn't include start page. Adjust outer_start
+                * in this case to report failed page properly
+                * on tracepoint in test_pages_isolated()
+                */
+               if (outer_start + (1UL << order) <= start)
+                       outer_start = start;
+       }
+
+       /* Grab isolated pages from freelists. */
+       outer_end = isolate_freepages_range(cc, outer_start, end);
+       if (!outer_end) {
+               ret = -EBUSY;
+               goto done;
+       }
+
+       if (start != outer_start)
+               free_contig_range(outer_start, start - outer_start);
+       if (end != outer_end)
+               free_contig_range(end, outer_end - end);
+
+done:
+       return ret;
+}
+
 /* [start, end) must belong to a single zone. */
 static int __alloc_contig_migrate_range(struct compact_control *cc,
                                        unsigned long start, unsigned long end)
@@ -7390,6 +7435,9 @@ int alloc_contig_range(unsigned long start, unsigned long end)
        };
        INIT_LIST_HEAD(&cc.migratepages);
 
+       if (!alloc_contig_range_fast(start, end, &cc))
+               return 0;
+
        /*
         * What we do here is we mark all pageblocks in range as
         * MIGRATE_ISOLATE.  Because pageblock and max order pages may


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
