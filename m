Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40BC96B2BC2
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 09:58:20 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a199so9235461qkb.23
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 06:58:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n86si4645103qkh.253.2018.11.22.06.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 06:58:19 -0800 (PST)
Date: Thu, 22 Nov 2018 22:57:50 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 03/19] block: introduce bio_for_each_bvec()
Message-ID: <20181122145749.GA22146@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-4-ming.lei@redhat.com>
 <20181121133244.GB1640@lst.de>
 <20181121153135.GB19111@ming.t460p>
 <20181121161025.GB4977@lst.de>
 <20181121171217.GA6259@lst.de>
 <20181122101527.GB27273@ming.t460p>
 <20181122102309.GA29295@lst.de>
 <20181122103033.GA29418@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122103033.GA29418@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 22, 2018 at 11:30:33AM +0100, Christoph Hellwig wrote:
> Btw, this patch instead of the plain rever might make it a little
> more clear what is going on by skipping the confusing helper altogher
> and operating on the raw bvec array:
> 
> 
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index e5b975fa0558..926550ce2d21 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -137,24 +137,18 @@ static inline bool bio_full(struct bio *bio)
>  	for (i = 0, iter_all.idx = 0; iter_all.idx < (bio)->bi_vcnt; iter_all.idx++)	\
>  		bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)
>  
> -static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> -				      unsigned bytes, unsigned max_seg_len)
> +static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> +				    unsigned bytes)
>  {
>  	iter->bi_sector += bytes >> 9;
>  
>  	if (bio_no_advance_iter(bio))
>  		iter->bi_size -= bytes;
>  	else
> -		__bvec_iter_advance(bio->bi_io_vec, iter, bytes, max_seg_len);
> +		bvec_iter_advance(bio->bi_io_vec, iter, bytes);
>  		/* TODO: It is reasonable to complete bio with error here. */
>  }
>  
> -static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> -				    unsigned bytes)
> -{
> -	__bio_advance_iter(bio, iter, bytes, PAGE_SIZE);
> -}
> -
>  #define __bio_for_each_segment(bvl, bio, iter, start)			\
>  	for (iter = (start);						\
>  	     (iter).bi_size &&						\
> @@ -168,7 +162,7 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
>  	for (iter = (start);						\
>  	     (iter).bi_size &&						\
>  		((bvl = bio_iter_mp_iovec((bio), (iter))), 1);	\
> -	     __bio_advance_iter((bio), &(iter), (bvl).bv_len, BVEC_MAX_LEN))
> +	     bio_advance_iter((bio), &(iter), (bvl).bv_len))
>  
>  /* returns one real segment(multi-page bvec) each time */
>  #define bio_for_each_bvec(bvl, bio, iter)			\
> diff --git a/include/linux/bvec.h b/include/linux/bvec.h
> index cab36d838ed0..7d0f9bdb6f05 100644
> --- a/include/linux/bvec.h
> +++ b/include/linux/bvec.h
> @@ -25,8 +25,6 @@
>  #include <linux/errno.h>
>  #include <linux/mm.h>
>  
> -#define BVEC_MAX_LEN  ((unsigned int)-1)
> -
>  /*
>   * was unsigned short, but we might as well be ready for > 64kB I/O pages
>   */
> @@ -102,8 +100,8 @@ struct bvec_iter_all {
>  	.bv_offset	= segment_iter_offset((bvec), (iter)),	\
>  })
>  
> -static inline bool __bvec_iter_advance(const struct bio_vec *bv,
> -		struct bvec_iter *iter, unsigned bytes, unsigned max_seg_len)
> +static inline bool bvec_iter_advance(const struct bio_vec *bv,
> +		struct bvec_iter *iter, unsigned bytes)
>  {
>  	if (WARN_ONCE(bytes > iter->bi_size,
>  		     "Attempted to advance past end of bvec iter\n")) {
> @@ -112,20 +110,15 @@ static inline bool __bvec_iter_advance(const struct bio_vec *bv,
>  	}
>  
>  	while (bytes) {
> -		unsigned segment_len = segment_iter_len(bv, *iter);
> -
> -		if (max_seg_len < BVEC_MAX_LEN)
> -			segment_len = min_t(unsigned, segment_len,
> -					    max_seg_len -
> -					    bvec_iter_offset(bv, *iter));
> +		const struct bio_vec *cur = bv + iter->bi_idx;
> +		unsigned len = min3(bytes, iter->bi_size,
> +				    cur->bv_len - iter->bi_bvec_done);
>  
> -		segment_len = min(bytes, segment_len);
> -
> -		bytes -= segment_len;
> -		iter->bi_size -= segment_len;
> -		iter->bi_bvec_done += segment_len;
> +		bytes -= len;
> +		iter->bi_size -= len;
> +		iter->bi_bvec_done += len;
>  
> -		if (iter->bi_bvec_done == __bvec_iter_bvec(bv, *iter)->bv_len) {
> +		if (iter->bi_bvec_done == cur->bv_len) {
>  			iter->bi_bvec_done = 0;
>  			iter->bi_idx++;
>  		}

I'd rather not do the optimization part in this patchset, given it doesn't
belong to this patchset, and it may decrease readability. So I plan to revert
the delta part in V12 first.

Thanks,
Ming
