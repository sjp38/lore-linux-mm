Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3E35E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 05:46:08 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so8560510pbc.15
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:46:07 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so8676080pad.23
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:46:05 -0700 (PDT)
Date: Tue, 15 Oct 2013 02:45:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: fix set_blocksize race during swapon/swapoff
In-Reply-To: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
Message-ID: <alpine.LNX.2.00.1310150235110.6194@eggly.anvils>
References: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Fri, 11 Oct 2013, Krzysztof Kozlowski wrote:

> Swapoff used old_block_size from swap_info which could be overwritten by
> concurrent swapon.
> 
> Reported-by: Weijie Yang <weijie.yang.kh@gmail.com>
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Acked-by: Hugh Dickins <hughd@google.com>

Yes, this is straightforward: it was relying on p->old_block_size
after it had given up its hold on *p: a use-after-free (though
those slots are not freed back to a lower-level allocator).

What is not obvious is why swapon needs to use set_blocksize() at all:
if I knew once upon a time, I've forgotten now: because a bdev starts
out with blocksize 0 and someone needs to set it non-0??

> ---
>  mm/swapfile.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3963fc2..de7c904 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1824,6 +1824,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	struct filename *pathname;
>  	int i, type, prev;
>  	int err;
> +	unsigned int old_block_size;
>  
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> @@ -1914,6 +1915,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	}
>  
>  	swap_file = p->swap_file;
> +	old_block_size = p->old_block_size;
>  	p->swap_file = NULL;
>  	p->max = 0;
>  	swap_map = p->swap_map;
> @@ -1938,7 +1940,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	inode = mapping->host;
>  	if (S_ISBLK(inode->i_mode)) {
>  		struct block_device *bdev = I_BDEV(inode);
> -		set_blocksize(bdev, p->old_block_size);
> +		set_blocksize(bdev, old_block_size);
>  		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
>  	} else {
>  		mutex_lock(&inode->i_mutex);
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
