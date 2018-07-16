Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9346B0281
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:13:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x2-v6so25094091plv.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:13:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d26-v6si30103688pgd.32.2018.07.16.10.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:13:24 -0700 (PDT)
Subject: [PATCH v2 03/14] mm: Teach memmap_init_zone() to initialize
 ZONE_DEVICE pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:00:37 -0700
Message-ID: <153176043742.12695.12733023097134464039.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, vishal.l.verma@intel.com, linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

Rather than run a loop over the freshly initialized pages in
devm_memremap_pages() *after* arch_add_memory() returns, teach
memmap_init_zone() to return the pages fully initialized. This is in
preparation for multi-threading page initialization work, but it also
has some straight line performance benefits to not incur another loop of
cache misses across a large (100s of GBs to TBs) address range.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   16 +---------------
 mm/page_alloc.c   |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index b861fe909932..85e4a7c576b2 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -173,8 +173,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 	struct vmem_altmap *altmap = pgmap->altmap_valid ?
 			&pgmap->altmap : NULL;
 	struct resource *res = &pgmap->res;
-	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
+	unsigned long pgoff, order;
 	int error, nid, is_ram;
 
 	if (!pgmap->ref || !kill)
@@ -251,20 +251,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 	if (error)
 		goto err_add_memory;
 
-	for_each_device_pfn(pfn, pgmap) {
-		struct page *page = pfn_to_page(pfn);
-
-		/*
-		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
-		 * pointer.  It is a bug if a ZONE_DEVICE page is ever
-		 * freed or placed on a driver-private list.  Seed the
-		 * storage with LIST_POISON* values.
-		 */
-		list_del(&page->lru);
-		page->pgmap = pgmap;
-		percpu_ref_get(pgmap->ref);
-	}
-
 	pgmap->kill = kill;
 	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
 			pgmap);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f83682ef006e..fb45cfeb4a50 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5548,6 +5548,25 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 			cond_resched();
 		}
+
+		if (is_zone_device_page(page)) {
+			if (WARN_ON_ONCE(!pgmap))
+				continue;
+
+			/* skip invalid device pages */
+			if (altmap && (pfn < (altmap->base_pfn
+						+ vmem_altmap_offset(altmap))))
+				continue;
+			/*
+			 * ZONE_DEVICE pages union ->lru with a ->pgmap back
+			 * pointer.  It is a bug if a ZONE_DEVICE page is ever
+			 * freed or placed on a driver-private list.  Seed the
+			 * storage with poison.
+			 */
+			page->lru.prev = LIST_POISON2;
+			page->pgmap = pgmap;
+			percpu_ref_get(pgmap->ref);
+		}
 	}
 }
 
