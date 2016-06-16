Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBDC46B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:30:37 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so5627227lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:30:37 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id q3si4049433wje.150.2016.06.16.01.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:30:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 98ED01C2115
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:30:35 +0100 (IST)
Date: Thu, 16 Jun 2016 09:30:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/27] mm, vmscan: Simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160616083033.GF1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-9-git-send-email-mgorman@techsingularity.net>
 <6b6b9f95-869a-a9f2-c5cf-f0a3e4d6bd6a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6b6b9f95-869a-a9f2-c5cf-f0a3e4d6bd6a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2016 at 05:18:00PM +0200, Vlastimil Babka wrote:
> >@@ -1209,9 +1209,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
> >
> > 		arch_refresh_nodedata(nid, pgdat);
> > 	} else {
> >-		/* Reset the nr_zones and classzone_idx to 0 before reuse */
> >+		/* Reset the nr_zones, order and classzone_idx before reuse */
> > 		pgdat->nr_zones = 0;
> >-		pgdat->classzone_idx = 0;
> >+		pgdat->kswapd_order = 0;
> >+		pgdat->kswapd_classzone_idx = -1;
> > 	}
> >
> > 	/* we can use NODE_DATA(nid) from here */
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 4ce578b969da..d8cb483d5cad 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -6036,7 +6036,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> > 	unsigned long end_pfn = 0;
> >
> > 	/* pg_data_t should be reset to zero when it's allocated */
> >-	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
> >+	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
> 
> Above you changed the reset value of kswapd_classzone_idx from 0 to -1, so
> won't this trigger? Also should we check kswapd_order that's newly reset
> too?
> 

Good spot. The memory initialisation paths are ok but node memory hotplug
was broken.

> >
> > 	reset_deferred_meminit(pgdat);
> > 	pgdat->node_id = nid;
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 96bf841f9352..14b34eebedff 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -2727,7 +2727,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> >
> > 	/* kswapd must be awake if processes are being throttled */
> > 	if (!wmark_ok && waitqueue_active(&pgdat->kswapd_wait)) {
> >-		pgdat->classzone_idx = min(pgdat->classzone_idx,
> >+		pgdat->kswapd_classzone_idx = min(pgdat->kswapd_classzone_idx,
> > 						(enum zone_type)ZONE_NORMAL);
> > 		wake_up_interruptible(&pgdat->kswapd_wait);
> > 	}
> >@@ -3211,6 +3211,12 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
> >
> > 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> >
> >+	/* If kswapd has not been woken recently, then full sleep */
> >+	if (classzone_idx == -1) {
> >+		classzone_idx = balanced_classzone_idx = MAX_NR_ZONES - 1;
> >+		goto full_sleep;
> 
> This will skip the wakeup_kcompactd() part.
> 

I wrestled with this one. I decided to leave it alone on the grounds
that if kswapd has not been woken recently then compaction efforts also
have not failed and kcompactd is not required.

> >@@ -3311,38 +3316,25 @@ static int kswapd(void *p)
> > 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > 	set_freezable();
> >
> >-	order = new_order = 0;
> >-	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
> >-	balanced_classzone_idx = classzone_idx;
> >+	pgdat->kswapd_order = order = 0;
> >+	pgdat->kswapd_classzone_idx = classzone_idx = -1;
> > 	for ( ; ; ) {
> > 		bool ret;
> >
> >+kswapd_try_sleep:
> >+		kswapd_try_to_sleep(pgdat, order, classzone_idx, classzone_idx);
> 
> The last two parameters are now the same, remove one?
> 

Yes. A few more basic simplifications are then possible.

> >@@ -3352,12 +3344,19 @@ static int kswapd(void *p)
> > 		 * We can speed up thawing tasks if we don't call balance_pgdat
> > 		 * after returning from the refrigerator
> > 		 */
> >-		if (!ret) {
> >-			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> >+		if (ret)
> >+			continue;
> >
> >-			/* return value ignored until next patch */
> >-			balance_pgdat(pgdat, order, classzone_idx);
> >-		}
> >+		/*
> >+		 * Try reclaim the requested order but if that fails
> >+		 * then try sleeping on the basis of the order reclaimed.
> 
> Is the last word really meant to be "reclaimed", or "requested"?
> 

No, I really meant reclaimed.

> >+		 */
> >+		trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> >+		if (balance_pgdat(pgdat, order, classzone_idx) < order)
> >+			goto kswapd_try_sleep;
> 
> AFAICS now kswapd_try_to_sleep() will use the "requested" order. That's
> needed for proper wakeup_kcompactd(), but won't it prevent kswapd from
> actually going to sleep, because zone_balanced() in prepare-sleep will be
> false? So I think you need to give it both orders to do the right thing?
> 

You're right. There is a risk that kswapd stays awake longer in high
fragmentation scenarios.

Should be fixed now by passing in both orders.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
