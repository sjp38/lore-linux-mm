Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 58C926B00D1
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:35:29 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] mm: filemap: pass __GFP_WRITE from grab_cache_page_write_begin()
Date: Wed, 23 Nov 2011 14:34:17 +0100
Message-Id: <1322055258-3254-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

Tell the page allocator that pages allocated through
grab_cache_page_write_begin() are expected to become dirty soon.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/filemap.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c0018f2..5344dec 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2354,8 +2354,11 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 					pgoff_t index, unsigned flags)
 {
 	int status;
+	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
+
+	gfp_mask = mapping_gfp_mask(mapping) | __GFP_WRITE;
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
 repeat:
@@ -2363,7 +2366,7 @@ repeat:
 	if (page)
 		goto found;
 
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
+	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
