Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D80076B440C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:28:55 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so21779856plt.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:28:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor2335855pll.68.2018.11.26.14.28.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:28:54 -0800 (PST)
Date: Mon, 26 Nov 2018 14:28:51 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 01/20] btrfs: remove various bio_offset arguments
Message-ID: <20181126222851.GH30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-2-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-2-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:01AM +0800, Ming Lei wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> The btrfs write path passes a bio_offset argument through some deep
> callchains including async offloading.  In the end this is easily
> calculatable using page_offset plus the bvec offset for the first
> page in the bio, and only actually used by by a single function.
> Just move the calculation of the offset there.
> 
> Reviewed-by: David Sterba <dsterba@suse.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/btrfs/disk-io.c   | 21 +++++----------------
>  fs/btrfs/disk-io.h   |  2 +-
>  fs/btrfs/extent_io.c |  9 ++-------
>  fs/btrfs/extent_io.h |  5 ++---
>  fs/btrfs/inode.c     | 17 ++++++++---------
>  5 files changed, 18 insertions(+), 36 deletions(-)

[snip]

> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 9ea4c6f0352f..c576b3fcaea7 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -1920,8 +1920,7 @@ int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
>   * At IO completion time the cums attached on the ordered extent record
>   * are inserted into the btree
>   */
> -static blk_status_t btrfs_submit_bio_start(void *private_data, struct bio *bio,
> -				    u64 bio_offset)
> +static blk_status_t btrfs_submit_bio_start(void *private_data, struct bio *bio)
>  {
>  	struct inode *inode = private_data;
>  	blk_status_t ret = 0;
> @@ -1973,8 +1972,7 @@ blk_status_t btrfs_submit_bio_done(void *private_data, struct bio *bio,
>   *    c-3) otherwise:			async submit
>   */
>  static blk_status_t btrfs_submit_bio_hook(void *private_data, struct bio *bio,
> -				 int mirror_num, unsigned long bio_flags,
> -				 u64 bio_offset)
> +				 int mirror_num, unsigned long bio_flags)
>  {
>  	struct inode *inode = private_data;
>  	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
> @@ -2011,8 +2009,7 @@ static blk_status_t btrfs_submit_bio_hook(void *private_data, struct bio *bio,
>  			goto mapit;
>  		/* we're doing a write, do the async checksumming */
>  		ret = btrfs_wq_submit_bio(fs_info, bio, mirror_num, bio_flags,
> -					  bio_offset, inode,
> -					  btrfs_submit_bio_start);
> +					  inode, btrfs_submit_bio_start);
>  		goto out;
>  	} else if (!skip_sum) {
>  		ret = btrfs_csum_one_bio(inode, bio, 0, 0);
> @@ -8123,10 +8120,13 @@ static void btrfs_endio_direct_write(struct bio *bio)
>  }
>  
>  static blk_status_t btrfs_submit_bio_start_direct_io(void *private_data,
> -				    struct bio *bio, u64 offset)
> +				    struct bio *bio)
>  {
>  	struct inode *inode = private_data;
> +	struct bio_vec *bvec = bio_first_bvec_all(bio);
> +	u64 offset = page_offset(bvec->bv_page) + bvec->bv_offset;

Hm, but for direct I/O, these will be user pages (or the zero page), so
page_offset() won't be valid?

>  	blk_status_t ret;
> +
>  	ret = btrfs_csum_one_bio(inode, bio, offset, 1);
>  	BUG_ON(ret); /* -ENOMEM */
>  	return 0;
