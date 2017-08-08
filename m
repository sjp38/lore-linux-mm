Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2C36B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 12:33:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so5214164wmh.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:33:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m15si1657926edb.511.2017.08.08.09.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 09:33:07 -0700 (PDT)
Date: Tue, 8 Aug 2017 09:32:32 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v3 41/49] xfs: convert to bio_for_each_segment_all_sp()
Message-ID: <20170808163232.GO24087@magnolia>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-42-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-42-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@vger.kernel.org

On Tue, Aug 08, 2017 at 04:45:40PM +0800, Ming Lei wrote:

Sure would be nice to have a changelog explaining why we're doing this.

> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: linux-xfs@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  fs/xfs/xfs_aops.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 6bf120bb1a17..94df43dcae0b 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -139,6 +139,7 @@ xfs_destroy_ioend(
>  	for (bio = &ioend->io_inline_bio; bio; bio = next) {
>  		struct bio_vec	*bvec;
>  		int		i;
> +		struct bvec_iter_all bia;
>  
>  		/*
>  		 * For the last bio, bi_private points to the ioend, so we
> @@ -150,7 +151,7 @@ xfs_destroy_ioend(
>  			next = bio->bi_private;
>  
>  		/* walk each page on bio, ending page IO on them */
> -		bio_for_each_segment_all(bvec, bio, i)
> +		bio_for_each_segment_all_sp(bvec, bio, i, bia)

It's confusing that you're splitting the old bio_for_each_segment_all
into multipage and singlepage variants, but bio_for_each_segment_all
continues to exist?

Hmm, the new multipage variant aliases the name bio_for_each_segment_all,
so clearly the _all function's sematics have changed a bit, but its name
and signature haven't, which seems likely to trip up someone who didn't
notice the behavioral change.

Is it still valid to call bio_for_each_segment_all?  I get the feeling
from this patchset that you're really supposed to decide whether you
want one page at a time or more than one page at a time and choose _sp
or _mp?

(And, seeing how this was the only patch sent to this list, the chances
are higher of someone missing out on these subtle changes...)

--D

>  			xfs_finish_page_writeback(inode, bvec, error);
>  
>  		bio_put(bio);
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
