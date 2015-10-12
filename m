Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31A9E6B0253
	for <linux-mm@kvack.org>; Sun, 11 Oct 2015 22:40:32 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so140251781pad.1
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 19:40:31 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id we9si22272064pac.164.2015.10.11.19.40.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Oct 2015 19:40:31 -0700 (PDT)
Received: by pacik9 with SMTP id ik9so17519656pac.3
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 19:40:31 -0700 (PDT)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [RFC] mm: fix a BUG, the page is allocated 2 times
Date: Mon, 12 Oct 2015 10:40:06 +0800
Message-Id: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: yalin wang <yalin.wang2010@gmail.com>

Remove unlikely(order), because we are sure order is not zero if
code reach here, also add if (page == NULL), only allocate page again if
__rmqueue_smallest() failed or alloc_flags & ALLOC_HARDER == 0

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d6f540..de82e2c 100644
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
+		if (page == NULL)
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
