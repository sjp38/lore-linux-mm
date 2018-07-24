Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56E8E6B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 20:26:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v65-v6so5064113qka.23
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:26:00 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g187-v6si3872003qkb.320.2018.07.24.17.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 17:25:59 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored memory
Date: Tue, 24 Jul 2018 19:55:19 -0400
Message-Id: <20180724235520.10200-3-pasha.tatashin@oracle.com>
In-Reply-To: <20180724235520.10200-1-pasha.tatashin@oracle.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
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
 mm/page_alloc.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cea749b26394..86c678cec6bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -306,24 +306,28 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 }
 
 /*
- * Returns false when the remaining initialisation should be deferred until
+ * Returns true when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
  */
-static inline bool update_defer_init(pg_data_t *pgdat,
-				unsigned long pfn, unsigned long zone_end,
-				unsigned long *nr_initialised)
+static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
 {
+	static unsigned long prev_end_pfn, nr_initialised;
+
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
@@ -331,11 +335,9 @@ static inline bool early_page_uninitialised(unsigned long pfn)
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
 
@@ -5462,9 +5464,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		struct vmem_altmap *altmap)
 {
 	unsigned long end_pfn = start_pfn + size;
-	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long pfn;
-	unsigned long nr_initialised = 0;
 	struct page *page;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	struct memblock_region *r = NULL, *tmp;
@@ -5492,8 +5492,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			continue;
 		if (!early_pfn_in_nid(pfn, nid))
 			continue;
-		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
-			break;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		/*
@@ -5516,6 +5514,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			}
 		}
 #endif
+		if (defer_init(nid, pfn, end_pfn))
+			break;
 
 not_early:
 		page = pfn_to_page(pfn);
-- 
2.18.0
