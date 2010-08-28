Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC9F6B01F8
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 22:40:53 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 1/4] mm: exporting account_page_dirty
Date: Fri, 27 Aug 2010 19:40:24 -0700
Message-Id: <1282963227-31867-2-git-send-email-mrubin@google.com>
In-Reply-To: <1282963227-31867-1-git-send-email-mrubin@google.com>
References: <1282963227-31867-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

This allows code outside of the mm core to safely manipulate page state
and not worry about the other accounting. Not using these routines means
that some code will lose track of the accounting and we get bugs. This
has happened once already.

Modified cephs to use the interface.

Signed-off-by: Michael Rubin <mrubin@google.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

---
 fs/ceph/addr.c      |    8 +-------
 mm/page-writeback.c |    1 +
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 5598a0d..420d469 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -105,13 +105,7 @@ static int ceph_set_page_dirty(struct page *page)
 	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(!PageUptodate(page));
-
-		if (mapping_cap_account_dirty(mapping)) {
-			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			__inc_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			task_io_account_write(PAGE_CACHE_SIZE);
-		}
+		account_page_dirtied(page, page->mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7262aac..9d07a8d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1131,6 +1131,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
 }
+EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
