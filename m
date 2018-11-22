Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A40256B2ADA
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 04:48:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i19-v6so2681600pfi.21
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 01:48:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor5663201plz.28.2018.11.22.01.48.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 01:48:16 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: check nr_initialised with PAGES_PER_SECTION directly in defer_init()
Date: Thu, 22 Nov 2018 17:48:07 +0800
Message-Id: <20181122094807.6985-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

When DEFERRED_STRUCT_PAGE_INIT is configured, only the first section of
each node's highest zone is initialized before defer stage.

static_init_pgcnt is used to store the number of pages like this:

    pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
                                              pgdat->node_spanned_pages);

because we don't want to overflow zone's range.

But this is not necessary, since defer_init() is called like this:

  memmap_init_zone()
    for pfn in [start_pfn, end_pfn)
      defer_init(pfn, end_pfn)

In case (pgdat->node_spanned_pages < PAGES_PER_SECTION), the loop would
stop before calling defer_init().

BTW, comparing PAGES_PER_SECTION with node_spanned_pages is not correct,
since nr_initialised is zone based instead of node based. Even
node_spanned_pages is bigger than PAGES_PER_SECTION, its highest zone
would have pages less than PAGES_PER_SECTION.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h |  2 --
 mm/page_alloc.c        | 13 ++++++-------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ae7a830a21eb..68d7b558924b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -692,8 +692,6 @@ typedef struct pglist_data {
 	 * is the first PFN that needs to be initialised.
 	 */
 	unsigned long first_deferred_pfn;
-	/* Number of non-deferred pages */
-	unsigned long static_init_pgcnt;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76e12179cd5e..b542d82400cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -326,8 +326,13 @@ defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
 	/* Always populate low zones for address-constrained allocations */
 	if (end_pfn < pgdat_end_pfn(NODE_DATA(nid)))
 		return false;
+
+	/*
+	 * We start only with one section of pages, more pages are added as
+	 * needed until the rest of deferred pages are initialized.
+	 */
 	nr_initialised++;
-	if ((nr_initialised > NODE_DATA(nid)->static_init_pgcnt) &&
+	if ((nr_initialised > PAGES_PER_SECTION) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		NODE_DATA(nid)->first_deferred_pfn = pfn;
 		return true;
@@ -6451,12 +6456,6 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void pgdat_set_deferred_range(pg_data_t *pgdat)
 {
-	/*
-	 * We start only with one section of pages, more pages are added as
-	 * needed until the rest of deferred pages are initialized.
-	 */
-	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
-						pgdat->node_spanned_pages);
 	pgdat->first_deferred_pfn = ULONG_MAX;
 }
 #else
-- 
2.15.1
