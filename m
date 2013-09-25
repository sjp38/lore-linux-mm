Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED776B005A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:21:02 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so319157pdj.22
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:21:02 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:20:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4B03B2BB0052
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:56 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNKixl65077256
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:45 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNKsDg020364
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:55 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 13/40] mm: Print memory region statistics to understand
 the buddy allocator behavior
Date: Thu, 26 Sep 2013 04:46:44 +0530
Message-ID: <20130925231642.26184.60271.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In order to observe the behavior of the region-aware buddy allocator, modify
vmstat.c to also print memory region related statistics. In particular, enable
memory region-related info in /proc/zoneinfo and /proc/buddyinfo, since they
would help us to atleast (roughly) observe how the new buddy allocator is
behaving.

For now, the region statistics correspond to the zone memory regions and not
the (absolute) node memory regions, and some of the statistics (especially the
no. of present pages) might not be very accurate. But since we account for
and print the free page statistics for every zone memory region accurately, we
should be able to observe the new page allocator behavior to a reasonable
degree of accuracy.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/vmstat.c |   34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index c967043..8e8c8bd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -866,11 +866,28 @@ const char * const vmstat_text[] = {
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
-	int order;
+	int i, order, t;
+	struct free_area *area;
 
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
-	for (order = 0; order < MAX_ORDER; ++order)
-		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+	seq_printf(m, "Node %d, zone %8s \n", pgdat->node_id, zone->name);
+
+	for (i = 0; i < zone->nr_zone_regions; i++) {
+
+		seq_printf(m, "\t\t Region %6d ", i);
+
+		for (order = 0; order < MAX_ORDER; ++order) {
+			unsigned long nr_free = 0;
+
+			area = &zone->free_area[order];
+
+			for (t = 0; t < MIGRATE_TYPES; t++) {
+				nr_free +=
+					area->free_list[t].mr_list[i].nr_free;
+			}
+			seq_printf(m, "%6lu ", nr_free);
+		}
+		seq_putc(m, '\n');
+	}
 	seq_putc(m, '\n');
 }
 
@@ -1057,6 +1074,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   zone->present_pages,
 		   zone->managed_pages);
 
+	seq_printf(m, "\n\nPer-region page stats\t present\t free\n\n");
+	for (i = 0; i < zone->nr_zone_regions; i++) {
+		struct zone_mem_region *region;
+
+		region = &zone->zone_regions[i];
+		seq_printf(m, "\tRegion %6d \t %6lu \t %6lu\n", i,
+				region->present_pages, region->nr_free);
+	}
+
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
