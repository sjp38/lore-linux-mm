Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 114576B0276
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 12:20:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so88794759wmg.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 09:20:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q12si9173379wme.20.2016.09.26.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 09:20:32 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/4] mm, compaction: restrict fragindex to costly orders
Date: Mon, 26 Sep 2016 18:20:25 +0200
Message-Id: <20160926162025.21555-5-vbabka@suse.cz>
In-Reply-To: <20160926162025.21555-1-vbabka@suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

Fragmentation index and the vm.extfrag_threshold sysctl is meant as a heuristic
to prevent excessive compaction for costly orders (i.e. THP). It's unlikely to
make any difference for non-costly orders, especially with the default
threshold. But we cannot afford any uncertainty for the non-costly orders where
the only alternative to successful reclaim/compaction is OOM. After the recent
patches we are guaranteed maximum effort without heuristics from compaction
before deciding OOM, and fragindex is the last remaining heuristic. Therefore
skip fragindex altogether for non-costly orders.

Suggested-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 5ff7f801c345..badb92bf14b4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1435,9 +1435,14 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
 	 * index towards 0 implies failure is due to lack of memory
 	 * index towards 1000 implies failure is due to fragmentation
 	 *
-	 * Only compact if a failure would be due to fragmentation.
+	 * Only compact if a failure would be due to fragmentation. Also
+	 * ignore fragindex for non-costly orders where the alternative to
+	 * a successful reclaim/compaction is OOM. Fragindex and the
+	 * vm.extfrag_threshold sysctl is meant as a heuristic to prevent
+	 * excessive compaction for costly orders, but it should not be at the
+	 * expense of system stability.
 	 */
-	if (ret == COMPACT_CONTINUE) {
+	if (ret == COMPACT_CONTINUE && (order > PAGE_ALLOC_COSTLY_ORDER)) {
 		fragindex = fragmentation_index(zone, order);
 		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
 			return COMPACT_NOT_SUITABLE_ZONE;
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
