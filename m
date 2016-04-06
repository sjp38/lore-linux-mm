Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD146B027D
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:24:08 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l6so60438849wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:24:08 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id p5si3239474wmd.62.2016.04.06.04.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:24:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id C67301C1C55
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:24:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 26/27] mm: vmstat: Replace __count_zone_vm_events with a zone id equivalent
Date: Wed,  6 Apr 2016 12:22:15 +0100
Message-Id: <1459941736-3633-27-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
References: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is partially a preparation patch for more vmstat work but it also
has the slight advantage that __count_zid_vm_events is cheaper to
calculate than __count_zone_vm_events().

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/vmstat.h | 5 ++---
 mm/page_alloc.c        | 2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ea00884ac8a0..810914b63564 100644
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
index a6e6184d3e38..ef04dc74e7e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2399,7 +2399,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
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
