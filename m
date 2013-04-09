Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 134976B0037
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:14:41 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 02/18] jbd2: change jbd2_journal_invalidatepage to accept length
Date: Tue,  9 Apr 2013 11:14:11 +0200
Message-Id: <1365498867-27782-3-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>

invalidatepage now accepts range to invalidate and there are two file
system using jbd2 also implementing punch hole feature which can benefit
from this. We need to implement the same thing for jbd2 layer in order to
allow those file system take benefit of this functionality.

This commit adds length argument to the jbd2_journal_invalidatepage()
and updates all instances in ext4 and ocfs2.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/inode.c       |    3 ++-
 fs/jbd2/transaction.c |   24 +++++++++++++++++-------
 fs/ocfs2/aops.c       |    3 ++-
 include/linux/jbd2.h  |    2 +-
 4 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index f5bf189..69595f5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3000,7 +3000,8 @@ static int __ext4_journalled_invalidatepage(struct page *page,
 	if (offset == 0)
 		ClearPageChecked(page);
 
-	return jbd2_journal_invalidatepage(journal, page, offset);
+	return jbd2_journal_invalidatepage(journal, page, offset,
+					   PAGE_CACHE_SIZE - offset);
 }
 
 /* Wrapper for aops... */
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 325bc01..d334e17 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -2027,18 +2027,23 @@ zap_buffer_unlocked:
  * void jbd2_journal_invalidatepage()
  * @journal: journal to use for flush...
  * @page:    page to flush
- * @offset:  length of page to invalidate.
+ * @offset:  start of the range to invalidate
+ * @length:  length of the range to invalidate
  *
- * Reap page buffers containing data after offset in page. Can return -EBUSY
- * if buffers are part of the committing transaction and the page is straddling
- * i_size. Caller then has to wait for current commit and try again.
+ * Reap page buffers containing data after in the specified range in page.
+ * Can return -EBUSY if buffers are part of the committing transaction and
+ * the page is straddling i_size. Caller then has to wait for current commit
+ * and try again.
  */
 int jbd2_journal_invalidatepage(journal_t *journal,
 				struct page *page,
-				unsigned long offset)
+				unsigned int offset,
+				unsigned int length)
 {
 	struct buffer_head *head, *bh, *next;
+	unsigned int stop = offset + length;
 	unsigned int curr_off = 0;
+	int partial_page = (offset || length < PAGE_CACHE_SIZE);
 	int may_free = 1;
 	int ret = 0;
 
@@ -2047,6 +2052,8 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 	if (!page_has_buffers(page))
 		return 0;
 
+	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+
 	/* We will potentially be playing with lists other than just the
 	 * data lists (especially for journaled data mode), so be
 	 * cautious in our locking. */
@@ -2056,10 +2063,13 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 		unsigned int next_off = curr_off + bh->b_size;
 		next = bh->b_this_page;
 
+		if (next_off > stop)
+			return 0;
+
 		if (offset <= curr_off) {
 			/* This block is wholly outside the truncation point */
 			lock_buffer(bh);
-			ret = journal_unmap_buffer(journal, bh, offset > 0);
+			ret = journal_unmap_buffer(journal, bh, partial_page);
 			unlock_buffer(bh);
 			if (ret < 0)
 				return ret;
@@ -2070,7 +2080,7 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 
 	} while (bh != head);
 
-	if (!offset) {
+	if (!partial_page) {
 		if (may_free && try_to_free_buffers(page))
 			J_ASSERT(!page_has_buffers(page));
 	}
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index ecb86ca..7c47755 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -608,7 +608,8 @@ static void ocfs2_invalidatepage(struct page *page, unsigned int offset,
 {
 	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
 
-	jbd2_journal_invalidatepage(journal, page, offset);
+	jbd2_journal_invalidatepage(journal, page, offset,
+				    PAGE_CACHE_SIZE - offset);
 }
 
 static int ocfs2_releasepage(struct page *page, gfp_t wait)
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index f9fe889..8c34abd 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -1090,7 +1090,7 @@ extern int	 jbd2_journal_dirty_metadata (handle_t *, struct buffer_head *);
 extern int	 jbd2_journal_forget (handle_t *, struct buffer_head *);
 extern void	 journal_sync_buffer (struct buffer_head *);
 extern int	 jbd2_journal_invalidatepage(journal_t *,
-				struct page *, unsigned long);
+				struct page *, unsigned int, unsigned int);
 extern int	 jbd2_journal_try_to_free_buffers(journal_t *, struct page *, gfp_t);
 extern int	 jbd2_journal_stop(handle_t *);
 extern int	 jbd2_journal_flush (journal_t *);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
