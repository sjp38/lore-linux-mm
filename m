Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6480D6B0203
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:14:59 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache pages
Date: Tue, 30 Mar 2010 10:14:49 +0100
Message-Id: <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

PageAnon pages that are unmapped may or may not have an anon_vma so
are not currently migrated. However, a swap cache page can be migrated
and fits this description. This patch identifies page swap caches and
allows them to be migrated.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/migrate.c |   15 ++++++++++-----
 mm/rmap.c    |    6 ++++--
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 35aad2a..f9bf37e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -203,6 +203,9 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	void **pslot;
 
 	if (!mapping) {
+		if (PageSwapCache(page))
+			SetPageSwapCache(newpage);
+
 		/* Anonymous page without mapping */
 		if (page_count(page) != 1)
 			return -EAGAIN;
@@ -607,11 +610,13 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		 * the page was isolated and when we reached here while
 		 * the RCU lock was not held
 		 */
-		if (!page_mapped(page))
-			goto rcu_unlock;
-
-		anon_vma = page_anon_vma(page);
-		atomic_inc(&anon_vma->external_refcount);
+		if (!page_mapped(page)) {
+			if (!PageSwapCache(page))
+				goto rcu_unlock;
+		} else {
+			anon_vma = page_anon_vma(page);
+			atomic_inc(&anon_vma->external_refcount);
+		}
 	}
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index af35b75..d5ea1f2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 
 	if (unlikely(PageKsm(page)))
 		return rmap_walk_ksm(page, rmap_one, arg);
-	else if (PageAnon(page))
+	else if (PageAnon(page)) {
+		if (PageSwapCache(page))
+			return SWAP_AGAIN;
 		return rmap_walk_anon(page, rmap_one, arg);
-	else
+	} else
 		return rmap_walk_file(page, rmap_one, arg);
 }
 #endif /* CONFIG_MIGRATION */
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
