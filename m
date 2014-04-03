Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D4FD06B0148
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 04:57:32 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so1481052pdj.12
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 01:57:32 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id j4si2776097pad.145.2014.04.03.01.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 03 Apr 2014 01:57:32 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N3G009BQ676JV90@mailout1.samsung.com> for linux-mm@kvack.org;
 Thu, 03 Apr 2014 17:57:06 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH 2/2] mm/compaction: fix to initialize free scanner properly
Date: Thu, 03 Apr 2014 17:57:04 +0900
Message-id: <1396515424-18794-2-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com>
References: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>

Free scanner does not works well on systems having zones which do not
span to pageblock-aligned boundary.

zone->compact_cached_free_pfn is reset when the migration and free
scanner across or compaction restarts. After the reset, if end_pfn of
the zone was not aligned to pageblock_nr_pages, free scanner tries to
isolate free pages from the middle of pageblock to the end, which can
be very small range.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
Cc: Dongjun Shin <d.j.shin@samsung.com>
Cc: Sunghwan Yun <sunghwan.yun@samsung.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 1ef9144..fefe1da 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -983,7 +983,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	 */
 	cc->migrate_pfn = zone->compact_cached_migrate_pfn;
 	cc->free_pfn = zone->compact_cached_free_pfn;
-	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
+	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
 		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
 		zone->compact_cached_free_pfn = cc->free_pfn;
 	}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
