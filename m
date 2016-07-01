Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55D09828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:04:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so25886359wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 13:04:46 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id pm5si5064853wjb.183.2016.07.01.13.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 13:04:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id C22E01C224D
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 21:04:44 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/31] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Date: Fri,  1 Jul 2016 21:01:25 +0100
Message-Id: <1467403299-25786-18-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_PAGES  is the number of mapped anon pages.

This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and
NR_ANON_PAGES for mapped pages.  This patch renames NR_ANON_PAGES so we
have

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_MAPPED is the number of mapped anon pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/base/node.c    | 2 +-
 fs/proc/meminfo.c      | 2 +-
 include/linux/mmzone.h | 2 +-
 mm/migrate.c           | 2 +-
 mm/rmap.c              | 8 ++++----
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index acca09536ad9..ac69a7215bcc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -122,7 +122,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
-		       nid, K(node_page_state(pgdat, NR_ANON_PAGES)),
+		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
 		       nid, K(i.sharedram),
 		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index b8d52aa2f19a..40f108783d59 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -140,7 +140,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-		K(global_node_page_state(NR_ANON_PAGES)),
+		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3f87306b3a37..21aaafcee7de 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -161,7 +161,7 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
diff --git a/mm/migrate.c b/mm/migrate.c
index 3033dae33a0a..fba770c54d84 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -501,7 +501,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * new page and drop references to the old page.
 	 *
 	 * Note that anonymous pages are accounted for
-	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
+	 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
 	 * are mapped to swap space.
 	 */
 	if (newzone != oldzone) {
diff --git a/mm/rmap.c b/mm/rmap.c
index 17876517f5fa..a66f80bc8703 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1217,7 +1217,7 @@ void do_page_add_anon_rmap(struct page *page,
 		 */
 		if (compound)
 			__inc_zone_page_state(page, NR_ANON_THPS);
-		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
+		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1261,7 +1261,7 @@ void page_add_new_anon_rmap(struct page *page,
 		/* increment count (starts at -1) */
 		atomic_set(&page->_mapcount, 0);
 	}
-	__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
+	__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1378,7 +1378,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		clear_page_mlock(page);
 
 	if (nr) {
-		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
 		deferred_split_huge_page(page);
 	}
 }
@@ -1407,7 +1407,7 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_node_page_state(page, NR_ANON_PAGES);
+	__dec_node_page_state(page, NR_ANON_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
