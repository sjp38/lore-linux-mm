Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3F2A6B02B1
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:32:26 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v137so6961926oia.21
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:32:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g43si4156277ote.384.2017.12.18.04.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:32:25 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 39/45] gfs2: conver to bio_for_each_page_all2
Date: Mon, 18 Dec 2017 20:22:41 +0800
Message-Id: <20171218122247.3488-40-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_page_all2().

Given bvec can't be changed inside bio_for_each_page_all2(), this patch
marks the bvec parameter as 'const' for gfs2_end_log_write_bh().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/gfs2/lops.c    | 6 ++++--
 fs/gfs2/meta_io.c | 3 ++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 4579b8433955..29c8751f9672 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -167,7 +167,8 @@ static u64 gfs2_log_bmap(struct gfs2_sbd *sdp)
  * that is pinned in the pagecache.
  */
 
-static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
+static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp,
+				  const struct bio_vec *bvec,
 				  blk_status_t error)
 {
 	struct buffer_head *bh, *next;
@@ -206,6 +207,7 @@ static void gfs2_end_log_write(struct bio *bio)
 	struct bio_vec *bvec;
 	struct page *page;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status) {
 		fs_err(sdp, "Error %d writing to journal, jid=%u\n",
@@ -213,7 +215,7 @@ static void gfs2_end_log_write(struct bio *bio)
 		wake_up(&sdp->sd_logd_waitq);
 	}
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index 1d720352310a..a945c9fa1dc6 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -190,8 +190,9 @@ static void gfs2_meta_read_endio(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
