Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B84386B0694
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 19:20:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12-v6so15685236plo.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:20:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10-v6sor34478826pla.29.2018.11.15.16.20.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 16:20:24 -0800 (PST)
Date: Thu, 15 Nov 2018 16:20:20 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 06/19] fs/buffer.c: use bvec iterator to truncate the
 bio
Message-ID: <20181116002020.GA23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-7-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-7-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:53PM +0800, Ming Lei wrote:
> Once multi-page bvec is enabled, the last bvec may include more than one
> page, this patch use bvec_last_segment() to truncate the bio.
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
>  fs/buffer.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 1286c2b95498..fa37ad52e962 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -3032,7 +3032,10 @@ void guard_bio_eod(int op, struct bio *bio)
>  
>  	/* ..and clear the end of the buffer for reads */
>  	if (op == REQ_OP_READ) {
> -		zero_user(bvec->bv_page, bvec->bv_offset + bvec->bv_len,
> +		struct bio_vec bv;
> +
> +		bvec_last_segment(bvec, &bv);
> +		zero_user(bv.bv_page, bv.bv_offset + bv.bv_len,
>  				truncated_bytes);
>  	}
>  }
> -- 
> 2.9.5
> 
