Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 8FD046B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 21:43:20 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A0523EE0B6
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:43:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E830145DEAD
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:43:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D317145DE9E
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:43:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C531A1DB803C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:43:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7440E1DB803B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 11:43:18 +0900 (JST)
Date: Thu, 19 Jan 2012 11:42:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
Message-Id: <20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1326912662-18805-1-git-send-email-asharma@fb.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org

On Wed, 18 Jan 2012 10:51:02 -0800
Arun Sharma <asharma@fb.com> wrote:

> This enables malloc optimizations where we might
> madvise(..,MADV_DONTNEED) a page only to fault it
> back at a different virtual address.
> 
> To ensure that we don't leak sensitive data to
> unprivileged processes, we enable this optimization
> only for pages that are reused within a memory
> cgroup.
> 
> The idea is to make this opt-in both at the mmap()
> level and cgroup level so the default behavior is
> unchanged after the patch.
> 
> TODO: Ask for a VM_UNINITIALIZED bit
> TODO: Implement a cgroup level opt-in flag
> 

Hmm, then, 
1. a new task jumped into this cgroup can see any uncleared data...
2. if a memcg pointer is reused, the information will be leaked.
3. If VM_UNINITALIZED is set, the process can see any data which
   was freed by other process which doesn't know VM_UNINITALIZED at all.

4. The process will be able to see file cache data which the it has no
   access right if it's accessed by memcg once.

3 & 4 seems too danger.

Isn't it better to have this as per-task rather than per-memcg ?
And just allow to reuse pages the page has freed ?


Thanks,
-Kame


> To: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: akpm@linux-foundation.org
> Signed-off-by: Arun Sharma <asharma@fb.com>
> ---
>  include/asm-generic/mman-common.h |    6 +-----
>  include/linux/highmem.h           |    6 ++++++
>  include/linux/mm.h                |    2 ++
>  include/linux/mman.h              |    1 +
>  include/linux/page_cgroup.h       |   29 +++++++++++++++++++++++++++++
>  init/Kconfig                      |    2 +-
>  mm/mempolicy.c                    |   29 +++++++++++++++++++++++------
>  7 files changed, 63 insertions(+), 12 deletions(-)
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> index 787abbb..71e079f 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -19,11 +19,7 @@
>  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
>  #define MAP_FIXED	0x10		/* Interpret addr exactly */
>  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> -#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> -# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
> -#else
> -# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
> -#endif
> +#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
>  
>  #define MS_ASYNC	1		/* sync memory asynchronously */
>  #define MS_INVALIDATE	2		/* invalidate the caches */
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 3a93f73..caae922 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -4,6 +4,7 @@
>  #include <linux/fs.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> +#include <linux/page_cgroup.h>
>  #include <linux/uaccess.h>
>  #include <linux/hardirq.h>
>  
> @@ -156,6 +157,11 @@ __alloc_zeroed_user_highpage(gfp_t movableflags,
>  	struct page *page = alloc_page_vma(GFP_HIGHUSER | movableflags,
>  			vma, vaddr);
>  
> +#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> +	if (!page_needs_clearing(page, vma))
> +		return page;
> +#endif
> +
>  	if (page)
>  		clear_user_highpage(page, vaddr);
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4baadd1..c6bab01 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -118,6 +118,8 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
>  #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
>  #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
> +#define VM_UNINITIALIZED VM_SAO		/* Steal a powerpc bit for now, since we're out
> +					   of bits for 32 bit archs */
>  
>  /* Bits set in the VMA until the stack is in its final location */
>  #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index 8b74e9b..9bef6c9 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -87,6 +87,7 @@ calc_vm_flag_bits(unsigned long flags)
>  	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
>  	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
>  	       _calc_vm_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE) |
> +	       _calc_vm_trans(flags, MAP_UNINITIALIZED, VM_UNINITIALIZED) |
>  	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
>  }
>  #endif /* __KERNEL__ */
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 961ecc7..e959869 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -155,6 +155,17 @@ static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
>  	return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
>  }
>  
> +static int mm_match_cgroup(const struct mm_struct *mm,
> +			   const struct mem_cgroup *cgroup);
> +static inline bool page_seen_by_cgroup(struct page *page,
> +				       const struct mm_struct *mm)
> +{
> +	struct page_cgroup *pcg = lookup_page_cgroup(page);
> +	if (pcg == NULL)
> +		return false;
> +	return mm_match_cgroup(mm, pcg->mem_cgroup);
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> @@ -175,8 +186,26 @@ static inline void __init page_cgroup_init_flatmem(void)
>  {
>  }
>  
> +static inline bool page_seen_by_cgroup(struct page *page,
> +				       const struct mm_struct *mm)
> +{
> +	return false;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
>  
> +static inline bool vma_requests_uninitialized(struct vm_area_struct *vma)
> +{
> +	return vma && !vma->vm_file && vma->vm_flags & VM_UNINITIALIZED;
> +}
> +
> +static inline bool page_needs_clearing(struct page *page,
> +				       struct vm_area_struct *vma)
> +{
> +	return !(vma_requests_uninitialized(vma)
> +		&& page_seen_by_cgroup(page, vma->vm_mm));
> +}
> +
>  #include <linux/swap.h>
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> diff --git a/init/Kconfig b/init/Kconfig
> index 43298f9..428e047 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1259,7 +1259,7 @@ endchoice
>  
>  config MMAP_ALLOW_UNINITIALIZED
>  	bool "Allow mmapped anonymous memory to be uninitialized"
> -	depends on EXPERT && !MMU
> +	depends on EXPERT
>  	default n
>  	help
>  	  Normally, and according to the Linux spec, anonymous memory obtained
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index c3fdbcb..7c9ab68 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -90,6 +90,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/ctype.h>
>  #include <linux/mm_inline.h>
> +#include <linux/page_cgroup.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/uaccess.h>
> @@ -1847,6 +1848,11 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  	struct zonelist *zl;
>  	struct page *page;
>  
> +#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> +	if (vma_requests_uninitialized(vma))
> +		gfp &= ~__GFP_ZERO;
> +#endif
> +
>  	get_mems_allowed();
>  	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
>  		unsigned nid;
> @@ -1854,25 +1860,36 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
>  		mpol_cond_put(pol);
>  		page = alloc_page_interleave(gfp, order, nid);
> -		put_mems_allowed();
> -		return page;
> +		goto out;
>  	}
>  	zl = policy_zonelist(gfp, pol, node);
>  	if (unlikely(mpol_needs_cond_ref(pol))) {
>  		/*
>  		 * slow path: ref counted shared policy
>  		 */
> -		struct page *page =  __alloc_pages_nodemask(gfp, order,
> -						zl, policy_nodemask(gfp, pol));
> +		page =  __alloc_pages_nodemask(gfp, order,
> +					       zl, policy_nodemask(gfp, pol));
>  		__mpol_put(pol);
> -		put_mems_allowed();
> -		return page;
> +		goto out;
>  	}
> +
>  	/*
>  	 * fast path:  default or task policy
>  	 */
>  	page = __alloc_pages_nodemask(gfp, order, zl,
>  				      policy_nodemask(gfp, pol));
> +
> +out:
> +#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> +	if (page_needs_clearing(page, vma)) {
> +		int i;
> +		for (i = 0; i < (1 << order); i++) {
> +			void *kaddr = kmap_atomic(page + i, KM_USER0);
> +			clear_page(kaddr);
> +			kunmap_atomic(kaddr, KM_USER0);
> +		}
> +	}
> +#endif
>  	put_mems_allowed();
>  	return page;
>  }
> -- 
> 1.7.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
