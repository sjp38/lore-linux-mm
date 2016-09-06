Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFE7C82F64
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:53:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m139so80394006wma.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:53:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg6si22284413wjd.136.2016.09.06.06.53.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:53:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm, compaction: more reliably increase direct compaction priority
Date: Tue,  6 Sep 2016 15:52:56 +0200
Message-Id: <20160906135258.18335-3-vbabka@suse.cz>
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>

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
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1df7694f4ec7..f8bed910e3cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3174,13 +3174,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
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
@@ -3204,6 +3199,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
