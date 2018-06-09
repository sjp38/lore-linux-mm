Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1C646B0290
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:35:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p12-v6so14542006qtg.5
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:35:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t1-v6si7769934qtb.341.2018.06.09.05.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:35:07 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 24/30] xfs: conver to bio_for_each_chunk_segment_all
Date: Sat,  9 Jun 2018 20:30:08 +0800
Message-Id: <20180609123014.8861-25-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_chunk_segment_all().

Given bvec can't be changed under bio_for_each_chunk_segment_all(), this patch
marks the bvec parameter as 'const' for xfs_finish_page_writeback().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/xfs/xfs_aops.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index ca6903726689..c134db97911d 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -107,7 +107,7 @@ xfs_find_daxdev_for_inode(
 static void
 xfs_finish_page_writeback(
 	struct inode		*inode,
-	struct bio_vec		*bvec,
+	const struct bio_vec	*bvec,
 	int			error)
 {
 	struct buffer_head	*head = page_buffers(bvec->bv_page), *bh = head;
@@ -169,6 +169,7 @@ xfs_destroy_ioend(
 	for (bio = &ioend->io_inline_bio; bio; bio = next) {
 		struct bio_vec	*bvec;
 		int		i;
+		struct bvec_chunk_iter citer;
 
 		/*
 		 * For the last bio, bi_private points to the ioend, so we
@@ -180,7 +181,7 @@ xfs_destroy_ioend(
 			next = bio->bi_private;
 
 		/* walk each page on bio, ending page IO on them */
-		bio_for_each_segment_all(bvec, bio, i)
+		bio_for_each_chunk_segment_all(bvec, bio, i, citer)
 			xfs_finish_page_writeback(inode, bvec, error);
 
 		bio_put(bio);
-- 
2.9.5
