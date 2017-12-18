Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCD8B6B0297
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:29:41 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w196so6959574oia.17
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:29:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u9si948448oti.201.2017.12.18.04.29.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:29:41 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 26/45] block: introduce bio_segments()
Date: Mon, 18 Dec 2017 20:22:28 +0800
Message-Id: <20171218122247.3488-27-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

There are still cases in which we need to use bio_segments() for get the
number of segment, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 2dd1ca0285e1..205a914ee3c0 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -223,9 +223,9 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
-static inline unsigned bio_pages(struct bio *bio)
+static inline unsigned __bio_elements(struct bio *bio, bool seg)
 {
-	unsigned segs = 0;
+	unsigned elems = 0;
 	struct bio_vec bv;
 	struct bvec_iter iter;
 
@@ -245,10 +245,25 @@ static inline unsigned bio_pages(struct bio *bio)
 		break;
 	}
 
-	bio_for_each_page(bv, bio, iter)
-		segs++;
+	if (!seg) {
+		bio_for_each_page(bv, bio, iter)
+			elems++;
+	} else {
+		bio_for_each_segment(bv, bio, iter)
+			elems++;
+	}
+
+	return elems;
+}
+
+static inline unsigned bio_pages(struct bio *bio)
+{
+	return __bio_elements(bio, false);
+}
 
-	return segs;
+static inline unsigned bio_segments(struct bio *bio)
+{
+	return __bio_elements(bio, true);
 }
 
 /*
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
