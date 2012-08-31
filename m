Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1EF3B6B0075
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:15 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 05/15 v2] ocfs2: implement invalidatepage_range aop
Date: Fri, 31 Aug 2012 18:21:41 -0400
Message-Id: <1346451711-1931-6-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>, ocfs2-devel@oss.oracle.com

mm now supports invalidatepage_range address space operation which is
useful to allow truncating page range which is not aligned to the end of
the page. This will help in punch hole implementation once
truncate_inode_pages_range() is modify to allow this as well.

With this commit ocfs2 now register only invalidatepage_range.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: ocfs2-devel@oss.oracle.com
---
 fs/ocfs2/aops.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index 6577432..a101232 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -603,11 +603,12 @@ static void ocfs2_dio_end_io(struct kiocb *iocb,
  * from ext3.  PageChecked() bits have been removed as OCFS2 does not
  * do journalled data.
  */
-static void ocfs2_invalidatepage(struct page *page, unsigned long offset)
+static void ocfs2_invalidatepage_range(struct page *page, unsigned int offset,
+				       unsigned int length)
 {
 	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
 
-	jbd2_journal_invalidatepage(journal, page, offset);
+	jbd2_journal_invalidatepage_range(journal, page, offset, length);
 }
 
 static int ocfs2_releasepage(struct page *page, gfp_t wait)
@@ -2091,7 +2092,7 @@ const struct address_space_operations ocfs2_aops = {
 	.write_end		= ocfs2_write_end,
 	.bmap			= ocfs2_bmap,
 	.direct_IO		= ocfs2_direct_IO,
-	.invalidatepage		= ocfs2_invalidatepage,
+	.invalidatepage_range	= ocfs2_invalidatepage_range,
 	.releasepage		= ocfs2_releasepage,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate	= block_is_partially_uptodate,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
