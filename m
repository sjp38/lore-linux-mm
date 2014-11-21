Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 919B090001C
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 10:39:23 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id hy10so2434355vcb.6
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 07:39:23 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wz1si2706193vcb.80.2014.11.21.07.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 07:39:20 -0800 (PST)
Message-ID: <546F5C98.4030202@oracle.com>
Date: Fri, 21 Nov 2014 09:39:04 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] direct-io: don't dirty ITER_BVEC pages on read
References: <cover.1416563833.git.osandov@osandov.com> <d5e6bbb3e54f76bbc11ffd106bc98a2c531b67ad.1416563833.git.osandov@osandov.com>
In-Reply-To: <d5e6bbb3e54f76bbc11ffd106bc98a2c531b67ad.1416563833.git.osandov@osandov.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>
Cc: Ming Lei <ming.lei@canonical.com>

On 11/21/2014 04:08 AM, Omar Sandoval wrote:
> Reads through the iov_iter infrastructure for kernel pages shouldn't be dirtied
> by the direct I/O code.
> 
> This is based on Dave Kleikamp's and Ming Lei's previously posted patches.

Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>

> Cc: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Omar Sandoval <osandov@osandov.com>
> ---
>  fs/direct-io.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index e181b6b..e542ce4 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -120,6 +120,7 @@ struct dio {
>  	spinlock_t bio_lock;		/* protects BIO fields below */
>  	int page_errors;		/* errno from get_user_pages() */
>  	int is_async;			/* is IO async ? */
> +	int should_dirty;		/* should we mark read pages dirty? */
>  	bool defer_completion;		/* defer AIO completion to workqueue? */
>  	int io_error;			/* IO error in completion path */
>  	unsigned long refcount;		/* direct_io_worker() and bios */
> @@ -392,7 +393,7 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
>  	dio->refcount++;
>  	spin_unlock_irqrestore(&dio->bio_lock, flags);
>  
> -	if (dio->is_async && dio->rw == READ)
> +	if (dio->is_async && dio->rw == READ && dio->should_dirty)
>  		bio_set_pages_dirty(bio);
>  
>  	if (sdio->submit_io)
> @@ -463,13 +464,13 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio)
>  	if (!uptodate)
>  		dio->io_error = -EIO;
>  
> -	if (dio->is_async && dio->rw == READ) {
> +	if (dio->is_async && dio->rw == READ && dio->should_dirty) {
>  		bio_check_pages_dirty(bio);	/* transfers ownership */
>  	} else {
>  		bio_for_each_segment_all(bvec, bio, i) {
>  			struct page *page = bvec->bv_page;
>  
> -			if (dio->rw == READ && !PageCompound(page))
> +			if (dio->rw == READ && !PageCompound(page) && dio->should_dirty)
>  				set_page_dirty_lock(page);
>  			page_cache_release(page);
>  		}
> @@ -1177,6 +1178,7 @@ do_blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
>  
>  	dio->inode = inode;
>  	dio->rw = rw;
> +	dio->should_dirty = !(iter->type & ITER_BVEC);
>  
>  	/*
>  	 * For AIO O_(D)SYNC writes we need to defer completions to a workqueue
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
