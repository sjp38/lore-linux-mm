Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF3F86B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 21:53:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so129905970pgc.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 18:53:00 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u22si2583727plk.137.2017.02.06.18.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 18:52:59 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] swapfile: initialize spinlock for swap_cluster_info
References: <1486434945-29753-1-git-send-email-minchan@kernel.org>
Date: Tue, 07 Feb 2017 10:52:57 +0800
In-Reply-To: <1486434945-29753-1-git-send-email-minchan@kernel.org> (Minchan
	Kim's message of "Tue, 7 Feb 2017 11:35:45 +0900")
Message-ID: <87vasmg19y.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> We changed swap_cluster_info lock from bit_spin_lock to spinlock
> so we need to initialize the spinlock before the using. Otherwise,
> lockdep is broken.
>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Good catch!  Thanks a lot for your fixing!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
> Andrew,
> I think it's no worth to add this patch to separate commit.
> If you don't mind, it's okay to fold this patch to mm-swap-add-cluster-lock-v5.
> Thanks.
>
>  mm/swapfile.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 1fc1824140e1..5ac2cb40dbd3 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2762,6 +2762,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  
>  	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
>  		int cpu;
> +		unsigned long ci, nr_cluster;
>  
>  		p->flags |= SWP_SOLIDSTATE;
>  		/*
> @@ -2769,13 +2770,17 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		 * SSD
>  		 */
>  		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
> +		nr_cluster = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
>  
> -		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
> -			SWAPFILE_CLUSTER) * sizeof(*cluster_info));
> +		cluster_info = vzalloc(nr_cluster * sizeof(*cluster_info));
>  		if (!cluster_info) {
>  			error = -ENOMEM;
>  			goto bad_swap;
>  		}
> +
> +		for (ci = 0; ci < nr_cluster; ci++)
> +			spin_lock_init(&((cluster_info + ci)->lock));
> +
>  		p->percpu_cluster = alloc_percpu(struct percpu_cluster);
>  		if (!p->percpu_cluster) {
>  			error = -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
