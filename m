Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D10236B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 01:42:41 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so2172970pde.15
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 22:42:41 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id pe2si5147338pbc.181.2014.12.09.22.42.38
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 22:42:40 -0800 (PST)
Date: Wed, 10 Dec 2014 15:46:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/4] mm/compaction: enhance compaction finish condition
Message-ID: <20141210064632.GD13371@js1304-P5Q-DELUXE>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1418022980-4584-4-git-send-email-iamjoonsoo.kim@lge.com>
 <5485708D.3070009@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5485708D.3070009@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 08, 2014 at 10:34:05AM +0100, Vlastimil Babka wrote:
> On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> >Compaction has anti fragmentation algorithm. It is that freepage
> >should be more than pageblock order to finish the compaction if we don't
> >find any freepage in requested migratetype buddy list. This is for
> >mitigating fragmentation, but, it is a lack of migratetype consideration
> >and too excessive.
> >
> >At first, it doesn't consider migratetype so there would be false positive
> >on compaction finish decision. For example, if allocation request is
> >for unmovable migratetype, freepage in CMA migratetype doesn't help that
> >allocation, so compaction should not be stopped. But, current logic
> >considers it as compaction is no longer needed and stop the compaction.
> >
> >Secondly, it is too excessive. We can steal freepage from other migratetype
> >and change pageblock migratetype on more relaxed conditions. In page
> >allocator, there is another conditions that can succeed to steal without
> >introducing fragmentation.
> >
> >To solve these problems, this patch borrows anti fragmentation logic from
> >page allocator. It will reduce premature compaction finish in some cases
> >and reduce excessive compaction work.
> >
> >stress-highalloc test in mmtests with non movable order 7 allocation shows
> >in allocation success rate on phase 1 and compaction success rate.
> >
> >Allocation success rate on phase 1 (%)
> >57.00 : 63.67
> >
> >Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> >28.94 : 35.13
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  include/linux/mmzone.h |    3 +++
> >  mm/compaction.c        |   31 +++++++++++++++++++++++++++++--
> >  mm/internal.h          |    1 +
> >  mm/page_alloc.c        |    5 ++---
> >  4 files changed, 35 insertions(+), 5 deletions(-)
> >
> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >index 2f0856d..87f5bb5 100644
> >--- a/include/linux/mmzone.h
> >+++ b/include/linux/mmzone.h
> >@@ -63,6 +63,9 @@ enum {
> >  	MIGRATE_TYPES
> >  };
> >
> >+#define FALLBACK_MIGRATETYPES (4)
> >+extern int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES];
> >+
> >  #ifdef CONFIG_CMA
> >  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> >  #else
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 1a5f465..2fd5f79 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -1054,6 +1054,30 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
> >  }
> >
> >+static bool can_steal_fallbacks(struct free_area *area,
> >+			unsigned int order, int migratetype)
> >+{
> >+	int i;
> >+	int fallback_mt;
> >+
> >+	if (area->nr_free == 0)
> >+		return false;
> >+
> >+	for (i = 0; i < FALLBACK_MIGRATETYPES; i++) {
> >+		fallback_mt = fallbacks[migratetype][i];
> >+		if (fallback_mt == MIGRATE_RESERVE)
> >+			break;
> >+
> >+		if (list_empty(&area->free_list[fallback_mt]))
> >+			continue;
> >+
> >+		if (can_steal_freepages(order, migratetype, fallback_mt))
> >+			return true;
> >+	}
> >+
> >+	return false;
> >+}
> >+
> >  static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  			    const int migratetype)
> >  {
> >@@ -1104,8 +1128,11 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  		if (!list_empty(&area->free_list[migratetype]))
> >  			return COMPACT_PARTIAL;
> >
> >-		/* Job done if allocation would set block type */
> >-		if (order >= pageblock_order && area->nr_free)
> 
> So, can_steal_fallbacks() -> can_steal_freepages() is quite involved
> way if in the end we just realize that order >= pageblock_order and
> we are stealing whole pageblock. Given that often compaction is done
> for THP, it would be better to check order >= pageblock_order and
> handle it upfront. This goes together with my comments on previous
> patch that order >= pageblock_order is better handled separately.

I'd like to keep this order check in can_steal_freepages(). At first, we
should first check migratetype before order checking. If high order page
is on CMA, we can't steal it. Secondly, I think that maintaining well
defined function to check whether we can steal or not is better than
separating logic. It would help future maintanance.

Thanks.

> 
> >+		/*
> >+		 * Job done if allocation would steal freepages from
> >+		 * other migratetype buddy lists.
> >+		 */
> >+		if (can_steal_fallbacks(area, order, migratetype))
> >  			return COMPACT_PARTIAL;
> >  	}
> >
> >diff --git a/mm/internal.h b/mm/internal.h
> >index efad241..7028d83 100644
> >--- a/mm/internal.h
> >+++ b/mm/internal.h
> >@@ -179,6 +179,7 @@ unsigned long
> >  isolate_migratepages_range(struct compact_control *cc,
> >  			   unsigned long low_pfn, unsigned long end_pfn);
> >
> >+bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt);
> >  #endif
> >
> >  /*
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 7b4c9aa..dcb8523 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -1031,7 +1031,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
> >   * This array describes the order lists are fallen back to when
> >   * the free lists for the desirable migrate type are depleted
> >   */
> >-static int fallbacks[MIGRATE_TYPES][4] = {
> >+int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES] = {
> >  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
> >  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
> >  #ifdef CONFIG_CMA
> >@@ -1161,8 +1161,7 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
> >  	}
> >  }
> >
> >-static bool can_steal_freepages(unsigned int order,
> >-			int start_mt, int fallback_mt)
> >+bool can_steal_freepages(unsigned int order, int start_mt, int fallback_mt)
> >  {
> >  	/*
> >  	 * When borrowing from MIGRATE_CMA, we need to release the excess
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
