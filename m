Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91A476B026A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:19:37 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 34-v6so11379599plf.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:19:37 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r17-v6si42465337pgh.56.2018.11.05.13.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:19:36 -0800 (PST)
Subject: [mm PATCH v5 2/7] mm: Drop meminit_pfn_in_nid as it is redundant
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 05 Nov 2018 13:19:35 -0800
Message-ID: <154145277561.30046.12617658691920831062.stgit@ahduyck-desk1.jf.intel.com>
In-Reply-To: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

As best as I can tell the meminit_pfn_in_nid call is completely redundant.
The deferred memory initialization is already making use of
for_each_free_mem_range which in turn will call into __next_mem_range which
will only return a memory range if it matches the node ID provided assuming
it is not NUMA_NO_NODE.

I am operating on the assumption that there are no zones or pgdata_t
structures that have a NUMA node of NUMA_NO_NODE associated with them. If
that is the case then __next_mem_range will never return a memory range
that doesn't match the zone's node ID and as such the check is redundant.

So one piece I would like to verify on this is if this works for ia64.
Technically it was using a different approach to get the node ID, but it
seems to have the node ID also encoded into the memblock. So I am
assuming this is okay, but would like to get confirmation on that.

On my x86_64 test system with 384GB of memory per node I saw a reduction in
initialization time from 2.80s to 1.85s as a result of this patch.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |   51 ++++++++++++++-------------------------------------
 1 file changed, 14 insertions(+), 37 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ae31839874b8..be1197c120a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1301,36 +1301,22 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 #endif
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-static inline bool __meminit __maybe_unused
-meminit_pfn_in_nid(unsigned long pfn, int node,
-		   struct mminit_pfnnid_cache *state)
+/* Only safe to use early in boot when initialisation is single-threaded */
+static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	int nid;
 
-	nid = __early_pfn_to_nid(pfn, state);
+	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
 	if (nid >= 0 && nid != node)
 		return false;
 	return true;
 }
 
-/* Only safe to use early in boot when initialisation is single-threaded */
-static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
-{
-	return meminit_pfn_in_nid(pfn, node, &early_pfnnid_cache);
-}
-
 #else
-
 static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	return true;
 }
-static inline bool __meminit  __maybe_unused
-meminit_pfn_in_nid(unsigned long pfn, int node,
-		   struct mminit_pfnnid_cache *state)
-{
-	return true;
-}
 #endif
 
 
@@ -1459,21 +1445,13 @@ static inline void __init pgdat_init_report_one_done(void)
  *
  * Then, we check if a current large page is valid by only checking the validity
  * of the head pfn.
- *
- * Finally, meminit_pfn_in_nid is checked on systems where pfns can interleave
- * within a node: a pfn is between start and end of a node, but does not belong
- * to this memory node.
  */
-static inline bool __init
-deferred_pfn_valid(int nid, unsigned long pfn,
-		   struct mminit_pfnnid_cache *nid_init_state)
+static inline bool __init deferred_pfn_valid(unsigned long pfn)
 {
 	if (!pfn_valid_within(pfn))
 		return false;
 	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
 		return false;
-	if (!meminit_pfn_in_nid(pfn, nid, nid_init_state))
-		return false;
 	return true;
 }
 
@@ -1481,15 +1459,14 @@ deferred_pfn_valid(int nid, unsigned long pfn,
  * Free pages to buddy allocator. Try to free aligned pages in
  * pageblock_nr_pages sizes.
  */
-static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
+static void __init deferred_free_pages(unsigned long pfn,
 				       unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	unsigned long nr_free = 0;
 
 	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+		if (!deferred_pfn_valid(pfn)) {
 			deferred_free_range(pfn - nr_free, nr_free);
 			nr_free = 0;
 		} else if (!(pfn & nr_pgmask)) {
@@ -1509,17 +1486,18 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
  * by performing it only once every pageblock_nr_pages.
  * Return number of pages initialized.
  */
-static unsigned long  __init deferred_init_pages(int nid, int zid,
+static unsigned long  __init deferred_init_pages(struct zone *zone,
 						 unsigned long pfn,
 						 unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	int nid = zone_to_nid(zone);
 	unsigned long nr_pages = 0;
+	int zid = zone_idx(zone);
 	struct page *page = NULL;
 
 	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+		if (!deferred_pfn_valid(pfn)) {
 			page = NULL;
 			continue;
 		} else if (!page || !(pfn & nr_pgmask)) {
@@ -1582,12 +1560,12 @@ static int __init deferred_init_memmap(void *data)
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		nr_pages += deferred_init_pages(nid, zid, spfn, epfn);
+		nr_pages += deferred_init_pages(zone, spfn, epfn);
 	}
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		deferred_free_pages(nid, zid, spfn, epfn);
+		deferred_free_pages(spfn, epfn);
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
@@ -1626,7 +1604,6 @@ static DEFINE_STATIC_KEY_TRUE(deferred_pages);
 static noinline bool __init
 deferred_grow_zone(struct zone *zone, unsigned int order)
 {
-	int zid = zone_idx(zone);
 	int nid = zone_to_nid(zone);
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
@@ -1676,7 +1653,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 		while (spfn < epfn && nr_pages < nr_pages_needed) {
 			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
 			first_deferred_pfn = min(t, epfn);
-			nr_pages += deferred_init_pages(nid, zid, spfn,
+			nr_pages += deferred_init_pages(zone, spfn,
 							first_deferred_pfn);
 			spfn = first_deferred_pfn;
 		}
@@ -1688,7 +1665,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
-		deferred_free_pages(nid, zid, spfn, epfn);
+		deferred_free_pages(spfn, epfn);
 
 		if (first_deferred_pfn == epfn)
 			break;
