Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A200A6B0280
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so306638354pfa.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:52 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y184si1210362pfg.180.2017.01.26.03.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 29/37] ext4: handle huge pages in ext4_da_write_end()
Date: Thu, 26 Jan 2017 14:58:11 +0300
Message-Id: <20170126115819.58875-30-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Call ext4_da_should_update_i_disksize() for head page with offset
relative to head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/inode.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3eae2d058fd0..bdd62dcaa0b2 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3019,7 +3019,6 @@ static int ext4_da_write_end(struct file *file,
 	int ret = 0, ret2;
 	handle_t *handle = ext4_journal_current_handle();
 	loff_t new_i_size;
-	unsigned long start, end;
 	int write_mode = (int)(unsigned long)fsdata;
 
 	if (write_mode == FALL_BACK_TO_NONDELALLOC)
@@ -3027,8 +3026,6 @@ static int ext4_da_write_end(struct file *file,
 				      len, copied, page, fsdata);
 
 	trace_ext4_da_write_end(inode, pos, len, copied);
-	start = pos & (PAGE_SIZE - 1);
-	end = start + copied - 1;
 
 	/*
 	 * generic_write_end() will run mark_inode_dirty() if i_size
@@ -3037,8 +3034,10 @@ static int ext4_da_write_end(struct file *file,
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
