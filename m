Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7EA6B03A4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:37 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o85so29658357qkh.15
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i186si8269498qkf.173.2017.04.24.06.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:36 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 19/20] jbd2: don't reset error in journal_finish_inode_data_buffers
Date: Mon, 24 Apr 2017 09:22:58 -0400
Message-Id: <20170424132259.8680-20-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

Now that we don't clear writeback errors after fetching them, there is
no need to reset them. This is also potentially racy.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/jbd2/commit.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index b6b194ec1b4f..4c6262652028 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -264,17 +264,8 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
 		jinode->i_flags |= JI_COMMIT_RUNNING;
 		spin_unlock(&journal->j_list_lock);
 		err = filemap_fdatawait(jinode->i_vfs_inode->i_mapping);
-		if (err) {
-			/*
-			 * Because AS_EIO is cleared by
-			 * filemap_fdatawait_range(), set it again so
-			 * that user process can get -EIO from fsync().
-			 */
-			mapping_set_error(jinode->i_vfs_inode->i_mapping, -EIO);
-
-			if (!ret)
-				ret = err;
-		}
+		if (err && !ret)
+			ret = err;
 		spin_lock(&journal->j_list_lock);
 		jinode->i_flags &= ~JI_COMMIT_RUNNING;
 		smp_mb();
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
