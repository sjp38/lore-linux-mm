Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92FC96B02C0
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:51:49 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z10-v6so2832315qto.11
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:51:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 37-v6si12463896qvj.156.2018.05.24.20.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:51:48 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 27/33] gfs2: conver to bio_for_each_page_all2
Date: Fri, 25 May 2018 11:46:15 +0800
Message-Id: <20180525034621.31147-28-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index a31b9b028957..0284cd66089c 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -168,7 +168,8 @@ u64 gfs2_log_bmap(struct gfs2_sbd *sdp)
  * that is pinned in the pagecache.
  */
 
-static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp, struct bio_vec *bvec,
+static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp,
+				  const struct bio_vec *bvec,
 				  blk_status_t error)
 {
 	struct buffer_head *bh, *next;
@@ -207,6 +208,7 @@ static void gfs2_end_log_write(struct bio *bio)
 	struct bio_vec *bvec;
 	struct page *page;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status) {
 		fs_err(sdp, "Error %d writing to journal, jid=%u\n",
@@ -214,7 +216,7 @@ static void gfs2_end_log_write(struct bio *bio)
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
