Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8F8B96B005A
	for <linux-mm@kvack.org>; Sun, 16 Sep 2012 15:13:07 -0400 (EDT)
Date: Sun, 16 Sep 2012 20:12:55 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120916191255.GA5184@alpha.arachsys.com>
References: <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
 <20120915155524.GA24182@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120915155524.GA24182@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Richard Davies wrote:
> Thank you for your latest patches. I attach my latest perf report for a slow
> boot with all of these applied.

For avoidance of any doubt, there is the combined diff versus 3.6.0-rc5
which I tested:

diff --git a/fs/btrfs/qgroup.c b/fs/btrfs/qgroup.c
index 38b42e7..090405d 100644
--- a/fs/btrfs/qgroup.c
+++ b/fs/btrfs/qgroup.c
@@ -1383,10 +1383,8 @@ int btrfs_qgroup_inherit(struct btrfs_trans_handle *trans,
 		qgroup_dirty(fs_info, srcgroup);
 	}
 
-	if (!inherit) {
-		ret = -EINVAL;
+	if (!inherit)
 		goto unlock;
-	}
 
 	i_qgroups = (u64 *)(inherit + 1);
 	for (i = 0; i < inherit->num_qgroups; ++i) {
diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..92bae88 100644
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
 
@@ -296,8 +295,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	locked = true;
+	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
+	if (!locked)
+		return 0;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 
@@ -431,17 +431,21 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
- * Returns the start pfn of the last page block in a zone.  This is the starting
- * point for full compaction of a zone.  Compaction searches for free pages from
- * the end of each zone, while isolate_freepages_block scans forward inside each
- * page block.
+ * We scan the zone in a circular fashion, starting at
+ * zone->compact_cached_free_pfn. Be careful not to skip if
+ * one compacting thread has just wrapped back to the end of the
+ * zone, but another thread has not.
  */
-static unsigned long start_free_pfn(struct zone *zone)
+static bool compaction_may_skip(struct zone *zone,
+				struct compact_control *cc)
 {
-	unsigned long free_pfn;
-	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	free_pfn &= ~(pageblock_nr_pages-1);
-	return free_pfn;
+	if (!cc->wrapped && zone->compact_cached_free_pfn < cc->start_free_pfn)
+		return true;
+
+	if (cc->wrapped && zone->compact_cached_free_pfn > cc->start_free_pfn)
+		return true;
+
+	return false;
 }
 
 /*
@@ -483,6 +487,13 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
+		/*
+		 * Skip ahead if another thread is compacting in the area
+		 * simultaneously, and has finished with this page block.
+		 */
+		if (cc->order > 0 && compaction_may_skip(zone, cc))
+			pfn = min(pfn, zone->compact_cached_free_pfn);
+
 		if (!pfn_valid(pfn))
 			continue;
 
@@ -533,15 +544,7 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		if (isolated) {
 			high_pfn = max(high_pfn, pfn);
-
-			/*
-			 * If the free scanner has wrapped, update
-			 * compact_cached_free_pfn to point to the highest
-			 * pageblock with free pages. This reduces excessive
-			 * scanning of full pageblocks near the end of the
-			 * zone
-			 */
-			if (cc->order > 0 && cc->wrapped)
+			if (cc->order > 0)
 				zone->compact_cached_free_pfn = high_pfn;
 		}
 	}
@@ -551,11 +554,6 @@ static void isolate_freepages(struct zone *zone,
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
-
-	/* If compact_cached_free_pfn is reset then set it now */
-	if (cc->order > 0 && !cc->wrapped &&
-			zone->compact_cached_free_pfn == start_free_pfn(zone))
-		zone->compact_cached_free_pfn = high_pfn;
 }
 
 /*
@@ -634,7 +632,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	/* Perform the isolation */
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
+	if (!low_pfn || cc->contended)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;
@@ -642,6 +640,20 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
+/*
+ * Returns the start pfn of the last page block in a zone.  This is the starting
+ * point for full compaction of a zone.  Compaction searches for free pages from
+ * the end of each zone, while isolate_freepages_block scans forward inside each
+ * page block.
+ */
+static unsigned long start_free_pfn(struct zone *zone)
+{
+	unsigned long free_pfn;
+	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	free_pfn &= ~(pageblock_nr_pages-1);
+	return free_pfn;
+}
+
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -787,6 +799,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
+			putback_lru_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
 			continue;
@@ -831,6 +845,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {
+	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -838,12 +853,17 @@ static unsigned long compact_zone_order(struct zone *zone,
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
