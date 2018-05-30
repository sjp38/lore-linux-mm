Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2255A6B02A6
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:12:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j14-v6so992338wro.7
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:12:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l26-v6sor5620466wmc.2.2018.05.30.03.12.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 03:12:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530095813.31245-2-hch@lst.de>
References: <20180530095813.31245-1-hch@lst.de> <20180530095813.31245-2-hch@lst.de>
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 30 May 2018 18:12:56 +0800
Message-ID: <CACVXFVMb6LWYtp4MjryAW-UAH-dLtU+z1AO4b-_wC0amMXFKww@mail.gmail.com>
Subject: Re: [PATCH 01/13] block: add a lower-level bio_add_page interface
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, May 30, 2018 at 5:58 PM, Christoph Hellwig <hch@lst.de> wrote:
> For the upcoming removal of buffer heads in XFS we need to keep track of
> the number of outstanding writeback requests per page.  For this we need
> to know if bio_add_page merged a region with the previous bvec or not.
> Instead of adding additional arguments this refactors bio_add_page to
> be implemented using three lower level helpers which users like XFS can
> use directly if they care about the merge decisions.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jens Axboe <axboe@kernel.dk>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  block/bio.c         | 96 +++++++++++++++++++++++++++++----------------
>  include/linux/bio.h |  9 +++++
>  2 files changed, 72 insertions(+), 33 deletions(-)
>
> diff --git a/block/bio.c b/block/bio.c
> index 53e0f0a1ed94..fdf635d42bbd 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -773,7 +773,7 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
>                         return 0;
>         }
>
> -       if (bio->bi_vcnt >= bio->bi_max_vecs)
> +       if (bio_full(bio))
>                 return 0;
>
>         /*
> @@ -821,52 +821,82 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
>  EXPORT_SYMBOL(bio_add_pc_page);
>
>  /**
> - *     bio_add_page    -       attempt to add page to bio
> - *     @bio: destination bio
> - *     @page: page to add
> - *     @len: vec entry length
> - *     @offset: vec entry offset
> + * __bio_try_merge_page - try appending data to an existing bvec.
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the data to add
> + * @off: offset of the data in @page
>   *
> - *     Attempt to add a page to the bio_vec maplist. This will only fail
> - *     if either bio->bi_vcnt == bio->bi_max_vecs or it's a cloned bio.
> + * Try to add the data at @page + @off to the last bvec of @bio.  This is a
> + * a useful optimisation for file systems with a block size smaller than the
> + * page size.
> + *
> + * Return %true on success or %false on failure.
>   */
> -int bio_add_page(struct bio *bio, struct page *page,
> -                unsigned int len, unsigned int offset)
> +bool __bio_try_merge_page(struct bio *bio, struct page *page,
> +               unsigned int len, unsigned int off)
>  {
> -       struct bio_vec *bv;
> -
> -       /*
> -        * cloned bio must not modify vec list
> -        */
>         if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
> -               return 0;
> +               return false;
>
> -       /*
> -        * For filesystems with a blocksize smaller than the pagesize
> -        * we will often be called with the same page as last time and
> -        * a consecutive offset.  Optimize this special case.
> -        */
>         if (bio->bi_vcnt > 0) {
> -               bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +               struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
>
> -               if (page == bv->bv_page &&
> -                   offset == bv->bv_offset + bv->bv_len) {
> +               if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
>                         bv->bv_len += len;
> -                       goto done;
> +                       bio->bi_iter.bi_size += len;
> +                       return true;
>                 }
>         }
> +       return false;
> +}
> +EXPORT_SYMBOL_GPL(__bio_try_merge_page);
>
> -       if (bio->bi_vcnt >= bio->bi_max_vecs)
> -               return 0;
> +/**
> + * __bio_add_page - add page to a bio in a new segment
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the data to add
> + * @off: offset of the data in @page
> + *
> + * Add the data at @page + @off to @bio as a new bvec.  The caller must ensure
> + * that @bio has space for another bvec.
> + */
> +void __bio_add_page(struct bio *bio, struct page *page,
> +               unsigned int len, unsigned int off)
> +{
> +       struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt];
>
> -       bv              = &bio->bi_io_vec[bio->bi_vcnt];
> -       bv->bv_page     = page;
> -       bv->bv_len      = len;
> -       bv->bv_offset   = offset;
> +       WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
> +       WARN_ON_ONCE(bio_full(bio));
> +
> +       bv->bv_page = page;
> +       bv->bv_offset = off;
> +       bv->bv_len = len;
>
> -       bio->bi_vcnt++;
> -done:
>         bio->bi_iter.bi_size += len;
> +       bio->bi_vcnt++;
> +}
> +EXPORT_SYMBOL_GPL(__bio_add_page);
> +
> +/**
> + *     bio_add_page    -       attempt to add page to bio
> + *     @bio: destination bio
> + *     @page: page to add
> + *     @len: vec entry length
> + *     @offset: vec entry offset
> + *
> + *     Attempt to add a page to the bio_vec maplist. This will only fail
> + *     if either bio->bi_vcnt == bio->bi_max_vecs or it's a cloned bio.
> + */
> +int bio_add_page(struct bio *bio, struct page *page,
> +                unsigned int len, unsigned int offset)
> +{
> +       if (!__bio_try_merge_page(bio, page, len, offset)) {
> +               if (bio_full(bio))
> +                       return 0;
> +               __bio_add_page(bio, page, len, offset);
> +       }
>         return len;
>  }
>  EXPORT_SYMBOL(bio_add_page);
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index ce547a25e8ae..3e73c8bc25ea 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -123,6 +123,11 @@ static inline void *bio_data(struct bio *bio)
>         return NULL;
>  }
>
> +static inline bool bio_full(struct bio *bio)
> +{
> +       return bio->bi_vcnt >= bio->bi_max_vecs;
> +}
> +
>  /*
>   * will die
>   */
> @@ -470,6 +475,10 @@ void bio_chain(struct bio *, struct bio *);
>  extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
>  extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
>                            unsigned int, unsigned int);
> +bool __bio_try_merge_page(struct bio *bio, struct page *page,
> +               unsigned int len, unsigned int off);
> +void __bio_add_page(struct bio *bio, struct page *page,
> +               unsigned int len, unsigned int off);
>  int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
>  struct rq_map_data;
>  extern struct bio *bio_map_user_iov(struct request_queue *,
> --
> 2.17.0
>

Looks fine:

Reviewed-by: Ming Lei <ming.lei@redhat.com>

-- 
Ming Lei
