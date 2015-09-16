Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2CE6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 08:09:37 -0400 (EDT)
Received: by oibi136 with SMTP id i136so123439047oib.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 05:09:36 -0700 (PDT)
Received: from m12-13.163.com (m12-13.163.com. [220.181.12.13])
        by mx.google.com with ESMTP id t10si12683055oek.35.2015.09.16.05.09.34
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 05:09:36 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 3/3] mm/compaction: add an is_via_compact_memory helper function
Date: Wed, 16 Sep 2015 20:00:00 +0800
Message-Id: <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Introduce is_via_compact_memory helper function indicating compacting
via /proc/sys/vm/compact_memory to improve readability.

To catch this situation in __compaction_suitable, use order as parameter
directly instead of using struct compact_control.

This patch has no functional changes.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/compaction.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c5c627a..a8e6593 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1197,6 +1197,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
+/*
+ * order == -1 is expected when compacting via
+ * /proc/sys/vm/compact_memory
+ */
+static inline bool is_via_compact_memory(int order)
+{
+	return order == -1;
+}
+
 static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
@@ -1223,11 +1232,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 		return COMPACT_COMPLETE;
 	}
 
-	/*
-	 * order == -1 is expected when compacting via
-	 * /proc/sys/vm/compact_memory
-	 */
-	if (cc->order == -1)
+	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
 
 	/* Compaction run is not finished if the watermark is not met */
@@ -1290,11 +1295,7 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
 	int fragindex;
 	unsigned long watermark;
 
-	/*
-	 * order == -1 is expected when compacting via
-	 * /proc/sys/vm/compact_memory
-	 */
-	if (order == -1)
+	if (is_via_compact_memory(order))
 		return COMPACT_CONTINUE;
 
 	watermark = low_wmark_pages(zone);
@@ -1658,10 +1659,11 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		 * this makes sure we compact the whole zone regardless of
 		 * cached scanner positions.
 		 */
-		if (cc->order == -1)
+		if (is_via_compact_memory(cc->order))
 			__reset_isolation_suitable(zone);
 
-		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
+		if (is_via_compact_memory(cc->order) ||
+				!compaction_deferred(zone, cc->order))
 			compact_zone(zone, cc);
 
 		if (cc->order > 0) {
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
