Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F576900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:09 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so87286282wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk4si1364110wib.6.2015.06.08.06.56.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:58 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/25] mm: Rename NR_ANON_PAGES to NR_ANON_MAPPED
Date: Mon,  8 Jun 2015 14:56:20 +0100
Message-Id: <1433771791-30567-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_PAGES  is the number of mapped anon pages.

This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and NR_ANON_PAGES for
mapped pages. This patch renames NR_ANON_PAGES so we have

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_MAPPED is the number of mapped anon pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/proc/meminfo.c      | 2 +-
 include/linux/mmzone.h | 2 +-
 mm/migrate.c           | 2 +-
 mm/rmap.c              | 8 ++++----
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8f105c774b2e..2072876cce7c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -173,7 +173,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-		K(global_node_page_state(NR_ANON_PAGES)),
+		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a523e1a30e54..4406f855d58e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -157,7 +157,7 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
diff --git a/mm/migrate.c b/mm/migrate.c
index a33e4b4ed60d..4a50bb7c06a6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -376,7 +376,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * new page and drop references to the old page.
 	 *
 	 * Note that anonymous pages are accounted for
-	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
+	 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
 	 * are mapped to swap space.
 	 */
 	__dec_zone_page_state(page, NR_FILE_PAGES);
diff --git a/mm/rmap.c b/mm/rmap.c
index f2ce8d11bed6..e6bf7a205913 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1047,7 +1047,7 @@ void do_page_add_anon_rmap(struct page *page,
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 		__mod_node_page_state(page_zone(page)->zone_pgdat,
-				NR_ANON_PAGES, hpage_nr_pages(page));
+				NR_ANON_MAPPED, hpage_nr_pages(page));
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1078,7 +1078,7 @@ void page_add_new_anon_rmap(struct page *page,
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES,
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_MAPPED,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
 }
@@ -1146,7 +1146,7 @@ void page_remove_rmap(struct page *page)
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		return;
 
-	/* Hugepages are not counted in NR_ANON_PAGES for now. */
+	/* Hugepages are not counted in NR_ANON_MAPPED for now. */
 	if (unlikely(PageHuge(page)))
 		return;
 
@@ -1158,7 +1158,7 @@ void page_remove_rmap(struct page *page)
 	if (PageTransHuge(page))
 		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 
-	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES,
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_MAPPED,
 			      -hpage_nr_pages(page));
 
 	if (unlikely(PageMlocked(page)))
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
