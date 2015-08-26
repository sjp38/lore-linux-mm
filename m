Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id BC6E56B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:53:22 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so49617179wid.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:53:22 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id d3si10293225wie.23.2015.08.26.07.53.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 07:53:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 8C32A988C2
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:53:20 +0000 (UTC)
Date: Wed, 26 Aug 2015 15:53:18 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150826145318.GP12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
 <55DDC23F.8020004@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55DDC23F.8020004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 26, 2015 at 03:42:23PM +0200, Vlastimil Babka wrote:
> >@@ -2309,22 +2311,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  #ifdef CONFIG_CMA
> >  	/* If allocation can't use CMA areas don't use free CMA pages */
> >  	if (!(alloc_flags & ALLOC_CMA))
> >-		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> >+		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> >  #endif
> >
> >-	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> >+	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
> >  		return false;
> >-	for (o = 0; o < order; o++) {
> >-		/* At the next order, this order's pages become unavailable */
> >-		free_pages -= z->free_area[o].nr_free << o;
> >
> >-		/* Require fewer higher order pages to be free */
> >-		min >>= 1;
> >+	/* order-0 watermarks are ok */
> >+	if (!order)
> >+		return true;
> >+
> >+	/* Check at least one high-order page is free */
> >+	for (o = order; o < MAX_ORDER; o++) {
> >+		struct free_area *area = &z->free_area[o];
> >+		int mt;
> >+
> >+		if (atomic && area->nr_free)
> >+			return true;
> >
> >-		if (free_pages <= min)
> >-			return false;
> >+		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> >+			if (!list_empty(&area->free_list[mt]))
> >+				return true;
> >+		}
> 
> I think we really need something like this here:
> 
> #ifdef CONFIG_CMA
> if (alloc_flags & ALLOC_CMA)) &&
> 	!list_empty(&area->free_list[MIGRATE_CMA])
> 		return true;
> #endif
> 
> This is not about CMA and high-order atomic allocations being used at the
> same time. This is about high-order MIGRATE_MOVABLE allocations (that set
> ALLOC_CMA) failing to use MIGRATE_CMA pageblocks, which they should be
> allowed to use. It's complementary to the existing free_pages adjustment
> above.
> 
> Maybe there's not many high-order MIGRATE_MOVABLE allocations today, but
> they might increase with the driver migration framework. So why set up us a
> bomb.
> 

Ok, that seems sensible. Will apply this hunk on top

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1a4169be1498..10f25bf18665 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2337,6 +2337,13 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 			if (!list_empty(&area->free_list[mt]))
 				return true;
 		}
+
+#ifdef CONFIG_CMA
+		if ((alloc_flags & ALLOC_CMA) &&
+		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+			return true;
+		}
+#endif
 	}
 	return false;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
