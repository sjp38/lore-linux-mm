Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F48D8D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 10:09:44 -0500 (EST)
Received: by iyi20 with SMTP id 20so3919774iyi.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 07:09:41 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] mm: Add hook of freepage
Date: Mon,  7 Feb 2011 00:08:54 +0900
Message-Id: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Miklos Szeredi <mszeredi@suse.cz>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

Recently, "Call the filesystem back whenever a page is removed from
the page cache(6072d13c)" added new freepage hook in page cache
drop function.

So, replace_page_cache_page should call freepage to support
page cleanup to fs.

Cc: Miklos Szeredi <mszeredi@suse.cz>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/filemap.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3c89c96..a25c898 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -436,7 +436,10 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (!error) {
 		struct address_space *mapping = old->mapping;
+		void (*freepage)(struct page *);
+
 		pgoff_t offset = old->index;
+		freepage = mapping->a_ops->freepage;
 
 		page_cache_get(new);
 		new->mapping = mapping;
@@ -452,6 +455,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
+		if (freepage)
+			freepage(old);
 		page_cache_release(old);
 		mem_cgroup_end_migration(memcg, old, new, true);
 	} else {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
