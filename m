Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 888B26B0268
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:54:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p1so29899639pfp.13
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:54:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m20si9087911pgv.668.2017.12.28.23.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:54:56 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/17] mm: pass the vmem_altmap to memmap_init_zone
Date: Fri, 29 Dec 2017 08:53:57 +0100
Message-Id: <20171229075406.1936-9-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Pass the vmem_altmap two levels down instead of needing a lookup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/mm/init.c            | 9 +++++----
 include/linux/memory_hotplug.h | 2 +-
 include/linux/mm.h             | 4 ++--
 kernel/memremap.c              | 2 +-
 mm/hmm.c                       | 2 +-
 mm/memory_hotplug.c            | 9 +++++----
 mm/page_alloc.c                | 6 +++---
 7 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 6a8ce9e1536e..18278b448530 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -501,7 +501,7 @@ virtual_memmap_init(u64 start, u64 end, void *arg)
 	if (map_start < map_end)
 		memmap_init_zone((unsigned long)(map_end - map_start),
 				 args->nid, args->zone, page_to_pfn(map_start),
-				 MEMMAP_EARLY);
+				 MEMMAP_EARLY, NULL);
 	return 0;
 }
 
@@ -509,9 +509,10 @@ void __meminit
 memmap_init (unsigned long size, int nid, unsigned long zone,
 	     unsigned long start_pfn)
 {
-	if (!vmem_map)
-		memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY);
-	else {
+	if (!vmem_map) {
+		memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY,
+				NULL);
+	} else {
 		struct page *start;
 		struct memmap_init_callback_data args;
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 20dd98ad44a0..aba5f86eb038 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -324,7 +324,7 @@ extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int arch_add_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap, bool want_memblock);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
-		unsigned long nr_pages);
+		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern void remove_memory(int nid, u64 start, u64 size);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9d4cd4c1dc6d..fd01135324b6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2069,8 +2069,8 @@ static inline void zero_resv_unavail(void) {}
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-extern void memmap_init_zone(unsigned long, int, unsigned long,
-				unsigned long, enum memmap_context);
+extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
+		enum memmap_context, struct vmem_altmap *);
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 380fca1c4a02..64b12c806cc5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -432,7 +432,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (!error)
 		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 					align_start >> PAGE_SHIFT,
-					align_size >> PAGE_SHIFT);
+					align_size >> PAGE_SHIFT, altmap);
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
diff --git a/mm/hmm.c b/mm/hmm.c
index 5d17ba89062f..2f2e13c61040 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -942,7 +942,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
 	}
 	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
 				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT);
+				align_size >> PAGE_SHIFT, NULL);
 	mem_hotplug_done();
 
 	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a8dde9734120..12df8a5fadcc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -798,8 +798,8 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
 	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
 }
 
-void __ref move_pfn_range_to_zone(struct zone *zone,
-		unsigned long start_pfn, unsigned long nr_pages)
+void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nid = pgdat->node_id;
@@ -824,7 +824,8 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 	 * expects the zone spans the pfn range. All the pages in the range
 	 * are reserved so nobody should be touching them so we should be safe
 	 */
-	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLUG);
+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn,
+			MEMMAP_HOTPLUG, altmap);
 
 	set_zone_contiguous(zone);
 }
@@ -896,7 +897,7 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	struct zone *zone;
 
 	zone = zone_for_pfn_range(online_type, nid, start_pfn, nr_pages);
-	move_pfn_range_to_zone(zone, start_pfn, nr_pages);
+	move_pfn_range_to_zone(zone, start_pfn, nr_pages, NULL);
 	return zone;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e5e775e97f4..1748dd4a4b1b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5314,9 +5314,9 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
  * done. Non-atomic initialization, single-pass.
  */
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
-		unsigned long start_pfn, enum memmap_context context)
+		unsigned long start_pfn, enum memmap_context context,
+		struct vmem_altmap *altmap)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
 	unsigned long end_pfn = start_pfn + size;
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
@@ -5417,7 +5417,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
 #define memmap_init(size, nid, zone, start_pfn) \
-	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
+	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY, NULL)
 #endif
 
 static int zone_batchsize(struct zone *zone)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
