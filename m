Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E08E86B184D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 22:31:44 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v64so5818475qka.5
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 19:31:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v1si9211605qtc.391.2018.11.18.19.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Nov 2018 19:31:44 -0800 (PST)
Date: Mon, 19 Nov 2018 11:31:11 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 02/19] block: introduce bio_for_each_bvec()
Message-ID: <20181119033110.GE10838@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-3-ming.lei@redhat.com>
 <20181116133028.GB3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116133028.GB3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:30:28PM +0100, Christoph Hellwig wrote:
> > +static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> > +				      unsigned bytes, bool mp)
> 
> I think these magic 'bool np' arguments and wrappers over wrapper
> don't help anyone to actually understand the code.  I'd vote for
> removing as many wrappers as we really don't need, and passing the
> actual segment limit instead of the magic bool flag.  Something like
> this untested patch:

I think this way is fine, just a little comment.

> 
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 277921ad42e7..dcad0b69f57a 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -138,30 +138,21 @@ static inline bool bio_full(struct bio *bio)
>  		bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)
>  
>  static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> -				      unsigned bytes, bool mp)
> +				      unsigned bytes, unsigned max_segment)

The new parameter should have been named as 'max_segment_len' or
'max_seg_len'.

>  {
>  	iter->bi_sector += bytes >> 9;
>  
>  	if (bio_no_advance_iter(bio))
>  		iter->bi_size -= bytes;
>  	else
> -		if (!mp)
> -			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
> -		else
> -			mp_bvec_iter_advance(bio->bi_io_vec, iter, bytes);
> +		__bvec_iter_advance(bio->bi_io_vec, iter, bytes, max_segment);
>  		/* TODO: It is reasonable to complete bio with error here. */
>  }
>  
>  static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
>  				    unsigned bytes)
>  {
> -	__bio_advance_iter(bio, iter, bytes, false);
> -}
> -
> -static inline void bio_advance_mp_iter(struct bio *bio, struct bvec_iter *iter,
> -				       unsigned bytes)
> -{
> -	__bio_advance_iter(bio, iter, bytes, true);
> +	__bio_advance_iter(bio, iter, bytes, PAGE_SIZE);
>  }
>  
>  #define __bio_for_each_segment(bvl, bio, iter, start)			\
> @@ -177,7 +168,7 @@ static inline void bio_advance_mp_iter(struct bio *bio, struct bvec_iter *iter,
>  	for (iter = (start);						\
>  	     (iter).bi_size &&						\
>  		((bvl = bio_iter_mp_iovec((bio), (iter))), 1);	\
> -	     bio_advance_mp_iter((bio), &(iter), (bvl).bv_len))
> +	     __bio_advance_iter((bio), &(iter), (bvl).bv_len, 0))

Even we might pass '-1' for multi-page segment.

>  
>  /* returns one real segment(multipage bvec) each time */
>  #define bio_for_each_bvec(bvl, bio, iter)			\
> diff --git a/include/linux/bvec.h b/include/linux/bvec.h
> index 02f26d2b59ad..5e2ed46c1c88 100644
> --- a/include/linux/bvec.h
> +++ b/include/linux/bvec.h
> @@ -138,8 +138,7 @@ struct bvec_iter_all {
>  })
>  
>  static inline bool __bvec_iter_advance(const struct bio_vec *bv,
> -				       struct bvec_iter *iter,
> -				       unsigned bytes, bool mp)
> +		struct bvec_iter *iter, unsigned bytes, unsigned max_segment)
>  {
>  	if (WARN_ONCE(bytes > iter->bi_size,
>  		     "Attempted to advance past end of bvec iter\n")) {
> @@ -148,18 +147,18 @@ static inline bool __bvec_iter_advance(const struct bio_vec *bv,
>  	}
>  
>  	while (bytes) {
> -		unsigned len;
> +		unsigned segment_len = mp_bvec_iter_len(bv, *iter);
>  
> -		if (mp)
> -			len = mp_bvec_iter_len(bv, *iter);
> -		else
> -			len = bvec_iter_len(bv, *iter);
> +		if (max_segment) {
> +			max_segment -= bvec_iter_offset(bv, *iter);
> +			segment_len = min(segment_len, max_segment);

Looks 'max_segment' needs to be constant, shouldn't be updated.

If '-1' is passed for multipage case, the above change may become:

		segment_len = min_t(segment_len, max_seg_len - bvec_iter_offset(bv, *iter));

This way is more clean, but with extra cost of the above line for multipage
case.

Thanks,
Ming
