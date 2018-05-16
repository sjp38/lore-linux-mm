Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE0D6B02E1
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:06:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20-v6so1813048pff.14
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:06:26 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s24-v6si1679730pfm.257.2018.05.15.22.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 22:06:20 -0700 (PDT)
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-2-hch@lst.de>
From: Ritesh Harjani <riteshh@codeaurora.org>
Message-ID: <37c16316-aa3a-e3df-79d0-9fca37a5996f@codeaurora.org>
Date: Wed, 16 May 2018 10:36:14 +0530
MIME-Version: 1.0
In-Reply-To: <20180509074830.16196-2-hch@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org



On 5/9/2018 1:17 PM, Christoph Hellwig wrote:
> For the upcoming removal of buffer heads in XFS we need to keep track of
> the number of outstanding writeback requests per page.  For this we need
> to know if bio_add_page merged a region with the previous bvec or not.
> Instead of adding additional arguments this refactors bio_add_page to
> be implemented using three lower level helpers which users like XFS can
> use directly if they care about the merge decisions.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   block/bio.c         | 87 ++++++++++++++++++++++++++++++---------------
>   include/linux/bio.h |  9 +++++
>   2 files changed, 67 insertions(+), 29 deletions(-)
> 
> diff --git a/block/bio.c b/block/bio.c
> index 53e0f0a1ed94..6ceba6adbf42 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -773,7 +773,7 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
>   			return 0;
>   	}
>   
> -	if (bio->bi_vcnt >= bio->bi_max_vecs)
> +	if (bio_full(bio))
>   		return 0;
>   
>   	/*
> @@ -820,6 +820,59 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
>   }
>   EXPORT_SYMBOL(bio_add_pc_page);
>   
> +/**
> + * __bio_try_merge_page - try adding data to an existing bvec
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the range to add
> + * @off: offset into @page
> + *
> + * Try adding the data described at @page + @offset to the last bvec of @bio.
> + * Return %true on success or %false on failure.  This can happen frequently
> + * for file systems with a block size smaller than the page size.
> + */
> +bool __bio_try_merge_page(struct bio *bio, struct page *page,
> +		unsigned int len, unsigned int off)
> +{
> +	if (bio->bi_vcnt > 0) {
> +		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +
> +		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> +			bv->bv_len += len;
> +			bio->bi_iter.bi_size += len;
> +			return true;
> +		}
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(__bio_try_merge_page);
> +
> +/**
> + * __bio_add_page - add page to a bio in a new segment
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the range to add
> + * @off: offset into @page
> + *
> + * Add the data at @page + @offset to @bio as a new bvec.  The caller must
> + * ensure that @bio has space for another bvec.
> + */
> +void __bio_add_page(struct bio *bio, struct page *page,
> +		unsigned int len, unsigned int off)
> +{
> +	struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt];
> +
> +	WARN_ON_ONCE(bio_full(bio));

Please correct my understanding here. I am still new at understanding this.

1. if bio_full is true that means no space in bio->bio_io_vec[] no?
Than how come we are still proceeding ahead with only warning?
While originally in bio_add_page we used to return after checking
bio_full. Callers can still call __bio_add_page directly right.

2. Also the bio_io_vec size allocated will only be upto bio->bi_max_vecs 
right?
I could not follow up very well with the bvec_alloc function,
mainly when nr_iovec > inline_vecs. So how and where it is getting sure 
that we are getting _nr_iovecs_ allocated from the bvec_pool?

hmm.. tricky. Please help me understand this.
1. So we have defined different slabs of different sizes in bvec_slabs. 
and when the allocation request of nr_iovecs come
we try to grab the predefined(in terms of size) slab of bvec_slabs
and return. In case if that allocation does not succeed from slab,
we go for mempool_alloc.

2. IF above is correct why don't we set the bio->bi_max_vecs to the size
of the slab instead of keeeping it to nr_iovecs which user requested?
(in bio_alloc_bioset)


3. Could you please help understand why for cloned bio we still allow
__bio_add_page to work? why not WARN and return like in original code?

4. Ok, I see that in patch 32 you are first checking bio_full and 
calling for xfs_chain_bio. But there also I think you are making sure 
that new ioend->io_bio is the new chained bio which is not full.

Apologies if above doesn't make any sense.

> +
> +	bv->bv_page = page;
> +	bv->bv_offset = off;
> +	bv->bv_len = len;
> +
> +	bio->bi_iter.bi_size += len;
> +	bio->bi_vcnt++;
> +}
> +EXPORT_SYMBOL_GPL(__bio_add_page);
> +
>   /**
>    *	bio_add_page	-	attempt to add page to bio
>    *	@bio: destination bio
> @@ -833,40 +886,16 @@ EXPORT_SYMBOL(bio_add_pc_page);
>   int bio_add_page(struct bio *bio, struct page *page,
>   		 unsigned int len, unsigned int offset)
>   {
> -	struct bio_vec *bv;
> -
>   	/*
>   	 * cloned bio must not modify vec list
>   	 */
>   	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
>   		return 0;
> -
> -	/*
> -	 * For filesystems with a blocksize smaller than the pagesize
> -	 * we will often be called with the same page as last time and
> -	 * a consecutive offset.  Optimize this special case.
> -	 */
> -	if (bio->bi_vcnt > 0) {
> -		bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> -
> -		if (page == bv->bv_page &&
> -		    offset == bv->bv_offset + bv->bv_len) {
> -			bv->bv_len += len;
> -			goto done;
> -		}
> +	if (!__bio_try_merge_page(bio, page, len, offset)) {
> +		if (bio_full(bio))
> +			return 0;
> +		__bio_add_page(bio, page, len, offset);
>   	}
> -
> -	if (bio->bi_vcnt >= bio->bi_max_vecs)
> -		return 0;
Originally here we were supposed to return and not proceed further.
Should __bio_add_page not have similar checks to safeguard crossing
the bio_io_vec[] boundary?


> -
> -	bv		= &bio->bi_io_vec[bio->bi_vcnt];
> -	bv->bv_page	= page;
> -	bv->bv_len	= len;
> -	bv->bv_offset	= offset;
> -
> -	bio->bi_vcnt++;
> -done:
> -	bio->bi_iter.bi_size += len;
>   	return len;
>   }
>   EXPORT_SYMBOL(bio_add_page);
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index ce547a25e8ae..3e73c8bc25ea 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -123,6 +123,11 @@ static inline void *bio_data(struct bio *bio)
>   	return NULL;
>   }
>   
> +static inline bool bio_full(struct bio *bio)
> +{
> +	return bio->bi_vcnt >= bio->bi_max_vecs;
> +}
> +
>   /*
>    * will die
>    */
> @@ -470,6 +475,10 @@ void bio_chain(struct bio *, struct bio *);
>   extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
>   extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
>   			   unsigned int, unsigned int);
> +bool __bio_try_merge_page(struct bio *bio, struct page *page,
> +		unsigned int len, unsigned int off);
> +void __bio_add_page(struct bio *bio, struct page *page,
> +		unsigned int len, unsigned int off);
>   int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
>   struct rq_map_data;
>   extern struct bio *bio_map_user_iov(struct request_queue *,
> 

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, 
Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project.
