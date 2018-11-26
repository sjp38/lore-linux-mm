Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE656B441B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:39:42 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p15so7541451pfk.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:39:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s16sor2652389pfi.69.2018.11.26.14.39.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:39:41 -0800 (PST)
Date: Mon, 26 Nov 2018 14:39:38 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 13/20] block: loop: pass multi-page bvec to iov_iter
Message-ID: <20181126223938.GJ30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-14-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-14-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:13AM +0800, Ming Lei wrote:
> iov_iter is implemented on bvec itererator helpers, so it is safe to pass
> multi-page bvec to it, and this way is much more efficient than passing one
> page in each bvec.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  drivers/block/loop.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index 176ab1f28eca..e3683211f12d 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -510,21 +510,22 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
>  		     loff_t pos, bool rw)
>  {
>  	struct iov_iter iter;
> +	struct req_iterator rq_iter;
>  	struct bio_vec *bvec;
>  	struct request *rq = blk_mq_rq_from_pdu(cmd);
>  	struct bio *bio = rq->bio;
>  	struct file *file = lo->lo_backing_file;
> +	struct bio_vec tmp;
>  	unsigned int offset;
> -	int segments = 0;
> +	int nr_bvec = 0;
>  	int ret;
>  
> +	rq_for_each_bvec(tmp, rq, rq_iter)
> +		nr_bvec++;
> +
>  	if (rq->bio != rq->biotail) {
> -		struct req_iterator iter;
> -		struct bio_vec tmp;
>  
> -		__rq_for_each_bio(bio, rq)
> -			segments += bio_segments(bio);
> -		bvec = kmalloc_array(segments, sizeof(struct bio_vec),
> +		bvec = kmalloc_array(nr_bvec, sizeof(struct bio_vec),
>  				     GFP_NOIO);
>  		if (!bvec)
>  			return -EIO;
> @@ -533,10 +534,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
>  		/*
>  		 * The bios of the request may be started from the middle of
>  		 * the 'bvec' because of bio splitting, so we can't directly
> -		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_segment
> +		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_bvec
>  		 * API will take care of all details for us.
>  		 */
> -		rq_for_each_segment(tmp, rq, iter) {
> +		rq_for_each_bvec(tmp, rq, rq_iter) {
>  			*bvec = tmp;
>  			bvec++;
>  		}
> @@ -550,11 +551,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
>  		 */
>  		offset = bio->bi_iter.bi_bvec_done;
>  		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
> -		segments = bio_segments(bio);
>  	}
>  	atomic_set(&cmd->ref, 2);
>  
> -	iov_iter_bvec(&iter, rw, bvec, segments, blk_rq_bytes(rq));
> +	iov_iter_bvec(&iter, rw, bvec, nr_bvec, blk_rq_bytes(rq));
>  	iter.iov_offset = offset;
>  
>  	cmd->iocb.ki_pos = pos;
> -- 
> 2.9.5
> 
