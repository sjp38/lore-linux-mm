Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 462526B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 01:41:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so11765483pff.6
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 22:41:37 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 89si3591600ple.523.2017.09.24.22.41.35
        for <linux-mm@kvack.org>;
        Sun, 24 Sep 2017 22:41:35 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:41:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170925054133.GB27410@bbox>
References: <20170921013310.31348-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921013310.31348-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Hi Huang,

On Thu, Sep 21, 2017 at 09:33:10AM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patch adds a new Kconfig option VMA_SWAP_READAHEAD and wraps VMA
> based swap readahead code inside #ifdef CONFIG_VMA_SWAP_READAHEAD/#endif.
> This is more friendly for tiny kernels.  And as pointed to by Minchan
> Kim, give people who want to disable the swap readahead an opportunity
> to notice the changes to the swap readahead algorithm and the
> corresponding knobs.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  include/linux/mm_types.h |  2 ++
>  include/linux/swap.h     | 64 +++++++++++++++++++++++++-----------------------
>  mm/Kconfig               | 20 +++++++++++++++
>  mm/swap_state.c          | 25 ++++++++++++-------
>  4 files changed, 72 insertions(+), 39 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 46f4ecf5479a..51da54d8027f 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -336,7 +336,9 @@ struct vm_area_struct {
>  	struct file * vm_file;		/* File we map to (can be NULL). */
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>  
> +#ifdef CONFIG_VMA_SWAP_READAHEAD
>  	atomic_long_t swap_readahead_info;
> +#endif
>  #ifndef CONFIG_MMU
>  	struct vm_region *vm_region;	/* NOMMU mapping region */
>  #endif
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 8a807292037f..ebc783a23b80 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -278,6 +278,7 @@ struct swap_info_struct {
>  #endif
>  
>  struct vma_swap_readahead {
> +#ifdef CONFIG_VMA_SWAP_READAHEAD
>  	unsigned short win;
>  	unsigned short offset;
>  	unsigned short nr_pte;
> @@ -286,6 +287,7 @@ struct vma_swap_readahead {
>  #else
>  	pte_t ptes[SWAP_RA_PTE_CACHE_SIZE];
>  #endif
> +#endif
>  };
>  
>  /* linux/mm/workingset.c */
> @@ -387,7 +389,6 @@ int generic_swapfile_activate(struct swap_info_struct *, struct file *,
>  #define SWAP_ADDRESS_SPACE_SHIFT	14
>  #define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)
>  extern struct address_space *swapper_spaces[];
> -extern bool swap_vma_readahead;
>  #define swap_address_space(entry)			    \
>  	(&swapper_spaces[swp_type(entry)][swp_offset(entry) \
>  		>> SWAP_ADDRESS_SPACE_SHIFT])
> @@ -412,23 +413,12 @@ extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
>  extern struct page *swapin_readahead(swp_entry_t, gfp_t,
>  			struct vm_area_struct *vma, unsigned long addr);
>  
> -extern struct page *swap_readahead_detect(struct vm_fault *vmf,
> -					  struct vma_swap_readahead *swap_ra);
> -extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
> -					   struct vm_fault *vmf,
> -					   struct vma_swap_readahead *swap_ra);
> -
>  /* linux/mm/swapfile.c */
>  extern atomic_long_t nr_swap_pages;
>  extern long total_swap_pages;
>  extern atomic_t nr_rotate_swap;
>  extern bool has_usable_swap(void);
>  
> -static inline bool swap_use_vma_readahead(void)
> -{
> -	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
> -}
> -
>  /* Swap 50% full? Release swapcache more aggressively.. */
>  static inline bool vm_swap_full(void)
>  {
> @@ -518,24 +508,6 @@ static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
>  	return NULL;
>  }
>  
> -static inline bool swap_use_vma_readahead(void)
> -{
> -	return false;
> -}
> -
> -static inline struct page *swap_readahead_detect(
> -	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
> -{
> -	return NULL;
> -}
> -
> -static inline struct page *do_swap_page_readahead(
> -	swp_entry_t fentry, gfp_t gfp_mask,
> -	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
> -{
> -	return NULL;
> -}
> -
>  static inline int swap_writepage(struct page *p, struct writeback_control *wbc)
>  {
>  	return 0;
> @@ -662,5 +634,37 @@ static inline bool mem_cgroup_swap_full(struct page *page)
>  }
>  #endif
>  
> +#ifdef CONFIG_VMA_SWAP_READAHEAD
> +extern bool swap_vma_readahead;
> +
> +static inline bool swap_use_vma_readahead(void)
> +{
> +	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
> +}
> +extern struct page *swap_readahead_detect(struct vm_fault *vmf,
> +					  struct vma_swap_readahead *swap_ra);
> +extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
> +					   struct vm_fault *vmf,
> +					   struct vma_swap_readahead *swap_ra);
> +#else
> +static inline bool swap_use_vma_readahead(void)
> +{
> +	return false;
> +}
> +
> +static inline struct page *swap_readahead_detect(struct vm_fault *vmf,
> +				struct vma_swap_readahead *swap_ra)
> +{
> +	return NULL;
> +}
> +
> +static inline struct page *do_swap_page_readahead(swp_entry_t fentry,
> +				gfp_t gfp_mask, struct vm_fault *vmf,
> +				struct vma_swap_readahead *swap_ra)
> +{
> +	return NULL;
> +}
> +#endif
> +
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9c4bdddd80c2..e62c8e2e34ef 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -434,6 +434,26 @@ config THP_SWAP
>  
>  	  For selection by architectures with reasonable THP sizes.
>  
> +config VMA_SWAP_READAHEAD
> +	bool "VMA based swap readahead"
> +	depends on SWAP
> +	default y
> +	help
> +	  VMA based swap readahead detects page accessing pattern in a
> +	  VMA and adjust the swap readahead window for pages in the
> +	  VMA accordingly.  It works better for more complex workload
> +	  compared with the original physical swap readahead.
> +
> +	  It can be controlled via the following sysfs interface,
> +
> +	    /sys/kernel/mm/swap/vma_ra_enabled
> +	    /sys/kernel/mm/swap/vma_ra_max_order

It might be better to discuss in other thread but if you mention new
interface here again, I will discuss it here.

We are creating new ABI in here so I want to ask question in here.

Did you consier to use /sys/block/xxx/queue/read_ahead_kb for the
swap readahead knob? Reusing such common/consistent knob would be better
than adding new separate konb.

> +
> +	  If set to no, the original physical swap readahead will be
> +	  used.

In here, could you point out kindly somewhere where describes two
readahead algorithm in the system?

I don't mean we should explain how it works. Rather than, there are
two parallel algorithm in swap readahead.

Anonymous memory works based on VMA while shm works based on physical
block. There are working separately on parallel. Each of knobs are
vma_ra_max_order and page-cluster, blah, blah.

> +
> +	  If unsure, say Y to enable VMA based swap readahead.
> +
>  config	TRANSPARENT_HUGE_PAGECACHE
>  	def_bool y
>  	depends on TRANSPARENT_HUGEPAGE
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 71ce2d1ccbf7..6d6f6a534bf9 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -37,11 +37,6 @@ static const struct address_space_operations swap_aops = {
>  
>  struct address_space *swapper_spaces[MAX_SWAPFILES];
>  static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
> -bool swap_vma_readahead = true;
> -
> -#define SWAP_RA_MAX_ORDER_DEFAULT	3
> -
> -static int swap_ra_max_order = SWAP_RA_MAX_ORDER_DEFAULT;
>  
>  #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
>  #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
> @@ -324,8 +319,7 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  			       unsigned long addr)
>  {
>  	struct page *page;
> -	unsigned long ra_info;
> -	int win, hits, readahead;
> +	int readahead;
>  
>  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
>  
> @@ -335,7 +329,11 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  		if (unlikely(PageTransCompound(page)))
>  			return page;
>  		readahead = TestClearPageReadahead(page);
> +#ifdef CONFIG_VMA_SWAP_READAHEAD
>  		if (vma) {
> +			unsigned long ra_info;
> +			int win, hits;
> +
>  			ra_info = GET_SWAP_RA_VAL(vma);
>  			win = SWAP_RA_WIN(ra_info);
>  			hits = SWAP_RA_HITS(ra_info);
> @@ -344,6 +342,7 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  			atomic_long_set(&vma->swap_readahead_info,
>  					SWAP_RA_VAL(addr, win, hits));
>  		}
> +#endif
>  		if (readahead) {
>  			count_vm_event(SWAP_RA_HIT);
>  			if (!vma)
> @@ -625,6 +624,13 @@ void exit_swap_address_space(unsigned int type)
>  	kvfree(spaces);
>  }
>  
> +#ifdef CONFIG_VMA_SWAP_READAHEAD
> +bool swap_vma_readahead = true;
> +
> +#define SWAP_RA_MAX_ORDER_DEFAULT	3
> +
> +static int swap_ra_max_order = SWAP_RA_MAX_ORDER_DEFAULT;
> +
>  static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
>  				     unsigned long faddr,
>  				     unsigned long lpfn,
> @@ -751,8 +757,9 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  	return read_swap_cache_async(fentry, gfp_mask, vma, vmf->address,
>  				     swap_ra->win == 1);
>  }
> +#endif /* CONFIG_VMA_SWAP_READAHEAD */
>  
> -#ifdef CONFIG_SYSFS
> +#if defined(CONFIG_SYSFS) && defined(CONFIG_VMA_SWAP_READAHEAD)
>  static ssize_t vma_ra_enabled_show(struct kobject *kobj,
>  				     struct kobj_attribute *attr, char *buf)
>  {
> @@ -830,4 +837,4 @@ static int __init swap_init_sysfs(void)
>  	return err;
>  }
>  subsys_initcall(swap_init_sysfs);
> -#endif
> +#endif /* defined(CONFIG_SYSFS) && defined(CONFIG_VMA_SWAP_READAHEAD) */
> -- 
> 2.14.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
