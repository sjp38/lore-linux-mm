Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD876B05D4
	for <linux-mm@kvack.org>; Thu, 10 May 2018 04:52:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p7-v6so942090wrj.4
        for <linux-mm@kvack.org>; Thu, 10 May 2018 01:52:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5-v6sor165839wrh.87.2018.05.10.01.52.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 01:52:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180509074830.16196-2-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-2-hch@lst.de>
From: Ming Lei <tom.leiming@gmail.com>
Date: Thu, 10 May 2018 16:52:00 +0800
Message-ID: <CACVXFVMPwQV8M0raTcLUtqDix-kEkYV3E3fJSVOVw8m=iiv5Uw@mail.gmail.com>
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, May 9, 2018 at 3:47 PM, Christoph Hellwig <hch@lst.de> wrote:
> For the upcoming removal of buffer heads in XFS we need to keep track of
> the number of outstanding writeback requests per page.  For this we need
> to know if bio_add_page merged a region with the previous bvec or not.
> Instead of adding additional arguments this refactors bio_add_page to
> be implemented using three lower level helpers which users like XFS can
> use directly if they care about the merge decisions.

The merge policy may be transparent to fs, such as multipage bvec.

>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/bio.c         | 87 ++++++++++++++++++++++++++++++---------------
>  include/linux/bio.h |  9 +++++
>  2 files changed, 67 insertions(+), 29 deletions(-)
>
> diff --git a/block/bio.c b/block/bio.c
> index 53e0f0a1ed94..6ceba6adbf42 100644
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
> @@ -820,6 +820,59 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
>  }
>  EXPORT_SYMBOL(bio_add_pc_page);
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
> +               unsigned int len, unsigned int off)
> +{
> +       if (bio->bi_vcnt > 0) {
> +               struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +
> +               if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> +                       bv->bv_len += len;
> +                       bio->bi_iter.bi_size += len;
> +                       return true;
> +               }
> +       }
> +       return false;
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
> +               unsigned int len, unsigned int off)
> +{
> +       struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt];
> +
> +       WARN_ON_ONCE(bio_full(bio));
> +
> +       bv->bv_page = page;
> +       bv->bv_offset = off;
> +       bv->bv_len = len;
> +
> +       bio->bi_iter.bi_size += len;
> +       bio->bi_vcnt++;
> +}
> +EXPORT_SYMBOL_GPL(__bio_add_page);

Given both __bio_try_merge_page() and __bio_add_page() are exported,
please add WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)), otherwise
both may be misused by external users.

-- 
Ming Lei
