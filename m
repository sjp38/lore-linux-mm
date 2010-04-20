Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB60C6B01F2
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:15 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache pages
Date: Tue, 20 Apr 2010 22:01:06 +0100
Message-Id: <1271797276-31358-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

PageAnon pages that are unmapped may or may not have an anon_vma so are
not currently migrated.  However, a swap cache page can be migrated and
fits this description.  This patch identifies page swap caches and allows
them to be migrated but ensures that no attempt to made to remap the pages
would would potentially try to access an already freed anon_vma.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |   53 ++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b114635..4afd6fe 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -485,7 +485,8 @@ static int fallback_migrate_page(struct address_space *mapping,
  *   < 0 - error code
  *  == 0 - success
  */
-static int move_to_new_page(struct page *newpage, struct page *page)
+static int move_to_new_page(struct page *newpage, struct page *page,
+						int remap_swapcache)
 {
 	struct address_space *mapping;
 	int rc;
@@ -520,10 +521,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
 	else
 		rc = fallback_migrate_page(mapping, newpage, page);
 
-	if (!rc)
-		remove_migration_ptes(page, newpage);
-	else
+	if (rc) {
 		newpage->mapping = NULL;
+	} else {
+		if (remap_swapcache)
+			remove_migration_ptes(page, newpage);
+	}
 
 	unlock_page(newpage);
 
@@ -540,6 +543,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	int remap_swapcache = 1;
 	int rcu_locked = 0;
 	int charge = 0;
 	struct mem_cgroup *mem = NULL;
@@ -601,18 +605,33 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		rcu_read_lock();
 		rcu_locked = 1;
 
-		/*
-		 * If the page has no mappings any more, just bail. An
-		 * unmapped anon page is likely to be freed soon but worse,
-		 * it's possible its anon_vma disappeared between when
-		 * the page was isolated and when we reached here while
-		 * the RCU lock was not held
-		 */
-		if (!page_mapped(page))
-			goto rcu_unlock;
+		/* Determine how to safely use anon_vma */
+		if (!page_mapped(page)) {
+			if (!PageSwapCache(page))
+				goto rcu_unlock;
 
-		anon_vma = page_anon_vma(page);
-		atomic_inc(&anon_vma->external_refcount);
+			/*
+			 * We cannot be sure that the anon_vma of an unmapped
+			 * swapcache page is safe to use because we don't
+			 * know in advance if the VMA that this page belonged
+			 * to still exists. If the VMA and others sharing the
+			 * data have been freed, then the anon_vma could
+			 * already be invalid.
+			 *
+			 * To avoid this possibility, swapcache pages get
+			 * migrated but are not remapped when migration
+			 * completes
+			 */
+			remap_swapcache = 0;
+		} else {
+			/*
+			 * Take a reference count on the anon_vma if the
+			 * page is mapped so that it is guaranteed to
+			 * exist when the page is remapped later
+			 */
+			anon_vma = page_anon_vma(page);
+			atomic_inc(&anon_vma->external_refcount);
+		}
 	}
 
 	/*
@@ -647,9 +666,9 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page);
+		rc = move_to_new_page(newpage, page, remap_swapcache);
 
-	if (rc)
+	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
 rcu_unlock:
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
