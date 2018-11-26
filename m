Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7416B4438
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:56:54 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so8767252pgc.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:56:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i128sor2520749pgc.75.2018.11.26.14.56.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:56:53 -0800 (PST)
Date: Mon, 26 Nov 2018 14:56:49 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 16/20] block: enable multipage bvecs
Message-ID: <20181126225649.GP30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-17-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-17-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:16AM +0800, Ming Lei wrote:
> This patch pulls the trigger for multi-page bvecs.

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/bio.c         | 22 +++++++++++++++-------
>  fs/iomap.c          |  4 ++--
>  fs/xfs/xfs_aops.c   |  4 ++--
>  include/linux/bio.h |  2 +-
>  4 files changed, 20 insertions(+), 12 deletions(-)
> 
> diff --git a/block/bio.c b/block/bio.c
> index 75fde30af51f..8bf9338d4783 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -753,6 +753,8 @@ EXPORT_SYMBOL(bio_add_pc_page);
>   * @page: page to add
>   * @len: length of the data to add
>   * @off: offset of the data in @page
> + * @same_page: if %true only merge if the new data is in the same physical
> + *		page as the last segment of the bio.
>   *
>   * Try to add the data at @page + @off to the last bvec of @bio.  This is a
>   * a useful optimisation for file systems with a block size smaller than the
> @@ -761,19 +763,25 @@ EXPORT_SYMBOL(bio_add_pc_page);
>   * Return %true on success or %false on failure.
>   */
>  bool __bio_try_merge_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off)
> +		unsigned int len, unsigned int off, bool same_page)
>  {
>  	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
>  		return false;
>  
>  	if (bio->bi_vcnt > 0) {
>  		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
> +			bv->bv_offset + bv->bv_len;
> +		phys_addr_t page_addr = page_to_phys(page);
>  
> -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> -			bv->bv_len += len;
> -			bio->bi_iter.bi_size += len;
> -			return true;
> -		}
> +		if (vec_end_addr != page_addr + off)
> +			return false;
> +		if (same_page && ((vec_end_addr - 1) & PAGE_MASK) != page_addr)
> +			return false;
> +
> +		bv->bv_len += len;
> +		bio->bi_iter.bi_size += len;
> +		return true;
>  	}
>  	return false;
>  }
> @@ -819,7 +827,7 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
>  int bio_add_page(struct bio *bio, struct page *page,
>  		 unsigned int len, unsigned int offset)
>  {
> -	if (!__bio_try_merge_page(bio, page, len, offset)) {
> +	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
>  		if (bio_full(bio))
>  			return 0;
>  		__bio_add_page(bio, page, len, offset);
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 1f648d098a3b..ec5527b0fba4 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -313,7 +313,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	 */
>  	sector = iomap_sector(iomap, pos);
>  	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
> -		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
> +		if (__bio_try_merge_page(ctx->bio, page, plen, poff, true))
>  			goto done;
>  		is_contig = true;
>  	}
> @@ -344,7 +344,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		ctx->bio->bi_end_io = iomap_read_end_io;
>  	}
>  
> -	__bio_add_page(ctx->bio, page, plen, poff);
> +	bio_add_page(ctx->bio, page, plen, poff);
>  done:
>  	/*
>  	 * Move the caller beyond our range so that it keeps making progress.
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 1f1829e506e8..b9fd44168f61 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -616,12 +616,12 @@ xfs_add_to_ioend(
>  				bdev, sector);
>  	}
>  
> -	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
> +	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff, true)) {
>  		if (iop)
>  			atomic_inc(&iop->write_count);
>  		if (bio_full(wpc->ioend->io_bio))
>  			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
> -		__bio_add_page(wpc->ioend->io_bio, page, len, poff);
> +		bio_add_page(wpc->ioend->io_bio, page, len, poff);
>  	}
>  
>  	wpc->ioend->io_size += len;
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index c35997dd02c2..5505f74aef8b 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -441,7 +441,7 @@ extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
>  extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
>  			   unsigned int, unsigned int);
>  bool __bio_try_merge_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off);
> +		unsigned int len, unsigned int off, bool same_page);
>  void __bio_add_page(struct bio *bio, struct page *page,
>  		unsigned int len, unsigned int off);
>  int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
> -- 
> 2.9.5
> 
