Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 572E2828E4
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:16:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a140so13383842wma.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:16:40 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id b202si10977935wmf.46.2016.04.15.02.16.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:16:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 3C8CBCF51
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:16:38 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/27] mm: Rename NR_ANON_PAGES to NR_ANON_MAPPED
Date: Fri, 15 Apr 2016 10:13:23 +0100
Message-Id: <1460711613-2761-18-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_PAGES  is the number of mapped anon pages.

This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and NR_ANON_PAGES for
mapped pages. This patch renames NR_ANON_PAGES so we have

NR_FILE_PAGES  is the number of        file pages.
NR_FILE_MAPPED is the number of mapped file pages.
NR_ANON_MAPPED is the number of mapped anon pages.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/base/node.c    | 2 +-
 fs/proc/meminfo.c      | 2 +-
 include/linux/mmzone.h | 2 +-
 mm/migrate.c           | 2 +-
 mm/rmap.c              | 8 ++++----
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 66aed68a0fdc..897b6bcb36be 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -120,7 +120,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
-		       nid, K(node_page_state(pgdat, NR_ANON_PAGES)),
+		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
 		       nid, K(i.sharedram),
 		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 54e039682ec9..076afb43fc56 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -138,7 +138,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-		K(global_node_page_state(NR_ANON_PAGES)),
+		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c6d59b60caec..f7cba770e524 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -153,7 +153,7 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
diff --git a/mm/migrate.c b/mm/migrate.c
index 53bb33c570bf..507277571847 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -412,7 +412,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * new page and drop references to the old page.
 	 *
 	 * Note that anonymous pages are accounted for
-	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
+	 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
 	 * are mapped to swap space.
 	 */
 	if (newzone != oldzone) {
diff --git a/mm/rmap.c b/mm/rmap.c
index b27b87653c36..f55f5c084489 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1218,7 +1218,7 @@ void do_page_add_anon_rmap(struct page *page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 		}
 		__mod_node_page_state(page_zone(page)->zone_pgdat,
-				NR_ANON_PAGES, nr);
+				NR_ANON_MAPPED, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1262,7 +1262,7 @@ void page_add_new_anon_rmap(struct page *page,
 		/* increment count (starts at -1) */
 		atomic_set(&page->_mapcount, 0);
 	}
-	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES, nr);
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_MAPPED, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1344,7 +1344,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		clear_page_mlock(page);
 
 	if (nr) {
-		__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES, -nr);
+		__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_MAPPED, -nr);
 		deferred_split_huge_page(page);
 	}
 }
@@ -1376,7 +1376,7 @@ void page_remove_rmap(struct page *page, bool compound)
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
