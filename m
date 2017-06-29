Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4C576B03A1
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:37 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n2so21671847oig.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:37 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e2si3615588oih.275.2017.06.29.06.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:37 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 15/18] fs: convert __generic_file_fsync to use errseq_t based reporting
Date: Thu, 29 Jun 2017 09:19:51 -0400
Message-Id: <20170629131954.28733-16-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/libfs.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 1dec90819366..3aabe553fc45 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -974,7 +974,7 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 	int err;
 	int ret;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(file, start, end);
 	if (err)
 		return err;
 
@@ -991,8 +991,11 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 
 out:
 	inode_unlock(inode);
-	err = filemap_check_errors(inode->i_mapping);
-	return ret ? ret : err;
+	/* check and advance again to catch errors after syncing out buffers */
+	err = file_check_and_advance_wb_err(file);
+	if (ret == 0)
+		ret = err;
+	return ret;
 }
 EXPORT_SYMBOL(__generic_file_fsync);
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
