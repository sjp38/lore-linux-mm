Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7716B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:06:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j200so4773696ioe.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:06:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h184si734923iof.166.2017.06.26.11.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 11:06:56 -0700 (PDT)
Date: Mon, 26 Jun 2017 11:04:01 -0700
From: Liu Bo <bo.li.liu@oracle.com>
Subject: Re: [PATCH v2 14/51] btrfs: avoid to access bvec table directly for
 a cloned bio
Message-ID: <20170626180401.GB31661@lim.localdomain>
Reply-To: bo.li.liu@oracle.com
References: <20170626121034.3051-1-ming.lei@redhat.com>
 <20170626121034.3051-15-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170626121034.3051-15-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org

On Mon, Jun 26, 2017 at 08:09:57PM +0800, Ming Lei wrote:
> Commit 17347cec15f919901c90(Btrfs: change how we iterate bios in endio)
> mentioned that for dio the submitted bio may be fast cloned, we
> can't access the bvec table directly for a cloned bio, so use
> bio_get_first_bvec() to retrieve the 1st bvec.
>

Looks good to me.

Reviewed-by: Liu Bo <bo.li.liu@oracle.com>

-liubo
> Cc: Chris Mason <clm@fb.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: David Sterba <dsterba@suse.com>
> Cc: linux-btrfs@vger.kernel.org
> Cc: Liu Bo <bo.li.liu@oracle.com>
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  fs/btrfs/inode.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 06dea7c89bbd..4ab02b34f029 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -7993,6 +7993,7 @@ static int dio_read_error(struct inode *inode, struct bio *failed_bio,
>  	int read_mode = 0;
>  	int segs;
>  	int ret;
> +	struct bio_vec bvec;
>  
>  	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
>  
> @@ -8008,8 +8009,9 @@ static int dio_read_error(struct inode *inode, struct bio *failed_bio,
>  	}
>  
>  	segs = bio_segments(failed_bio);
> +	bio_get_first_bvec(failed_bio, &bvec);
>  	if (segs > 1 ||
> -	    (failed_bio->bi_io_vec->bv_len > btrfs_inode_sectorsize(inode)))
> +	    (bvec.bv_len > btrfs_inode_sectorsize(inode)))
>  		read_mode |= REQ_FAILFAST_DEV;
>  
>  	isector = start - btrfs_io_bio(failed_bio)->logical;
> -- 
> 2.9.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
