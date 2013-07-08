Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 57E696B003C
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:52:07 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id x10so3583157lbi.33
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 02:52:05 -0700 (PDT)
Subject: [PATCH 1/5] mm: remove redundant dirty pages check from
 __delete_from_page_cache()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 13:52:02 +0400
Message-ID: <20130708095202.13810.11659.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

This chunk was added by commit 3a6927906f1b2adf5a31b789322d32eb8559ada0
("Do dirty page accounting when removing a page from the page cache") in 2.6.24.

That was fix for side-effects of commit 3e67c0987d7567ad666641164a153dca9a43b11d
("[PATCH] truncate: clear page dirtiness before running try_to_free_buffers()")
which was required for 46d2277c796f9f4937bfa668c40b2e3f43e93dd0 ("Clean up and
make try_to_free_buffers() not race with dirty pages") and that patch in turn
was reverted by commit ecdfc9787fe527491baefc22dce8b2dbd5b2908d ("Resurrect
'try_to_free_buffers()' VM hackery").

And finally, cancel_dirty_page() was placed after do_invalidatepage in 2.6.25 by
commit a2b345642f530054a92b8d2b5108436225a8093e
("Fix dirty page accounting leak with ext3 data=journal")

So, that hunk is redundant. All other callers of delete_from_page_cache() and
__delete_from_page_cache() handle dirty pages themselves.

I have run xfstest on ext3 in mode data=journal several times. Everything works
fine, except testcase '068' which have triggered deadlock on fs-freeze.
This seems unrelated and probably it's never worked for ext3 in this mode.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/filemap.c  |   12 ------------
 mm/truncate.c |    4 ++++
 2 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7905fe7..504aab2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -135,18 +135,6 @@ void __delete_from_page_cache(struct page *page)
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
 	BUG_ON(page_mapped(page));
-
-	/*
-	 * Some filesystems seem to re-dirty the page even after
-	 * the VM has canceled the dirty bit (eg ext3 journaling).
-	 *
-	 * Fix it up by doing a final dirty accounting check after
-	 * having removed the page entirely.
-	 */
-	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
-	}
 }
 
 /**
diff --git a/mm/truncate.c b/mm/truncate.c
index e2e8a8a..9b4721f 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -100,6 +100,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (page_has_private(page))
 		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
+	/*
+	 * This is final dirty accounting check. Some filesystems may re-dirty
+	 * pages during invalidation, hence it's placed after that.
+	 */
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	ClearPageMappedToDisk(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
