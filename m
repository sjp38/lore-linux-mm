Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C7DF86B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 03:48:48 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so4176792bkb.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 00:48:46 -0800 (PST)
Message-ID: <1327999722.2422.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 09:48:42 +0100
In-Reply-To: <1327996780.21268.42.camel@sli10-conroe>
References: <1327996780.21268.42.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <wfg@linux.intel.com>

Le mardi 31 janvier 2012 A  15:59 +0800, Shaohua Li a A(C)crit :
> Herbert Poetzl reported a performance regression since 2.6.39. The test
> is a simple dd read, but with big block size. The reason is:
> 
> T1: ra (A, A+128k), (A+128k, A+256k)
> T2: lock_page for page A, submit the 256k
> T3: hit page A+128K, ra (A+256k, A+384). the range isn't submitted
> because of plug and there isn't any lock_page till we hit page A+256k
> because all pages from A to A+256k is in memory
> T4: hit page A+256k, ra (A+384, A+ 512). Because of plug, the range isn't
> submitted again.
> T5: lock_page A+256k, so (A+256k, A+512k) will be submitted. The task is
> waitting for (A+256k, A+512k) finish.
> 
> There is no request to disk in T3 and T4, so readahead pipeline breaks.
> 
> We really don't need block plug for generic_file_aio_read() for buffered
> I/O. The readahead already has plug and has fine grained control when I/O
> should be submitted. Deleting plug for buffered I/O fixes the regression.
> 
> One side effect is plug makes the request size 256k, the size is 128k
> without it. This is because default ra size is 128k and not a reason we
> need plug here.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> Tested-by: Herbert Poetzl <herbert@13thfloor.at>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Hmm, this is not exactly the patch I tested from Wu Fengguang 

I'll test this one before adding my "Tested-by: ..."

> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 97f49ed..b662757 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1400,15 +1400,12 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  	unsigned long seg = 0;
>  	size_t count;
>  	loff_t *ppos = &iocb->ki_pos;
> -	struct blk_plug plug;
>  
>  	count = 0;
>  	retval = generic_segment_checks(iov, &nr_segs, &count, VERIFY_WRITE);
>  	if (retval)
>  		return retval;
>  
> -	blk_start_plug(&plug);
> -
>  	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
>  	if (filp->f_flags & O_DIRECT) {
>  		loff_t size;
> @@ -1424,8 +1421,12 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			retval = filemap_write_and_wait_range(mapping, pos,
>  					pos + iov_length(iov, nr_segs) - 1);
>  			if (!retval) {
> +				struct blk_plug plug;
> +
> +				blk_start_plug(&plug);

This part was not on the tested patch yesterday.

>  				retval = mapping->a_ops->direct_IO(READ, iocb,
>  							iov, pos, nr_segs);
> +				blk_finish_plug(&plug);
>  			}
>  			if (retval > 0) {
>  				*ppos = pos + retval;
> @@ -1481,7 +1482,6 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			break;
>  	}
>  out:
> -	blk_finish_plug(&plug);
>  	return retval;
>  }
>  EXPORT_SYMBOL(generic_file_aio_read);
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
