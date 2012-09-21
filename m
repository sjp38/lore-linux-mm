Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EDDBA6B0068
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 06:46:31 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/9] Revert "mm: compaction: abort compaction loop if lock is contended or run too long"
Date: Fri, 21 Sep 2012 11:46:17 +0100
Message-Id: <1348224383-1499-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1348224383-1499-1-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long.patch
as it is replaced by a later patch in the series.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   12 +++++-------
 mm/internal.h   |    2 +-
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 1c873bb..614f18b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -70,7 +70,8 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (!cc->sync) {
-			cc->contended = true;
+			if (cc->contended)
+				*cc->contended = true;
 			return false;
 		}
 
@@ -685,7 +686,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	/* Perform the isolation */
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn || cc->contended)
+	if (!low_pfn)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;
@@ -893,7 +894,6 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 bool sync, bool *contended,
 				 struct page **page)
 {
-	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -901,15 +901,13 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
+		.contended = contended,
 		.page = page,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	ret = compact_zone(zone, &cc);
-	if (contended)
-		*contended = cc.contended;
-	return ret;
+	return compact_zone(zone, &cc);
 }
 
 int sysctl_extfrag_threshold = 500;
diff --git a/mm/internal.h b/mm/internal.h
index eebbed5..386772f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -131,7 +131,7 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool contended;			/* True if a lock was contended */
+	bool *contended;		/* True if a lock was contended */
 	struct page **page;		/* Page captured of requested size */
 };
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
