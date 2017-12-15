Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2A36B0294
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:03 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id f185so16495107itc.2
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u11si5100665iod.295.2017.12.15.14.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:02 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 65/78] dax: Convert grab_mapping_entry to XArray
Date: Fri, 15 Dec 2017 14:04:37 -0800
Message-Id: <20171215220450.7899-66-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 98 +++++++++++++++++-----------------------------------------------
 1 file changed, 26 insertions(+), 72 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index a3e795ad2493..f591ab5be590 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -44,6 +44,7 @@
 
 /* The 'colour' (ie low bits) within a PMD of a page offset.  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
+#define PMD_ORDER	(PMD_SHIFT - PAGE_SHIFT)
 
 static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
 
@@ -89,10 +90,10 @@ static void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
 			DAX_ENTRY_LOCK);
 }
 
-static unsigned int dax_radix_order(void *entry)
+static unsigned int dax_entry_order(void *entry)
 {
 	if (xa_to_value(entry) & DAX_PMD)
-		return PMD_SHIFT - PAGE_SHIFT;
+		return PMD_ORDER;
 	return 0;
 }
 
@@ -299,10 +300,11 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 {
 	XA_STATE(xas, &mapping->pages, index);
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
-	void *entry, **slot;
+	void *entry;
 
+	xas_set_order(&xas, index, size_flag ? PMD_ORDER : 0);
 restart:
-	xa_lock_irq(&mapping->pages);
+	xas_lock_irq(&xas);
 	entry = get_unlocked_mapping_entry(&xas);
 
 	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
@@ -326,84 +328,36 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		}
 	}
 
-	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!entry || pmd_downgrade) {
-		int err;
-
-		if (pmd_downgrade) {
-			/*
-			 * Make sure 'entry' remains valid while we drop
-			 * xa_lock.
-			 */
-			entry = lock_slot(&xas);
-		}
-
-		xa_unlock_irq(&mapping->pages);
+	if (pmd_downgrade) {
+		entry = lock_slot(&xas);
 		/*
 		 * Besides huge zero pages the only other thing that gets
 		 * downgraded are empty entries which don't need to be
 		 * unmapped.
 		 */
-		if (pmd_downgrade && dax_is_zero_entry(entry))
+		if (dax_is_zero_entry(entry)) {
+			xas_pause(&xas);
+			xas_unlock_irq(&xas);
 			unmap_mapping_range(mapping,
 				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
-
-		err = radix_tree_preload(
-				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
-		if (err) {
-			if (pmd_downgrade)
-				put_locked_mapping_entry(mapping, index);
-			return ERR_PTR(err);
+			xas_lock_irq(&xas);
 		}
-		xa_lock_irq(&mapping->pages);
-
-		if (!entry) {
-			/*
-			 * We needed to drop the pages lock while calling
-			 * radix_tree_preload() and we didn't have an entry to
-			 * lock.  See if another thread inserted an entry at
-			 * our index during this time.
-			 */
-			entry = __radix_tree_lookup(&mapping->pages, index,
-					NULL, &slot);
-			if (entry) {
-				radix_tree_preload_end();
-				xa_unlock_irq(&mapping->pages);
-				goto restart;
-			}
-		}
-
-		if (pmd_downgrade) {
-			radix_tree_delete(&mapping->pages, index);
-			mapping->nrexceptional--;
-			dax_wake_entry(&xas, entry, true);
-		}
-
+		xas_store(&xas, NULL);
+		mapping->nrexceptional--;
+		dax_wake_entry(&xas, entry, true);
+	}
+	if (!entry || pmd_downgrade) {
 		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
-
-		err = __radix_tree_insert(&mapping->pages, index,
-				dax_radix_order(entry), entry);
-		radix_tree_preload_end();
-		if (err) {
-			xa_unlock_irq(&mapping->pages);
-			/*
-			 * Our insertion of a DAX entry failed, most likely
-			 * because we were inserting a PMD entry and it
-			 * collided with a PTE sized entry at a different
-			 * index in the PMD range.  We haven't inserted
-			 * anything into the radix tree and have no waiters to
-			 * wake.
-			 */
-			return ERR_PTR(err);
-		}
-		/* Good, we have inserted empty locked entry into the tree. */
-		mapping->nrexceptional++;
-		xa_unlock_irq(&mapping->pages);
-		return entry;
+		xas_store(&xas, entry);
+		if (!xas_error(&xas))
+			mapping->nrexceptional++;
+	} else {
+		entry = lock_slot(&xas);
 	}
-	entry = lock_slot(&xas);
  out_unlock:
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
+	if (xas_nomem(&xas, GFP_NOIO))
+		goto restart;
 	return entry;
 }
 
@@ -683,7 +637,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * worry about partial PMD writebacks.
 	 */
 	sector = dax_radix_sector(entry);
-	size = PAGE_SIZE << dax_radix_order(entry);
+	size = PAGE_SIZE << dax_entry_order(entry);
 
 	id = dax_read_lock();
 	ret = bdev_dax_pgoff(bdev, sector, size, &pgoff);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
