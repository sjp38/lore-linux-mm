Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7C18828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so52870731wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ti3si38953233wjb.1.2016.08.10.02.12.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:43 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 06/11] mm, compaction: more reliably increase direct compaction priority
Date: Wed, 10 Aug 2016 11:12:21 +0200
Message-Id: <20160810091226.6709-7-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

During reclaim/compaction loop, compaction priority can be increased by the
should_compact_retry() function, but the current code is not optimal. Priority
is only increased when compaction_failed() is true, which means that compaction
has scanned the whole zone. This may not happen even after multiple attempts
with a lower priority due to parallel activity, so we might needlessly
struggle on the lower priorities and possibly run out of compaction retry
attempts in the process.

After this patch we are guaranteed at least one attempt at the highest
compaction priority even if we exhaust all retries at the lower priorities.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fb975cec3518..b28517b918b0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3155,13 +3155,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * so it doesn't really make much sense to retry except when the
 	 * failure could be caused by insufficient priority
 	 */
-	if (compaction_failed(compact_result)) {
-		if (*compact_priority > MIN_COMPACT_PRIORITY) {
-			(*compact_priority)--;
-			return true;
-		}
-		return false;
-	}
+	if (compaction_failed(compact_result))
+		goto check_priority;
 
 	/*
 	 * make sure the compaction wasn't deferred or didn't bail out early
@@ -3185,6 +3180,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (compaction_retries <= max_retries)
 		return true;
 
+	/*
+	 * Make sure there is at least one attempt at the highest priority
+	 * if we exhausted all retries at the lower priorities
+	 */
+check_priority:
+	if (*compact_priority > MIN_COMPACT_PRIORITY) {
+		(*compact_priority)--;
+		return true;
+	}
 	return false;
 }
 #else
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
