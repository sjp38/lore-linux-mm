Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06AF86B0260
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:07:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so280710055pfx.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:07:08 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hm6si5740071pac.254.2016.08.23.15.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 15:04:34 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 6/9] dax: consistent variable naming for DAX entries
Date: Tue, 23 Aug 2016 16:04:16 -0600
Message-Id: <20160823220419.11717-7-ross.zwisler@linux.intel.com>
In-Reply-To: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

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
index 3066a9b..0e3f462 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -355,7 +355,7 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
 static void *get_unlocked_mapping_entry(struct address_space *mapping,
 					pgoff_t index, void ***slotp)
 {
-	void *ret, **slot;
+	void *entry, **slot;
 	struct wait_exceptional_entry_queue ewait;
 	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
 
@@ -365,13 +365,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
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
@@ -394,13 +394,13 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
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
@@ -408,10 +408,10 @@ restart:
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
@@ -423,11 +423,11 @@ restart:
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
@@ -440,9 +440,9 @@ restart:
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
@@ -467,11 +467,11 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 
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
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
