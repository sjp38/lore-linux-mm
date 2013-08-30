Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3EF676B0038
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:22:33 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:22:32 +0100
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5FC1F6E8048
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:22:28 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDMSRe39125058
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:22:28 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDMOps026430
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:22:27 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 15/35] mm: Print memory region statistics to understand
 the buddy allocator behavior
Date: Fri, 30 Aug 2013 18:48:30 +0530
Message-ID: <20130830131827.4947.32837.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index 0451957..4cba0da 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -827,11 +827,28 @@ const char * const vmstat_text[] = {
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
 
@@ -1018,6 +1035,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
