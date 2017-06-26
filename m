Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFF86B03C9
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:19:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so8178819qta.14
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:19:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a184si6523350qkd.27.2017.06.26.05.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:19:05 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 36/51] md: raid1: convert to bio_for_each_segment_all_sp()
Date: Mon, 26 Jun 2017 20:10:19 +0800
Message-Id: <20170626121034.3051-37-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/raid1.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 835c42396861..ca4b9ff8d39b 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2135,13 +2135,14 @@ static void process_checks(struct r1bio *r1_bio)
 		struct page **spages = get_resync_pages(sbio)->pages;
 		struct bio_vec *bi;
 		int page_len[RESYNC_PAGES] = { 0 };
+		struct bvec_iter_all bia;
 
 		if (sbio->bi_end_io != end_sync_read)
 			continue;
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_segment_all(bi, sbio, j)
+		bio_for_each_segment_all_sp(bi, sbio, j, bia)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
