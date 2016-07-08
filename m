Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6662E6B0282
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:40:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so8417418wmr.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:40:41 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id 137si2089275wms.63.2016.07.08.02.40.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:40:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 17F9C1DC071
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:40:39 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 31/34] mm: vmstat: replace __count_zone_vm_events with a zone id equivalent
Date: Fri,  8 Jul 2016 10:35:07 +0100
Message-Id: <1467970510-21195-32-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is partially a preparation patch for more vmstat work but it also has
the slight advantage that __count_zid_vm_events is cheaper to calculate
than __count_zone_vm_events().

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vmstat.h | 5 ++---
 mm/page_alloc.c        | 2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 6b7975cd98aa..613771909b6e 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -101,9 +101,8 @@ static inline void vm_events_fold_cpu(int cpu)
 #define count_vm_vmacache_event(x) do {} while (0)
 #endif
 
-#define __count_zone_vm_events(item, zone, delta) \
-		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
-		zone_idx(zone), delta)
+#define __count_zid_vm_events(item, zid, delta) \
+	__count_vm_events(item##_NORMAL - ZONE_NORMAL + zid, delta)
 
 /*
  * Zone and node-based page accounting with per cpu differentials.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 958424fc64be..030114f55b0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2659,7 +2659,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 					  get_pcppage_migratetype(page));
 	}
 
-	__count_zone_vm_events(PGALLOC, zone, 1 << order);
+	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
