Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C3DEC6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 21:26:32 -0500 (EST)
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20120131103416.GA1661@localhost>
References: <1327996780.21268.42.camel@sli10-conroe>
	 <20120131103416.GA1661@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Feb 2012 10:25:26 +0800
Message-ID: <1328063126.21268.54.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <wfg@linux.intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Vivek Goyal <vgoyal@redhat.com>

On Tue, 2012-01-31 at 18:34 +0800, Wu Fengguang wrote:
> I'd like to propose a sister patch on the write part. It may not be
> as easy to measure any performance impacts of it, but I'll try.
I did think about it, the write case doesn't matter because we didn't do
real IO there.
I can do another patch to cleanup the code (moving it to direct_io),
sounds ok?

> ---
> Subject: remove plugging at buffered write time 
> Date: Tue Jan 31 18:25:48 CST 2012
> 
> Buffered write(2) is not directly tied to IO, so no need to handle plug
> in generic_file_aio_write().
> 
> CC: Jens Axboe <axboe@kernel.dk>
> CC: Li Shaohua <shaohua.li@intel.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/filemap.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> --- linux-next.orig/mm/filemap.c	2012-01-31 18:23:52.000000000 +0800
> +++ linux-next/mm/filemap.c	2012-01-31 18:25:38.000000000 +0800
> @@ -2267,6 +2267,7 @@ generic_file_direct_write(struct kiocb *
>  	struct file	*file = iocb->ki_filp;
>  	struct address_space *mapping = file->f_mapping;
>  	struct inode	*inode = mapping->host;
> +	struct blk_plug plug;
>  	ssize_t		written;
>  	size_t		write_len;
>  	pgoff_t		end;
> @@ -2301,7 +2302,9 @@ generic_file_direct_write(struct kiocb *
>  		}
>  	}
>  
> +	blk_start_plug(&plug);
>  	written = mapping->a_ops->direct_IO(WRITE, iocb, iov, pos, *nr_segs);
> +	blk_finish_plug(&plug);
>  
>  	/*
>  	 * Finally, try again to invalidate clean pages which might have been
> @@ -2610,13 +2613,11 @@ ssize_t generic_file_aio_write(struct ki
>  {
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file->f_mapping->host;
> -	struct blk_plug plug;
>  	ssize_t ret;
>  
>  	BUG_ON(iocb->ki_pos != pos);
>  
>  	mutex_lock(&inode->i_mutex);
> -	blk_start_plug(&plug);
>  	ret = __generic_file_aio_write(iocb, iov, nr_segs, &iocb->ki_pos);
>  	mutex_unlock(&inode->i_mutex);
>  
> @@ -2627,7 +2628,6 @@ ssize_t generic_file_aio_write(struct ki
>  		if (err < 0 && ret > 0)
>  			ret = err;
>  	}
> -	blk_finish_plug(&plug);
>  	return ret;
>  }
>  EXPORT_SYMBOL(generic_file_aio_write);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
