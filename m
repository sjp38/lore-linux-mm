Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 35DA16B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:51:09 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4V0p4nt018713
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:51:05 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz5.hot.corp.google.com with ESMTP id p4V0p22N029034
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:51:03 -0700
Received: by pzk9 with SMTP id 9so1784552pzk.19
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:51:02 -0700 (PDT)
Date: Mon, 30 May 2011 17:51:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 11/14] mm: tidy vmtruncate_range and related functions
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301749570.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Use consistent variable names in truncate_pagecache(), truncate_setsize(),
vmtruncate() and vmtruncate_range().

unmap_mapping_range() and vmtruncate_range() have mismatched interfaces:
don't change either, but make the vmtruncates more precise about what
they expect unmap_mapping_range() to do.

vmtruncate_range() is currently called only with page-aligned start and
end+1: can handle unaligned start, but unaligned end+1 would hit BUG_ON
in truncate_inode_pages_range() (lacks partial clearing of the end page).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/truncate.c |   31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

--- linux.orig/mm/truncate.c	2011-05-30 14:15:29.000000000 -0700
+++ linux/mm/truncate.c	2011-05-30 14:51:03.553127951 -0700
@@ -528,8 +528,8 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages
 /**
  * truncate_pagecache - unmap and remove pagecache that has been truncated
  * @inode: inode
- * @old: old file offset
- * @new: new file offset
+ * @oldsize: old file size
+ * @newsize: new file size
  *
  * inode's new i_size must already be written before truncate_pagecache
  * is called.
@@ -541,9 +541,10 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages
  * situations such as writepage being called for a page that has already
  * had its underlying blocks deallocated.
  */
-void truncate_pagecache(struct inode *inode, loff_t old, loff_t new)
+void truncate_pagecache(struct inode *inode, loff_t oldsize, loff_t newsize)
 {
 	struct address_space *mapping = inode->i_mapping;
+	loff_t holebegin = round_up(newsize, PAGE_SIZE);
 
 	/*
 	 * unmap_mapping_range is called twice, first simply for
@@ -554,9 +555,9 @@ void truncate_pagecache(struct inode *in
 	 * truncate_inode_pages finishes, hence the second
 	 * unmap_mapping_range call must be made for correctness.
 	 */
-	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
-	truncate_inode_pages(mapping, new);
-	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
+	unmap_mapping_range(mapping, holebegin, 0, 1);
+	truncate_inode_pages(mapping, newsize);
+	unmap_mapping_range(mapping, holebegin, 0, 1);
 }
 EXPORT_SYMBOL(truncate_pagecache);
 
@@ -586,29 +587,31 @@ EXPORT_SYMBOL(truncate_setsize);
 /**
  * vmtruncate - unmap mappings "freed" by truncate() syscall
  * @inode: inode of the file used
- * @offset: file offset to start truncating
+ * @newsize: file offset to start truncating
  *
  * This function is deprecated and truncate_setsize or truncate_pagecache
  * should be used instead, together with filesystem specific block truncation.
  */
-int vmtruncate(struct inode *inode, loff_t offset)
+int vmtruncate(struct inode *inode, loff_t newsize)
 {
 	int error;
 
-	error = inode_newsize_ok(inode, offset);
+	error = inode_newsize_ok(inode, newsize);
 	if (error)
 		return error;
 
-	truncate_setsize(inode, offset);
+	truncate_setsize(inode, newsize);
 	if (inode->i_op->truncate)
 		inode->i_op->truncate(inode);
 	return 0;
 }
 EXPORT_SYMBOL(vmtruncate);
 
-int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
+int vmtruncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	struct address_space *mapping = inode->i_mapping;
+	loff_t holebegin = round_up(lstart, PAGE_SIZE);
+	loff_t holelen = 1 + lend - holebegin;
 
 	/*
 	 * If the underlying filesystem is not going to provide
@@ -620,10 +623,10 @@ int vmtruncate_range(struct inode *inode
 
 	mutex_lock(&inode->i_mutex);
 	down_write(&inode->i_alloc_sem);
-	unmap_mapping_range(mapping, offset, (end - offset), 1);
-	inode->i_op->truncate_range(inode, offset, end);
+	unmap_mapping_range(mapping, holebegin, holelen, 1);
+	inode->i_op->truncate_range(inode, lstart, lend);
 	/* unmap again to remove racily COWed private pages */
-	unmap_mapping_range(mapping, offset, (end - offset), 1);
+	unmap_mapping_range(mapping, holebegin, holelen, 1);
 	up_write(&inode->i_alloc_sem);
 	mutex_unlock(&inode->i_mutex);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
