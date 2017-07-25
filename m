Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2555A6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 16:51:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c184so14270219wmd.6
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 13:51:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e136si7999924wmg.137.2017.07.25.13.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 13:51:02 -0700 (PDT)
Date: Tue, 25 Jul 2017 13:50:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v3 6/6] mm, swap: Don't use VMA based swap
 readahead if HDD is used as swap
Message-Id: <20170725135059.11d65c1f6f17101e977f2b59@linux-foundation.org>
In-Reply-To: <20170725015151.19502-7-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
	<20170725015151.19502-7-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Tue, 25 Jul 2017 09:51:51 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> VMA based swap readahead will readahead the virtual pages that is
> continuous in the virtual address space.  While the original swap
> readahead will readahead the swap slots that is continuous in the swap
> device.  Although VMA based swap readahead is more correct for the
> swap slots to be readahead, it will trigger more small random
> readings, which may cause the performance of HDD (hard disk) to
> degrade heavily, and may finally exceed the benefit.
> 
> To avoid the issue, in this patch, if the HDD is used as swap, the VMA
> based swap readahead will be disabled, and the original swap readahead
> will be used instead.
>
> ...
> 
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -399,16 +399,17 @@ extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  					   struct vm_fault *vmf,
>  					   struct vma_swap_readahead *swap_ra);
>  
> -static inline bool swap_use_vma_readahead(void)
> -{
> -	return READ_ONCE(swap_vma_readahead);
> -}
> -
>  /* linux/mm/swapfile.c */
>  extern atomic_long_t nr_swap_pages;
>  extern long total_swap_pages;
> +extern atomic_t nr_rotate_swap;

This is rather ugly.  If the system is swapping to both an SSD and to a
spinning disk, we'll treat the spinning disk as SSD.

Surely this decision can be made in a per-device fashion?

>  extern bool has_usable_swap(void);
>  
> +static inline bool swap_use_vma_readahead(void)
> +{
> +	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
> +}
> +
>  /* Swap 50% full? Release swapcache more aggressively.. */
>  static inline bool vm_swap_full(void)
>  {
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6ba4aab2db0b..2685b9951cc1 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -96,6 +96,8 @@ static DECLARE_WAIT_QUEUE_HEAD(proc_poll_wait);
>  /* Activity counter to indicate that a swapon or swapoff has occurred */
>  static atomic_t proc_poll_event = ATOMIC_INIT(0);
>  
> +atomic_t nr_rotate_swap = ATOMIC_INIT(0);
> +
>  static inline unsigned char swap_count(unsigned char ent)
>  {
>  	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
> @@ -2387,6 +2389,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	if (p->flags & SWP_CONTINUED)
>  		free_swap_count_continuations(p);
>  
> +	if (!p->bdev || !blk_queue_nonrot(bdev_get_queue(p->bdev)))
> +		atomic_dec(&nr_rotate_swap);

What's that p->bdev test for?  It's not symmetrical with the
sys_swapon() change and one wonders if the counter can get out of sync.


>  	mutex_lock(&swapon_mutex);
>  	spin_lock(&swap_lock);
>  	spin_lock(&p->lock);
> @@ -2963,7 +2968,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  			cluster = per_cpu_ptr(p->percpu_cluster, cpu);
>  			cluster_set_null(&cluster->index);
>  		}
> -	}
> +	} else
> +		atomic_inc(&nr_rotate_swap);
>  
>  	error = swap_cgroup_swapon(p->type, maxpages);
>  	if (error)
> -- 
> 2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
