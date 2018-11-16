Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D80066B09D9
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:58:05 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b186so6318705wmc.8
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:58:05 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r16si4346930wrp.189.2018.11.16.05.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:58:04 -0800 (PST)
Date: Fri, 16 Nov 2018 14:58:03 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 18/19] block: kill QUEUE_FLAG_NO_SG_MERGE
Message-ID: <20181116135803.GN3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-19-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-19-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:05PM +0800, Ming Lei wrote:
> Since bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting"),
> physical segment number is mainly figured out in blk_queue_split() for
> fast path, and the flag of BIO_SEG_VALID is set there too.
> 
> Now only blk_recount_segments() and blk_recalc_rq_segments() use this
> flag.
> 
> Basically blk_recount_segments() is bypassed in fast path given BIO_SEG_VALID
> is set in blk_queue_split().
> 
> For another user of blk_recalc_rq_segments():
> 
> - run in partial completion branch of blk_update_request, which is an unusual case
> 
> - run in blk_cloned_rq_check_limits(), still not a big problem if the flag is killed
> since dm-rq is the only user.
> 
> Multi-page bvec is enabled now, QUEUE_FLAG_NO_SG_MERGE doesn't make sense any more.
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
>  block/blk-merge.c      | 31 ++++++-------------------------
>  block/blk-mq-debugfs.c |  1 -
>  block/blk-mq.c         |  3 ---
>  drivers/md/dm-table.c  | 13 -------------
>  include/linux/blkdev.h |  1 -
>  5 files changed, 6 insertions(+), 43 deletions(-)
> 
> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 153a659fde74..06be298be332 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -351,8 +351,7 @@ void blk_queue_split(struct request_queue *q, struct bio **bio)
>  EXPORT_SYMBOL(blk_queue_split);
>  
>  static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
> -					     struct bio *bio,
> -					     bool no_sg_merge)
> +					     struct bio *bio)
>  {
>  	struct bio_vec bv, bvprv = { NULL };
>  	int cluster, prev = 0;
> @@ -379,13 +378,6 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  	nr_phys_segs = 0;
>  	for_each_bio(bio) {
>  		bio_for_each_bvec(bv, bio, iter) {
> -			/*
> -			 * If SG merging is disabled, each bio vector is
> -			 * a segment
> -			 */
> -			if (no_sg_merge)
> -				goto new_segment;
> -
>  			if (prev && cluster) {
>  				if (seg_size + bv.bv_len
>  				    > queue_max_segment_size(q))
> @@ -420,27 +412,16 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
>  
>  void blk_recalc_rq_segments(struct request *rq)
>  {
> -	bool no_sg_merge = !!test_bit(QUEUE_FLAG_NO_SG_MERGE,
> -			&rq->q->queue_flags);
> -
> -	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio,
> -			no_sg_merge);
> +	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio);

Can we rename __blk_recalc_rq_segments to blk_recalc_rq_segments
can kill the old blk_recalc_rq_segments now?

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
