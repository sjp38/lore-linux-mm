Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8276B02A8
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:49:43 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g3-v6so2906259qtp.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:49:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l4-v6si6301844qkc.332.2018.05.24.20.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:49:42 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 15/33] block: introduce bio_clone_seg_bioset()
Date: Fri, 25 May 2018 11:46:03 +0800
Message-Id: <20180525034621.31147-16-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

There is one use case(DM) which requires to clone bio segment by
segement, so introduce this API.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c         | 56 +++++++++++++++++++++++++++++++++++++++--------------
 include/linux/bio.h |  1 +
 2 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index d0debb22ee34..63d4fe85f42e 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -644,21 +644,13 @@ struct bio *bio_clone_fast(struct bio *bio, gfp_t gfp_mask, struct bio_set *bs)
 }
 EXPORT_SYMBOL(bio_clone_fast);
 
-/**
- * 	bio_clone_bioset - clone a bio
- * 	@bio_src: bio to clone
- *	@gfp_mask: allocation priority
- *	@bs: bio_set to allocate from
- *
- *	Clone bio. Caller will own the returned bio, but not the actual data it
- *	points to. Reference count of returned bio will be one.
- */
-struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
-			     struct bio_set *bs)
+static struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
+				      struct bio_set *bs, bool page)
 {
 	struct bvec_iter iter;
 	struct bio_vec bv;
 	struct bio *bio;
+	int nr_vecs = page ? bio_pages(bio_src) : bio_segments(bio_src);
 
 	/*
 	 * Pre immutable biovecs, __bio_clone() used to just do a memcpy from
@@ -682,7 +674,7 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 	 *    __bio_clone_fast() anyways.
 	 */
 
-	bio = bio_alloc_bioset(gfp_mask, bio_pages(bio_src), bs);
+	bio = bio_alloc_bioset(gfp_mask, nr_vecs, bs);
 	if (!bio)
 		return NULL;
 	bio->bi_disk		= bio_src->bi_disk;
@@ -700,8 +692,13 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 		bio->bi_io_vec[bio->bi_vcnt++] = bio_src->bi_io_vec[0];
 		break;
 	default:
-		bio_for_each_page(bv, bio_src, iter)
-			bio->bi_io_vec[bio->bi_vcnt++] = bv;
+		if (page) {
+			bio_for_each_page(bv, bio_src, iter)
+				bio->bi_io_vec[bio->bi_vcnt++] = bv;
+		} else {
+			bio_for_each_segment(bv, bio_src, iter)
+				bio->bi_io_vec[bio->bi_vcnt++] = bv;
+		}
 		break;
 	}
 
@@ -719,9 +716,40 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 
 	return bio;
 }
+
+/**
+ * 	bio_clone_bioset - clone a bio
+ * 	@bio_src: bio to clone
+ *	@gfp_mask: allocation priority
+ *	@bs: bio_set to allocate from
+ *
+ *	Clone bio. Caller will own the returned bio, but not the actual data it
+ *	points to. Reference count of returned bio will be one.
+ */
+struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
+			     struct bio_set *bs)
+{
+	return __bio_clone_bioset(bio_src, gfp_mask, bs, true);
+}
 EXPORT_SYMBOL(bio_clone_bioset);
 
 /**
+ * 	bio_clone_seg_bioset - clone a bio segment by segment
+ * 	@bio_src: bio to clone
+ *	@gfp_mask: allocation priority
+ *	@bs: bio_set to allocate from
+ *
+ *	Clone bio. Caller will own the returned bio, but not the actual data it
+ *	points to. Reference count of returned bio will be one.
+ */
+struct bio *bio_clone_seg_bioset(struct bio *bio_src, gfp_t gfp_mask,
+				 struct bio_set *bs)
+{
+	return __bio_clone_bioset(bio_src, gfp_mask, bs, false);
+}
+EXPORT_SYMBOL(bio_clone_seg_bioset);
+
+/**
  *	bio_add_pc_page	-	attempt to add page to bio
  *	@q: the target queue
  *	@bio: destination bio
diff --git a/include/linux/bio.h b/include/linux/bio.h
index b24c00f99c9c..61a04c131641 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -475,6 +475,7 @@ extern void bio_put(struct bio *);
 extern void __bio_clone_fast(struct bio *, struct bio *);
 extern struct bio *bio_clone_fast(struct bio *, gfp_t, struct bio_set *);
 extern struct bio *bio_clone_bioset(struct bio *, gfp_t, struct bio_set *bs);
+extern struct bio *bio_clone_seg_bioset(struct bio *, gfp_t, struct bio_set *bs);
 
 extern struct bio_set fs_bio_set;
 
-- 
2.9.5
