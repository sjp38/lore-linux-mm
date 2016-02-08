Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 78A04830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:53:35 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id x4so84301174lbm.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:53:35 -0800 (PST)
Received: from relay.sw.ru (mailhub.sw.ru. [195.214.232.25])
        by mx.google.com with ESMTPS id u7si16164737lbw.3.2016.02.08.05.53.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:53:33 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 2/2] dax: fix race dax_fault write vs read
Date: Mon,  8 Feb 2016 17:53:18 +0400
Message-Id: <1454939598-16238-2-git-send-email-dmonakhov@openvz.org>
In-Reply-To: <1454939598-16238-1-git-send-email-dmonakhov@openvz.org>
References: <87bn7rwim2.fsf@openvz.org>
 <1454939598-16238-1-git-send-email-dmonakhov@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com, Dmitry Monakhov <dmonakhov@openvz.org>

Two read/write tasks does fault inside file-hole
task_1(writer)                  task_2(reader)
__dax_fault(write)
  ->lock_page_or_retry
  ->delete_from_page_cache()    __dax_fault(read)
						->dax_load_hole
                                  ->find_or_create_page()
                                    ->new page in mapping->radix_tree
  ->dax_insert_mapping
     ->dax_radix_entry => collision

Let's move radix_tree update to dax_radix_entry_replace() where
page deletion and dax entry insertion will be protected by ->tree_lock

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 fs/dax.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 89bb1f8..0294fc9 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -424,6 +424,31 @@ static int dax_radix_entry_insert(struct address_space *mapping, pgoff_t index,
 	error =__dax_radix_entry_insert(mapping, index, sector, pmd_entry, dirty);
 	spin_unlock_irq(&mapping->tree_lock);
 	return error;
+
+}
+
+static int dax_radix_entry_replace(struct address_space *mapping, pgoff_t index,
+				   sector_t sector, bool pmd_entry, bool dirty,
+				   struct page* old_page)
+{
+	int error;
+
+	BUG_ON(old_page && !PageLocked(old_page));
+	if (dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	spin_lock_irq(&mapping->tree_lock);
+	if (old_page)
+		__delete_from_page_cache(old_page, NULL);
+	error =__dax_radix_entry_insert(mapping, index, sector, pmd_entry, dirty);
+	spin_unlock_irq(&mapping->tree_lock);
+	if (old_page) {
+		if (mapping->a_ops->freepage)
+			mapping->a_ops->freepage(old_page);
+		page_cache_release(old_page);
+	}
+	return error;
+
 }
 
 static int dax_writeback_one(struct block_device *bdev,
@@ -586,7 +611,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = dax_radix_entry_insert(mapping, vmf->pgoff, dax.sector, false,
+	error = dax_radix_entry_replace(mapping, vmf->pgoff, dax.sector, false,
 				vmf->flags & FAULT_FLAG_WRITE, vmf->page);
 	if (error)
 		goto out;
@@ -711,14 +736,16 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		page = find_lock_page(mapping, vmf->pgoff);
 
 	if (page) {
+		vmf->page = page;
 		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
 							PAGE_CACHE_SIZE, 0);
-		delete_from_page_cache(page);
+	}
+	error = dax_insert_mapping(inode, &bh, vma, vmf);
+	if (page) {
 		unlock_page(page);
 		page_cache_release(page);
-		page = NULL;
+		vmf->page = page = NULL;
 	}
-
 	/*
 	 * If we successfully insert the new mapping over an unwritten extent,
 	 * we need to ensure we convert the unwritten extent. If there is an
@@ -729,14 +756,12 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * indicate what the callback should do via the uptodate variable, same
 	 * as for normal BH based IO completions.
 	 */
-	error = dax_insert_mapping(inode, &bh, vma, vmf);
 	if (buffer_unwritten(&bh)) {
 		if (complete_unwritten)
 			complete_unwritten(&bh, !error);
 		else
 			WARN_ON_ONCE(!(vmf->flags & FAULT_FLAG_WRITE));
 	}
-
  out:
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM | major;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
