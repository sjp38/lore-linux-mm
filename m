Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D051E6B0092
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:23 -0400 (EDT)
Received: by mail-px0-f177.google.com with SMTP id 10so3802021pxi.8
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:21 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 07/10] migration: clean up unmap_and_move
Date: Tue,  7 Jun 2011 23:38:20 +0900
Message-Id: <cf5cd5055db22ae301e01294f191bd94b17e7775.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

The unmap_and_move is one of big messy functions.
This patch try to clean up.

It can help readability and make unmap_and_move_ilru simple.
unmap_and_move_ilru will be introduced by next patch.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |   82 +++++++++++++++++++++++++++++++++------------------------
 1 files changed, 47 insertions(+), 35 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 874c081..3aec310 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -645,38 +645,18 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	return rc;
 }
 
-/*
- * Obtain the lock on page, remove all ptes and migrate the page
- * to the newly allocated page in newpage.
- */
-static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, bool offlining, bool sync)
+static int __unmap_and_move(struct page *page, struct page *newpage,
+				int force, bool offlining, bool sync)
 {
-	int rc = 0;
-	int *result = NULL;
-	struct page *newpage = get_new_page(page, private, &result);
+	int rc = -EAGAIN;
 	int remap_swapcache = 1;
 	int charge = 0;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
-	if (!newpage)
-		return -ENOMEM;
-
-	if (page_count(page) == 1) {
-		/* page was freed from under us. So we are done. */
-		goto move_newpage;
-	}
-	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page(page)))
-			goto move_newpage;
-
-	/* prepare cgroup just returns 0 or -ENOMEM */
-	rc = -EAGAIN;
-
 	if (!trylock_page(page)) {
 		if (!force || !sync)
-			goto move_newpage;
+			goto out;
 
 		/*
 		 * It's not safe for direct compaction to call lock_page.
@@ -692,7 +672,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		 * altogether.
 		 */
 		if (current->flags & PF_MEMALLOC)
-			goto move_newpage;
+			goto out;
 
 		lock_page(page);
 	}
@@ -813,9 +793,13 @@ uncharge:
 		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
+out:
+	return rc;
+}
 
-move_newpage:
-	if (rc != -EAGAIN) {
+static void __put_lru_pages(struct page *page, struct page *newpage)
+{
+	if (page != NULL) {
  		/*
  		 * A page that has been migrated has all references
  		 * removed and will be freed. A page that has not been
@@ -827,20 +811,48 @@ move_newpage:
 				page_is_file_cache(page));
 		putback_lru_page(page);
 	}
-
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
 	 */
 	putback_lru_page(newpage);
+}
 
-	if (result) {
-		if (rc)
-			*result = rc;
-		else
-			*result = page_to_nid(newpage);
-	}
-	return rc;
+/*
+ * Obtain the lock on page, remove all ptes and migrate the page
+ * to the newly allocated page in newpage.
+ */
+static int unmap_and_move(new_page_t get_new_page, unsigned long private,
+			struct page *page, int force, bool offlining, bool sync)
+{
+        int rc = 0;
+        int *result = NULL;
+        struct page *newpage = get_new_page(page, private, &result);
+
+        if (!newpage)
+                return -ENOMEM;
+
+        if (page_count(page) == 1) {
+                /* page was freed from under us. So we are done. */
+                goto out;
+        }
+
+        if (unlikely(PageTransHuge(page)))
+                if (unlikely(split_huge_page(page)))
+                        goto out;
+
+        rc = __unmap_and_move(page, newpage, force, offlining, sync);
+        if (rc == -EAGAIN)
+                page = NULL;
+out:
+        __put_lru_pages(page, newpage);
+        if (result) {
+                if (rc)
+                        *result = rc;
+                else
+                        *result = page_to_nid(newpage);
+        }
+        return rc;
 }
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
