Date: Thu, 25 Jan 2007 21:42:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054208.10564.45172.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 3/8] Reorder ZVCs according to cacheline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Reorder ZVCs so that the main counters are in the same cacheline.

The global and per zone counter sums are in arrays of longs. Reorder
the ZVCs so that the most frequently used ZVCs are put into the same
cacheline. That way calculations of the global, node and per zone
vm state touches only a single cacheline. This is mostly important
for 64 bit systems were one 128 byte cacheline takes only 8 longs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/mmzone.h	2007-01-25 11:20:59.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/mmzone.h	2007-01-25 11:28:07.000000000 -0800
@@ -47,6 +47,7 @@ struct zone_padding {
 #endif
 
 enum zone_stat_item {
+	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
 	NR_INACTIVE,
 	NR_ACTIVE,
@@ -54,11 +55,12 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
-	NR_SLAB_RECLAIMABLE,
-	NR_SLAB_UNRECLAIMABLE,
-	NR_PAGETABLE,	/* used for pagetables */
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
+	/* Second 128 byte cacheline */
+	NR_SLAB_RECLAIMABLE,
+	NR_SLAB_UNRECLAIMABLE,
+	NR_PAGETABLE,		/* used for pagetables */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
Index: linux-2.6.20-rc6/mm/vmstat.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/vmstat.c	2007-01-25 11:21:30.000000000 -0800
+++ linux-2.6.20-rc6/mm/vmstat.c	2007-01-25 11:22:22.000000000 -0800
@@ -447,11 +447,11 @@ static const char * const vmstat_text[] 
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
+	"nr_dirty",
+	"nr_writeback",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
-	"nr_dirty",
-	"nr_writeback",
 	"nr_unstable",
 	"nr_bounce",
 	"nr_vmscan_write",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
