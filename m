Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 906C28296C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so6410460pfg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b64si10109475pfa.51.2016.08.12.11.38.51
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 30/41] ext4: make ext4_writepage() work on huge pages
Date: Fri, 12 Aug 2016 21:38:13 +0300
Message-Id: <1471027104-115213-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Change ext4_writepage() and underlying ext4_bio_write_page().

It basically removes assumption on page size, infer it from struct page
instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c   | 10 +++++-----
 fs/ext4/page-io.c | 11 +++++++++--
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3131747199e1..f585f9160a96 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2020,10 +2020,10 @@ static int ext4_writepage(struct page *page,
 
 	trace_ext4_writepage(page);
 	size = i_size_read(inode);
-	if (page->index == size >> PAGE_SHIFT)
-		len = size & ~PAGE_MASK;
-	else
-		len = PAGE_SIZE;
+
+	len = hpage_size(page);
+	if (page->index + hpage_nr_pages(page) - 1 == size >> PAGE_SHIFT)
+			len = size & ~hpage_mask(page);
 
 	page_bufs = page_buffers(page);
 	/*
@@ -2047,7 +2047,7 @@ static int ext4_writepage(struct page *page,
 				   ext4_bh_delay_or_unwritten)) {
 		redirty_page_for_writepage(wbc, page);
 		if ((current->flags & PF_MEMALLOC) ||
-		    (inode->i_sb->s_blocksize == PAGE_SIZE)) {
+		    (inode->i_sb->s_blocksize == hpage_size(page))) {
 			/*
 			 * For memory cleaning there's no point in writing only
 			 * some buffers. So just bail out. Warn if we came here
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index a6132a730967..952957ee48b7 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -415,6 +415,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageWriteback(page));
+	BUG_ON(PageTail(page));
 
 	if (keep_towrite)
 		set_page_writeback_keepwrite(page);
@@ -431,8 +432,14 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	 * the page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	if (len < PAGE_SIZE)
-		zero_user_segment(page, len, PAGE_SIZE);
+	if (len < hpage_size(page)) {
+		page += len / PAGE_SIZE;
+		if (len % PAGE_SIZE)
+			zero_user_segment(page, len % PAGE_SIZE, PAGE_SIZE);
+		while (page + 1 == compound_head(page))
+			clear_highpage(++page);
+		page = compound_head(page);
+	}
 	/*
 	 * In the first loop we prepare and mark buffers to submit. We have to
 	 * mark all buffers in the page before submitting so that
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
