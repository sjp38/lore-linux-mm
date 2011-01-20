Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 04BD98D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:17:25 -0500 (EST)
Received: by mail-px0-f169.google.com with SMTP id 12so155787pxi.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:17:24 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 2/3] migration: Fix page corruption during hugepage migration
Date: Fri, 21 Jan 2011 01:17:06 +0900
Message-Id: <ffab7f865b626cc7c62d18c612700b86ff53391c.1295539829.git.minchan.kim@gmail.com>
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

If migrate_huge_page by memory-failure fails , it calls put_page in itself
to decrease page reference and caller of migrate_huge_page also calls
putback_lru_pages. It can do double free of page so it can make page
corruption on page holder.

In addtion, clean of pages on caller is consistent behavior with
migrate_pages by cf608ac19c95804dc2df43b1f4f9e0.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory-failure.c |    5 ++++-
 mm/migrate.c        |    4 ----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 75398b0..237aaa4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1295,7 +1295,10 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
 				true);
 	if (ret) {
-		putback_lru_pages(&pagelist);
+		struct page *page1, *page2;
+		list_for_each_entry_safe(page1, page2, &pagelist, lru)
+			put_page(page1);
+
 		pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
 			 pfn, ret, page->flags);
 		if (ret > 0)
diff --git a/mm/migrate.c b/mm/migrate.c
index 7d34237..3a6d4fd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -980,10 +980,6 @@ int migrate_huge_pages(struct list_head *from,
 	}
 	rc = 0;
 out:
-
-	list_for_each_entry_safe(page, page2, from, lru)
-		put_page(page);
-
 	if (rc)
 		return rc;
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
