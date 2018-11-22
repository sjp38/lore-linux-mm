Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7B1B6B2B12
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:16:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b26so5854737qtq.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:16:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19si9499987qvm.155.2018.11.22.02.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:16:02 -0800 (PST)
Date: Thu, 22 Nov 2018 18:15:28 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 03/19] block: introduce bio_for_each_bvec()
Message-ID: <20181122101527.GB27273@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-4-ming.lei@redhat.com>
 <20181121133244.GB1640@lst.de>
 <20181121153135.GB19111@ming.t460p>
 <20181121161025.GB4977@lst.de>
 <20181121171217.GA6259@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121171217.GA6259@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 06:12:17PM +0100, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 05:10:25PM +0100, Christoph Hellwig wrote:
> > No - I think we can always use the code without any segment in
> > bvec_iter_advance.  Because bvec_iter_advance only operates on the
> > iteractor, the generation of an actual single-page or multi-page
> > bvec is left to the caller using the bvec_iter_bvec or segment_iter_bvec
> > helpers.  The only difference is how many bytes you can move the
> > iterator forward in a single loop iteration - so if you pass in
> > PAGE_SIZE as the max_seg_len you just will have to loop more often
> > for a large enough bytes, but not actually do anything different.
> 
> FYI, this patch reverts the max_seg_len related changes back to where
> we are in mainline, and as expected everything works fine for me:
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
> index cab36d838ed0..138b4007b8f2 100644
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
> @@ -112,18 +110,12 @@ static inline bool __bvec_iter_advance(const struct bio_vec *bv,
>  	}
>  
>  	while (bytes) {
> -		unsigned segment_len = segment_iter_len(bv, *iter);
> -
> -		if (max_seg_len < BVEC_MAX_LEN)
> -			segment_len = min_t(unsigned, segment_len,
> -					    max_seg_len -
> -					    bvec_iter_offset(bv, *iter));
> +		unsigned iter_len = bvec_iter_len(bv, *iter);
> +		unsigned len = min(bytes, iter_len);

It may not work to always use bvec_iter_len() here, and 'segment_len'
should be max length of the passed 'bv', however we don't know if it is
single-page or mutli-page bvec if no one tells us.

Thanks,
Ming
