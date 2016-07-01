Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAFA3828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:06:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so25925977wme.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 13:06:38 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id ef9si2882994wjd.278.2016.07.01.13.06.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 13:06:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 7785298E3A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 20:06:37 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 28/31] mm: vmstat: replace __count_zone_vm_events with a zone id equivalent
Date: Fri,  1 Jul 2016 21:01:36 +0100
Message-Id: <1467403299-25786-29-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index 552d0db4fca2..0e53874a66a9 100644
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
index 69ffaadc31ed..d3eb15c35bb1 100644
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
