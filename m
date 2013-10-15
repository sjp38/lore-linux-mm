Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 38DE76B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 05:59:54 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8550460pbb.41
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:59:53 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so8480362pbb.20
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:59:51 -0700 (PDT)
Date: Tue, 15 Oct 2013 02:59:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: fix setting PAGE_SIZE blocksize during swapoff/swapon
 race
In-Reply-To: <1381759136-8616-1-git-send-email-k.kozlowski@samsung.com>
Message-ID: <alpine.LNX.2.00.1310150257030.6194@eggly.anvils>
References: <1381759136-8616-1-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Weijie Yang <weijie.yang.kh@gmail.com>, Michal Hocko <mhocko@suse.cz>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Mon, 14 Oct 2013, Krzysztof Kozlowski wrote:

> Fix race between swapoff and swapon resulting in setting blocksize of
> PAGE_SIZE for block devices during swapoff.
> 
> The swapon modifies swap_info->old_block_size before acquiring
> swapon_mutex. It reads block_size of bdev, stores it under
> swap_info->old_block_size and sets new block_size to PAGE_SIZE.
> 
> On the other hand the swapoff sets the device's block_size to
> old_block_size after releasing swapon_mutex.
> 
> This patch locks the swapon_mutex much earlier during swapon. It also
> releases the swapon_mutex later during swapoff.
> 
> The effect of race can be triggered by following scenario:
>  - One block swap device with block size of 512
>  - thread 1: Swapon is called, swap is activated,
>    p->old_block_size = block_size(p->bdev); /512/
>    block_size(p->bdev) = PAGE_SIZE;
>    Thread ends.
> 
>  - thread 2: Swapoff is called and it goes just after releasing the
>    swapon_mutex. The swap is now fully disabled except of setting the
>    block size to old value. The p->bdev->block_size is still equal to
>    PAGE_SIZE.
> 
>  - thread 3: New swapon is called. This swap is disabled so without
>    acquiring the swapon_mutex:
>    - p->old_block_size = block_size(p->bdev); /PAGE_SIZE (!!!)/
>    - block_size(p->bdev) = PAGE_SIZE;
>    Swap is activated and thread ends.
> 
>  - thread 2: resumes work and sets blocksize to old value:
>    - set_blocksize(bdev, p->old_block_size)
>    But now the p->old_block_size is equal to PAGE_SIZE.
> 
> The patch swap-fix-set_blocksize-race-during-swapon-swapoff does not fix
> this particular issue. It reduces the possibility of races as the swapon
> must overwrite p->old_block_size before acquiring swapon_mutex in
> swapoff.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Sorry you're being blown back and forth on this, but I say Nack to
this version.  I've not spent the time to check whether it ends up
correct or not; but your original patch was appropriate to the bug,
and this one is just unnecessary churn in my view.

Hugh

> ---
>  mm/swapfile.c |   20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 3963fc2..9b64ef4 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1926,7 +1926,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  	frontswap_invalidate_area(type);
> -	mutex_unlock(&swapon_mutex);
>  	free_percpu(p->percpu_cluster);
>  	p->percpu_cluster = NULL;
>  	vfree(swap_map);
> @@ -1946,6 +1945,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  		mutex_unlock(&inode->i_mutex);
>  	}
>  	filp_close(swap_file, NULL);
> +	mutex_unlock(&swapon_mutex);
>  	err = 0;
>  	atomic_inc(&proc_poll_event);
>  	wake_up_interruptible(&proc_poll_wait);
> @@ -2402,37 +2402,38 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		}
>  	}
>  
> +	mutex_lock(&swapon_mutex);
>  	inode = mapping->host;
>  	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
>  	error = claim_swapfile(p, inode);
>  	if (unlikely(error))
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  
>  	/*
>  	 * Read the swap header.
>  	 */
>  	if (!mapping->a_ops->readpage) {
>  		error = -EINVAL;
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  	}
>  	page = read_mapping_page(mapping, 0, swap_file);
>  	if (IS_ERR(page)) {
>  		error = PTR_ERR(page);
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  	}
>  	swap_header = kmap(page);
>  
>  	maxpages = read_swap_header(p, swap_header, inode);
>  	if (unlikely(!maxpages)) {
>  		error = -EINVAL;
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  	}
>  
>  	/* OK, set up the swap map and apply the bad block list */
>  	swap_map = vzalloc(maxpages);
>  	if (!swap_map) {
>  		error = -ENOMEM;
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  	}
>  	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
>  		p->flags |= SWP_SOLIDSTATE;
> @@ -2462,13 +2463,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  
>  	error = swap_cgroup_swapon(p->type, maxpages);
>  	if (error)
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  
>  	nr_extents = setup_swap_map_and_extents(p, swap_header, swap_map,
>  		cluster_info, maxpages, &span);
>  	if (unlikely(nr_extents < 0)) {
>  		error = nr_extents;
> -		goto bad_swap;
> +		goto bad_swap_wmutex;
>  	}
>  	/* frontswap enabled? set up bit-per-page map for frontswap */
>  	if (frontswap_enabled)
> @@ -2504,7 +2505,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		}
>  	}
>  
> -	mutex_lock(&swapon_mutex);
>  	prio = -1;
>  	if (swap_flags & SWAP_FLAG_PREFER)
>  		prio =
> @@ -2529,6 +2529,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		inode->i_flags |= S_SWAPFILE;
>  	error = 0;
>  	goto out;
> +bad_swap_wmutex:
> +	mutex_unlock(&swapon_mutex);
>  bad_swap:
>  	free_percpu(p->percpu_cluster);
>  	p->percpu_cluster = NULL;
> -- 
> 1.7.9.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
