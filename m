Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 29B4D6B028E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:45:52 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id v188so121576858wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:45:52 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id n127si23206531wma.88.2016.04.12.03.45.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:45:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id CDC4D98BF1
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:45:50 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/28] mm: vmstat: Replace __count_zone_vm_events with a zone id equivalent
Date: Tue, 12 Apr 2016 11:45:03 +0100
Message-Id: <1460457904-754-14-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
 <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
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
index 24bca20ede8f..9360ef611f3e 100644
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
index 490a3cd34b7d..6b20efec0f60 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2466,7 +2466,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
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
