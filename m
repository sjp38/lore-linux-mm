Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56E696B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:37:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p192so1660597wme.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 00:37:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w72si14639149wrc.19.2017.01.18.00.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 00:37:35 -0800 (PST)
Date: Wed, 18 Jan 2017 09:37:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-swap-add-cluster-lock-v5.patch added to -mm tree
Message-ID: <20170118083731.GF7015@dhcp22.suse.cz>
References: <587eaca3.MRSwND8OEi+lF+VH%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <587eaca3.MRSwND8OEi+lF+VH%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ying.huang@intel.com, aarcange@redhat.com, aaron.lu@intel.com, ak@linux.intel.com, borntraeger@de.ibm.com, corbet@lwn.net, dave.hansen@intel.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hughd@google.com, kirill.shutemov@linux.intel.com, minchan@kernel.org, riel@redhat.com, shli@kernel.org, tim.c.chen@linux.intel.com, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 15:45:39, Andrew Morton wrote:
[...]
> From: "Huang\, Ying" <ying.huang@intel.com>
> Subject: mm-swap-add-cluster-lock-v5

I assume you are going to fold this into the original patch. Do you
think it would make sense to have it in a separate patch along with
the reasoning provided via email?

> Link: http://lkml.kernel.org/r/878tqeuuic.fsf_-_@yhuang-dev.intel.com
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Aaron Lu <aaron.lu@intel.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Jonathan Corbet <corbet@lwn.net> escreveu:
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/swap.h |   19 ++++++++++---------
>  mm/swapfile.c        |   32 ++++++++++++++++----------------
>  2 files changed, 26 insertions(+), 25 deletions(-)
> 
> diff -puN include/linux/swap.h~mm-swap-add-cluster-lock-v5 include/linux/swap.h
> --- a/include/linux/swap.h~mm-swap-add-cluster-lock-v5
> +++ a/include/linux/swap.h
> @@ -176,16 +176,17 @@ enum {
>   * protected by swap_info_struct.lock.
>   */
>  struct swap_cluster_info {
> -	unsigned long data;
> +	spinlock_t lock;	/*
> +				 * Protect swap_cluster_info fields
> +				 * and swap_info_struct->swap_map
> +				 * elements correspond to the swap
> +				 * cluster
> +				 */
> +	unsigned int data:24;
> +	unsigned int flags:8;
>  };
> -#define CLUSTER_COUNT_SHIFT		8
> -#define CLUSTER_FLAG_MASK		((1UL << CLUSTER_COUNT_SHIFT) - 1)
> -#define CLUSTER_COUNT_MASK		(~CLUSTER_FLAG_MASK)
> -#define CLUSTER_FLAG_FREE		1 /* This cluster is free */
> -#define CLUSTER_FLAG_NEXT_NULL		2 /* This cluster has no next cluster */
> -/* cluster lock, protect cluster_info contents and sis->swap_map */
> -#define CLUSTER_FLAG_LOCK_BIT		2
> -#define CLUSTER_FLAG_LOCK		(1 << CLUSTER_FLAG_LOCK_BIT)
> +#define CLUSTER_FLAG_FREE 1 /* This cluster is free */
> +#define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
>  
>  /*
>   * We assign a cluster to each CPU, so each CPU can allocate swap entry from
> diff -puN mm/swapfile.c~mm-swap-add-cluster-lock-v5 mm/swapfile.c
> --- a/mm/swapfile.c~mm-swap-add-cluster-lock-v5
> +++ a/mm/swapfile.c
> @@ -200,66 +200,66 @@ static void discard_swap_cluster(struct
>  #define LATENCY_LIMIT		256
>  
>  static inline void cluster_set_flag(struct swap_cluster_info *info,
> -				    unsigned int flag)
> +	unsigned int flag)
>  {
> -	info->data = (info->data & (CLUSTER_COUNT_MASK | CLUSTER_FLAG_LOCK)) |
> -		(flag & ~CLUSTER_FLAG_LOCK);
> +	info->flags = flag;
>  }
>  
>  static inline unsigned int cluster_count(struct swap_cluster_info *info)
>  {
> -	return info->data >> CLUSTER_COUNT_SHIFT;
> +	return info->data;
>  }
>  
>  static inline void cluster_set_count(struct swap_cluster_info *info,
>  				     unsigned int c)
>  {
> -	info->data = (c << CLUSTER_COUNT_SHIFT) | (info->data & CLUSTER_FLAG_MASK);
> +	info->data = c;
>  }
>  
>  static inline void cluster_set_count_flag(struct swap_cluster_info *info,
>  					 unsigned int c, unsigned int f)
>  {
> -	info->data = (info->data & CLUSTER_FLAG_LOCK) |
> -		(c << CLUSTER_COUNT_SHIFT) | (f & ~CLUSTER_FLAG_LOCK);
> +	info->flags = f;
> +	info->data = c;
>  }
>  
>  static inline unsigned int cluster_next(struct swap_cluster_info *info)
>  {
> -	return cluster_count(info);
> +	return info->data;
>  }
>  
>  static inline void cluster_set_next(struct swap_cluster_info *info,
>  				    unsigned int n)
>  {
> -	cluster_set_count(info, n);
> +	info->data = n;
>  }
>  
>  static inline void cluster_set_next_flag(struct swap_cluster_info *info,
>  					 unsigned int n, unsigned int f)
>  {
> -	cluster_set_count_flag(info, n, f);
> +	info->flags = f;
> +	info->data = n;
>  }
>  
>  static inline bool cluster_is_free(struct swap_cluster_info *info)
>  {
> -	return info->data & CLUSTER_FLAG_FREE;
> +	return info->flags & CLUSTER_FLAG_FREE;
>  }
>  
>  static inline bool cluster_is_null(struct swap_cluster_info *info)
>  {
> -	return info->data & CLUSTER_FLAG_NEXT_NULL;
> +	return info->flags & CLUSTER_FLAG_NEXT_NULL;
>  }
>  
>  static inline void cluster_set_null(struct swap_cluster_info *info)
>  {
> -	cluster_set_next_flag(info, 0, CLUSTER_FLAG_NEXT_NULL);
> +	info->flags = CLUSTER_FLAG_NEXT_NULL;
> +	info->data = 0;
>  }
>  
> -/* Protect swap_cluster_info fields and si->swap_map */
>  static inline void __lock_cluster(struct swap_cluster_info *ci)
>  {
> -	bit_spin_lock(CLUSTER_FLAG_LOCK_BIT, &ci->data);
> +	spin_lock(&ci->lock);
>  }
>  
>  static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
> @@ -278,7 +278,7 @@ static inline struct swap_cluster_info *
>  static inline void unlock_cluster(struct swap_cluster_info *ci)
>  {
>  	if (ci)
> -		bit_spin_unlock(CLUSTER_FLAG_LOCK_BIT, &ci->data);
> +		spin_unlock(&ci->lock);
>  }
>  
>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
> _
> 
> Patches currently in -mm which might be from ying.huang@intel.com are
> 
> mm-swap-fix-kernel-message-in-swap_info_get.patch
> mm-swap-add-cluster-lock.patch
> mm-swap-add-cluster-lock-v5.patch
> mm-swap-split-swap-cache-into-64mb-trunks.patch
> mm-swap-add-cache-for-swap-slots-allocation-fix.patch
> mm-swap-skip-readahead-only-when-swap-slot-cache-is-enabled.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
