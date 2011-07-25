Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 458C26B016C
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:20:21 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 5/5] mm: filemap: horrid hack to pass __GFP_WRITE for most page cache writers
Date: Mon, 25 Jul 2011 22:19:19 +0200
Message-Id: <1311625159-13771-6-git-send-email-jweiner@redhat.com>
In-Reply-To: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>

This makes every page allocation that results from grabbing a single
page in the page cache pass __GFP_WRITE.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/pagemap.h |    6 ++++--
 mm/filemap.c            |    8 ++++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 716875e..3355c9b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -244,12 +244,14 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
 
 /*
- * Returns locked page at given index in given cache, creating it if needed.
+ * Returns locked page at given index in given cache, creating it if
+ * needed.  XXX: Assumes that page will be dirtied soon!
  */
 static inline struct page *grab_cache_page(struct address_space *mapping,
 								pgoff_t index)
 {
-	return find_or_create_page(mapping, index, mapping_gfp_mask(mapping));
+	return find_or_create_page(mapping, index,
+				   mapping_gfp_mask(mapping) | __GFP_WRITE);
 }
 
 extern struct page * grab_cache_page_nowait(struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index a8251a8..e315d46 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1030,6 +1030,7 @@ struct page *
 grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 {
 	struct page *page = find_get_page(mapping, index);
+	gfp_t gfp_mask;
 
 	if (page) {
 		if (trylock_page(page))
@@ -1037,7 +1038,8 @@ grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	gfp_mask = (mapping_gfp_mask(mapping) | __GFP_WRITE) & ~__GFP_FS;
+	page = __page_cache_alloc(gfp_mask);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
@@ -2330,6 +2332,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 					pgoff_t index, unsigned flags)
 {
 	int status;
+	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
 	if (flags & AOP_FLAG_NOFS)
@@ -2339,7 +2342,8 @@ repeat:
 	if (page)
 		goto found;
 
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
+	gfp_mask = (mapping_gfp_mask(mapping) | __GFP_WRITE) & ~gfp_notmask;
+	page = __page_cache_alloc(gfp_mask);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
