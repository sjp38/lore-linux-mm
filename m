Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id BD9886B0173
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:48:28 -0400 (EDT)
Date: Thu, 13 Sep 2012 15:47:40 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 1/2] Revert "mm: have order > 0 compaction start near a
 pageblock with free pages"
Message-ID: <20120913154740.0d9a9a07@cuia.bos.redhat.com>
In-Reply-To: <20120912164615.GA14173@alpha.arachsys.com>
References: <20120822124032.GA12647@alpha.arachsys.com>
	<5034D437.8070106@redhat.com>
	<20120822144150.GA1400@alpha.arachsys.com>
	<5034F8F4.3080301@redhat.com>
	<20120825174550.GA8619@alpha.arachsys.com>
	<50391564.30401@redhat.com>
	<20120826105803.GA377@alpha.arachsys.com>
	<20120906092039.GA19234@alpha.arachsys.com>
	<20120912105659.GA23818@alpha.arachsys.com>
	<20120912122541.GO11266@suse.de>
	<20120912164615.GA14173@alpha.arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Mel Gorman <mgorman@suse.de>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Wed, 12 Sep 2012 17:46:15 +0100
Richard Davies <richard@arachsys.com> wrote:
> Mel Gorman wrote:
> > I see that this is an old-ish bug but I did not read the full history.
> > Is it now booting faster than 3.5.0 was? I'm asking because I'm
> > interested to see if commit c67fe375 helped your particular case.
> 
> Yes, I think 3.6.0-rc5 is already better than 3.5.x but can still be
> improved, as discussed.

Re-reading Mel's commit de74f1cc3b1e9730d9b58580cd11361d30cd182d,
I believe it re-introduces the quadratic behaviour that the code
was suffering from before, by not moving zone->compact_cached_free_pfn
down when no more free pfns are found in a page block.

This mail reverts that changeset, the next introduces what I hope to
be the proper fix.  Richard, would you be willing to give these patches
a try, since your system seems to reproduce this bug easily?

---8<---

Revert "mm: have order > 0 compaction start near a pageblock with free pages"
    
This reverts commit de74f1cc3b1e9730d9b58580cd11361d30cd182d.
    
Mel found a real issue with my "skip ahead" logic in the
compaction code, but unfortunately his approach appears to
have re-introduced quadratic behaviour in that the value
of zone->compact_cached_free_pfn is never advanced until
the compaction run wraps around the start of the zone.

This merely moved the starting point for the quadratic behaviour
further into the zone, but the behaviour has still been observed.

It looks like another fix is required.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Richard Davies <richard@daviesmail.org>

diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..771775d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -431,20 +431,6 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
- * Returns the start pfn of the last page block in a zone.  This is the starting
- * point for full compaction of a zone.  Compaction searches for free pages from
- * the end of each zone, while isolate_freepages_block scans forward inside each
- * page block.
- */
-static unsigned long start_free_pfn(struct zone *zone)
-{
-	unsigned long free_pfn;
-	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	free_pfn &= ~(pageblock_nr_pages-1);
-	return free_pfn;
-}
-
-/*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
  */
@@ -483,6 +469,17 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
+		/*
+		 * Skip ahead if another thread is compacting in the area
+		 * simultaneously. If we wrapped around, we can only skip
+		 * ahead if zone->compact_cached_free_pfn also wrapped to
+		 * above our starting point.
+		 */
+		if (cc->order > 0 && (!cc->wrapped ||
+				      zone->compact_cached_free_pfn >
+				      cc->start_free_pfn))
+			pfn = min(pfn, zone->compact_cached_free_pfn);
+
 		if (!pfn_valid(pfn))
 			continue;
 
@@ -533,15 +530,7 @@ static void isolate_freepages(struct zone *zone,
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
@@ -551,11 +540,6 @@ static void isolate_freepages(struct zone *zone,
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
-
-	/* If compact_cached_free_pfn is reset then set it now */
-	if (cc->order > 0 && !cc->wrapped &&
-			zone->compact_cached_free_pfn == start_free_pfn(zone))
-		zone->compact_cached_free_pfn = high_pfn;
 }
 
 /*
@@ -642,6 +626,20 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
