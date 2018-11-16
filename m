Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9EC66B06EF
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 20:47:02 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d6-v6so17599055pfn.19
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:47:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v62sor25042241pgd.23.2018.11.15.17.47.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 17:47:01 -0800 (PST)
Date: Thu, 15 Nov 2018 17:46:58 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 13/19] iomap & xfs: only account for new added page
Message-ID: <20181116014658.GH23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-14-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-14-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:00PM +0800, Ming Lei wrote:
> After multi-page is enabled, one new page may be merged to a segment
> even though it is a new added page.
> 
> This patch deals with this issue by post-check in case of merge, and
> only a freshly new added page need to be dealt with for iomap & xfs.
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
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  fs/iomap.c          | 22 ++++++++++++++--------
>  fs/xfs/xfs_aops.c   | 10 ++++++++--
>  include/linux/bio.h | 11 +++++++++++
>  3 files changed, 33 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index df0212560b36..a1b97a5c726a 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -288,6 +288,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	loff_t orig_pos = pos;
>  	unsigned poff, plen;
>  	sector_t sector;
> +	bool need_account = false;
>  
>  	if (iomap->type == IOMAP_INLINE) {
>  		WARN_ON_ONCE(pos);
> @@ -313,18 +314,15 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	 */
>  	sector = iomap_sector(iomap, pos);
>  	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
> -		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
> +		if (__bio_try_merge_page(ctx->bio, page, plen, poff)) {
> +			need_account = iop && bio_is_last_segment(ctx->bio,
> +					page, plen, poff);

It's redundant to make this iop && ... since you already check
iop && need_account below. Maybe rename it to added_page? Also, this
indentation is wack.

>  			goto done;
> +		}
>  		is_contig = true;
>  	}
>  
> -	/*
> -	 * If we start a new segment we need to increase the read count, and we
> -	 * need to do so before submitting any previous full bio to make sure
> -	 * that we don't prematurely unlock the page.
> -	 */
> -	if (iop)
> -		atomic_inc(&iop->read_count);
> +	need_account = true;
>  
>  	if (!ctx->bio || !is_contig || bio_full(ctx->bio)) {
>  		gfp_t gfp = mapping_gfp_constraint(page->mapping, GFP_KERNEL);
> @@ -347,6 +345,14 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	__bio_add_page(ctx->bio, page, plen, poff);
>  done:
>  	/*
> +	 * If we add a new page we need to increase the read count, and we
> +	 * need to do so before submitting any previous full bio to make sure
> +	 * that we don't prematurely unlock the page.
> +	 */
> +	if (iop && need_account)
> +		atomic_inc(&iop->read_count);
> +
> +	/*
>  	 * Move the caller beyond our range so that it keeps making progress.
>  	 * For that we have to include any leading non-uptodate ranges, but
>  	 * we can skip trailing ones as they will be handled in the next
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 1f1829e506e8..d8e9cc9f751a 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -603,6 +603,7 @@ xfs_add_to_ioend(
>  	unsigned		len = i_blocksize(inode);
>  	unsigned		poff = offset & (PAGE_SIZE - 1);
>  	sector_t		sector;
> +	bool			need_account;
>  
>  	sector = xfs_fsb_to_db(ip, wpc->imap.br_startblock) +
>  		((offset - XFS_FSB_TO_B(mp, wpc->imap.br_startoff)) >> 9);
> @@ -617,13 +618,18 @@ xfs_add_to_ioend(
>  	}
>  
>  	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
> -		if (iop)
> -			atomic_inc(&iop->write_count);
> +		need_account = true;
>  		if (bio_full(wpc->ioend->io_bio))
>  			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
>  		__bio_add_page(wpc->ioend->io_bio, page, len, poff);
> +	} else {
> +		need_account = iop && bio_is_last_segment(wpc->ioend->io_bio,
> +				page, len, poff);

Same here, no need for iop &&, rename it added_page, indentation is off.

>  	}
>  
> +	if (iop && need_account)
> +		atomic_inc(&iop->write_count);
> +
>  	wpc->ioend->io_size += len;
>  }
>  
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 1a2430a8b89d..5040e9a2eb09 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -341,6 +341,17 @@ static inline struct bio_vec *bio_last_bvec_all(struct bio *bio)
>  	return &bio->bi_io_vec[bio->bi_vcnt - 1];
>  }
>  
> +/* iomap needs this helper to deal with sub-pagesize bvec */
> +static inline bool bio_is_last_segment(struct bio *bio, struct page *page,
> +		unsigned int len, unsigned int off)

Indentation.

> +{
> +	struct bio_vec bv;
> +
> +	bvec_last_segment(bio_last_bvec_all(bio), &bv);
> +
> +	return bv.bv_page == page && bv.bv_len == len && bv.bv_offset == off;
> +}
> +
>  enum bip_flags {
>  	BIP_BLOCK_INTEGRITY	= 1 << 0, /* block layer owns integrity data */
>  	BIP_MAPPED_INTEGRITY	= 1 << 1, /* ref tag has been remapped */
> -- 
> 2.9.5
> 
