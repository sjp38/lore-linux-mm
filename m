Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D64776B03D7
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:21:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g89so47484354qkh.15
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:21:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w7si10899417qth.8.2017.06.26.05.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:21:22 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 46/51] exofs: convert to bio_for_each_segment_all_sp()
Date: Mon, 26 Jun 2017 20:10:29 +0800
Message-Id: <20170626121034.3051-47-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
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
