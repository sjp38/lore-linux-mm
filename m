Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2245D6B04C7
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:54:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l13so12638811qtc.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:54:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k8si735420qti.516.2017.08.08.01.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:53:59 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 42/49] gfs2: convert to bio_for_each_segment_all_sp()
Date: Tue,  8 Aug 2017 16:45:41 +0800
Message-Id: <20170808084548.18963-43-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/gfs2/lops.c    | 3 ++-
 fs/gfs2/meta_io.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 3010f9edd177..d1fd8ed01b9e 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -206,11 +206,12 @@ static void gfs2_end_log_write(struct bio *bio)
 	struct bio_vec *bvec;
 	struct page *page;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (bio->bi_status)
 		fs_err(sdp, "Error %d writing to log\n", bio->bi_status);
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		page = bvec->bv_page;
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index fabe1614f879..6879b0103539 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -190,8 +190,9 @@ static void gfs2_meta_read_endio(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
