Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 88C2A6B005D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 13:02:22 -0400 (EDT)
Received: by yhr47 with SMTP id 47so795291yhr.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:02:21 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm: fix wrong argument of migrate_huge_pages() in soft_offline_huge_page()
Date: Wed, 18 Jul 2012 02:01:00 +0900
Message-Id: <1342544460-20095-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

Commit a6bc32b899223a877f595ef9ddc1e89ead5072b8 ('mm: compaction: introduce
sync-light migration for use by compaction') change declaration of
migrate_pages() and migrate_huge_pages().
But, it miss changing argument of migrate_huge_pages()
in soft_offline_huge_page(). In this case, we should call with MIGRATE_SYNC.
So change it.

Additionally, there is mismatch between type of argument and function
declaration for migrate_pages(). So fix this simple case, too.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ab1e714..afde561 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1431,8 +1431,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	/* Keep page count to indicate a given hugepage is isolated. */
 
 	list_add(&hpage->lru, &pagelist);
-	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
-				true);
+	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, false,
+				MIGRATE_SYNC);
 	if (ret) {
 		struct page *page1, *page2;
 		list_for_each_entry_safe(page1, page2, &pagelist, lru)
@@ -1561,7 +1561,7 @@ int soft_offline_page(struct page *page, int flags)
 					    page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-							0, MIGRATE_SYNC);
+							false, MIGRATE_SYNC);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
