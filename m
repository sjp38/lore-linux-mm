Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDDC8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 18:02:04 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p3so2504577plk.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 15:02:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b18si19703407plz.105.2018.12.20.15.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 15:02:02 -0800 (PST)
Date: Thu, 20 Dec 2018 15:01:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: check nr_initialised with PAGES_PER_SECTION
 directly in defer_init()
Message-Id: <20181220150159.9a6f2356dbeb7d877a3fb447@linux-foundation.org>
In-Reply-To: <20181122094807.6985-1-richard.weiyang@gmail.com>
References: <20181122094807.6985-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, linux-mm@kvack.org


Could someone please review this?



From: Wei Yang <richard.weiyang@gmail.com>
Subject: mm: check nr_initialised with PAGES_PER_SECTION directly in defer_init()

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
since nr_initialised is zone based instead of node based.  Even
node_spanned_pages is bigger than PAGES_PER_SECTION, its highest zone
would have pages less than PAGES_PER_SECTION.

Link: http://lkml.kernel.org/r/20181122094807.6985-1-richard.weiyang@gmail.com
Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |    2 --
 mm/page_alloc.c        |   13 ++++++-------
 2 files changed, 6 insertions(+), 9 deletions(-)

--- a/include/linux/mmzone.h~mm-check-nr_initialised-with-pages_per_section-directly-in-defer_init
+++ a/include/linux/mmzone.h
@@ -692,8 +692,6 @@ typedef struct pglist_data {
 	 * is the first PFN that needs to be initialised.
 	 */
 	unsigned long first_deferred_pfn;
-	/* Number of non-deferred pages */
-	unsigned long static_init_pgcnt;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
--- a/mm/page_alloc.c~mm-check-nr_initialised-with-pages_per_section-directly-in-defer_init
+++ a/mm/page_alloc.c
@@ -326,8 +326,13 @@ defer_init(int nid, unsigned long pfn, u
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
@@ -6585,12 +6590,6 @@ static void __ref alloc_node_mem_map(str
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
_
