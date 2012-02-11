Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id DA0056B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 02:43:56 -0500 (EST)
Received: by bkty12 with SMTP id y12so3945717bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 23:43:55 -0800 (PST)
Subject: [PATCH 5/4] shmem: put shmem_delete_from_page_cache under CONFIG_SWAP
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 11 Feb 2012 11:43:52 +0400
Message-ID: <20120211074321.30852.66207.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Fix warning added in patch "shmem: tag swap entries in radix tree"

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7a3fe08..709e3d8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -302,25 +302,6 @@ static int shmem_add_to_page_cache(struct page *page,
 }
 
 /*
- * Like delete_from_page_cache, but substitutes swap for page.
- */
-static void shmem_delete_from_page_cache(struct page *page, void *radswap)
-{
-	struct address_space *mapping = page->mapping;
-	int error;
-
-	spin_lock_irq(&mapping->tree_lock);
-	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
-	page->mapping = NULL;
-	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
-	__dec_zone_page_state(page, NR_SHMEM);
-	spin_unlock_irq(&mapping->tree_lock);
-	page_cache_release(page);
-	BUG_ON(error);
-}
-
-/*
  * Like find_get_pages, but collecting swap entries as well as pages.
  */
 static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
@@ -718,6 +699,25 @@ out:
 }
 
 /*
+ * Like delete_from_page_cache, but substitutes swap for page.
+ */
+static void shmem_delete_from_page_cache(struct page *page, void *radswap)
+{
+	struct address_space *mapping = page->mapping;
+	int error;
+
+	spin_lock_irq(&mapping->tree_lock);
+	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
+	page->mapping = NULL;
+	mapping->nrpages--;
+	__dec_zone_page_state(page, NR_FILE_PAGES);
+	__dec_zone_page_state(page, NR_SHMEM);
+	spin_unlock_irq(&mapping->tree_lock);
+	page_cache_release(page);
+	BUG_ON(error);
+}
+
+/*
  * Move the page from the page cache to the swap cache.
  */
 static int shmem_writepage(struct page *page, struct writeback_control *wbc)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
