Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A40E19000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:25:45 -0400 (EDT)
Received: by iyh42 with SMTP id 42so951630iyh.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:25:43 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 1/8] Only isolate page we can handle
Date: Wed, 27 Apr 2011 01:25:18 +0900
Message-Id: <1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

There are some places to isolate lru page and I believe
users of isolate_lru_page will be growing.
The purpose of them is each different so part of isolated pages
should put back to LRU, again.

The problem is when we put back the page into LRU,
we lose LRU ordering and the page is inserted at head of LRU list.
It makes unnecessary LRU churning so that vm can evict working set pages
rather than idle pages.

This patch adds new filter mask when we isolate page in LRU.
So, we don't isolate pages if we can't handle it.
It could reduce LRU churning.

This patch shouldn't change old behavior.
It's just used by next patches.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    3 ++-
 mm/compaction.c      |    2 +-
 mm/memcontrol.c      |    2 +-
 mm/vmscan.c          |   26 ++++++++++++++++++++------
 4 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..baef4ad 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -259,7 +259,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned int swappiness,
 						struct zone *zone,
 						unsigned long *nr_scanned);
-extern int __isolate_lru_page(struct page *page, int mode, int file);
+extern int __isolate_lru_page(struct page *page, int mode, int file,
+				int not_dirty, int not_mapped);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..dea32e3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -335,7 +335,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
+		if (__isolate_lru_page(page, ISOLATE_BOTH, 0, 0, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c2776f1..471e7fd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1193,7 +1193,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 			continue;
 
 		scan++;
-		ret = __isolate_lru_page(page, mode, file);
+		ret = __isolate_lru_page(page, mode, file, 0, 0);
 		switch (ret) {
 		case 0:
 			list_move(&page->lru, dst);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..71d2da9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -954,10 +954,13 @@ keep_lumpy:
  *
  * page:	page to consider
  * mode:	one of the LRU isolation modes defined above
- *
+ * file:	page be on a file LRU
+ * not_dirty:	page should be not dirty or not writeback
+ * not_mapped:	page should be not mapped
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode, int file)
+int __isolate_lru_page(struct page *page, int mode, int file,
+				int not_dirty, int not_mapped)
 {
 	int ret = -EINVAL;
 
@@ -976,6 +979,12 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
 		return ret;
 
+	if (not_dirty)
+		if (PageDirty(page) || PageWriteback(page))
+			return ret;
+	if (not_mapped)
+		if (page_mapped(page))
+			return ret;
 	/*
 	 * When this function is being called for lumpy reclaim, we
 	 * initially look into all LRU pages, active, inactive and
@@ -1016,12 +1025,15 @@ int __isolate_lru_page(struct page *page, int mode, int file)
  * @order:	The caller's attempted allocation order
  * @mode:	One of the LRU isolation modes
  * @file:	True [1] if isolating file [!anon] pages
+ * @not_dirty:	True [1] if isolating file [!dirty] pages
+ * @not_mapped:	True [1] if isolating file [!mapped] pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode, int file)
+		unsigned long *scanned, int order, int mode, int file,
+		int not_dirty, int not_mapped)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1041,7 +1053,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode, file)) {
+		switch (__isolate_lru_page(page, mode, file,
+					not_dirty, not_mapped)) {
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
@@ -1100,7 +1113,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+			if (__isolate_lru_page(cursor_page, mode, file,
+					not_dirty, not_mapped) == 0) {
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
 				nr_taken += hpage_nr_pages(page);
@@ -1143,7 +1157,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
 	if (file)
 		lru += LRU_FILE;
 	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+					mode, file, 0, 0);
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
