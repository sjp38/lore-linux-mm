Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 468C76B0273
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:42 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id 64so7987666yby.11
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w139si1517006ybb.342.2017.12.15.14.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:41 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 62/78] dax: Convert dax_writeback_one to XArray
Date: Fri, 15 Dec 2017 14:04:34 -0800
Message-Id: <20171215220450.7899-63-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Likewise easy

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d3894c15609a..d6dd779e1b46 100644
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
