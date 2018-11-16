Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A65356B0698
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 19:22:02 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id k125so14193865pga.5
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:22:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z19-v6sor34474462plo.58.2018.11.15.16.22.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 16:22:01 -0800 (PST)
Date: Thu, 15 Nov 2018 16:21:57 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 07/19] btrfs: use bvec_last_segment to get bio's last
 page
Message-ID: <20181116002157.GB23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-8-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-8-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:54PM +0800, Ming Lei wrote:
> Preparing for supporting multi-page bvec.
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

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  fs/btrfs/compression.c | 5 ++++-
>  fs/btrfs/extent_io.c   | 5 +++--
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
> index 2955a4ea2fa8..161e14b8b180 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -400,8 +400,11 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
>  static u64 bio_end_offset(struct bio *bio)
>  {
>  	struct bio_vec *last = bio_last_bvec_all(bio);
> +	struct bio_vec bv;
>  
> -	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
> +	bvec_last_segment(last, &bv);
> +
> +	return page_offset(bv.bv_page) + bv.bv_len + bv.bv_offset;
>  }
>  
>  static noinline int add_ra_bio_pages(struct inode *inode,
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index d228f706ff3e..5d5965297e7e 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -2720,11 +2720,12 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
>  {
>  	blk_status_t ret = 0;
>  	struct bio_vec *bvec = bio_last_bvec_all(bio);
> -	struct page *page = bvec->bv_page;
> +	struct bio_vec bv;
>  	struct extent_io_tree *tree = bio->bi_private;
>  	u64 start;
>  
> -	start = page_offset(page) + bvec->bv_offset;
> +	bvec_last_segment(bvec, &bv);
> +	start = page_offset(bv.bv_page) + bv.bv_offset;
>  
>  	bio->bi_private = NULL;
>  
> -- 
> 2.9.5
> 
