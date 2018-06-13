Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1D46B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:57:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n3-v6so982990pgp.21
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:57:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c18-v6si3103858plo.185.2018.06.13.07.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 07:57:11 -0700 (PDT)
Date: Wed, 13 Jun 2018 07:56:54 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 15/30] block: introduce bio_clone_chunk_bioset()
Message-ID: <20180613145654.GE4693@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-16-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180609123014.8861-16-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Sat, Jun 09, 2018 at 08:29:59PM +0800, Ming Lei wrote:
> There is one use case(DM) which requires to clone bio chunk by
> chunk, so introduce this API.

I don't think DM is the special case here.  The special case is the
bounce code that only wants single page bios.  Between that, and the
fact that we only have two callers and one of them is inside the
block layer I would suggest to fold in the following patch to make
bio_clone_bioset clone in multi-page bvecs and make the bounce code
use the low-level interface directly:

diff --git a/block/bio.c b/block/bio.c
index 284085ab97e7..cef45c8d0a19 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -644,13 +644,14 @@ struct bio *bio_clone_fast(struct bio *bio, gfp_t gfp_mask, struct bio_set *bs)
 }
 EXPORT_SYMBOL(bio_clone_fast);
 
-static struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
-				      struct bio_set *bs, bool seg)
+struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
+		struct bio_set *bs, bool single_page_only)
 {
 	struct bvec_iter iter;
 	struct bio_vec bv;
 	struct bio *bio;
-	int nr_vecs = seg ? bio_segments(bio_src) : bio_chunks(bio_src);
+	int nr_vecs = single_page_only ?
+		bio_segments(bio_src) : bio_chunks(bio_src);
 
 	/*
 	 * Pre immutable biovecs, __bio_clone() used to just do a memcpy from
@@ -692,7 +693,7 @@ static struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 		bio->bi_io_vec[bio->bi_vcnt++] = bio_src->bi_io_vec[0];
 		break;
 	default:
-		if (seg) {
+		if (single_page_only) {
 			bio_for_each_segment(bv, bio_src, iter)
 				bio->bi_io_vec[bio->bi_vcnt++] = bv;
 		} else {
@@ -728,26 +729,10 @@ static struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
  */
 struct bio *bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
 			     struct bio_set *bs)
-{
-	return __bio_clone_bioset(bio_src, gfp_mask, bs, true);
-}
-EXPORT_SYMBOL(bio_clone_bioset);
-
-/**
- * 	bio_clone_seg_bioset - clone a bio segment by segment
- * 	@bio_src: bio to clone
- *	@gfp_mask: allocation priority
- *	@bs: bio_set to allocate from
- *
- *	Clone bio. Caller will own the returned bio, but not the actual data it
- *	points to. Reference count of returned bio will be one.
- */
-struct bio *bio_clone_chunk_bioset(struct bio *bio_src, gfp_t gfp_mask,
-				   struct bio_set *bs)
 {
 	return __bio_clone_bioset(bio_src, gfp_mask, bs, false);
 }
-EXPORT_SYMBOL(bio_clone_chunk_bioset);
+EXPORT_SYMBOL(bio_clone_bioset);
 
 /**
  *	bio_add_pc_page	-	attempt to add page to bio
diff --git a/block/bounce.c b/block/bounce.c
index c6af0bd29ec9..62dab528dc1b 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -224,8 +224,8 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 		generic_make_request(*bio_orig);
 		*bio_orig = bio;
 	}
-	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, passthrough ? NULL :
-			&bounce_bio_set);
+	bio = __bio_clone_bioset(*bio_orig, GFP_NOIO, passthrough ? NULL :
+			&bounce_bio_set, true);
 
 	bio_for_each_chunk_segment_all(to, bio, i, citer) {
 		struct page *page = to->bv_page;
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 13ca3574d972..98dff36b89a3 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1582,8 +1582,8 @@ static blk_qc_t __split_and_process_bio(struct mapped_device *md,
 				 * the usage of io->orig_bio in dm_remap_zone_report()
 				 * won't be affected by this reassignment.
 				 */
-				struct bio *b = bio_clone_chunk_bioset(bio, GFP_NOIO,
-								       &md->queue->bio_split);
+				struct bio *b = bio_clone_bioset(bio, GFP_NOIO,
+								 &md->queue->bio_split);
 				ci.io->orig_bio = b;
 				bio_advance(bio, (bio_sectors(bio) - ci.sector_count) << 9);
 				bio_chain(b, bio);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 58838dc12d69..5ccafeadbe95 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -486,7 +486,8 @@ extern void bio_put(struct bio *);
 extern void __bio_clone_fast(struct bio *, struct bio *);
 extern struct bio *bio_clone_fast(struct bio *, gfp_t, struct bio_set *);
 extern struct bio *bio_clone_bioset(struct bio *, gfp_t, struct bio_set *bs);
-extern struct bio *bio_clone_chunk_bioset(struct bio *, gfp_t, struct bio_set *bs);
+extern struct bio *__bio_clone_bioset(struct bio *bio_src, gfp_t gfp_mask,
+		struct bio_set *bs, bool single_page_only);
 
 extern struct bio_set fs_bio_set;
 
