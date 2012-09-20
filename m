Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 92C186B0062
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 10:04:40 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/6] mm: compaction: Abort compaction loop if lock is contended or run too long
Date: Thu, 20 Sep 2012 15:04:30 +0100
Message-Id: <1348149875-29678-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-1-git-send-email-mgorman@suse.de>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Shaohua Li <shli@fusionio.com>

Changelog since V2
o Fix BUG_ON triggered due to pages left on cc.migratepages
o Make compact_zone_order() require non-NULL arg `contended'

Changelog since V1
o only abort the compaction if lock is contended or run too long
o Rearranged the code by Andrea Arcangeli.

isolate_migratepages_range() might isolate no pages if for example when
zone->lru_lock is contended and running asynchronous compaction. In this
case, we should abort compaction, otherwise, compact_zone will run a
useless loop and make zone->lru_lock is even contended.

[minchan@kernel.org: Putback pages isolated for migration if aborting]
[akpm@linux-foundation.org: compact_zone_order requires non-NULL arg contended]
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Shaohua Li <shli@fusionio.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   17 ++++++++++++-----
 mm/internal.h   |    2 +-
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..a8de20d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -70,8 +70,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (!cc->sync) {
-			if (cc->contended)
-				*cc->contended = true;
+			cc->contended = true;
 			return false;
 		}
 
@@ -634,7 +633,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	/* Perform the isolation */
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
+	if (!low_pfn || cc->contended)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;
@@ -787,6 +786,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
+			putback_lru_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
 			continue;
@@ -831,6 +832,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {
+	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -838,12 +840,17 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	ret = compact_zone(zone, &cc);
+
+	VM_BUG_ON(!list_empty(&cc.freepages));
+	VM_BUG_ON(!list_empty(&cc.migratepages));
+
+	*contended = cc.contended;
+	return ret;
 }
 
 int sysctl_extfrag_threshold = 500;
diff --git a/mm/internal.h b/mm/internal.h
index b8c91b3..4bd7c0e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -130,7 +130,7 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool *contended;		/* True if a lock was contended */
+	bool contended;			/* True if a lock was contended */
 };
 
 unsigned long
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
