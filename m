Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB64A6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 20:11:11 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so5166658pbc.1
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:11:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id t6si8760078pbg.155.2014.01.10.17.11.09
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 17:11:10 -0800 (PST)
Date: Fri, 10 Jan 2014 17:11:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/swap: fix race on swap_info reuse between swapoff
 and swapon
Message-Id: <20140110171108.32b2be171cd5e54bf22fb2a4@linux-foundation.org>
In-Reply-To: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
References: <000001cf0cfd$6d251640$476f42c0$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, hughd@google.com, 'Minchan Kim' <minchan@kernel.org>, shli@fusionio.com, 'Bob Liu' <bob.liu@oracle.com>, k.kozlowski@samsung.com, stable@vger.kernel.org, weijie.yang.kh@gmail.comKrzysztof Kozlowski <k.kozlowski@samsung.com>

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

I didn't look too closely, but this patch might also address the race
which Krzysztof addressed with
http://ozlabs.org/~akpm/mmots/broken-out/swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch.
Can we please check that out?

I do prefer fixing all these swapon-vs-swapoff races with some large,
simple, wide-scope exclusion scheme.  Perhaps SWP_USED is that scheme.

An alternative would be to add another mutex and just make sys_swapon()
and sys_swapoff() 100% exclusive.  But that is plastering yet another
lock over this mess to hide the horrors which lurk within :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
