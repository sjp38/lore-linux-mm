Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4DAA6B02ED
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:44:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a6so1610865pff.17
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:44:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v26si859475pge.759.2017.12.05.16.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:15 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 61/73] dax: Convert dax_writeback_one to XArray
Date: Tue,  5 Dec 2017 16:41:47 -0800
Message-Id: <20171206004159.3755-62-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Likewise easy

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 66f6c4ea18f7..7bd94f1b61d0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -633,8 +633,7 @@ static int dax_writeback_one(struct block_device *bdev,
 		struct dax_device *dax_dev, struct address_space *mapping,
 		pgoff_t index, void *entry)
 {
-	struct radix_tree_root *pages = &mapping->pages;
-	XA_STATE(xas, pages, index);
+	XA_STATE(xas, &mapping->pages, index);
 	void *entry2, *kaddr;
 	long ret = 0, id;
 	sector_t sector;
@@ -649,7 +648,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	if (WARN_ON(!xa_is_value(entry)))
 		return -EIO;
 
-	xa_lock_irq(&mapping->pages);
+	xas_lock_irq(&xas);
 	entry2 = get_unlocked_mapping_entry(&xas);
 	/* Entry got punched out / reallocated? */
 	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
@@ -668,7 +667,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	}
 
 	/* Another fsync thread may have already written back this entry */
-	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
+	if (!xas_get_tag(&xas, PAGECACHE_TAG_TOWRITE))
 		goto put_unlocked;
 	/* Lock the entry to serialize with page faults */
 	entry = lock_slot(&xas);
@@ -679,8 +678,8 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * at the entry only under xa_lock and once they do that they will
 	 * see the entry locked and wait for it to unlock.
 	 */
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_TOWRITE);
-	xa_unlock_irq(&mapping->pages);
+	xas_clear_tag(&xas, PAGECACHE_TAG_TOWRITE);
+	xas_unlock_irq(&xas);
 
 	/*
 	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
@@ -718,9 +717,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * the pfn mappings are writeprotected and fault waits for mapping
 	 * entry lock.
 	 */
-	xa_lock_irq(&mapping->pages);
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_DIRTY);
-	xa_unlock_irq(&mapping->pages);
+	xa_clear_tag(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
 	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
  dax_unlock:
 	dax_read_unlock(id);
@@ -729,7 +726,7 @@ static int dax_writeback_one(struct block_device *bdev,
 
  put_unlocked:
 	put_unlocked_mapping_entry(&xas, entry2);
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 	return ret;
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
