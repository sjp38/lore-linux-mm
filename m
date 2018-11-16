Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 180796B0705
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 21:11:44 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id l2-v6so14274430pgp.22
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 18:11:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u67sor13794607pgc.55.2018.11.15.18.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 18:11:43 -0800 (PST)
Date: Thu, 15 Nov 2018 18:11:40 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 17/19] block: don't use bio->bi_vcnt to figure out
 segment number
Message-ID: <20181116021140.GL23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-18-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-18-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:04PM +0800, Ming Lei wrote:
> It is wrong to use bio->bi_vcnt to figure out how many segments
> there are in the bio even though CLONED flag isn't set on this bio,
> because this bio may be splitted or advanced.
> 
> So always use bio_segments() in blk_recount_segments(), and it shouldn't
> cause any performance loss now because the physical segment number is figured
> out in blk_queue_split() and BIO_SEG_VALID is set meantime since
> bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting").
> 
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Fixes: 7f60dcaaf91 ("block: blk-merge: fix blk_recount_segments()")

>From what I can tell, the problem was originally introduced by
76d8137a3113 ("blk-merge: recaculate segment if it isn't less than max segments")

Is that right?

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
>  block/blk-merge.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index cb9f49bcfd36..153a659fde74 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -429,13 +429,7 @@ void blk_recalc_rq_segments(struct request *rq)
>  
>  void blk_recount_segments(struct request_queue *q, struct bio *bio)
>  {
> -	unsigned short seg_cnt;
> -
> -	/* estimate segment number by bi_vcnt for non-cloned bio */
> -	if (bio_flagged(bio, BIO_CLONED))
> -		seg_cnt = bio_segments(bio);
> -	else
> -		seg_cnt = bio->bi_vcnt;
> +	unsigned short seg_cnt = bio_segments(bio);
>  
>  	if (test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags) &&
>  			(seg_cnt < queue_max_segments(q)))
> -- 
> 2.9.5
> 
