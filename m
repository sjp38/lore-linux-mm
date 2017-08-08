Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEFE6B04CB
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:54:21 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s26so12697656qts.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:54:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y83si781441qkb.301.2017.08.08.01.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:54:20 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 44/49] exofs: convert to bio_for_each_segment_all_sp()
Date: Tue,  8 Aug 2017 16:45:43 +0800
Message-Id: <20170808084548.18963-45-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Boaz Harrosh <ooo@electrozaur.com>

Cc: Boaz Harrosh <ooo@electrozaur.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/exofs/ore.c      | 3 ++-
 fs/exofs/ore_raid.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 8bb72807e70d..38a7d8bfdd4c 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -406,8 +406,9 @@ static void _clear_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
 	unsigned i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all_sp(bv, bio, i, bia) {
 		unsigned this_count = bv->bv_len;
 
 		if (likely(PAGE_SIZE == this_count))
diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
index 27cbdb697649..37c0a9aa2ec2 100644
--- a/fs/exofs/ore_raid.c
+++ b/fs/exofs/ore_raid.c
@@ -429,6 +429,7 @@ static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
 {
 	struct bio_vec *bv;
 	unsigned i, d;
+	struct bvec_iter_all bia;
 
 	/* loop on all devices all pages */
 	for (d = 0; d < ios->numdevs; d++) {
@@ -437,7 +438,7 @@ static void _mark_read4write_pages_uptodate(struct ore_io_state *ios, int ret)
 		if (!bio)
 			continue;
 
-		bio_for_each_segment_all(bv, bio, i) {
+		bio_for_each_segment_all_sp(bv, bio, i, bia) {
 			struct page *page = bv->bv_page;
 
 			SetPageUptodate(page);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
