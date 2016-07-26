Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37C566B0275
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:36:57 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so359937467pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:36:57 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o78si36056294pfi.291.2016.07.25.17.36.34
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 29/33] ext4: handle huge pages in ext4_da_write_end()
Date: Tue, 26 Jul 2016 03:35:31 +0300
Message-Id: <1469493335-3622-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Call ext4_da_should_update_i_disksize() for head page with offset
relative to head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3df2cea763ce..744bba046268 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2998,7 +2998,6 @@ static int ext4_da_write_end(struct file *file,
 	int ret = 0, ret2;
 	handle_t *handle = ext4_journal_current_handle();
 	loff_t new_i_size;
-	unsigned long start, end;
 	int write_mode = (int)(unsigned long)fsdata;
 
 	if (write_mode == FALL_BACK_TO_NONDELALLOC)
@@ -3006,8 +3005,6 @@ static int ext4_da_write_end(struct file *file,
 				      len, copied, page, fsdata);
 
 	trace_ext4_da_write_end(inode, pos, len, copied);
-	start = pos & (PAGE_SIZE - 1);
-	end = start + copied - 1;
 
 	/*
 	 * generic_write_end() will run mark_inode_dirty() if i_size
@@ -3016,8 +3013,10 @@ static int ext4_da_write_end(struct file *file,
 	 */
 	new_i_size = pos + copied;
 	if (copied && new_i_size > EXT4_I(inode)->i_disksize) {
+		struct page *head = compound_head(page);
+		unsigned long end = (pos & ~hpage_mask(head)) + copied - 1;
 		if (ext4_has_inline_data(inode) ||
-		    ext4_da_should_update_i_disksize(page, end)) {
+		    ext4_da_should_update_i_disksize(head, end)) {
 			ext4_update_i_disksize(inode, new_i_size);
 			/* We need to mark inode dirty even if
 			 * new_i_size is less that inode->i_size
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
