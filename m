Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C7FAE6B003C
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:21:52 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so315579pde.38
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:21:52 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:21:48 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0E4C23578040
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:21:46 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PN55mw53084168
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:05:05 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNLiPR030143
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:21:45 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 16/40] mm: Introduce a "Region Allocator" to manage
 entire memory regions
Date: Thu, 26 Sep 2013 04:47:34 +0530
Message-ID: <20130925231730.26184.19552.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Today, the MM subsystem uses the buddy 'Page Allocator' to manage memory
at a 'page' granularity. But this allocator has no notion of the physical
topology of the underlying memory hardware, and hence it is hard to
influence memory allocation decisions keeping the platform constraints
in mind.

So we need to augment the page-allocator with a new entity to manage
memory (at a much larger granularity) keeping the underlying platform
characteristics and the memory hardware topology in mind.

To that end, introduce a "Memory Region Allocator" as a backend to the
existing "Page Allocator".


Splitting the memory allocator into a Page-Allocator front-end and a
Region-Allocator backend:


                 Page Allocator          |      Memory Region Allocator
                                         -
           __    __    __                |    ________    ________
          |__|--|__|--|__|-- ...         -   |        |  |        |
           ____    ____    ____          |   |        |  |        |
          |____|--|____|--|____|-- ...   -   |        |--|        |-- ...
                                         |   |        |  |        |
                                         -   |________|  |________|
                                         |
                                         -
             Manages pages using         |     Manages memory regions
              buddy freelists            -  (allocates and frees entire
                                         |   memory regions, i.e., at a
                                         -   memory-region granularity)


The flow of memory allocations/frees between entities requesting memory
(applications/kernel) and the MM subsystem:

                  pages               regions
  Applications <========>   Page    <========>  Memory Region
   and Kernel             Allocator               Allocator



Since the region allocator is supposed to function as a backend to the
page allocator, we implement it on a per-zone basis (since the page-allocator
is also per-zone).

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |   17 +++++++++++++++++
 mm/page_alloc.c        |   19 +++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 155c1a1..7c87518 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -112,6 +112,21 @@ struct free_area {
 	unsigned long		nr_free;
 };
 
+/* A simplified free_area for managing entire memory regions */
+struct free_area_region {
+	struct list_head	list;
+	unsigned long		nr_free;
+};
+
+struct mem_region {
+	struct free_area_region	region_area[MAX_ORDER];
+};
+
+struct region_allocator {
+	struct mem_region	region[MAX_NR_ZONE_REGIONS];
+	int			next_region;
+};
+
 struct pglist_data;
 
 /*
@@ -405,6 +420,8 @@ struct zone {
 	struct zone_mem_region	zone_regions[MAX_NR_ZONE_REGIONS];
 	int 			nr_zone_regions;
 
+	struct region_allocator	region_allocator;
+
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dc02a80..876c231 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5240,6 +5240,23 @@ static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
 	pgdat->nr_node_regions = idx;
 }
 
+static void __meminit init_zone_region_allocator(struct zone *zone)
+{
+	struct free_area_region *area;
+	int i, j;
+
+	for (i = 0; i < zone->nr_zone_regions; i++) {
+		area = zone->region_allocator.region[i].region_area;
+
+		for (j = 0; j < MAX_ORDER; j++) {
+			INIT_LIST_HEAD(&area[j].list);
+			area[j].nr_free = 0;
+		}
+	}
+
+	zone->region_allocator.next_region = -1;
+}
+
 static void __meminit zone_init_free_lists_late(struct zone *zone)
 {
 	struct mem_region_list *mr_list;
@@ -5326,6 +5343,8 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 
 		zone_init_free_lists_late(z);
 
+		init_zone_region_allocator(z);
+
 		/*
 		 * Revisit the last visited node memory region, in case it
 		 * spans multiple zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
