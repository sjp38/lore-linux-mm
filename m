Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03E6D6B0038
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 07:57:28 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id pv20so17249508lab.19
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 04:57:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ug4si13610556lbc.5.2014.09.08.04.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 04:57:23 -0700 (PDT)
Date: Mon, 8 Sep 2014 12:57:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Fix setting of ZONE_FAIR_DEPLETED on UP v2
Message-ID: <20140908115718.GL17501@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de>
 <53E4EC53.1050904@suse.cz>
 <20140811121241.GD7970@suse.de>
 <53E8B83D.1070004@suse.cz>
 <20140902140116.GD29501@cmpxchg.org>
 <20140905101451.GF17501@suse.de>
 <CALq1K=JO2b-=iq40RRvK8JFFbrzyH5EyAp5jyS50CeV0P3eQcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALq1K=JO2b-=iq40RRvK8JFFbrzyH5EyAp5jyS50CeV0P3eQcA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Leon Romanovsky <leon@leon.nu>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Commit 4ffeaf35 (mm: page_alloc: reduce cost of the fair zone allocation
policy) arguably broke the fair zone allocation policy on UP with these
hunks.

a/mm/page_alloc.c
b/mm/page_alloc.c
@@ -1612,6 +1612,9 @@ again:
       	}

       	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+       if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
+           !zone_is_fair_depleted(zone))
+               zone_set_flag(zone, ZONE_FAIR_DEPLETED);

       	__count_zone_vm_events(PGALLOC, zone, 1 << order);
       	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1966,8 +1985,10 @@ zonelist_scan:
               	if (alloc_flags & ALLOC_FAIR) {
                       	if (!zone_local(preferred_zone, zone))
                               	break;
-                       if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+                       if (zone_is_fair_depleted(zone)) {
+                               nr_fair_skipped++;
                               	continue;
+                       }
               	}

A <= check was replaced with a ==. On SMP it doesn't matter because
negative values are returned as zero due to per-CPU drift which is not
possible in the UP case. Vlastimil Babka correctly pointed out that this
can wrap negative due to high-order allocations.

However, Leon Romanovsky pointed out that a <= check on zone_page_state
was never correct as zone_page_state returns unsigned long so the root
cause of the breakage was the <= check in the first place.

zone_page_state is an API hazard because of the difference in behaviour
between SMP and UP is very surprising. There is a good reason to allow
NR_ALLOC_BATCH to go negative -- when the counter is reset the negative
value takes recent activity into account. This patch makes zone_page_state
behave the same on SMP and UP as saving one branch on UP is not likely to
make a measurable performance difference.

Reported-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Leon Romanovsky <leon@leon.nu>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vmstat.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7..cece0f0 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -131,10 +131,8 @@ static inline unsigned long zone_page_state(struct zone *zone,
 					enum zone_stat_item item)
 {
 	long x = atomic_long_read(&zone->vm_stat[item]);
-#ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
-#endif
 	return x;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
