Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB5E6B0533
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:28:57 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id l2-v6so13423905pgp.22
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:28:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w185sor31648853pgd.7.2018.11.15.10.28.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 10:28:56 -0800 (PST)
Date: Thu, 15 Nov 2018 10:28:54 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 02/19] block: introduce bio_for_each_bvec()
Message-ID: <20181115182854.GB9348@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-3-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-3-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:49PM +0800, Ming Lei wrote:
> This helper is used for iterating over multi-page bvec for bio
> split & merge code.
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

One comment below.

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  include/linux/bio.h  | 34 +++++++++++++++++++++++++++++++---
>  include/linux/bvec.h | 36 ++++++++++++++++++++++++++++++++----
>  2 files changed, 63 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 056fb627edb3..1f0dcf109841 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -76,6 +76,9 @@
>  #define bio_data_dir(bio) \
>  	(op_is_write(bio_op(bio)) ? WRITE : READ)
>  
> +#define bio_iter_mp_iovec(bio, iter)				\
> +	mp_bvec_iter_bvec((bio)->bi_io_vec, (iter))
> +
>  /*
>   * Check whether this bio carries any data or not. A NULL bio is allowed.
>   */
> @@ -135,18 +138,33 @@ static inline bool bio_full(struct bio *bio)
>  #define bio_for_each_segment_all(bvl, bio, i)				\
>  	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
>  
> -static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> -				    unsigned bytes)
> +static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> +				      unsigned bytes, bool mp)
>  {
>  	iter->bi_sector += bytes >> 9;
>  
>  	if (bio_no_advance_iter(bio))
>  		iter->bi_size -= bytes;
>  	else
> -		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
> +		if (!mp)
> +			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
> +		else
> +			mp_bvec_iter_advance(bio->bi_io_vec, iter, bytes);

if (!foo) {} else {} hurts my brain, please do

		if (mp)
			mp_bvec_iter_advance(bio->bi_io_vec, iter, bytes);
		else
			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
