Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8D686B0266
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:36:05 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id q8so124164242lfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:36:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si776470wmk.45.2016.04.18.14.35.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:52 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/18] dax: Remove pointless writeback from dax_do_io()
Date: Mon, 18 Apr 2016 23:35:33 +0200
Message-Id: <1461015341-20153-11-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

dax_do_io() is calling filemap_write_and_wait() if DIO_LOCKING flags is
set. Presumably this was copied over from direct IO code. However DAX
inodes have no pagecache pages to write so the call is pointless. Remove
it.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 7c0036dd1570..237581441bc1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -268,15 +268,8 @@ ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
 
-	if ((flags & DIO_LOCKING) && iov_iter_rw(iter) == READ) {
-		struct address_space *mapping = inode->i_mapping;
+	if ((flags & DIO_LOCKING) && iov_iter_rw(iter) == READ)
 		inode_lock(inode);
-		retval = filemap_write_and_wait_range(mapping, pos, end - 1);
-		if (retval) {
-			inode_unlock(inode);
-			goto out;
-		}
-	}
 
 	/* Protects against truncate */
 	if (!(flags & DIO_SKIP_DIO_COUNT))
@@ -297,7 +290,6 @@ ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
 
 	if (!(flags & DIO_SKIP_DIO_COUNT))
 		inode_dio_end(inode);
- out:
 	return retval;
 }
 EXPORT_SYMBOL_GPL(dax_do_io);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
