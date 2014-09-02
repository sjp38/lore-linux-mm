Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEC56B003A
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 10:01:24 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id v6so7702515lbi.9
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 07:01:23 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ay8si5205545lab.0.2014.09.02.07.01.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 07:01:22 -0700 (PDT)
Date: Tue, 2 Sep 2014 10:01:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140902140116.GD29501@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de>
 <53E4EC53.1050904@suse.cz>
 <20140811121241.GD7970@suse.de>
 <53E8B83D.1070004@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E8B83D.1070004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Mon, Aug 11, 2014 at 02:34:05PM +0200, Vlastimil Babka wrote:
> On 08/11/2014 02:12 PM, Mel Gorman wrote:
> >On Fri, Aug 08, 2014 at 05:27:15PM +0200, Vlastimil Babka wrote:
> >>On 07/09/2014 10:13 AM, Mel Gorman wrote:
> >>>--- a/mm/page_alloc.c
> >>>+++ b/mm/page_alloc.c
> >>>@@ -1604,6 +1604,9 @@ again:
> >>>  	}
> >>>
> >>>  	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> >>
> >>This can underflow zero, right?
> >>
> >
> >Yes, because of per-cpu accounting drift.
> 
> I meant mainly because of order > 0.
> 
> >>>+	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
> >>
> >>AFAICS, zone_page_state will correct negative values to zero only for
> >>CONFIG_SMP. Won't this check be broken on !CONFIG_SMP?
> >>
> >
> >On !CONFIG_SMP how can there be per-cpu accounting drift that would make
> >that counter negative?
> 
> Well original code used "if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)"
> elsewhere, that you are replacing with zone_is_fair_depleted check. I
> assumed it's because it can get negative due to order > 0. I might have not
> looked thoroughly enough but it seems to me there's nothing that would
> prevent it, such as skipping a zone because its remaining batch is lower
> than 1 << order.
> So I think the check should be "<= 0" to be safe.

Any updates on this?

The counter can definitely underflow on !CONFIG_SMP, and then the flag
gets out of sync with the actual batch state.  I'd still prefer just
removing this flag again; it's extra complexity and error prone (case
in point) while the upsides are not even measurable in real life.

---

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 318df7051850..0bd77f730b38 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -534,7 +534,6 @@ typedef enum {
 	ZONE_WRITEBACK,			/* reclaim scanning has recently found
 					 * many pages under writeback
 					 */
-	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 } zone_flags_t;
 
 static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
@@ -572,11 +571,6 @@ static inline int zone_is_reclaim_locked(const struct zone *zone)
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
 }
 
-static inline int zone_is_fair_depleted(const struct zone *zone)
-{
-	return test_bit(ZONE_FAIR_DEPLETED, &zone->flags);
-}
-
 static inline int zone_is_oom_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d4c8a2..d913809a328f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1612,9 +1612,6 @@ again:
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
-	    !zone_is_fair_depleted(zone))
-		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1934,7 +1931,6 @@ static void reset_alloc_batches(struct zone *preferred_zone)
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 			high_wmark_pages(zone) - low_wmark_pages(zone) -
 			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
 	} while (zone++ != preferred_zone);
 }
 
@@ -1985,7 +1981,7 @@ zonelist_scan:
 		if (alloc_flags & ALLOC_FAIR) {
 			if (!zone_local(preferred_zone, zone))
 				break;
-			if (zone_is_fair_depleted(zone)) {
+			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0) {
 				nr_fair_skipped++;
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
