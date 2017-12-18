Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39DD76B0294
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:29:29 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 74so8829638otv.10
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:29:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c205si3765778oig.195.2017.12.18.04.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:29:28 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 25/45] block: implement bio_pages_all() via bio_for_each_page_all()
Date: Mon, 18 Dec 2017 20:22:27 +0800
Message-Id: <20171218122247.3488-26-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

As multipage bvec will be enabled soon, bio->bi_vcnt isn't same with
page count in the bio any more, so use bio_for_each_page_all() to
compute the number.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 0cb29c73ff27..2dd1ca0285e1 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -330,8 +330,14 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 
 static inline unsigned bio_pages_all(struct bio *bio)
 {
+	unsigned i;
+	struct bio_vec *bv;
+
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-	return bio->bi_vcnt;
+
+	bio_for_each_page_all(bv, bio, i)
+		;
+	return i;
 }
 
 static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
