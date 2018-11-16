Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9E9A6B06D4
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 20:22:49 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i19-v6so17570177pfi.21
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:22:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor32939plv.9.2018.11.15.17.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 17:22:48 -0800 (PST)
Date: Thu, 15 Nov 2018 17:22:45 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 12/19] block: allow bio_for_each_segment_all() to
 iterate over multi-page bvec
Message-ID: <20181116012245.GG23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-13-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-13-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:59PM +0800, Ming Lei wrote:
> This patch introduces one extra iterator variable to bio_for_each_segment_all(),
> then we can allow bio_for_each_segment_all() to iterate over multi-page bvec.
> 
> Given it is just one mechannical & simple change on all bio_for_each_segment_all()
> users, this patch does tree-wide change in one single patch, so that we can
> avoid to use a temporary helper for this conversion.
> 
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: linux-raid@vger.kernel.org
> Cc: linux-erofs@lists.ozlabs.org
> Cc: linux-btrfs@vger.kernel.org
> Cc: David Sterba <dsterba@suse.com>
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
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
>  block/bio.c                       | 27 ++++++++++++++++++---------
>  block/blk-zoned.c                 |  1 +
>  block/bounce.c                    |  6 ++++--
>  drivers/md/bcache/btree.c         |  3 ++-
>  drivers/md/dm-crypt.c             |  3 ++-
>  drivers/md/raid1.c                |  3 ++-
>  drivers/staging/erofs/data.c      |  3 ++-
>  drivers/staging/erofs/unzip_vle.c |  3 ++-
>  fs/block_dev.c                    |  6 ++++--
>  fs/btrfs/compression.c            |  3 ++-
>  fs/btrfs/disk-io.c                |  3 ++-
>  fs/btrfs/extent_io.c              | 12 ++++++++----
>  fs/btrfs/inode.c                  |  6 ++++--
>  fs/btrfs/raid56.c                 |  3 ++-
>  fs/crypto/bio.c                   |  3 ++-
>  fs/direct-io.c                    |  4 +++-
>  fs/exofs/ore.c                    |  3 ++-
>  fs/exofs/ore_raid.c               |  3 ++-
>  fs/ext4/page-io.c                 |  3 ++-
>  fs/ext4/readpage.c                |  3 ++-
>  fs/f2fs/data.c                    |  9 ++++++---
>  fs/gfs2/lops.c                    |  6 ++++--
>  fs/gfs2/meta_io.c                 |  3 ++-
>  fs/iomap.c                        |  6 ++++--
>  fs/mpage.c                        |  3 ++-
>  fs/xfs/xfs_aops.c                 |  5 +++--
>  include/linux/bio.h               | 11 +++++++++--
>  include/linux/bvec.h              | 31 +++++++++++++++++++++++++++++++
>  28 files changed, 129 insertions(+), 46 deletions(-)
> 

[snip]

> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 3496c816946e..1a2430a8b89d 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -131,12 +131,19 @@ static inline bool bio_full(struct bio *bio)
>  	return bio->bi_vcnt >= bio->bi_max_vecs;
>  }
>  
> +#define bvec_for_each_segment(bv, bvl, i, iter_all)			\
> +	for (bv = bvec_init_iter_all(&iter_all);			\
> +		(iter_all.done < (bvl)->bv_len) &&			\
> +		((bvec_next_segment((bvl), &iter_all)), 1);		\

The parentheses around (bvec_next_segment((bvl), &iter_all)) are
unnecessary.

> +		iter_all.done += bv->bv_len, i += 1)
> +
>  /*
>   * drivers should _never_ use the all version - the bio may have been split
>   * before it got to the driver and the driver won't own all of it
>   */
> -#define bio_for_each_segment_all(bvl, bio, i)				\
> -	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
> +#define bio_for_each_segment_all(bvl, bio, i, iter_all)		\
> +	for (i = 0, iter_all.idx = 0; iter_all.idx < (bio)->bi_vcnt; iter_all.idx++)	\
> +		bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)

Would it be possible to move i into iter_all to streamline this a bit?

>  static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
>  				      unsigned bytes, bool mp)
> diff --git a/include/linux/bvec.h b/include/linux/bvec.h
> index 01616a0b6220..02f26d2b59ad 100644
> --- a/include/linux/bvec.h
> +++ b/include/linux/bvec.h
> @@ -82,6 +82,12 @@ struct bvec_iter {
>  						   current bvec */
>  };
>  
> +struct bvec_iter_all {
> +	struct bio_vec	bv;
> +	int		idx;
> +	unsigned	done;
> +};
> +
>  /*
>   * various member access, note that bio_data should of course not be used
>   * on highmem page vectors
> @@ -216,6 +222,31 @@ static inline bool mp_bvec_iter_advance(const struct bio_vec *bv,
>  	.bi_bvec_done	= 0,						\
>  }
>  
> +static inline struct bio_vec *bvec_init_iter_all(struct bvec_iter_all *iter_all)
> +{
> +	iter_all->bv.bv_page = NULL;
> +	iter_all->done = 0;
> +
> +	return &iter_all->bv;
> +}
> +
> +/* used for chunk_for_each_segment */
> +static inline void bvec_next_segment(const struct bio_vec *bvec,
> +		struct bvec_iter_all *iter_all)

Indentation.

> +{
> +	struct bio_vec *bv = &iter_all->bv;
> +
> +	if (bv->bv_page) {
> +		bv->bv_page += 1;
> +		bv->bv_offset = 0;
> +	} else {
> +		bv->bv_page = bvec->bv_page;
> +		bv->bv_offset = bvec->bv_offset;
> +	}
> +	bv->bv_len = min_t(unsigned int, PAGE_SIZE - bv->bv_offset,
> +			bvec->bv_len - iter_all->done);

Indentation.

> +}
> +
>  /*
>   * Get the last singlepage segment from the multipage bvec and store it
>   * in @seg
> -- 
> 2.9.5
> 
