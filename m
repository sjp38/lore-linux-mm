Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31CC96B037C
	for <linux-mm@kvack.org>; Wed, 16 May 2018 21:40:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d4-v6so1755099plr.17
        for <linux-mm@kvack.org>; Wed, 16 May 2018 18:40:06 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b65-v6si3737267plb.162.2018.05.16.18.40.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 18:40:05 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: fix nr_rotate_swap leak in swapon() error case
References: <b6fe6b879f17fa68eee6cbd876f459f6e5e33495.1526491581.git.osandov@fb.com>
Date: Thu, 17 May 2018 09:40:03 +0800
In-Reply-To: <b6fe6b879f17fa68eee6cbd876f459f6e5e33495.1526491581.git.osandov@fb.com>
	(Omar Sandoval's message of "Wed, 16 May 2018 10:56:22 -0700")
Message-ID: <87h8n7xdos.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com

Omar Sandoval <osandov@osandov.com> writes:

> From: Omar Sandoval <osandov@fb.com>
>
> If swapon() fails after incrementing nr_rotate_swap, we don't decrement
> it and thus effectively leak it. Make sure we decrement it if we
> incremented it.
>
> Fixes: 81a0298bdfab ("mm, swap: don't use VMA based swap readahead if HDD is used as swap")
> Signed-off-by: Omar Sandoval <osandov@fb.com>

Good catch!  Thanks!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
> Based on v4.17-rc5.
>
>  mm/swapfile.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index cc2cf04d9018..78a015fcec3b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3112,6 +3112,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	unsigned long *frontswap_map = NULL;
>  	struct page *page = NULL;
>  	struct inode *inode = NULL;
> +	bool inced_nr_rotate_swap = false;
>  
>  	if (swap_flags & ~SWAP_FLAGS_VALID)
>  		return -EINVAL;
> @@ -3215,8 +3216,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  			cluster = per_cpu_ptr(p->percpu_cluster, cpu);
>  			cluster_set_null(&cluster->index);
>  		}
> -	} else
> +	} else {
>  		atomic_inc(&nr_rotate_swap);
> +		inced_nr_rotate_swap = true;
> +	}
>  
>  	error = swap_cgroup_swapon(p->type, maxpages);
>  	if (error)
> @@ -3307,6 +3310,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	vfree(swap_map);
>  	kvfree(cluster_info);
>  	kvfree(frontswap_map);
> +	if (inced_nr_rotate_swap)
> +		atomic_dec(&nr_rotate_swap);
>  	if (swap_file) {
>  		if (inode && S_ISREG(inode->i_mode)) {
>  			inode_unlock(inode);
