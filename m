Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CC6BD6B0089
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 14:04:36 -0500 (EST)
Date: Sat, 26 Nov 2011 18:31:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] MIPS: changes in VM core for adding THP
Message-ID: <20111126173151.GF8397@redhat.com>
References: <CAJd=RBB2gSCaJSsFfJXBg2zmgzNjXPAn8OakAZACNG0mv2D7nQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBB2gSCaJSsFfJXBg2zmgzNjXPAn8OakAZACNG0mv2D7nQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Daney <ddaney.cavm@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-mm@kvack.org

On Sat, Nov 26, 2011 at 10:43:15PM +0800, Hillf Danton wrote:
> In VM core, window is opened for MIPS to use THP.
> 
> And two simple helper functions are added to easy MIPS a bit.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/Kconfig	Thu Nov 24 21:12:00 2011
> +++ b/mm/Kconfig	Sat Nov 26 22:12:56 2011
> @@ -307,7 +307,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> 
>  config TRANSPARENT_HUGEPAGE
>  	bool "Transparent Hugepage Support"
> -	depends on X86 && MMU
> +	depends on MMU
>  	select COMPACTION
>  	help
>  	  Transparent Hugepages allows the kernel to use huge pages and

Then the build will break for all archs if they enable it, better to
limit the option to those archs that supports it.

> --- a/mm/huge_memory.c	Thu Nov 24 21:12:48 2011
> +++ b/mm/huge_memory.c	Sat Nov 26 22:30:24 2011
> @@ -17,6 +17,7 @@
>  #include <linux/khugepaged.h>
>  #include <linux/freezer.h>
>  #include <linux/mman.h>
> +#include <linux/pagemap.h>
>  #include <asm/tlb.h>
>  #include <asm/pgalloc.h>
>  #include "internal.h"
> @@ -135,6 +136,30 @@ static int set_recommended_min_free_kbyt
>  }
>  late_initcall(set_recommended_min_free_kbytes);
> 
> +/* helper function for MIPS to call pmd_page() indirectly */
> +static inline struct page *__pmd_page(pmd_t pmd)
> +{
> +	struct page *page;
> +
> +#ifdef __HAVE_ARCH_THP_PMD_PAGE
> +	page = thp_pmd_page(pmd);
> +#else
> +	page = pmd_page(pmd);
> +#endif
> +	return page;
> +}

Why do you need this and also a branch in thp_pmd_page checking for
pmd_trans_huge? If you fallback in pmd_page that would mean you're
called by hugetlbfs. Doesn't make much sense to fallback in pmd_page
if the hugepmd format for thp and hugetlbfs is different.

Couldn't you set a different _PAGE_HUGE flag in the pmd in the thp
case to avoid the above? Then you could have a pmd_page that works on
both. Ok it'll be slower and require 1 more branch (but you already
have a branch for something that doesn't seem needed).

pmd_page is only called by hugetlbfs/thp, rest uses pte_offset* so I
don't think a branch would be a big deal and you could hide the fact
he format of the pmd between hugetlbfs and thp is different with a
bitflag on the pmd (if any reserved is available to use to software).

> +
> +/* helper function for MIPS to call update_mmu_cache() indirectly */
> +static inline void __update_mmu_cache(struct vm_area_struct *vma,
> +					unsigned long addr, pmd_t *pmdp)
> +{
> +#ifdef __HAVE_ARCH_UPDATE_MMU_THP
> +	update_mmu_thp(vma, addr, pmdp);
> +#else
> +	update_mmu_cache(vma, addr, pmdp);
> +#endif
> +}

Maybe here same, check pmd_trans_huge (and make it succeed only in the
thp case and not the hugetlbfs case) and avoid it the __ and the ifdefs.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
