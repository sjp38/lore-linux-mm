Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (unknown [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 893FF6B0068
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:59 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1698049eei.33
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si40636408eeo.11.2014.04.18.07.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:48 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/16] mm: page_alloc: Only check the alloc flags and gfp_mask for dirty once
Date: Fri, 18 Apr 2014 15:50:35 +0100
Message-Id: <1397832643-14275-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Currently it's calculated once per zone in the zonelist.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5933a5..770735a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1911,6 +1911,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
+				(gfp_mask & __GFP_WRITE);
 
 zonelist_scan:
 	/*
@@ -1969,8 +1971,7 @@ zonelist_scan:
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if ((alloc_flags & ALLOC_WMARK_LOW) &&
-		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
+		if (consider_zone_dirty && !zone_dirty_ok(zone))
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
