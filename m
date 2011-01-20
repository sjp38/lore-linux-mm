Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC258D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:17:23 -0500 (EST)
Received: by pxi12 with SMTP id 12so155787pxi.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:17:21 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/3] When migrate_pages returns 0, all pages must have been released
Date: Fri, 21 Jan 2011 01:17:05 +0900
Message-Id: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

From: Andrea Arcangeli <aarcange@redhat.com>

In some cases migrate_pages could return zero while still leaving a
few pages in the pagelist (and some caller wouldn't notice it has to
call putback_lru_pages after commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab).

Add one missing putback_lru_pages not added by commit
cf608ac19c95804dc2df43b1f4f9e068aa9034ab.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/memory-failure.c |    1 +
 mm/migrate.c        |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 548fbd7..75398b0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1419,6 +1419,7 @@ int soft_offline_page(struct page *page, int flags)
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
 								0, true);
 		if (ret) {
+			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
 			if (ret > 0)
diff --git a/mm/migrate.c b/mm/migrate.c
index 46fe8cc..7d34237 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -772,6 +772,7 @@ uncharge:
 unlock:
 	unlock_page(page);
 
+move_newpage:
 	if (rc != -EAGAIN) {
  		/*
  		 * A page that has been migrated has all references
@@ -785,8 +786,6 @@ unlock:
 		putback_lru_page(page);
 	}
 
-move_newpage:
-
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
