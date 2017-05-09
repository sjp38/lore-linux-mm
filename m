Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D82932806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:49:49 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v195so1602210qka.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:49:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t3si374431qkg.314.2017.05.09.08.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:49:49 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 05/27] btrfs: btrfs_wait_tree_block_writeback can be void return
Date: Tue,  9 May 2017 11:49:08 -0400
Message-Id: <20170509154930.29524-6-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

Nothing checks its return value.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/btrfs/disk-io.c | 6 +++---
 fs/btrfs/disk-io.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index eb1ee7b6f532..8c479bd5534a 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1222,10 +1222,10 @@ int btrfs_write_tree_block(struct extent_buffer *buf)
 					buf->start + buf->len - 1);
 }
 
-int btrfs_wait_tree_block_writeback(struct extent_buffer *buf)
+void btrfs_wait_tree_block_writeback(struct extent_buffer *buf)
 {
-	return filemap_fdatawait_range(buf->pages[0]->mapping,
-				       buf->start, buf->start + buf->len - 1);
+	filemap_fdatawait_range(buf->pages[0]->mapping,
+			        buf->start, buf->start + buf->len - 1);
 }
 
 struct extent_buffer *read_tree_block(struct btrfs_fs_info *fs_info, u64 bytenr,
diff --git a/fs/btrfs/disk-io.h b/fs/btrfs/disk-io.h
index 2e0ec29bfd69..9cc87835abb5 100644
--- a/fs/btrfs/disk-io.h
+++ b/fs/btrfs/disk-io.h
@@ -127,7 +127,7 @@ int btrfs_wq_submit_bio(struct btrfs_fs_info *fs_info, struct inode *inode,
 			extent_submit_bio_hook_t *submit_bio_done);
 unsigned long btrfs_async_submit_limit(struct btrfs_fs_info *info);
 int btrfs_write_tree_block(struct extent_buffer *buf);
-int btrfs_wait_tree_block_writeback(struct extent_buffer *buf);
+void btrfs_wait_tree_block_writeback(struct extent_buffer *buf);
 int btrfs_init_log_root_tree(struct btrfs_trans_handle *trans,
 			     struct btrfs_fs_info *fs_info);
 int btrfs_add_log_tree(struct btrfs_trans_handle *trans,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
