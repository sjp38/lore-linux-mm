Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 159576B0389
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 20:14:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so4210782pfx.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 17:14:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s3si207520pgn.344.2017.03.14.17.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 17:14:20 -0700 (PDT)
Message-ID: <1489536859.2733.53.camel@linux.intel.com>
Subject: Re: [PATCH -mm -v6 5/9] mm, THP, swap: Support to clear
 SWAP_HAS_CACHE for huge page
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 14 Mar 2017 17:14:19 -0700
In-Reply-To: <20170308072613.17634-6-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
	 <20170308072613.17634-6-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> __swapcache_free() is added to support to clear the SWAP_HAS_CACHE flag
> for the huge page.A A This will free the specified swap cluster now.
> Because now this function will be called only in the error path to free
> the swap cluster just allocated.A A So the corresponding swap_map[i] ==
> SWAP_HAS_CACHE, that is, the swap count is 0.A A This makes the
> implementation simpler than that of the ordinary swap entry.
> 
> This will be used for delaying splitting THP (Transparent Huge Page)
> during swapping out.A A Where for one THP to swap out, we will allocate a
> swap cluster, add the THP into the swap cache, then split the THP.A A If
> anything fails after allocating the swap cluster and before splitting
> the THP successfully, the swapcache_free_trans_huge() will be used to
> free the swap space allocated.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
> A include/linux/swap.h |A A 9 +++++++--
> A mm/swapfile.cA A A A A A A A | 34 ++++++++++++++++++++++++++++++++--
> A 2 files changed, 39 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index e3a7609a8989..2f2a6c0363aa 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -394,7 +394,7 @@ extern void swap_shmem_alloc(swp_entry_t);
> A extern int swap_duplicate(swp_entry_t);
> A extern int swapcache_prepare(swp_entry_t);
> A extern void swap_free(swp_entry_t);
> -extern void swapcache_free(swp_entry_t);
> +extern void __swapcache_free(swp_entry_t entry, bool huge);
> A extern void swapcache_free_entries(swp_entry_t *entries, int n);
> A extern int free_swap_and_cache(swp_entry_t);
> A extern int swap_type_of(dev_t, sector_t, struct block_device **);
> @@ -456,7 +456,7 @@ static inline void swap_free(swp_entry_t swp)
> A {
> A }
> A 
> -static inline void swapcache_free(swp_entry_t swp)
> +static inline void __swapcache_free(swp_entry_t swp, bool huge)
> A {
> A }
> A 
> @@ -544,6 +544,11 @@ static inline swp_entry_t get_huge_swap_page(void)
> A }
> A #endif
> A 
> +static inline void swapcache_free(swp_entry_t entry)
> +{
> +	__swapcache_free(entry, false);
> +}
> +
> A #ifdef CONFIG_MEMCG
> A static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> A {
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 7241c937e52b..6019f94afbaf 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -855,6 +855,29 @@ static void swap_free_huge_cluster(struct swap_info_struct *si,
> A 	_swap_entry_free(si, offset, true);
> A }
> A 
> +static void swapcache_free_trans_huge(struct swap_info_struct *si,
> +				A A A A A A swp_entry_t entry)
> +{
> +	unsigned long offset = swp_offset(entry);
> +	unsigned long idx = offset / SWAPFILE_CLUSTER;
> +	struct swap_cluster_info *ci;
> +	unsigned char *map;
> +	unsigned int i;
> +
> +	spin_lock(&si->lock);
> +	ci = lock_cluster(si, offset);
> +	map = si->swap_map + offset;
> +	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
> +		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
> +		map[i] &= ~SWAP_HAS_CACHE;

Nitpicking a bit:
map[i] = 0 A is more readable if map[i] == SWAP_HAS_CACHE here.


Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
