Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 665056B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:26:35 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id k48so5626640wev.33
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:26:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si30519611wjz.45.2014.06.09.02.26.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:26:34 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 02/10] mm, compaction: report compaction as contended only due to lock contention
Date: Mon,  9 Jun 2014 11:26:14 +0200
Message-Id: <1402305982-6928-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

Async compaction aborts when it detects zone lock contention or need_resched()
is true. David Rientjes has reported that in practice, most direct async
compactions for THP allocation abort due to need_resched(). This means that a
second direct compaction is never attempted, which might be OK for a page
fault, but hugepaged is intended to attempt a sync compaction in such case and
in these cases it won't.

This patch replaces "bool contended" in compact_control with an enum that
distinguieshes between aborting due to need_resched() and aborting due to lock
contention. This allows propagating the abort through all compaction functions
as before, but declaring the direct compaction as contended only when lock
contantion has been detected.

As a result, hugepaged will proceed with second sync compaction as intended,
when the preceding async compaction aborted due to need_resched().

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 20 ++++++++++++++------
 mm/internal.h   | 15 +++++++++++----
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b73b182..d37f4a8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -185,9 +185,14 @@ static void update_pageblock_skip(struct compact_control *cc,
 }
 #endif /* CONFIG_COMPACTION */
 
-static inline bool should_release_lock(spinlock_t *lock)
+enum compact_contended should_release_lock(spinlock_t *lock)
 {
-	return need_resched() || spin_is_contended(lock);
+	if (need_resched())
+		return COMPACT_CONTENDED_SCHED;
+	else if (spin_is_contended(lock))
+		return COMPACT_CONTENDED_LOCK;
+	else
+		return COMPACT_CONTENDED_NONE;
 }
 
 /*
@@ -202,7 +207,9 @@ static inline bool should_release_lock(spinlock_t *lock)
 static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 				      bool locked, struct compact_control *cc)
 {
-	if (should_release_lock(lock)) {
+	enum compact_contended contended = should_release_lock(lock);
+
+	if (contended) {
 		if (locked) {
 			spin_unlock_irqrestore(lock, *flags);
 			locked = false;
@@ -210,7 +217,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = true;
+			cc->contended = contended;
 			return false;
 		}
 
@@ -236,7 +243,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
 	/* async compaction aborts if contended */
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = true;
+			cc->contended = COMPACT_CONTENDED_SCHED;
 			return true;
 		}
 
@@ -1095,7 +1102,8 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
-	*contended = cc.contended;
+	/* We only signal lock contention back to the allocator */
+	*contended = cc.contended == COMPACT_CONTENDED_LOCK;
 	return ret;
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 7f22a11f..4659e8e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -117,6 +117,13 @@ extern int user_min_free_kbytes;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
+/* Used to signal whether compaction detected need_sched() or lock contention */
+enum compact_contended {
+	COMPACT_CONTENDED_NONE = 0, /* no contention detected */
+	COMPACT_CONTENDED_SCHED,    /* need_sched() was true */
+	COMPACT_CONTENDED_LOCK,     /* zone lock or lru_lock was contended */
+};
+
 /*
  * in mm/compaction.c
  */
@@ -144,10 +151,10 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool contended;			/* True if a lock was contended, or
-					 * need_resched() true during async
-					 * compaction
-					 */
+	enum compact_contended contended; /* Signal need_sched() or lock
+					   * contention detected during
+					   * compaction
+					   */
 };
 
 unsigned long
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
