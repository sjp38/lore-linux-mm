Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C79886B0069
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:13 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 01/15 v2] mm: add invalidatepage_range address space operation
Date: Fri, 31 Aug 2012 18:21:37 -0400
Message-Id: <1346451711-1931-2-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Currently there is no way to truncate partial page where the end
truncate point is not at the end of the page. This is because it was not
needed and the functionality was enough for file system truncate
operation to work properly. However more file systems now support punch
hole feature and it can benefit from mm supporting truncating page just
up to the certain point.

Specifically, with this functionality truncate_inode_pages_range() can
be changed so it supports truncating partial page at the end of the
range (currently it will BUG_ON() if 'end' is not at the end of the
page).

This commit add new address space operation invalidatepage_range which
allows specifying length of bytes to invalidate, rather than assuming
truncate to the end of the page. It also introduce
block_invalidatepage_range() and do_invalidatepage)range() functions for
exactly the same reason.

The caller does not have to implement both aops (invalidatepage and
invalidatepage_range) and the latter is preferred. The old method will be
used only if invalidatepage_range is not implemented by the caller.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/Locking |   17 ++++++++++++---
 Documentation/filesystems/vfs.txt |   17 +++++++++++++-
 fs/buffer.c                       |   30 ++++++++++++++++++++++++++-
 include/linux/buffer_head.h       |    2 +
 include/linux/fs.h                |    2 +
 include/linux/mm.h                |    2 +
 mm/truncate.c                     |   40 +++++++++++++++++++++++++++++++++---
 7 files changed, 99 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index e540a24..c137fce 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -193,7 +193,9 @@ prototypes:
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 	sector_t (*bmap)(struct address_space *, sector_t);
-	int (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage_range) (struct page *, unsigned int,
+				      unsigned int);
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
@@ -221,6 +223,7 @@ write_begin:		locks the page		yes
 write_end:		yes, unlocks		yes
 bmap:
 invalidatepage:		yes
+invalidatepage_range:	yes
 releasepage:		yes
 freepage:		yes
 direct_IO:
@@ -314,9 +317,15 @@ filesystems and by the swapper. The latter will eventually go away.  Please,
 keep it that way and don't breed new callers.
 
 	->invalidatepage() is called when the filesystem must attempt to drop
-some or all of the buffers from the page when it is being truncated.  It
-returns zero on success.  If ->invalidatepage is zero, the kernel uses
-block_invalidatepage() instead.
+some or all of the buffers from the page when it is being truncated. If
+->invalidatepage is zero, the kernel uses block_invalidatepage_range()
+instead.
+
+	->invalidatepage_range() serves the same purpose as ->invalidatepage()
+except that range within the page to invalidate can be specified. This should
+be preferred operation over the ->invalidatepage(). If ->invalidatepage_range()
+is zero, the kernel tries to use ->invalidatepage(), if it is zero as well the
+kernel uses block_invalidatepage_range() instead.
 
 	->releasepage() is called when the kernel is about to try to drop the
 buffers from the page in preparation for freeing it.  It returns zero to
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 2ee133e..c7d7da8 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -560,7 +560,7 @@ struct address_space_operations
 -------------------------------
 
 This describes how the VFS can manipulate mapping of a file to page cache in
-your filesystem. As of kernel 2.6.22, the following members are defined:
+your filesystem. The following members are defined:
 
 struct address_space_operations {
 	int (*writepage)(struct page *page, struct writeback_control *wbc);
@@ -577,7 +577,9 @@ struct address_space_operations {
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 	sector_t (*bmap)(struct address_space *, sector_t);
-	int (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage_range) (struct page *, unsigned int,
+				      unsigned int);
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
@@ -705,6 +707,17 @@ struct address_space_operations {
         calling the ->releasepage function, but in this case the
         release MUST succeed.
 
+  invalidatepage_range:  If a page has PagePrivate set, then
+	invalidatepage_range will be called when part or all of the page
+	is to be removed from the address space.  This generally corresponds
+	to either a truncation, punch hole or a complete invalidateion of
+	the address space. Any private data associated with the page should
+	be updated to reflect this.  If offset is 0 and length is
+	PAGE_CACHE_SIZE, then the private data should be released, because
+	the page must be able to be completely discarded.  This may be done
+	by calling the ->releasepage function, but in this case the release
+	MUST succeed.
+
   releasepage: releasepage is called on PagePrivate pages to indicate
         that the page should be freed if possible.  ->releasepage
         should remove any private data from the page and clear the
diff --git a/fs/buffer.c b/fs/buffer.c
index 58e2e7b..180c109 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1451,13 +1451,34 @@ static void discard_buffer(struct buffer_head * bh)
  */
 void block_invalidatepage(struct page *page, unsigned long offset)
 {
+	block_invalidatepage_range(page, offset, PAGE_CACHE_SIZE - offset);
+}
+EXPORT_SYMBOL(block_invalidatepage);
+
+/**
+ * block_invalidatepage_range() - invalidate all of a buffers within the
+ * 				  specified range of the buffer-backed page.
+ *
+ * @page: the page which is affected
+ * @offset: start of the range
+ * @length: length of the range
+ */
+void block_invalidatepage_range(struct page *page, unsigned int offset,
+				unsigned int length)
+{
 	struct buffer_head *head, *bh, *next;
 	unsigned int curr_off = 0;
+	unsigned int stop = length + offset;
 
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
 		goto out;
 
+	/*
+	 * Check for overflow
+	 */
+	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+
 	head = page_buffers(page);
 	bh = head;
 	do {
@@ -1465,6 +1486,12 @@ void block_invalidatepage(struct page *page, unsigned long offset)
 		next = bh->b_this_page;
 
 		/*
+		 * Are we still fully in range ?
+		 */
+		if (next_off > stop)
+			goto out;
+
+		/*
 		 * is this block fully invalidated?
 		 */
 		if (offset <= curr_off)
@@ -1483,7 +1510,8 @@ void block_invalidatepage(struct page *page, unsigned long offset)
 out:
 	return;
 }
-EXPORT_SYMBOL(block_invalidatepage);
+EXPORT_SYMBOL(block_invalidatepage_range);
+
 
 /*
  * We attach and possibly dirty the buffers atomically wrt
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 458f497..2e7f5ab 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -194,6 +194,8 @@ extern int buffer_heads_over_limit;
  * address_spaces.
  */
 void block_invalidatepage(struct page *page, unsigned long offset);
+void block_invalidatepage_range(struct page *page, unsigned int offset,
+				unsigned int length);
 int block_write_full_page(struct page *page, get_block_t *get_block,
 				struct writeback_control *wbc);
 int block_write_full_page_endio(struct page *page, get_block_t *get_block,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index aa11047..d80de28 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -626,6 +626,8 @@ struct address_space_operations {
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
+	void (*invalidatepage_range) (struct page *, unsigned int,
+				      unsigned int);
 	int (*releasepage) (struct page *, gfp_t);
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..9f616fd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1027,6 +1027,8 @@ struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
 extern void do_invalidatepage(struct page *page, unsigned long offset);
+extern void do_invalidatepage_range(struct page *page, unsigned int offset,
+				    unsigned int length);
 
 int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 75801ac..b22efdf 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -39,14 +39,46 @@
  */
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
+	do_invalidatepage_range(page, offset, PAGE_CACHE_SIZE - offset);
+}
+
+
+/**
+ * do_invalidatepage_range - invalidate range of the page
+ *
+ * @page: the page which is affected
+ * @offset: start of the range to invalidate
+ * @length: length of the range to invalidate
+  */
+void do_invalidatepage_range(struct page *page, unsigned int offset,
+			     unsigned int length)
+{
+	void (*invalidatepage_range)(struct page *, unsigned int,
+				     unsigned int);
 	void (*invalidatepage)(struct page *, unsigned long);
+
+	/*
+	 * Try invalidatepage_range first
+	 */
+	invalidatepage_range = page->mapping->a_ops->invalidatepage_range;
+	if (invalidatepage_range) {
+		(*invalidatepage_range)(page, offset, length);
+		return;
+	}
+
+	/*
+	 * When only invalidatepage is registered length + offset must be
+	 * PAGE_CACHE_SIZE
+	 */
 	invalidatepage = page->mapping->a_ops->invalidatepage;
+	if (invalidatepage) {
+		BUG_ON(length + offset != PAGE_CACHE_SIZE);
+		(*invalidatepage)(page, offset);
+	}
 #ifdef CONFIG_BLOCK
-	if (!invalidatepage)
-		invalidatepage = block_invalidatepage;
+	if (!invalidatepage_range && !invalidatepage)
+		block_invalidatepage_range(page, offset, length);
 #endif
-	if (invalidatepage)
-		(*invalidatepage)(page, offset);
 }
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
