Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 59FF06B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 19:38:07 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so5110844pbb.31
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 16:38:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gm1si8661671pac.216.2014.01.10.16.38.05
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 16:38:06 -0800 (PST)
Date: Fri, 10 Jan 2014 16:38:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff
 and swapon
Message-Id: <20140110163803.430c8ab05eca9fee19fa7991@linux-foundation.org>
In-Reply-To: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, hughd@google.com, 'Minchan Kim' <minchan@kernel.org>, shli@fusionio.com, 'Bob Liu' <bob.liu@oracle.com>, k.kozlowski@samsung.com, stable@vger.kernel.org, weijie.yang.kh@gmail.com

On Thu, 09 Jan 2014 13:39:55 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

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
> ...
>
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

I'm scratching my head over the swap_lock use here.  Is it being used
appropriately, is it the correct lock, etc.

swap_start() and friends are playing with SWP_USED, but they're using
swapon_mutex.  I wonder if a well-timed read of /proc/swaps could cause
problems.

The swapfile.c code does not make for pleasant reading :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
