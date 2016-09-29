Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E73BE6B0263
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:49:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so179228718pfb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 15:49:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d86si16422436pfe.90.2016.09.29.15.49.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 15:49:40 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 06/12] dax: consistent variable naming for DAX entries
Date: Thu, 29 Sep 2016 16:49:24 -0600
Message-Id: <1475189370-31634-7-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

No functional change.

Consistently use the variable name 'entry' instead of 'ret' for DAX radix
tree entries.  This was already happening in most of the code, so update
get_unlocked_mapping_entry(), grab_mapping_entry() and
dax_unlock_mapping_entry().

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ac28cdf..baef586 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -357,7 +357,7 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
 static void *get_unlocked_mapping_entry(struct address_space *mapping,
 					pgoff_t index, void ***slotp)
 {
-	void *ret, **slot;
+	void *entry, **slot;
 	struct wait_exceptional_entry_queue ewait;
 	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
 
@@ -367,13 +367,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	ewait.key.index = index;
 
 	for (;;) {
-		ret = __radix_tree_lookup(&mapping->page_tree, index, NULL,
+		entry = __radix_tree_lookup(&mapping->page_tree, index, NULL,
 					  &slot);
-		if (!ret || !radix_tree_exceptional_entry(ret) ||
+		if (!entry || !radix_tree_exceptional_entry(entry) ||
 		    !slot_locked(mapping, slot)) {
 			if (slotp)
 				*slotp = slot;
-			return ret;
+			return entry;
 		}
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
@@ -396,13 +396,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
  */
 static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
-	void *ret, **slot;
+	void *entry, **slot;
 
 restart:
 	spin_lock_irq(&mapping->tree_lock);
-	ret = get_unlocked_mapping_entry(mapping, index, &slot);
+	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!ret) {
+	if (!entry) {
 		int err;
 
 		spin_unlock_irq(&mapping->tree_lock);
@@ -410,10 +410,10 @@ restart:
 				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
 		if (err)
 			return ERR_PTR(err);
-		ret = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
+		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
 			       RADIX_DAX_ENTRY_LOCK);
 		spin_lock_irq(&mapping->tree_lock);
-		err = radix_tree_insert(&mapping->page_tree, index, ret);
+		err = radix_tree_insert(&mapping->page_tree, index, entry);
 		radix_tree_preload_end();
 		if (err) {
 			spin_unlock_irq(&mapping->tree_lock);
@@ -425,11 +425,11 @@ restart:
 		/* Good, we have inserted empty locked entry into the tree. */
 		mapping->nrexceptional++;
 		spin_unlock_irq(&mapping->tree_lock);
-		return ret;
+		return entry;
 	}
 	/* Normal page in radix tree? */
-	if (!radix_tree_exceptional_entry(ret)) {
-		struct page *page = ret;
+	if (!radix_tree_exceptional_entry(entry)) {
+		struct page *page = entry;
 
 		get_page(page);
 		spin_unlock_irq(&mapping->tree_lock);
@@ -442,9 +442,9 @@ restart:
 		}
 		return page;
 	}
-	ret = lock_slot(mapping, slot);
+	entry = lock_slot(mapping, slot);
 	spin_unlock_irq(&mapping->tree_lock);
-	return ret;
+	return entry;
 }
 
 void dax_wake_mapping_entry_waiter(struct address_space *mapping,
@@ -469,11 +469,11 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 
 void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
-	void *ret, **slot;
+	void *entry, **slot;
 
 	spin_lock_irq(&mapping->tree_lock);
-	ret = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
-	if (WARN_ON_ONCE(!ret || !radix_tree_exceptional_entry(ret) ||
+	entry = __radix_tree_lookup(&mapping->page_tree, index, NULL, &slot);
+	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry) ||
 			 !slot_locked(mapping, slot))) {
 		spin_unlock_irq(&mapping->tree_lock);
 		return;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
