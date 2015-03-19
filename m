Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 169796B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:30:01 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so64800059pab.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 22:30:00 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id x4si692861pdr.44.2015.03.18.22.29.59
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 22:30:00 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [PATCH] [RFC] mm/compaction: initialize compaction information
Date: Thu, 19 Mar 2015 14:30:31 +0900
Message-Id: <1426743031-30096-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

I tried to start compaction via /proc/sys/vm/compact_memory
as soon as I turned on my ARM-based platform.
But the compaction didn't start.
I found some variables in struct zone are not initalized.

I think zone->compact_cached_free_pfn and some cache values for compaction
are initalized when the kernel starts compaction, not via
/proc/sys/vm/compact_memory.
If my guess is correct, an initialization are needed for that case.


Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/compaction.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..944a9cc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1299,6 +1299,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		__reset_isolation_suitable(zone);
 
 	/*
+	 * If this is activated by /proc/sys/vm/compact_memory
+	 * and the first try, cached information for compaction is not
+	 * initialized.
+	 */
+	if (cc->order == -1 && zone->compact_cached_free_pfn == 0)
+		__reset_isolation_suitable(zone);
+
+	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
 	 * information on where the scanners should start but check that it
 	 * is initialised by ensuring the values are within zone boundaries.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
