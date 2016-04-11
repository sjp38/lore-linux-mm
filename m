Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6726B0260
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:15:45 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id u206so93204416wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:15:45 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id y62si17076277wmh.57.2016.04.11.01.15.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 01:15:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 2156F98B84
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:15:44 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 15/22] mm, page_alloc: Move might_sleep_if check to the allocator slowpath
Date: Mon, 11 Apr 2016 09:13:38 +0100
Message-Id: <1460362424-26369-16-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index e50e754ec9eb..73dc0413e997 100644
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
