Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 678C36B0081
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:59 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/34] mm: migration: clean up unmap_and_move()
Date: Mon, 23 Jul 2012 14:38:28 +0100
Message-Id: <1343050727-3045-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit 0dabec93de633a87adfbbe1d800a4c56cd19d73b upstream.

Stable note: Not tracked in Bugzilla. This patch makes later patches
	easier to apply but has no other impact.

unmap_and_move() is one a big messy function.  Clean it up.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/migrate.c |   59 ++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 33 insertions(+), 26 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 14d0a6a..e58ab66 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -621,38 +621,18 @@ static int move_to_new_page(struct page *newpage, struct page *page,
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
@@ -668,7 +648,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		 * altogether.
 		 */
 		if (current->flags & PF_MEMALLOC)
-			goto move_newpage;
+			goto out;
 
 		lock_page(page);
 	}
@@ -785,8 +765,35 @@ uncharge:
 		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
+out:
+	return rc;
+}
 
-move_newpage:
+/*
+ * Obtain the lock on page, remove all ptes and migrate the page
+ * to the newly allocated page in newpage.
+ */
+static int unmap_and_move(new_page_t get_new_page, unsigned long private,
+			struct page *page, int force, bool offlining, bool sync)
+{
+	int rc = 0;
+	int *result = NULL;
+	struct page *newpage = get_new_page(page, private, &result);
+
+	if (!newpage)
+		return -ENOMEM;
+
+	if (page_count(page) == 1) {
+		/* page was freed from under us. So we are done. */
+		goto out;
+	}
+
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page)))
+			goto out;
+
+	rc = __unmap_and_move(page, newpage, force, offlining, sync);
+out:
 	if (rc != -EAGAIN) {
  		/*
  		 * A page that has been migrated has all references
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
