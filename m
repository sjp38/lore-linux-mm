Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11E826B03A9
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 48so22797661qts.7
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t190si8490853qkf.49.2017.06.12.05.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:48 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 16/20] block: convert to errseq_t based writeback error tracking
Date: Mon, 12 Jun 2017 08:23:12 -0400
Message-Id: <20170612122316.13244-21-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

This is a very minimal conversion to errseq_t based error tracking
for raw block device access.

Only real change that is strictly required is that we must ensure that
filemap_report_wb_err is unconditionally called after fsync, which is
now done if FS_WB_ERRSEQ is set in fs_flags. That ensures that the
errseq_t in the file is advanced to the latest value in the mapping.

Note that there are internal callers that call sync_blockdev and the
like that are not affected by this. They'll continue to use the
AS_EIO/AS_ENOSPC flags for error reporting like they always have for
now.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/block_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 4d62fe771587..4bf865cc99de 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -801,6 +801,7 @@ static struct file_system_type bd_type = {
 	.name		= "bdev",
 	.mount		= bd_mount,
 	.kill_sb	= kill_anon_super,
+	.fs_flags	= FS_WB_ERRSEQ,
 };
 
 struct super_block *blockdev_superblock __read_mostly;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
