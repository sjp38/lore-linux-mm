Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72CC56B0010
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:35:34 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id j12-v6so830420uaq.16
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:35:34 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x72-v6si748474vkd.96.2018.07.26.12.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:35:33 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 2/3] mm: calculate deferred pages after skipping mirrored memory
Date: Thu, 26 Jul 2018 15:35:08 -0400
Message-Id: <20180726193509.3326-3-pasha.tatashin@oracle.com>
In-Reply-To: <20180726193509.3326-1-pasha.tatashin@oracle.com>
References: <20180726193509.3326-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

update_defer_init() should be called only when struct page is about to be
initialized. Because it counts number of initialized struct pages, but
there we may skip struct pages if there is some mirrored memory.

So move, update_defer_init() after checking for mirrored memory.

Also, rename update_defer_init() to defer_init() and reverse the return
boolean to emphasize that this is a boolean function, that tells that the
reset of memmap initialization should be deferred.

Make this function self-contained: do not pass number of already
initialized pages in this zone by using static counters.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 45 +++++++++++++++++++++++++--------------------
 1 file changed, 25 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6796dacd46ac..4946c73e549b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -306,24 +306,33 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 }
 
 /*
- * Returns false when the remaining initialisation should be deferred until
+ * Returns true when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
  */
-static inline bool update_defer_init(pg_data_t *pgdat,
-				unsigned long pfn, unsigned long zone_end,
-				unsigned long *nr_initialised)
+static bool __meminit
+defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
 {
+	static unsigned long prev_end_pfn, nr_initialised;
+
+	/*
+	 * prev_end_pfn static that contains the end of previous zone
+	 * No need to protect because called very early in boot before smp_init.
+	 */
+	if (prev_end_pfn != end_pfn) {
+		prev_end_pfn = end_pfn;
+		nr_initialised = 0;
+	}
+
 	/* Always populate low zones for address-constrained allocations */
-	if (zone_end < pgdat_end_pfn(pgdat))
-		return true;
-	(*nr_initialised)++;
-	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
-	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
-		pgdat->first_deferred_pfn = pfn;
+	if (end_pfn < pgdat_end_pfn(NODE_DATA(nid)))
 		return false;
+	nr_initialised++;
+	if ((nr_initialised > NODE_DATA(nid)->static_init_pgcnt) &&
+	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
+		NODE_DATA(nid)->first_deferred_pfn = pfn;
+		return true;
 	}
-
-	return true;
+	return false;
 }
 #else
 static inline bool early_page_uninitialised(unsigned long pfn)
@@ -331,11 +340,9 @@ static inline bool early_page_uninitialised(unsigned long pfn)
 	return false;
 }
 
-static inline bool update_defer_init(pg_data_t *pgdat,
-				unsigned long pfn, unsigned long zone_end,
-				unsigned long *nr_initialised)
+static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
 {
-	return true;
+	return false;
 }
 #endif
 
@@ -5459,9 +5466,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		struct vmem_altmap *altmap)
 {
 	unsigned long end_pfn = start_pfn + size;
-	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
-	unsigned long nr_initialised = 0;
 	struct page *page;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	struct memblock_region *r = NULL, *tmp;
@@ -5492,8 +5497,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 		if (!early_pfn_in_nid(pfn, nid))
 			continue;
-		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
-			break;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		/*
@@ -5516,6 +5519,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			}
 		}
 #endif
+		if (defer_init(nid, pfn, end_pfn))
+			break;
 
 not_early:
 		page = pfn_to_page(pfn);
-- 
2.18.0
