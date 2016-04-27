Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91CAC6B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:57:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so40346329wme.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:57:33 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id a71si9579753wma.36.2016.04.27.07.57.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 07:57:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 4CD549895D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 14:57:24 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/6] mm, page_alloc: move might_sleep_if check to the allocator slowpath -revert
Date: Wed, 27 Apr 2016 15:57:19 +0100
Message-Id: <1461769043-28337-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
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
index d8383750bd43..9ad4e68486e9 100644
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
