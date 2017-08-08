Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEB456B03C1
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:48:29 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o124so12934277qke.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:48:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h187si725685qkf.509.2017.08.08.01.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:48:29 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 13/49] btrfs: comment on direct access bvec table
Date: Tue,  8 Aug 2017 16:45:12 +0800
Message-Id: <20170808084548.18963-14-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Acked: David Sterba <dsterba@suse.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/compression.c |  4 ++++
 fs/btrfs/inode.c       | 12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index d2ef9ac2a630..f795d0a6d176 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -542,6 +542,10 @@ blk_status_t btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 
 	/* we need the actual starting offset of this extent in the file */
 	read_lock(&em_tree->lock);
+	/*
+	 * It is still safe to retrieve the 1st page of the bio
+	 * in this way after supporting multipage bvec.
+	 */
 	em = lookup_extent_mapping(em_tree,
 				   page_offset(bio->bi_io_vec->bv_page),
 				   PAGE_SIZE);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 5cf320ee7ea0..084ed99dd308 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -8051,6 +8051,12 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	if (bio->bi_status)
 		goto end;
 
+	/*
+	 * WARNING:
+	 *
+	 * With multipage bvec, the following way of direct access to
+	 * bvec table is only safe if the bio includes single page.
+	 */
 	ASSERT(bio->bi_vcnt == 1);
 	io_tree = &BTRFS_I(inode)->io_tree;
 	failure_tree = &BTRFS_I(inode)->io_failure_tree;
@@ -8143,6 +8149,12 @@ static void btrfs_retry_endio(struct bio *bio)
 
 	uptodate = 1;
 
+	/*
+	 * WARNING:
+	 *
+	 * With multipage bvec, the following way of direct access to
+	 * bvec table is only safe if the bio includes single page.
+	 */
 	ASSERT(bio->bi_vcnt == 1);
 	ASSERT(bio->bi_io_vec->bv_len == btrfs_inode_sectorsize(done->inode));
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
