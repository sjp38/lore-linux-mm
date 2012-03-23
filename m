Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6FF256B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 16:47:08 -0400 (EDT)
Received: by dakh32 with SMTP id h32so28677dak.9
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 13:47:07 -0700 (PDT)
Date: Fri, 23 Mar 2012 13:46:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm for fs: add truncate_pagecache_range
Message-ID: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Holepunching filesystems ext4 and xfs are using truncate_inode_pages_range
but forgetting to unmap pages first (ocfs2 remembers).  This is not really
a bug, since races already require truncate_inode_page() to handle that
case once the page is locked; but it can be very inefficient if the file
being punched happens to be mapped into many vmas.

Provide a drop-in replacement truncate_pagecache_range() which does the
unmapping pass first, handling the awkward mismatch between arguments
to truncate_inode_pages_range() and arguments to unmap_mapping_range().

Note that holepunching does not unmap privately COWed pages in the range:
POSIX requires that we do so when truncating, but it's hard to justify,
difficult to implement without an i_size cutoff, and no filesystem is
attempting to implement it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I do have patches for ext4, ocfs2 and xfs to use this, but they're too
late now for v3.4.  However, it would be helpful if this function could
go ahead into v3.4, so filesystems can convert to it at leisure afterwards.

 include/linux/mm.h |    2 +-
 mm/truncate.c      |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 1 deletion(-)

--- linux.git/include/linux/mm.h	2012-03-23 10:19:53.364051630 -0700
+++ linux/include/linux/mm.h	2012-03-23 10:40:06.036080706 -0700
@@ -953,7 +953,7 @@ extern void truncate_pagecache(struct in
 extern void truncate_setsize(struct inode *inode, loff_t newsize);
 extern int vmtruncate(struct inode *inode, loff_t offset);
 extern int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end);
-
+void truncate_pagecache_range(struct inode *inode, loff_t offset, loff_t end);
 int truncate_inode_page(struct address_space *mapping, struct page *page);
 int generic_error_remove_page(struct address_space *mapping, struct page *page);
 
--- linux.git/mm/truncate.c	2012-03-23 10:19:53.588051635 -0700
+++ linux/mm/truncate.c	2012-03-23 10:40:06.036080706 -0700
@@ -626,3 +626,43 @@ int vmtruncate_range(struct inode *inode
 
 	return 0;
 }
+
+/**
+ * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
+ * @inode: inode
+ * @lstart: offset of beginning of hole
+ * @lend: offset of last byte of hole
+ *
+ * This function should typically be called before the filesystem
+ * releases resources associated with the freed range (eg. deallocates
+ * blocks). This way, pagecache will always stay logically coherent
+ * with on-disk format, and the filesystem would not have to deal with
+ * situations such as writepage being called for a page that has already
+ * had its underlying blocks deallocated.
+ */
+void truncate_pagecache_range(struct inode *inode, loff_t lstart, loff_t lend)
+{
+	struct address_space *mapping = inode->i_mapping;
+	loff_t unmap_start = round_up(lstart, PAGE_SIZE);
+	loff_t unmap_end = round_down(1 + lend, PAGE_SIZE) - 1;
+	/*
+	 * This rounding is currently just for example: unmap_mapping_range
+	 * expands its hole outwards, whereas we want it to contract the hole
+	 * inwards.  However, existing callers of truncate_pagecache_range are
+	 * doing their own page rounding first; and truncate_inode_pages_range
+	 * currently BUGs if lend is not pagealigned-1 (it handles partial
+	 * page at start of hole, but not partial page at end of hole).  Note
+	 * unmap_mapping_range allows holelen 0 for all, and we allow lend -1.
+	 */
+
+	/*
+	 * Unlike in truncate_pagecache, unmap_mapping_range is called only
+	 * once (before truncating pagecache), and without "even_cows" flag:
+	 * hole-punching should not remove private COWed pages from the hole.
+	 */
+	if ((u64)unmap_end > (u64)unmap_start)
+		unmap_mapping_range(mapping, unmap_start,
+				    1 + unmap_end - unmap_start, 0);
+	truncate_inode_pages_range(mapping, lstart, lend);
+}
+EXPORT_SYMBOL(truncate_pagecache_range);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
