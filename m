Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 81EF46B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 15:24:43 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: keep pages from unevictable mappings off the LRU lists
Date: Sun, 22 Mar 2009 21:13:04 +0100
Message-Id: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <20090321102044.GA3427@cmpxchg.org>
References: <20090321102044.GA3427@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Check if the mapping is evictable when initially adding page cache
pages to the LRU lists.  If that is not the case, add them to the
unevictable list immediately instead of leaving it up to the reclaim
code to move them there.

This is useful for ramfs and locked shmem which mark whole mappings as
unevictable and we know at fault time already that it is useless to
try reclaiming these pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.com>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
---
 mm/filemap.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 23acefe..8574530 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -506,7 +506,9 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 
 	ret = add_to_page_cache(page, mapping, offset, gfp_mask);
 	if (ret == 0) {
-		if (page_is_file_cache(page))
+		if (mapping_unevictable(mapping))
+			add_page_to_unevictable_list(page);
+		else if (page_is_file_cache(page))
 			lru_cache_add_file(page);
 		else
 			lru_cache_add_active_anon(page);
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
