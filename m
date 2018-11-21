Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B46EE6B2574
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:33:58 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j6so6992131wrw.1
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:33:58 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x11si15480730wrq.288.2018.11.21.06.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:33:56 -0800 (PST)
Date: Wed, 21 Nov 2018 15:33:55 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 14/19] block: handle non-cluster bio out of
 blk_bio_segment_split
Message-ID: <20181121143355.GB2594@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-15-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121032327.8434-15-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> +			non-cluster.o

Do we really need a new source file for these few functions?

>  	default:
> +		if (!blk_queue_cluster(q)) {
> +			blk_queue_non_cluster_bio(q, bio);
> +			return;

I'd name this blk_bio_segment_split_singlepage or similar.

> +static __init int init_non_cluster_bioset(void)
> +{
> +	WARN_ON(bioset_init(&non_cluster_bio_set, BIO_POOL_SIZE, 0,
> +			   BIOSET_NEED_BVECS));
> +	WARN_ON(bioset_integrity_create(&non_cluster_bio_set, BIO_POOL_SIZE));
> +	WARN_ON(bioset_init(&non_cluster_bio_split, BIO_POOL_SIZE, 0, 0));

Please only allocate the resources once a queue without the cluster
flag is registered, there are only very few modern drivers that do that.

> +static void non_cluster_end_io(struct bio *bio)
> +{
> +	struct bio *bio_orig = bio->bi_private;
> +
> +	bio_orig->bi_status = bio->bi_status;
> +	bio_endio(bio_orig);
> +	bio_put(bio);
> +}

Why can't we use bio_chain for the split bios?

> +	bio_for_each_segment(from, *bio_orig, iter) {
> +		if (i++ < max_segs)
> +			sectors += from.bv_len >> 9;
> +		else
> +			break;
> +	}

The easy to read way would be:

	bio_for_each_segment(from, *bio_orig, iter) {
		if (i++ == max_segs)
			break;
		sectors += from.bv_len >> 9;
	}

> +	if (sectors < bio_sectors(*bio_orig)) {
> +		bio = bio_split(*bio_orig, sectors, GFP_NOIO,
> +				&non_cluster_bio_split);
> +		bio_chain(bio, *bio_orig);
> +		generic_make_request(*bio_orig);
> +		*bio_orig = bio;

I don't think this is very efficient, as this means we now
clone the bio twice, first to split it at the sector boundary,
and then again when converting it to single-page bio_vec.

I think this could be something like this (totally untested):

diff --git a/block/non-cluster.c b/block/non-cluster.c
index 9c2910be9404..60389f275c43 100644
--- a/block/non-cluster.c
+++ b/block/non-cluster.c
@@ -13,58 +13,59 @@
 
 #include "blk.h"
 
-static struct bio_set non_cluster_bio_set, non_cluster_bio_split;
+static struct bio_set non_cluster_bio_set;
 
 static __init int init_non_cluster_bioset(void)
 {
 	WARN_ON(bioset_init(&non_cluster_bio_set, BIO_POOL_SIZE, 0,
 			   BIOSET_NEED_BVECS));
 	WARN_ON(bioset_integrity_create(&non_cluster_bio_set, BIO_POOL_SIZE));
-	WARN_ON(bioset_init(&non_cluster_bio_split, BIO_POOL_SIZE, 0, 0));
 
 	return 0;
 }
 __initcall(init_non_cluster_bioset);
 
-static void non_cluster_end_io(struct bio *bio)
-{
-	struct bio *bio_orig = bio->bi_private;
-
-	bio_orig->bi_status = bio->bi_status;
-	bio_endio(bio_orig);
-	bio_put(bio);
-}
-
 void blk_queue_non_cluster_bio(struct request_queue *q, struct bio **bio_orig)
 {
-	struct bio *bio;
 	struct bvec_iter iter;
-	struct bio_vec from;
-	unsigned i = 0;
-	unsigned sectors = 0;
-	unsigned short max_segs = min_t(unsigned short, BIO_MAX_PAGES,
-					queue_max_segments(q));
+	struct bio *bio;
+	struct bio_vec bv;
+	unsigned short max_segs, segs = 0;
+
+	bio = bio_alloc_bioset(GFP_NOIO, bio_segments(*bio_orig),
+			&non_cluster_bio_set);
+	bio->bi_disk		= (*bio_orig)->bi_disk;
+	bio->bi_partno		= (*bio_orig)->bi_partno;
+	bio_set_flag(bio, BIO_CLONED);
+	if (bio_flagged(*bio_orig, BIO_THROTTLED))
+		bio_set_flag(bio, BIO_THROTTLED);
+	bio->bi_opf		= (*bio_orig)->bi_opf;
+	bio->bi_ioprio		= (*bio_orig)->bi_ioprio;
+	bio->bi_write_hint	= (*bio_orig)->bi_write_hint;
+	bio->bi_iter.bi_sector	= (*bio_orig)->bi_iter.bi_sector;
+	bio->bi_iter.bi_size	= (*bio_orig)->bi_iter.bi_size;
+
+	if (bio_integrity(*bio_orig))
+		bio_integrity_clone(bio, *bio_orig, GFP_NOIO);
 
-	bio_for_each_segment(from, *bio_orig, iter) {
-		if (i++ < max_segs)
-			sectors += from.bv_len >> 9;
-		else
+	bio_clone_blkcg_association(bio, *bio_orig);
+
+	max_segs = min_t(unsigned short, queue_max_segments(q), BIO_MAX_PAGES);
+	bio_for_each_segment(bv, *bio_orig, iter) {
+		bio->bi_io_vec[segs++] = bv;
+		if (segs++ == max_segs)
 			break;
 	}
 
-	if (sectors < bio_sectors(*bio_orig)) {
-		bio = bio_split(*bio_orig, sectors, GFP_NOIO,
-				&non_cluster_bio_split);
-		bio_chain(bio, *bio_orig);
-		generic_make_request(*bio_orig);
-		*bio_orig = bio;
-	}
-	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, &non_cluster_bio_set);
+	bio->bi_vcnt = segs;
+	bio->bi_phys_segments = segs;
+	bio_set_flag(bio, BIO_SEG_VALID);
+	bio_chain(bio, *bio_orig);
 
-	bio->bi_phys_segments = bio_segments(bio);
-        bio_set_flag(bio, BIO_SEG_VALID);
-	bio->bi_end_io = non_cluster_end_io;
+	if (bio_integrity(bio))
+		bio_integrity_trim(bio);
+	bio_advance(bio, (*bio_orig)->bi_iter.bi_size);
 
-	bio->bi_private = *bio_orig;
+	generic_make_request(*bio_orig);
 	*bio_orig = bio;
 }
