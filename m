Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3586B00A5
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:26:59 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so321022pbc.1
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:26:58 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:26:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 92FEE2CE8040
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:53 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNQgDB5767458
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:42 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNQqvb021192
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:53 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 39/40] mm: Add intelligence in kmempowerd to ignore
 regions unsuitable for evacuation
Date: Thu, 26 Sep 2013 04:52:42 +0530
Message-ID: <20130925232240.26184.54998.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Enhance kmempowerd to determine situations where evacuating a region would prove
to be too costly or counter-productive, and ignore those regions for region
evacuation.

For example, if the region has a significant number of used pages (say more than
32), then evacuation will involve more work and might not be justifiable. Also,
compacting region 0 would be pointless, since that is the target of all our
compaction runs. Add these checks in the region-evacuator.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    2 ++
 mm/compaction.c        |   25 +++++++++++++++++++++++--
 mm/internal.h          |    2 ++
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 257afdf..f383cc8d4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -84,6 +84,8 @@ static inline int get_pageblock_migratetype(struct page *page)
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
+#define MAX_MEMPWR_MIGRATE_PAGES	32
+
 struct mem_region_list {
 	struct list_head	*page_block;
 	unsigned long		nr_free;
diff --git a/mm/compaction.c b/mm/compaction.c
index b56be89..41585b0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1297,9 +1297,26 @@ void queue_mempower_work(struct pglist_data *pgdat, struct zone *zone,
 	queue_kthread_work(&pgdat->mempower_worker, &mpwork->work);
 }
 
+int should_evacuate_region(struct zone *z, struct zone_mem_region *region)
+{
+	unsigned long pages_in_use;
+
+	/* Don't try to evacuate region 0, since its the target of migration */
+	if (region == z->zone_regions)
+		return 0;
+
+	pages_in_use = region->present_pages - region->nr_free;
+
+	if (pages_in_use > 0 && pages_in_use <= MAX_MEMPWR_MIGRATE_PAGES)
+		return 1;
+
+	return 0;
+}
+
 static void kmempowerd(struct kthread_work *work)
 {
 	struct mempower_work *mpwork;
+	struct zone_mem_region *zmr;
 	struct zone *zone;
 	unsigned long flags;
 	int region_id;
@@ -1315,8 +1332,12 @@ repeat:
 	if (bitmap_empty(mpwork_mask, nr_zone_region_bits))
 		return;
 
-	for_each_set_bit(region_id, mpwork_mask, nr_zone_region_bits)
-		evacuate_mem_region(zone, &zone->zone_regions[region_id]);
+	for_each_set_bit(region_id, mpwork_mask, nr_zone_region_bits) {
+		zmr = &zone->zone_regions[region_id];
+
+		if (should_evacuate_region(zone, zmr))
+			evacuate_mem_region(zone, zmr);
+	}
 
 	spin_lock_irqsave(&mpwork->lock, flags);
 
diff --git a/mm/internal.h b/mm/internal.h
index 3fbc9f6..5b4658c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -184,6 +184,8 @@ int compact_range(struct compact_control *cc, struct aggression_control *ac,
 void queue_mempower_work(struct pglist_data *pgdat, struct zone *zone,
 			 int region_id);
 
+int should_evacuate_region(struct zone *z, struct zone_mem_region *region);
+
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
