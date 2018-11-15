Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 605696B05A3
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 15:20:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 190-v6so16908437pfd.7
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 12:20:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a17-v6sor34651642pff.8.2018.11.15.12.20.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 12:20:31 -0800 (PST)
Date: Thu, 15 Nov 2018 12:20:28 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 03/19] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181115202028.GC9348@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-4-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-4-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:50PM +0800, Ming Lei wrote:
> First it is more efficient to use bio_for_each_bvec() in both
> blk_bio_segment_split() and __blk_recalc_rq_segments() to compute how
> many multi-page bvecs there are in the bio.
> 
> Secondly once bio_for_each_bvec() is used, the bvec may need to be
> splitted because its length can be very longer than max segment size,
> so we have to split the big bvec into several segments.
> 
> Thirdly when splitting multi-page bvec into segments, the max segment
> limit may be reached, so the bio split need to be considered under
> this situation too.
> 
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: dm-devel@redhat.com
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Shaohua Li <shli@kernel.org>
> Cc: linux-raid@vger.kernel.org
> Cc: linux-erofs@lists.ozlabs.org
> Cc: David Sterba <dsterba@suse.com>
> Cc: linux-btrfs@vger.kernel.org
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Cc: linux-xfs@vger.kernel.org
> Cc: Gao Xiang <gaoxiang25@huawei.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Theodore Ts'o <tytso@mit.edu>
> Cc: linux-ext4@vger.kernel.org
> Cc: Coly Li <colyli@suse.de>
> Cc: linux-bcache@vger.kernel.org
> Cc: Boaz Harrosh <ooo@electrozaur.com>
> Cc: Bob Peterson <rpeterso@redhat.com>
> Cc: cluster-devel@redhat.com
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/blk-merge.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 76 insertions(+), 14 deletions(-)
> 
> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 91b2af332a84..6f7deb94a23f 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -160,6 +160,62 @@ static inline unsigned get_max_io_size(struct request_queue *q,
>  	return sectors;
>  }
>  
> +/*
> + * Split the bvec @bv into segments, and update all kinds of
> + * variables.
> + */
> +static bool bvec_split_segs(struct request_queue *q, struct bio_vec *bv,
> +		unsigned *nsegs, unsigned *last_seg_size,
> +		unsigned *front_seg_size, unsigned *sectors)
> +{
> +	bool need_split = false;
> +	unsigned len = bv->bv_len;
> +	unsigned total_len = 0;
> +	unsigned new_nsegs = 0, seg_size = 0;

"unsigned int" here and everywhere else.

> +	if ((*nsegs >= queue_max_segments(q)) || !len)
> +		return need_split;
> +
> +	/*
> +	 * Multipage bvec may be too big to hold in one segment,
> +	 * so the current bvec has to be splitted as multiple
> +	 * segments.
> +	 */
> +	while (new_nsegs + *nsegs < queue_max_segments(q)) {
> +		seg_size = min(queue_max_segment_size(q), len);
> +
> +		new_nsegs++;
> +		total_len += seg_size;
> +		len -= seg_size;
> +
> +		if ((queue_virt_boundary(q) && ((bv->bv_offset +
> +		    total_len) & queue_virt_boundary(q))) || !len)
> +			break;

Checking queue_virt_boundary(q) != 0 is superfluous, and the len check
could just control the loop, i.e.,

	while (len && new_nsegs + *nsegs < queue_max_segments(q)) {
		seg_size = min(queue_max_segment_size(q), len);

		new_nsegs++;
		total_len += seg_size;
		len -= seg_size;

		if ((bv->bv_offset + total_len) & queue_virt_boundary(q))
			break;
	}

And if you rewrite it this way, I _think_ you can get rid of this
special case:

	if ((*nsegs >= queue_max_segments(q)) || !len)
		return need_split;

above.

> +	}
> +
> +	/* split in the middle of the bvec */
> +	if (len)
> +		need_split = true;

need_split is unnecessary, just return len != 0.

> +
> +	/* update front segment size */
> +	if (!*nsegs) {
> +		unsigned first_seg_size = seg_size;
> +
> +		if (new_nsegs > 1)
> +			first_seg_size = queue_max_segment_size(q);
> +		if (*front_seg_size < first_seg_size)
> +			*front_seg_size = first_seg_size;
> +	}
> +
> +	/* update other varibles */
> +	*last_seg_size = seg_size;
> +	*nsegs += new_nsegs;
> +	if (sectors)
> +		*sectors += total_len >> 9;
> +
> +	return need_split;
> +}
> +
>  static struct bio *blk_bio_segment_split(struct request_queue *q,
>  					 struct bio *bio,
>  					 struct bio_set *bs,
> @@ -173,7 +229,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  	struct bio *new = NULL;
>  	const unsigned max_sectors = get_max_io_size(q, bio);
>  
> -	bio_for_each_segment(bv, bio, iter) {
> +	bio_for_each_bvec(bv, bio, iter) {
>  		/*
>  		 * If the queue doesn't support SG gaps and adding this
>  		 * offset would create a gap, disallow it.
> @@ -188,8 +244,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  			 */
>  			if (nsegs < queue_max_segments(q) &&
>  			    sectors < max_sectors) {
> -				nsegs++;
> -				sectors = max_sectors;
> +				/* split in the middle of bvec */
> +				bv.bv_len = (max_sectors - sectors) << 9;
> +				bvec_split_segs(q, &bv, &nsegs,
> +						&seg_size,
> +						&front_seg_size,
> +						&sectors);
>  			}
>  			goto split;
>  		}
> @@ -214,11 +274,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  		if (nsegs == 1 && seg_size > front_seg_size)
>  			front_seg_size = seg_size;

Hm, do we still need to check this here now that we're updating
front_seg_size inside of bvec_split_segs()?

>  
> -		nsegs++;
>  		bvprv = bv;
>  		bvprvp = &bvprv;
> -		seg_size = bv.bv_len;
> -		sectors += bv.bv_len >> 9;
> +
> +		if (bvec_split_segs(q, &bv, &nsegs, &seg_size,
> +					&front_seg_size, &sectors))

What happened to the indent alignment here?

> +			goto split;
>  
>  	}
>  
> @@ -296,6 +357,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  	struct bio_vec bv, bvprv = { NULL };
>  	int cluster, prev = 0;
>  	unsigned int seg_size, nr_phys_segs;
> +	unsigned front_seg_size = bio->bi_seg_front_size;
>  	struct bio *fbio, *bbio;
>  	struct bvec_iter iter;
>  
> @@ -316,7 +378,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  	seg_size = 0;
>  	nr_phys_segs = 0;
>  	for_each_bio(bio) {
> -		bio_for_each_segment(bv, bio, iter) {
> +		bio_for_each_bvec(bv, bio, iter) {
>  			/*
>  			 * If SG merging is disabled, each bio vector is
>  			 * a segment
> @@ -336,20 +398,20 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  				continue;
>  			}
>  new_segment:
> -			if (nr_phys_segs == 1 && seg_size >
> -			    fbio->bi_seg_front_size)
> -				fbio->bi_seg_front_size = seg_size;
> +			if (nr_phys_segs == 1 && seg_size > front_seg_size)
> +				front_seg_size = seg_size;

Same comment as in blk_bio_segment_split(), do we still need to check
this if we're updating front_seg_size in bvec_split_segs()?

>  
> -			nr_phys_segs++;
>  			bvprv = bv;
>  			prev = 1;
> -			seg_size = bv.bv_len;
> +			bvec_split_segs(q, &bv, &nr_phys_segs, &seg_size,
> +					&front_seg_size, NULL);
>  		}
>  		bbio = bio;
>  	}
>  
> -	if (nr_phys_segs == 1 && seg_size > fbio->bi_seg_front_size)
> -		fbio->bi_seg_front_size = seg_size;
> +	if (nr_phys_segs == 1 && seg_size > front_seg_size)
> +		front_seg_size = seg_size;
> +	fbio->bi_seg_front_size = front_seg_size;
>  	if (seg_size > bbio->bi_seg_back_size)
>  		bbio->bi_seg_back_size = seg_size;
>  
> -- 
> 2.9.5
> 
