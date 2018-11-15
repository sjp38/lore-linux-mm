Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABFFA6B0630
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:34:03 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so14005589pgr.15
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 14:34:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11-v6sor34215820plg.0.2018.11.15.14.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 14:34:02 -0800 (PST)
Date: Thu, 15 Nov 2018 14:33:58 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 04/19] block: use bio_for_each_bvec() to map sg
Message-ID: <20181115223358.GE9348@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-5-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-5-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:51PM +0800, Ming Lei wrote:
> It is more efficient to use bio_for_each_bvec() to map sg, meantime
> we have to consider splitting multipage bvec as done in blk_bio_segment_split().
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

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/blk-merge.c | 72 +++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 52 insertions(+), 20 deletions(-)
> 
> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 6f7deb94a23f..cb9f49bcfd36 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -473,6 +473,56 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
>  	return biovec_phys_mergeable(q, &end_bv, &nxt_bv);
>  }
>  
> +static struct scatterlist *blk_next_sg(struct scatterlist **sg,
> +		struct scatterlist *sglist)
> +{
> +	if (!*sg)
> +		return sglist;
> +	else {
> +		/*
> +		 * If the driver previously mapped a shorter
> +		 * list, we could see a termination bit
> +		 * prematurely unless it fully inits the sg
> +		 * table on each mapping. We KNOW that there
> +		 * must be more entries here or the driver
> +		 * would be buggy, so force clear the
> +		 * termination bit to avoid doing a full
> +		 * sg_init_table() in drivers for each command.
> +		 */
> +		sg_unmark_end(*sg);
> +		return sg_next(*sg);
> +	}
> +}
> +
> +static unsigned blk_bvec_map_sg(struct request_queue *q,
> +		struct bio_vec *bvec, struct scatterlist *sglist,
> +		struct scatterlist **sg)
> +{
> +	unsigned nbytes = bvec->bv_len;
> +	unsigned nsegs = 0, total = 0;
> +
> +	while (nbytes > 0) {
> +		unsigned seg_size;
> +		struct page *pg;
> +		unsigned offset, idx;
> +
> +		*sg = blk_next_sg(sg, sglist);
> +
> +		seg_size = min(nbytes, queue_max_segment_size(q));
> +		offset = (total + bvec->bv_offset) % PAGE_SIZE;
> +		idx = (total + bvec->bv_offset) / PAGE_SIZE;
> +		pg = nth_page(bvec->bv_page, idx);
> +
> +		sg_set_page(*sg, pg, seg_size, offset);
> +
> +		total += seg_size;
> +		nbytes -= seg_size;
> +		nsegs++;
> +	}
> +
> +	return nsegs;
> +}
> +
>  static inline void
>  __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
>  		     struct scatterlist *sglist, struct bio_vec *bvprv,
> @@ -490,25 +540,7 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
>  		(*sg)->length += nbytes;
>  	} else {
>  new_segment:
> -		if (!*sg)
> -			*sg = sglist;
> -		else {
> -			/*
> -			 * If the driver previously mapped a shorter
> -			 * list, we could see a termination bit
> -			 * prematurely unless it fully inits the sg
> -			 * table on each mapping. We KNOW that there
> -			 * must be more entries here or the driver
> -			 * would be buggy, so force clear the
> -			 * termination bit to avoid doing a full
> -			 * sg_init_table() in drivers for each command.
> -			 */
> -			sg_unmark_end(*sg);
> -			*sg = sg_next(*sg);
> -		}
> -
> -		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
> -		(*nsegs)++;
> +		(*nsegs) += blk_bvec_map_sg(q, bvec, sglist, sg);
>  	}
>  	*bvprv = *bvec;
>  }
> @@ -530,7 +562,7 @@ static int __blk_bios_map_sg(struct request_queue *q, struct bio *bio,
>  	int cluster = blk_queue_cluster(q), nsegs = 0;
>  
>  	for_each_bio(bio)
> -		bio_for_each_segment(bvec, bio, iter)
> +		bio_for_each_bvec(bvec, bio, iter)
>  			__blk_segment_map_sg(q, &bvec, sglist, &bvprv, sg,
>  					     &nsegs, &cluster);
>  
> -- 
> 2.9.5
> 
