Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C804C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EB1222CF5
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EB1222CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C14B86B0010; Thu, 29 Aug 2019 03:00:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC5876B0266; Thu, 29 Aug 2019 03:00:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB3216B0269; Thu, 29 Aug 2019 03:00:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 83F8A6B0010
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:00:43 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 309E0181AC9B6
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:43 +0000 (UTC)
X-FDA: 75874567566.26.boat86_623d0a4e221a
X-HE-Tag: boat86_623d0a4e221a
X-Filterd-Recvd-Size: 10916
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:00:42 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 95A4B106E289;
	Thu, 29 Aug 2019 07:00:40 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-166.ams2.redhat.com [10.36.117.166])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8DDD41001B07;
	Thu, 29 Aug 2019 07:00:35 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Dave Airlie <airlied@redhat.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Arun KS <arunks@codeaurora.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Logan Gunthorpe <logang@deltatee.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Alexander Potapenko <glider@google.com>
Subject: [PATCH v3 01/11] mm/memremap: Get rid of memmap_init_zone_device()
Date: Thu, 29 Aug 2019 09:00:09 +0200
Message-Id: <20190829070019.12714-2-david@redhat.com>
In-Reply-To: <20190829070019.12714-1-david@redhat.com>
References: <20190829070019.12714-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.64]); Thu, 29 Aug 2019 07:00:41 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As far as I can see, the original split wanted to speed up a duplicate
initialization. We now only initialize once - and we really should
initialize under the lock, when resizing the zones.

As soon as we drop the lock we might have memory unplug running, trying
to shrink the zone again. In case the memmap was not properly initialized=
,
the zone/node shrinking code might get false negatives when search for
the new zone/node boundaries - bad. We suddenly could no longer span the
memory we just added.

Also, once we want to fix set_zone_contiguous(zone) inside
move_pfn_range_to_zone() to actually work with ZONE_DEVICE (instead of
always immediately stopping and never setting zone->contiguous) we have
to have the whole memmap initialized at that point. (not sure if we
want that in the future, just a note)

Let's just keep things simple and initialize the memmap when resizing
the zones under the lock.

If this is a real performance issue, we have to watch out for
alternatives.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Alexander Potapenko <glider@google.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  2 +-
 include/linux/mm.h             |  4 +---
 mm/memory_hotplug.c            |  4 ++--
 mm/memremap.c                  |  9 +-------
 mm/page_alloc.c                | 42 ++++++++++++----------------------
 5 files changed, 20 insertions(+), 41 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index f46ea71b4ffd..235530cdface 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -344,7 +344,7 @@ extern int __add_memory(int nid, u64 start, u64 size)=
;
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long star=
t_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap);
+		unsigned long nr_pages, struct dev_pagemap *pgmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_section(int nid, unsigned long pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad6766a08f9b..2bd445c4d3b4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -962,8 +962,6 @@ static inline bool is_zone_device_page(const struct p=
age *page)
 {
 	return page_zonenum(page) =3D=3D ZONE_DEVICE;
 }
-extern void memmap_init_zone_device(struct zone *, unsigned long,
-				    unsigned long, struct dev_pagemap *);
 #else
 static inline bool is_zone_device_page(const struct page *page)
 {
@@ -2243,7 +2241,7 @@ static inline void zero_resv_unavail(void) {}
=20
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned=
 long,
-		enum memmap_context, struct vmem_altmap *);
+		enum memmap_context, struct dev_pagemap *);
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 49f7bf91c25a..35a395d195c6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -719,7 +719,7 @@ static void __meminit resize_pgdat_range(struct pglis=
t_data *pgdat, unsigned lon
  * call, all affected pages are PG_reserved.
  */
 void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start=
_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap)
+		unsigned long nr_pages, struct dev_pagemap *pgmap)
 {
 	struct pglist_data *pgdat =3D zone->zone_pgdat;
 	int nid =3D pgdat->node_id;
@@ -744,7 +744,7 @@ void __ref move_pfn_range_to_zone(struct zone *zone, =
unsigned long start_pfn,
 	 * are reserved so nobody should be touching them so we should be safe
 	 */
 	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn,
-			MEMMAP_HOTPLUG, altmap);
+			 MEMMAP_HOTPLUG, pgmap);
=20
 	set_zone_contiguous(zone);
 }
diff --git a/mm/memremap.c b/mm/memremap.c
index f6c17339cd0d..9ee23374e6da 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -308,20 +308,13 @@ void *memremap_pages(struct dev_pagemap *pgmap, int=
 nid)
=20
 		zone =3D &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		move_pfn_range_to_zone(zone, PHYS_PFN(res->start),
-				PHYS_PFN(resource_size(res)), restrictions.altmap);
+				PHYS_PFN(resource_size(res)), pgmap);
 	}
=20
 	mem_hotplug_done();
 	if (error)
 		goto err_add_memory;
=20
-	/*
-	 * Initialization of the pages has been deferred until now in order
-	 * to allow us to do the work while not holding the hotplug lock.
-	 */
-	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				PHYS_PFN(res->start),
-				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 	return __va(res->start);
=20
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c5d62f1c2851..44038665fe8e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5845,7 +5845,7 @@ overlap_memmap_init(unsigned long zone, unsigned lo=
ng *pfn)
  */
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned lo=
ng zone,
 		unsigned long start_pfn, enum memmap_context context,
-		struct vmem_altmap *altmap)
+		struct dev_pagemap *pgmap)
 {
 	unsigned long pfn, end_pfn =3D start_pfn + size;
 	struct page *page;
@@ -5853,24 +5853,6 @@ void __meminit memmap_init_zone(unsigned long size=
, int nid, unsigned long zone,
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn =3D end_pfn - 1;
=20
-#ifdef CONFIG_ZONE_DEVICE
-	/*
-	 * Honor reservation requested by the driver for this ZONE_DEVICE
-	 * memory. We limit the total number of pages to initialize to just
-	 * those that might contain the memory mapping. We will defer the
-	 * ZONE_DEVICE page initialization until after we have released
-	 * the hotplug lock.
-	 */
-	if (zone =3D=3D ZONE_DEVICE) {
-		if (!altmap)
-			return;
-
-		if (start_pfn =3D=3D altmap->base_pfn)
-			start_pfn +=3D altmap->reserve;
-		end_pfn =3D altmap->base_pfn + vmem_altmap_offset(altmap);
-	}
-#endif
-
 	for (pfn =3D start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s handed to this
@@ -5892,6 +5874,20 @@ void __meminit memmap_init_zone(unsigned long size=
, int nid, unsigned long zone,
 		if (context =3D=3D MEMMAP_HOTPLUG)
 			__SetPageReserved(page);
=20
+#ifdef CONFIG_ZONE_DEVICE
+		if (zone =3D=3D ZONE_DEVICE) {
+			WARN_ON_ONCE(!pgmap);
+			/*
+			 * ZONE_DEVICE pages union ->lru with a ->pgmap back
+			 * pointer and zone_device_data. It is a bug if a
+			 * ZONE_DEVICE page is ever freed or placed on a driver
+			 * private list.
+			 */
+			page->pgmap =3D pgmap;
+			page->zone_device_data =3D NULL;
+		}
+#endif
+
 		/*
 		 * Mark the block movable so that blocks are reserved for
 		 * movable at startup. This will force kernel allocations
@@ -5951,14 +5947,6 @@ void __ref memmap_init_zone_device(struct zone *zo=
ne,
 		 */
 		__SetPageReserved(page);
=20
-		/*
-		 * ZONE_DEVICE pages union ->lru with a ->pgmap back pointer
-		 * and zone_device_data.  It is a bug if a ZONE_DEVICE page is
-		 * ever freed or placed on a driver-private list.
-		 */
-		page->pgmap =3D pgmap;
-		page->zone_device_data =3D NULL;
-
 		/*
 		 * Mark the block movable so that blocks are reserved for
 		 * movable at startup. This will force kernel allocations
--=20
2.21.0


