Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE9A86B027E
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:33:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l10-v6so14532322qth.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:33:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d7-v6si3646714qvf.4.2018.06.09.05.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:33:38 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 15/30] block: introduce bio_clone_chunk_bioset()
Date: Sat,  9 Jun 2018 20:29:59 +0800
Message-Id: <20180609123014.8861-16-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

There is one use case(DM) which requires to clone bio chunk by
chunk, so introduce this API.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c         | 56 +++++++++++++++++++++++++++++++++++++++--------------
 include/linux/bio.h |  1 +
 2 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index cb0f46e2752b..60219f82ddab 100644
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
+				      struct bio_set *bs, bool seg)
 {
 	struct bvec_iter iter;
 	struct bio_vec bv;
 	struct bio *bio;
+	int nr_vecs = seg ? bio_segments(bio_src) : bio_chunks(bio_src);
 
 	/*
 	 * Pre immutable biovecs, __bio_clone() used to just do a memcpy from
@@ -682,7 +674,7 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 	 *    __bio_clone_fast() anyways.
 	 */
 
-	bio = bio_alloc_bioset(gfp_mask, bio_segments(bio_src), bs);
+	bio = bio_alloc_bioset(gfp_mask, nr_vecs, bs);
 	if (!bio)
 		return NULL;
 	bio->bi_disk		= bio_src->bi_disk;
@@ -700,8 +692,13 @@ struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 		bio->bi_io_vec[bio->bi_vcnt++] = bio_src->bi_io_vec[0];
 		break;
 	default:
-		bio_for_each_segment(bv, bio_src, iter)
-			bio->bi_io_vec[bio->bi_vcnt++] = bv;
+		if (seg) {
+			bio_for_each_segment(bv, bio_src, iter)
+				bio->bi_io_vec[bio->bi_vcnt++] = bv;
+		} else {
+			bio_for_each_chunk(bv, bio_src, iter)
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
+struct bio *bio_clone_chunk_bioset(struct bio *bio_src, gfp_t gfp_mask,
+				   struct bio_set *bs)
+{
+	return __bio_clone_bioset(bio_src, gfp_mask, bs, false);
+}
+EXPORT_SYMBOL(bio_clone_chunk_bioset);
+
+/**
  *	bio_add_pc_page	-	attempt to add page to bio
  *	@q: the target queue
  *	@bio: destination bio
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 13fd7bc30390..0fa1035dde38 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -483,6 +483,7 @@ extern void bio_put(struct bio *);
 extern void __bio_clone_fast(struct bio *, struct bio *);
 extern struct bio *bio_clone_fast(struct bio *, gfp_t, struct bio_set *);
 extern struct bio *bio_clone_bioset(struct bio *, gfp_t, struct bio_set *bs);
+extern struct bio *bio_clone_chunk_bioset(struct bio *, gfp_t, struct bio_set *bs);
 
 extern struct bio_set fs_bio_set;
 
-- 
2.9.5
