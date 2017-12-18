Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0964B6B02B3
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:32:40 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id c33so5335661ote.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:32:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s4si4057211otb.311.2017.12.18.04.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:32:39 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 40/45] block: kill bio_for_each_page_all()
Date: Mon, 18 Dec 2017 20:22:42 +0800
Message-Id: <20171218122247.3488-41-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

No one uses it any more, so kill it and we can reuse this helper
name.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 899db6701f0d..05027f0df83f 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -155,8 +155,10 @@ static inline void *bio_data(struct bio *bio)
 /*
  * drivers should _never_ use the all version - the bio may have been split
  * before it got to the driver and the driver won't own all of it
+ *
+ * This helper iterates bio segment by segment.
  */
-#define bio_for_each_page_all(bvl, bio, i)				\
+#define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
 static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
@@ -221,9 +223,6 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)			\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
-#define bio_for_each_segment_all(bvl, bio, i) \
-	bio_for_each_page_all((bvl), (bio), (i))
-
 /*
  * This helper returns singlepage bvec to caller, and the sp bvec is
  * generated in-flight from multipage bvec stored in bvec table. So we
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
