Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F0B386B005A
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:55:44 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:52:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JjGGX4587972
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:45:16 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JtceS028122
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:55:39 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 8/8] mm: Print memory region statistics to understand the
 buddy allocator behavior
Date: Wed, 07 Nov 2012 01:24:32 +0530
Message-ID: <20121106195428.6941.92699.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In order to observe the behavior of the region-aware buddy allocator, modify
vmstat.c to also print memory region related statistics. In particular, enable
memory region-related info in /proc/zoneinfo and /proc/buddyinfo, since they
would help us to atleast (roughly) see how the new buddy allocator is
performing.

For now, the region statistics correspond to the zone memory regions and not
the (absolute) node memory regions, and some of the statistics (especially the
no. of present pages) might not be very accurate. But since we account for
and print the free page statistics for every zone memory region accurately, we
should be able to observe the new page allocator behavior to a reasonable
degree of accuracy.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/vmstat.c |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 53 insertions(+), 4 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8183331..cbcd373 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -812,11 +812,31 @@ const char * const vmstat_text[] = {
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
+		seq_printf(m, "\t\t Region %d ", i);
+
+		for (order = 0; order < MAX_ORDER; ++order) {
+			unsigned long nr_free = 0;
+
+			area = &zone->free_area[order];
+
+			for (t = 0; t < MIGRATE_TYPES; t++) {
+				if (t == MIGRATE_ISOLATE ||
+					t == MIGRATE_RESERVE)
+					continue;
+				nr_free +=
+					area->free_list[t].mr_list[i].nr_free;
+			}
+			seq_printf(m, "%6lu ", nr_free);
+		}
+		seq_putc(m, '\n');
+	}
 	seq_putc(m, '\n');
 }
 
@@ -984,6 +1004,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 							struct zone *zone)
 {
 	int i;
+	unsigned long zone_nr_free = 0;
+
 	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
 	seq_printf(m,
 		   "\n  pages free     %lu"
@@ -1001,6 +1023,33 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   zone->spanned_pages,
 		   zone->present_pages);
 
+	for (i = 0; i < zone->nr_zone_regions; i++) {
+		int order, t;
+		unsigned long nr_free = 0;
+		struct free_area *area = zone->free_area;
+
+		for_each_migratetype_order(order, t) {
+			if (t == MIGRATE_ISOLATE || t == MIGRATE_RESERVE)
+				continue;
+			nr_free +=
+				area[order].free_list[t].mr_list[i].nr_free
+				* (1UL << order);
+		}
+		seq_printf(m, "\n\nZone mem region %d", i);
+		seq_printf(m,
+			   "\n  pages spanned	%lu"
+			   "\n        present	%lu"
+			   "\n        free	%lu",
+			   zone->zone_mem_region[i].spanned_pages,
+			   zone->zone_mem_region[i].present_pages,
+			   nr_free);
+	}
+
+	for (i = 0; i < MAX_ORDER; i++)
+		zone_nr_free += zone->free_area[i].nr_free * (1UL << i);
+
+	seq_printf(m, "\nZone pages nr_free  %lu\n", zone_nr_free);
+
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
