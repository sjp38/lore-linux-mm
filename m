Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F02C96B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:06:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r63so8224931pfb.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:06:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r2si5515156pgo.574.2017.07.24.10.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 10:06:22 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 2/5] dax: relocate some dax functions
Date: Mon, 24 Jul 2017 11:06:13 -0600
Message-Id: <20170724170616.25810-3-ross.zwisler@linux.intel.com>
In-Reply-To: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
References: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

dax_load_hole() will soon need to call dax_insert_mapping_entry(), so it
needs to be moved lower in dax.c so the definition exists.

dax_wake_mapping_entry_waiter() will soon be removed from dax.h and be made
static to dax.c, so we need to move its definition above all its callers.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 138 +++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 69 insertions(+), 69 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 306c2b6..197067f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -121,6 +121,31 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
 }
 
 /*
+ * We do not necessarily hold the mapping->tree_lock when we call this
+ * function so it is possible that 'entry' is no longer a valid item in the
+ * radix tree.  This is okay because all we really need to do is to find the
+ * correct waitqueue where tasks might be waiting for that old 'entry' and
+ * wake them.
+ */
+void dax_wake_mapping_entry_waiter(struct address_space *mapping,
+		pgoff_t index, void *entry, bool wake_all)
+{
+	struct exceptional_entry_key key;
+	wait_queue_head_t *wq;
+
+	wq = dax_entry_waitqueue(mapping, index, entry, &key);
+
+	/*
+	 * Checking for locked entry and prepare_to_wait_exclusive() happens
+	 * under mapping->tree_lock, ditto for entry handling in our callers.
+	 * So at this point all tasks that could have seen our entry locked
+	 * must be in the waitqueue and the following check will see them.
+	 */
+	if (waitqueue_active(wq))
+		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
+}
+
+/*
  * Check whether the given slot is locked. The function must be called with
  * mapping->tree_lock held
  */
@@ -392,31 +417,6 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	return entry;
 }
 
-/*
- * We do not necessarily hold the mapping->tree_lock when we call this
- * function so it is possible that 'entry' is no longer a valid item in the
- * radix tree.  This is okay because all we really need to do is to find the
- * correct waitqueue where tasks might be waiting for that old 'entry' and
- * wake them.
- */
-void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-		pgoff_t index, void *entry, bool wake_all)
-{
-	struct exceptional_entry_key key;
-	wait_queue_head_t *wq;
-
-	wq = dax_entry_waitqueue(mapping, index, entry, &key);
-
-	/*
-	 * Checking for locked entry and prepare_to_wait_exclusive() happens
-	 * under mapping->tree_lock, ditto for entry handling in our callers.
-	 * So at this point all tasks that could have seen our entry locked
-	 * must be in the waitqueue and the following check will see them.
-	 */
-	if (waitqueue_active(wq))
-		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
-}
-
 static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
@@ -468,50 +468,6 @@ int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 	return __dax_invalidate_mapping_entry(mapping, index, false);
 }
 
-/*
- * The user has performed a load from a hole in the file.  Allocating
- * a new page in the file would cause excessive storage usage for
- * workloads with sparse files.  We allocate a page cache page instead.
- * We'll kick it out of the page cache if it's ever written to,
- * otherwise it will simply fall out of the page cache under memory
- * pressure without ever having been dirtied.
- */
-static int dax_load_hole(struct address_space *mapping, void **entry,
-			 struct vm_fault *vmf)
-{
-	struct inode *inode = mapping->host;
-	struct page *page;
-	int ret;
-
-	/* Hole page already exists? Return it...  */
-	if (!radix_tree_exceptional_entry(*entry)) {
-		page = *entry;
-		goto finish_fault;
-	}
-
-	/* This will replace locked radix tree entry with a hole page */
-	page = find_or_create_page(mapping, vmf->pgoff,
-				   vmf->gfp_mask | __GFP_ZERO);
-	if (!page) {
-		ret = VM_FAULT_OOM;
-		goto out;
-	}
-
-finish_fault:
-	vmf->page = page;
-	ret = finish_fault(vmf);
-	vmf->page = NULL;
-	*entry = page;
-	if (!ret) {
-		/* Grab reference for PTE that is now referencing the page */
-		get_page(page);
-		ret = VM_FAULT_NOPAGE;
-	}
-out:
-	trace_dax_load_hole(inode, vmf, ret);
-	return ret;
-}
-
 static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
 		sector_t sector, size_t size, struct page *to,
 		unsigned long vaddr)
@@ -938,6 +894,50 @@ int dax_pfn_mkwrite(struct vm_fault *vmf)
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
 
+/*
+ * The user has performed a load from a hole in the file.  Allocating
+ * a new page in the file would cause excessive storage usage for
+ * workloads with sparse files.  We allocate a page cache page instead.
+ * We'll kick it out of the page cache if it's ever written to,
+ * otherwise it will simply fall out of the page cache under memory
+ * pressure without ever having been dirtied.
+ */
+static int dax_load_hole(struct address_space *mapping, void **entry,
+			 struct vm_fault *vmf)
+{
+	struct inode *inode = mapping->host;
+	struct page *page;
+	int ret;
+
+	/* Hole page already exists? Return it...  */
+	if (!radix_tree_exceptional_entry(*entry)) {
+		page = *entry;
+		goto finish_fault;
+	}
+
+	/* This will replace locked radix tree entry with a hole page */
+	page = find_or_create_page(mapping, vmf->pgoff,
+				   vmf->gfp_mask | __GFP_ZERO);
+	if (!page) {
+		ret = VM_FAULT_OOM;
+		goto out;
+	}
+
+finish_fault:
+	vmf->page = page;
+	ret = finish_fault(vmf);
+	vmf->page = NULL;
+	*entry = page;
+	if (!ret) {
+		/* Grab reference for PTE that is now referencing the page */
+		get_page(page);
+		ret = VM_FAULT_NOPAGE;
+	}
+out:
+	trace_dax_load_hole(inode, vmf, ret);
+	return ret;
+}
+
 static bool dax_range_is_aligned(struct block_device *bdev,
 				 unsigned int offset, unsigned int length)
 {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
