Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DB1946B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 21:42:40 -0400 (EDT)
Received: by iofl186 with SMTP id l186so6199281iof.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:42:40 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id o10si830956igv.56.2015.10.12.18.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 18:42:40 -0700 (PDT)
Received: by palb17 with SMTP id b17so410412pal.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:42:40 -0700 (PDT)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH V2] mm, page_alloc: reserve pageblocks for high-order atomic allocations on demand -fix
Date: Tue, 13 Oct 2015 09:42:24 +0800
Message-Id: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: yalin wang <yalin.wang2010@gmail.com>

There is a redundant check and a memory leak introduced by a patch in
mmotm. This patch removes an unlikely(order) check as we are sure order
is not zero at the time. It also checks if a page is already allocated
to avoid a memory leak.

This is a fix to the mmotm patch
mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d6f540..043b691 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2241,13 +2241,13 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		spin_lock_irqsave(&zone->lock, flags);
 
 		page = NULL;
-		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
+		if (alloc_flags & ALLOC_HARDER) {
 			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
 			if (page)
 				trace_mm_page_alloc_zone_locked(page, order, migratetype);
 		}
-
-		page = __rmqueue(zone, order, migratetype, gfp_flags);
+		if (!page)
+			page = __rmqueue(zone, order, migratetype, gfp_flags);
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
