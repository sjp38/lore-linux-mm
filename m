Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B441A82965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:15 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so2249410wib.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si6817275wij.57.2014.07.09.01.13.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/6] mm: page_alloc: Abort fair zone allocation policy when remotes nodes are encountered
Date: Wed,  9 Jul 2014 09:13:07 +0100
Message-Id: <1404893588-21371-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-1-git-send-email-mgorman@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

The purpose of numa_zonelist_order=zone is to preserve lower zones
for use with 32-bit devices. If locality is preferred then the
numa_zonelist_order=node policy should be used. Unfortunately, the fair
zone allocation policy overrides this by skipping zones on remote nodes
until the lower one is found. While this makes sense from a page aging
and performance perspective, it breaks the expected zonelist policy. This
patch restores the expected behaviour for zone-list ordering.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aa46f00..0bf384a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1957,7 +1957,7 @@ zonelist_scan:
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
 			if (!zone_local(preferred_zone, zone))
-				continue;
+				break;
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
 		}
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
