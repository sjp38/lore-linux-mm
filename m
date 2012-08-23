Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2CBFB6B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:11:59 -0400 (EDT)
Date: Thu, 23 Aug 2012 19:11:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: hugetlb: add arch hook for clearing page flags
 before entering pool
Message-ID: <20120823171156.GE19968@dhcp22.suse.cz>
References: <1345739833-25008-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345739833-25008-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org

On Thu 23-08-12 17:37:13, Will Deacon wrote:
> The core page allocator ensures that page flags are zeroed when freeing
> pages via free_pages_check. A number of architectures (ARM, PPC, MIPS)
> rely on this property to treat new pages as dirty with respect to the
> data cache and perform the appropriate flushing before mapping the pages
> into userspace.
> 
> This can lead to cache synchronisation problems when using hugepages,
> since the allocator keeps its own pool of pages above the usual page
> allocator and does not reset the page flags when freeing a page into
> the pool.
> 
> This patch adds a new architecture hook, arch_clear_hugepage_flags, so
> that architectures which rely on the page flags being in a particular
> state for fresh allocations can adjust the flags accordingly when a
> page is freed into the pool.
> 
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Looks good to me
Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> 
> v2: Made ia64 and powerpc code a nop, moved hook to free_huge_page
> 
>  arch/ia64/include/asm/hugetlb.h    |    4 ++++
>  arch/mips/include/asm/hugetlb.h    |    4 ++++
>  arch/powerpc/include/asm/hugetlb.h |    4 ++++
>  arch/s390/include/asm/hugetlb.h    |    1 +
>  arch/sh/include/asm/hugetlb.h      |    6 ++++++
>  arch/sparc/include/asm/hugetlb.h   |    4 ++++
>  arch/tile/include/asm/hugetlb.h    |    4 ++++
>  arch/x86/include/asm/hugetlb.h     |    4 ++++
>  mm/hugetlb.c                       |    1 +
>  9 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index da55c63..94eaa5b 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -77,4 +77,8 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #endif /* _ASM_IA64_HUGETLB_H */
> diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
> index 58d3688..bd94946 100644
> --- a/arch/mips/include/asm/hugetlb.h
> +++ b/arch/mips/include/asm/hugetlb.h
> @@ -112,4 +112,8 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #endif /* __ASM_HUGETLB_H */
> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index dfdb95b..62e11a3 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -151,6 +151,10 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #else /* ! CONFIG_HUGETLB_PAGE */
>  static inline void flush_hugetlb_page(struct vm_area_struct *vma,
>  				      unsigned long vmaddr)
> diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
> index 799ed0f..faa7655 100644
> --- a/arch/s390/include/asm/hugetlb.h
> +++ b/arch/s390/include/asm/hugetlb.h
> @@ -33,6 +33,7 @@ static inline int prepare_hugepage_range(struct file *file,
>  }
>  
>  #define hugetlb_prefault_arch_hook(mm)		do { } while (0)
> +#define arch_clear_hugepage_flags(page)		do { } while (0)
>  
>  int arch_prepare_hugepage(struct page *page);
>  void arch_release_hugepage(struct page *page);
> diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
> index 967068f..b3808c7 100644
> --- a/arch/sh/include/asm/hugetlb.h
> +++ b/arch/sh/include/asm/hugetlb.h
> @@ -1,6 +1,7 @@
>  #ifndef _ASM_SH_HUGETLB_H
>  #define _ASM_SH_HUGETLB_H
>  
> +#include <asm/cacheflush.h>
>  #include <asm/page.h>
>  
>  
> @@ -89,4 +90,9 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +	clear_bit(PG_dcache_clean, &page->flags);
> +}
> +
>  #endif /* _ASM_SH_HUGETLB_H */
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index 1770610..e7927c9 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -82,4 +82,8 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #endif /* _ASM_SPARC64_HUGETLB_H */
> diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
> index b204238..0f885af 100644
> --- a/arch/tile/include/asm/hugetlb.h
> +++ b/arch/tile/include/asm/hugetlb.h
> @@ -106,6 +106,10 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #ifdef CONFIG_HUGETLB_SUPER_PAGES
>  static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  				       struct page *page, int writable)
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 439a9ac..bdd35db 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -90,4 +90,8 @@ static inline void arch_release_hugepage(struct page *page)
>  {
>  }
>  
> +static inline void arch_clear_hugepage_flags(struct page *page)
> +{
> +}
> +
>  #endif /* _ASM_X86_HUGETLB_H */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc72712..f1bb534 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -637,6 +637,7 @@ static void free_huge_page(struct page *page)
>  		h->surplus_huge_pages--;
>  		h->surplus_huge_pages_node[nid]--;
>  	} else {
> +		arch_clear_hugepage_flags(page);
>  		enqueue_huge_page(h, page);
>  	}
>  	spin_unlock(&hugetlb_lock);
> -- 
> 1.7.4.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
