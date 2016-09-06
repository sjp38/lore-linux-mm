Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4123682F64
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:53:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so36226490lfs.1
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:53:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m68si23515282wma.37.2016.09.06.06.53.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:53:17 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/4] mm, compaction: restrict full priority to non-costly orders
Date: Tue,  6 Sep 2016 15:52:57 +0200
Message-Id: <20160906135258.18335-4-vbabka@suse.cz>
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>

The new ultimate compaction priority disables some heuristics, which may result
in excessive cost. This is fine for non-costly orders where we want to try hard
before resulting for OOM, but might be disruptive for costly orders which do
not trigger OOM and should generally have some fallback. Thus, we disable the
full priority for costly orders.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/compaction.h | 1 +
 mm/page_alloc.c            | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 585d55cb0dc0..0d8415820fc3 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -9,6 +9,7 @@ enum compact_priority {
 	COMPACT_PRIO_SYNC_FULL,
 	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_FULL,
 	COMPACT_PRIO_SYNC_LIGHT,
+	MIN_COMPACT_COSTLY_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
 	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
 	COMPACT_PRIO_ASYNC,
 	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8bed910e3cf..ff60a2837c58 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3165,6 +3165,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 		     int compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
+	int min_priority;
 
 	if (!order)
 		return false;
@@ -3204,7 +3205,9 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * if we exhausted all retries at the lower priorities
 	 */
 check_priority:
-	if (*compact_priority > MIN_COMPACT_PRIORITY) {
+	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
+			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
+	if (*compact_priority > min_priority) {
 		(*compact_priority)--;
 		return true;
 	}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
