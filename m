Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5B7D6B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 21:07:58 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so5074643pbc.41
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:07:58 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id i8si12419185pav.306.2014.01.31.18.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 18:07:57 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id q10so4968401pdj.38
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:07:57 -0800 (PST)
Date: Fri, 31 Jan 2014 18:07:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff
 and swapon
In-Reply-To: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
Message-ID: <alpine.LSU.2.11.1401311729250.4217@eggly.anvils>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, shli@fusionio.com, Bob Liu <bob.liu@oracle.com>, k.kozlowski@samsung.com, weijie.yang.kh@gmail.com

On Thu, 9 Jan 2014, Weijie Yang wrote:

> swapoff clear swap_info's SWP_USED flag prematurely and free its resources
> after that. A concurrent swapon will reuse this swap_info while its previous
> resources are not cleared completely.
> 
> These late freed resources are:
> - p->percpu_cluster
> - swap_cgroup_ctrl[type]
> - block_device setting
> - inode->i_flags &= ~S_SWAPFILE
> 
> This patch clear SWP_USED flag after all its resources freed, so that swapon
> can reuse this swap_info by alloc_swap_info() safely.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org

I've now read through the thread at last, and think this (or akpm's
mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
more clearly commented version) is the best of the patches on offer.

I agree that it fixes Krzysztof's set_blocksize issue among others,
and I prefer this one to his.  Largely because I dislike swapon_mutex:
it has always felt like one lock too many, so, contrary to akpm, I'm
usually (perhaps irrationally) resistant to extending its use.

swapon_mutex came into existence (as swapon_sem in 2.6.6) to handle a
very specific might_sleep issue where /proc/swaps was using swap_lock.
I may have abused it myself since in swapoff, not sure offhand: but
think of it as proc_swaps_mutex, that's what it's really about.

I'm sorry for derailing the previous discussion with my set_blocksize
doubts: I still don't understand what that's all about, but we didn't
get any clarification, and I now accept that it's safer to go on
doing what we've always done there - plus these fixes.

I think the use of swap_lock below is actually unnecessary, isn't it?
This is the only piece of code that might be writing to p->flags at
this point, and if another piece of code catches the before state
or the after state, so what?

But let's go ahead with
mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
as is: no need to remove every redundancy (there is more near here!),
and I may be playing too trickily.

Thanks for the patch: I'll explain in a separate response
why I prefer this to your later 2/8 version.

Hugh

> ---
>  mm/swapfile.c |   11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 612a7c9..89071c3
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1922,7 +1922,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	p->swap_map = NULL;
>  	cluster_info = p->cluster_info;
>  	p->cluster_info = NULL;
> -	p->flags = 0;
>  	frontswap_map = frontswap_map_get(p);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
> @@ -1948,6 +1947,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  		mutex_unlock(&inode->i_mutex);
>  	}
>  	filp_close(swap_file, NULL);
> +
> +	/*
> +	* clear SWP_USED flag after all resources freed
> +	* so that swapon can reuse this swap_info in alloc_swap_info() safely
> +	* it is ok to not hold p->lock after we cleared its SWP_WRITEOK
> +	*/
> +	spin_lock(&swap_lock);
> +	p->flags = 0;
> +	spin_unlock(&swap_lock);
> +
>  	err = 0;
>  	atomic_inc(&proc_poll_event);
>  	wake_up_interruptible(&proc_poll_wait);
> -- 
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
