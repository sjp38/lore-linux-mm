Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF8286B4417
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:37:13 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so8712813pgv.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:37:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor2681685pfj.12.2018.11.26.14.37.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:37:12 -0800 (PST)
Date: Mon, 26 Nov 2018 14:37:09 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 09/20] block: use bio_for_each_bvec() to compute
 multi-page bvec count
Message-ID: <20181126223709.GI30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-10-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-10-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:09AM +0800, Ming Lei wrote:
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

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/blk-merge.c | 100 +++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 80 insertions(+), 20 deletions(-)
> 
> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 51ec6ca56a0a..2d8f388d43de 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -161,6 +161,70 @@ static inline unsigned get_max_io_size(struct request_queue *q,
>  	return sectors;
>  }
>  
> +static unsigned get_max_segment_size(struct request_queue *q,
> +				     unsigned offset)
> +{
> +	unsigned long mask = queue_segment_boundary(q);
> +
> +	return min_t(unsigned long, mask - (mask & offset) + 1,
> +		     queue_max_segment_size(q));
> +}
> +
> +/*
> + * Split the bvec @bv into segments, and update all kinds of
> + * variables.
> + */
> +static bool bvec_split_segs(struct request_queue *q, struct bio_vec *bv,
> +		unsigned *nsegs, unsigned *last_seg_size,
> +		unsigned *front_seg_size, unsigned *sectors)
> +{
> +	unsigned len = bv->bv_len;
> +	unsigned total_len = 0;
> +	unsigned new_nsegs = 0, seg_size = 0;
> +
> +	/*
> +	 * Multipage bvec may be too big to hold in one segment,
> +	 * so the current bvec has to be splitted as multiple
> +	 * segments.
> +	 */
> +	while (len && new_nsegs + *nsegs < queue_max_segments(q)) {
> +		seg_size = get_max_segment_size(q, bv->bv_offset + total_len);
> +		seg_size = min(seg_size, len);
> +
> +		new_nsegs++;
> +		total_len += seg_size;
> +		len -= seg_size;
> +
> +		if ((bv->bv_offset + total_len) & queue_virt_boundary(q))
> +			break;
> +	}
> +
> +	if (!new_nsegs)
> +		return !!len;
> +
> +	/* update front segment size */
> +	if (!*nsegs) {
> +		unsigned first_seg_size;
> +
> +		if (new_nsegs == 1)
> +			first_seg_size = get_max_segment_size(q, bv->bv_offset);
> +		else
> +			first_seg_size = queue_max_segment_size(q);
> +
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
> +	/* split in the middle of the bvec if len != 0 */
> +	return !!len;
> +}
> +
>  static struct bio *blk_bio_segment_split(struct request_queue *q,
>  					 struct bio *bio,
>  					 struct bio_set *bs,
> @@ -174,7 +238,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  	struct bio *new = NULL;
>  	const unsigned max_sectors = get_max_io_size(q, bio);
>  
> -	bio_for_each_segment(bv, bio, iter) {
> +	bio_for_each_bvec(bv, bio, iter) {
>  		/*
>  		 * If the queue doesn't support SG gaps and adding this
>  		 * offset would create a gap, disallow it.
> @@ -189,8 +253,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
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
> @@ -212,14 +280,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  		if (nsegs == queue_max_segments(q))
>  			goto split;
>  
> -		if (nsegs == 1 && seg_size > front_seg_size)
> -			front_seg_size = seg_size;
> -
> -		nsegs++;
>  		bvprv = bv;
>  		bvprvp = &bvprv;
> -		seg_size = bv.bv_len;
> -		sectors += bv.bv_len >> 9;
> +
> +		if (bvec_split_segs(q, &bv, &nsegs, &seg_size,
> +				    &front_seg_size, &sectors))
> +			goto split;
>  
>  	}
>  
> @@ -233,8 +299,6 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
>  			bio = new;
>  	}
>  
> -	if (nsegs == 1 && seg_size > front_seg_size)
> -		front_seg_size = seg_size;
>  	bio->bi_seg_front_size = front_seg_size;
>  	if (seg_size > bio->bi_seg_back_size)
>  		bio->bi_seg_back_size = seg_size;
> @@ -296,6 +360,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  {
>  	struct bio_vec bv, bvprv = { NULL };
>  	unsigned int seg_size, nr_phys_segs;
> +	unsigned front_seg_size = bio->bi_seg_front_size;
>  	struct bio *fbio, *bbio;
>  	struct bvec_iter iter;
>  	bool prev = false;
> @@ -316,7 +381,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  	seg_size = 0;
>  	nr_phys_segs = 0;
>  	for_each_bio(bio) {
> -		bio_for_each_segment(bv, bio, iter) {
> +		bio_for_each_bvec(bv, bio, iter) {
>  			/*
>  			 * If SG merging is disabled, each bio vector is
>  			 * a segment
> @@ -336,20 +401,15 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  				continue;
>  			}
>  new_segment:
> -			if (nr_phys_segs == 1 && seg_size >
> -			    fbio->bi_seg_front_size)
> -				fbio->bi_seg_front_size = seg_size;
> -
> -			nr_phys_segs++;
>  			bvprv = bv;
>  			prev = true;
> -			seg_size = bv.bv_len;
> +			bvec_split_segs(q, &bv, &nr_phys_segs, &seg_size,
> +					&front_seg_size, NULL);
>  		}
>  		bbio = bio;
>  	}
>  
> -	if (nr_phys_segs == 1 && seg_size > fbio->bi_seg_front_size)
> -		fbio->bi_seg_front_size = seg_size;
> +	fbio->bi_seg_front_size = front_seg_size;
>  	if (seg_size > bbio->bi_seg_back_size)
>  		bbio->bi_seg_back_size = seg_size;
>  
> -- 
> 2.9.5
> 
