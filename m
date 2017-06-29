Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 604316B03A2
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:35 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n2so21671785oig.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o130si3590397oih.0.2017.06.29.06.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:34 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 14/18] block: convert to errseq_t based writeback error tracking
Date: Thu, 29 Jun 2017 09:19:50 -0400
Message-Id: <20170629131954.28733-15-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

This is a very minimal conversion to errseq_t based error tracking
for raw block device access. Just have it use the standard
file_write_and_wait_range call.

Note that there are internal callers that call sync_blockdev
and the like that are not affected by this. They'll continue
to use the AS_EIO/AS_ENOSPC flags for error reporting like
they always have for now.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/block_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 4d62fe771587..bcb0be6e423a 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -624,7 +624,7 @@ int blkdev_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
 	struct block_device *bdev = I_BDEV(bd_inode);
 	int error;
 	
-	error = filemap_write_and_wait_range(filp->f_mapping, start, end);
+	error = file_write_and_wait_range(filp, start, end);
 	if (error)
 		return error;
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
