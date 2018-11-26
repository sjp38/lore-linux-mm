Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9166B6B441E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:40:06 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69so1520366pff.5
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:40:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor2365228pll.68.2018.11.26.14.40.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:40:05 -0800 (PST)
Date: Mon, 26 Nov 2018 14:40:03 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 14/20] bcache: avoid to use
 bio_for_each_segment_all() in bch_bio_alloc_pages()
Message-ID: <20181126224003.GK30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-15-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-15-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:14AM +0800, Ming Lei wrote:
> bch_bio_alloc_pages() is always called on one new bio, so it is safe
> to access the bvec table directly. Given it is the only kind of this
> case, open code the bvec table access since bio_for_each_segment_all()
> will be changed to support for iterating over multipage bvec.
> 
> Acked-by: Coly Li <colyli@suse.de>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Omar Sandoval <osandov@fb.com>

> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  drivers/md/bcache/util.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
> index 20eddeac1531..62fb917f7a4f 100644
> --- a/drivers/md/bcache/util.c
> +++ b/drivers/md/bcache/util.c
> @@ -270,7 +270,11 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
>  	int i;
>  	struct bio_vec *bv;
>  
> -	bio_for_each_segment_all(bv, bio, i) {
> +	/*
> +	 * This is called on freshly new bio, so it is safe to access the
> +	 * bvec table directly.
> +	 */
> +	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++, i++) {
>  		bv->bv_page = alloc_page(gfp_mask);
>  		if (!bv->bv_page) {
>  			while (--bv >= bio->bi_io_vec)
> -- 
> 2.9.5
> 
