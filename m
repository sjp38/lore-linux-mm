Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49CA36B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:24:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so35910246wme.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:24:53 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id b23si8782972wmi.29.2016.04.27.05.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 05:24:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id EDF9E1C1583
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:24:46 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/4] mm, page_alloc: move might_sleep_if check to the allocator slowpath -revert
Date: Wed, 27 Apr 2016 13:24:44 +0100
Message-Id: <1461759885-17163-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
References: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Vlastimil Babka pointed out that a patch weakens a zone_reclaim test
which while "safe" defeats the purposes of the debugging check. As most
configurations eliminate this check anyway, I thought it was better to
simply revert the patch instead of adding a second check in zone_reclaim.

This is a revert of the mmotm patch
mm-page_alloc-move-might_sleep_if-check-to-the-allocator-slowpath.patch .

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 45a36e98b9cb..599bd1a49384 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3606,8 +3606,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
-	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
-
 	/*
 	 * We also sanity check to catch abuse of atomic reserves being used by
 	 * callers that are not in atomic context.
@@ -3806,6 +3804,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	lockdep_trace_alloc(gfp_mask);
 
+	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
+
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
