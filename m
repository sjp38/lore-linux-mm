Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9FD6B02AB
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:25:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p190so8569783wmp.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:25:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u189si2844170wmg.133.2016.11.03.21.25.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 19/21] dax: Make cache flushing protected by entry lock
Date: Fri,  4 Nov 2016 05:25:15 +0100
Message-Id: <1478233517-3571-20-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently, flushing of caches for DAX mappings was ignoring entry lock.
So far this was ok (modulo a bug that a difference in entry lock could
cause cache flushing to be mistakenly skipped) but in the following
patches we will write-protect PTEs on cache flushing and clear dirty
tags. For that we will need more exclusion. So do cache flushing under
an entry lock. This allows us to remove one lock-unlock pair of
mapping->tree_lock as a bonus.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 61 +++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 39 insertions(+), 22 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index acba769152bf..167583a9a324 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -619,32 +619,50 @@ static int dax_writeback_one(struct block_device *bdev,
 		struct address_space *mapping, pgoff_t index, void *entry)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
-	struct radix_tree_node *node;
 	struct blk_dax_ctl dax;
-	void **slot;
+	void *entry2, **slot;
 	int ret = 0;
 
-	spin_lock_irq(&mapping->tree_lock);
 	/*
-	 * Regular page slots are stabilized by the page lock even
-	 * without the tree itself locked.  These unlocked entries
-	 * need verification under the tree lock.
+	 * A page got tagged dirty in DAX mapping? Something is seriously
+	 * wrong.
 	 */
-	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
-		goto unlock;
-	if (*slot != entry)
-		goto unlock;
-
-	/* another fsync thread may have already written back this entry */
-	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
-		goto unlock;
+	if (WARN_ON(!radix_tree_exceptional_entry(entry)))
+		return -EIO;
 
+	spin_lock_irq(&mapping->tree_lock);
+	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
+	/* Entry got punched out / reallocated? */
+	if (!entry2 || !radix_tree_exceptional_entry(entry2))
+		goto put_unlocked;
+	/*
+	 * Entry got reallocated elsewhere? No need to writeback. We have to
+	 * compare sectors as we must not bail out due to difference in lockbit
+	 * or entry type.
+	 */
+	if (dax_radix_sector(entry2) != dax_radix_sector(entry))
+		goto put_unlocked;
 	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
 				dax_is_zero_entry(entry))) {
 		ret = -EIO;
-		goto unlock;
+		goto put_unlocked;
 	}
 
+	/* Another fsync thread may have already written back this entry */
+	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
+		goto put_unlocked;
+	/* Lock the entry to serialize with page faults */
+	entry = lock_slot(mapping, slot);
+	/*
+	 * We can clear the tag now but we have to be careful so that concurrent
+	 * dax_writeback_one() calls for the same index cannot finish before we
+	 * actually flush the caches. This is achieved as the calls will look
+	 * at the entry only under tree_lock and once they do that they will
+	 * see the entry locked and wait for it to unlock.
+	 */
+	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
+	spin_unlock_irq(&mapping->tree_lock);
+
 	/*
 	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
 	 * in the middle of a PMD, the 'index' we are given will be aligned to
@@ -654,15 +672,16 @@ static int dax_writeback_one(struct block_device *bdev,
 	 */
 	dax.sector = dax_radix_sector(entry);
 	dax.size = PAGE_SIZE << dax_radix_order(entry);
-	spin_unlock_irq(&mapping->tree_lock);
 
 	/*
 	 * We cannot hold tree_lock while calling dax_map_atomic() because it
 	 * eventually calls cond_resched().
 	 */
 	ret = dax_map_atomic(bdev, &dax);
-	if (ret < 0)
+	if (ret < 0) {
+		put_locked_mapping_entry(mapping, index, entry);
 		return ret;
+	}
 
 	if (WARN_ON_ONCE(ret < dax.size)) {
 		ret = -EIO;
@@ -670,15 +689,13 @@ static int dax_writeback_one(struct block_device *bdev,
 	}
 
 	wb_cache_pmem(dax.addr, dax.size);
-
-	spin_lock_irq(&mapping->tree_lock);
-	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
-	spin_unlock_irq(&mapping->tree_lock);
  unmap:
 	dax_unmap_atomic(bdev, &dax);
+	put_locked_mapping_entry(mapping, index, entry);
 	return ret;
 
- unlock:
+ put_unlocked:
+	put_unlocked_mapping_entry(mapping, index, entry2);
 	spin_unlock_irq(&mapping->tree_lock);
 	return ret;
 }
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
