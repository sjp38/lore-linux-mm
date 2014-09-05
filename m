Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id D4AEA6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 06:14:56 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id b17so13742206lan.27
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 03:14:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si2160275lbl.110.2014.09.05.03.14.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 03:14:55 -0700 (PDT)
Date: Fri, 5 Sep 2014 11:14:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Fix setting of ZONE_FAIR_DEPLETED on UP
Message-ID: <20140905101451.GF17501@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de>
 <53E4EC53.1050904@suse.cz>
 <20140811121241.GD7970@suse.de>
 <53E8B83D.1070004@suse.cz>
 <20140902140116.GD29501@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140902140116.GD29501@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Commit 4ffeaf35 (mm: page_alloc: reduce cost of the fair zone allocation policy)
broke the fair zone allocation policy on UP with these hunks.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e5e8f7..fb99081 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
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

The problem is that a <= check was replaced with a ==. On SMP it doesn't
matter because negative values are returned as zero due to per-CPU drift
which is not possible in the UP case. Vlastimil Babka correctly pointed
out that this can be negative due to high-order allocations. This patch
fixes the problem.

Reported-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d..cd4c05c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1612,7 +1612,7 @@ again:
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
+	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0 &&
 	    !zone_is_fair_depleted(zone))
 		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
