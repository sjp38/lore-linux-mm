Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79F1A6B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:08:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d19so63945808lfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:08:28 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id j5si49472083wjz.127.2016.04.15.02.08.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:08:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id D4C35210339
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:08:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 15/28] mm, page_alloc: Move might_sleep_if check to the allocator slowpath
Date: Fri, 15 Apr 2016 10:07:42 +0100
Message-Id: <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There is a debugging check for callers that specify __GFP_DIRECT_RECLAIM
from a context that cannot sleep. Triggering this is almost certainly
a bug but it's also overhead in the fast path. Move the check to the slow
path. It'll be harder to trigger as it'll only be checked when watermarks
are depleted but it'll also only be checked in a path that can sleep.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 21aaef6ddd7a..9ef2f4ab9ca5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3176,6 +3176,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
+	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
+
 	/*
 	 * We also sanity check to catch abuse of atomic reserves being used by
 	 * callers that are not in atomic context.
@@ -3369,8 +3371,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	lockdep_trace_alloc(gfp_mask);
 
-	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
-
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
