Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id CFE0E6B006C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:43:02 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:13:00 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JgvgD41287744
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:12:58 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6Jgvso030229
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:42:57 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 09/10] mm: Reflect memory region changes in zoneinfo
Date: Wed, 07 Nov 2012 01:11:54 +0530
Message-ID: <20121106194145.6560.98266.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

This patch modifies the output of /proc/zoneinfo to take the memory regions
into into account. Below is the output on a KVM guest booted with 4 regions,
each of size 512MB.

cat /proc/zoneinfo:

Node 0, Region 0, zone      DMA
  pages free     3975
        min      11
        low      13
        high     16
        scanned  0
        spanned  4080
        present  3977
    nr_free_pages 3975
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 2
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   0
    nr_written   0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 471, 471, 471)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 2
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 3
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
  all_unreclaimable: 0
  start_pfn:         16
  inactive_ratio:    1
Node 0, Region 0, zone    DMA32
  pages free     107720
        min      338
        low      422
        high     507
        scanned  0
        spanned  126992
        present  120642
.....
Node 0, Region 1, zone    DMA32
  pages free     131072
        min      367
        low      458
        high     550
        scanned  0
        spanned  131072
        present  131072
.....
Node 0, Region 2, zone    DMA32
  pages free     131072
        min      367
        low      458
        high     550
        scanned  0
        spanned  131072
        present  131072
.....
Node 0, Region 3, zone    DMA32
  pages free     121880
        min      341
        low      426
        high     511
        scanned  0
        spanned  131054
        present  121928
.....

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/vmstat.c |   31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 86a92a6..b3be9ba 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -179,9 +179,12 @@ void refresh_zone_stat_thresholds(void)
 		 */
 		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
 		max_drift = num_online_cpus() * threshold;
-		if (max_drift > tolerate_drift)
+		if (max_drift > tolerate_drift) {
 			zone->percpu_drift_mark = high_wmark_pages(zone) +
 					max_drift;
+			printk("zone %s drift mark %lu \n", zone->name,
+						zone->percpu_drift_mark);
+		}
 	}
 }
 
@@ -189,12 +192,11 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 				int (*calculate_pressure)(struct zone *))
 {
 	struct mem_region *region;
-	struct zone *zone;
 	int cpu;
 	int threshold;
 	int i;
 
-	for (i = 0; i < pgdat->nr_zones; i++) {
+	for (i = 0; i < pgdat->nr_node_zone_types; i++) {
 		for_each_mem_region_in_node(region, pgdat->node_id) {
 			struct zone *zone = region->region_zones + i;
 
@@ -818,11 +820,12 @@ const char * const vmstat_text[] = {
 
 #ifdef CONFIG_PROC_FS
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
-						struct zone *zone)
+					struct mem_region *region, struct zone *zone)
 {
 	int order;
 
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, REG %d, zone %8s ", pgdat->node_id,
+						region->region, zone->name);
 	for (order = 0; order < MAX_ORDER; ++order)
 		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
 	seq_putc(m, '\n');
@@ -838,14 +841,15 @@ static int frag_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static void pagetypeinfo_showfree_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
+static void pagetypeinfo_showfree_print(struct seq_file *m, pg_data_t *pgdat,
+						struct mem_region *region, struct zone *zone)
 {
 	int order, mtype;
 
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
-		seq_printf(m, "Node %4d, zone %8s, type %12s ",
+		seq_printf(m, "Node %4d, Region %d, zone %8s, type %12s ",
 					pgdat->node_id,
+					region->region,
 					zone->name,
 					migratetype_names[mtype]);
 		for (order = 0; order < MAX_ORDER; ++order) {
@@ -880,8 +884,8 @@ static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
 	return 0;
 }
 
-static void pagetypeinfo_showblockcount_print(struct seq_file *m,
-					pg_data_t *pgdat, struct zone *zone)
+static void pagetypeinfo_showblockcount_print(struct seq_file *m, pg_data_t *pgdat,
+							struct mem_region *region, struct zone *zone)
 {
 	int mtype;
 	unsigned long pfn;
@@ -908,7 +912,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	}
 
 	/* Print counts */
-	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, Region %d, zone %8s ", pgdat->node_id, region->region, zone->name);
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
 		seq_printf(m, "%12lu ", count[mtype]);
 	seq_putc(m, '\n');
@@ -989,10 +993,11 @@ static const struct file_operations pagetypeinfo_file_ops = {
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
-							struct zone *zone)
+					struct mem_region *region, struct zone *zone)
 {
 	int i;
-	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
+	seq_printf(m, "Node %d, Region %d, zone %8s", pgdat->node_id,
+						region->region, zone->name);
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
