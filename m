Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A318C6B0388
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v20so30310099qtg.3
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s2si8443989qkb.256.2017.06.12.05.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 07/20] mm: clean up error handling in write_one_page
Date: Mon, 12 Jun 2017 08:22:59 -0400
Message-Id: <20170612122316.13244-8-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Don't try to check PageError since that's potentially racy and not
necessarily going to be set after writepage errors out.

Instead, check the mapping for an error after writepage returns.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b901fe52b153..e369e8ea2a29 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2371,14 +2371,13 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
  *
  * The page must be locked by the caller and will be unlocked upon return.
  *
- * write_one_page() returns a negative error code if I/O failed. Note that
- * the address_space is not marked for error. The caller must do this if
- * needed.
+ * Note that the mapping's AS_EIO/AS_ENOSPC flags will be cleared when this
+ * function returns.
  */
 int write_one_page(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	int ret = 0;
+	int ret = 0, ret2;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 1,
@@ -2391,15 +2390,15 @@ int write_one_page(struct page *page)
 	if (clear_page_dirty_for_io(page)) {
 		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
-		if (ret == 0) {
+		if (ret == 0)
 			wait_on_page_writeback(page);
-			if (PageError(page))
-				ret = -EIO;
-		}
 		put_page(page);
 	} else {
 		unlock_page(page);
 	}
+
+	if (!ret)
+		ret = filemap_check_errors(mapping);
 	return ret;
 }
 EXPORT_SYMBOL(write_one_page);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
