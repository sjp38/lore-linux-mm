Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9F2B82F66
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 07:07:32 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u14so18316306lfd.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:07:32 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 204si8138331wmk.76.2016.09.08.04.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 04:07:31 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id b187so3314750wme.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:07:31 -0700 (PDT)
Date: Thu, 8 Sep 2016 14:07:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20160908110729.GC17331@node>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <1473266769-2155-2-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473266769-2155-2-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Sep 07, 2016 at 09:46:00AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, the size of the swap cluster is changed to that of the
> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> the THP swap support on x86_64.  Where one swap cluster will be used to
> hold the contents of each THP swapped out.  And some information of the
> swapped out THP (such as compound map count) will be recorded in the
> swap_cluster_info data structure.
> 
> For other architectures which want THP swap support, THP_SWAP_CLUSTER
> need to be selected in the Kconfig file for the architecture.
> 
> In effect, this will enlarge swap cluster size by 2 times on x86_64.
> Which may make it harder to find a free cluster when the swap space
> becomes fragmented.  So that, this may reduce the continuous swap space
> allocation and sequential write in theory.  The performance test in 0day
> shows no regressions caused by this.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  arch/x86/Kconfig |  1 +
>  mm/Kconfig       | 13 +++++++++++++
>  mm/swapfile.c    |  4 ++++
>  3 files changed, 18 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 4c39728..421d862 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -164,6 +164,7 @@ config X86
>  	select HAVE_STACK_VALIDATION		if X86_64
>  	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
>  	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
> +	select ARCH_USES_THP_SWAP_CLUSTER	if X86_64
>  
>  config INSTRUCTION_DECODER
>  	def_bool y
> diff --git a/mm/Kconfig b/mm/Kconfig
> index be0ee11..2da8128 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -503,6 +503,19 @@ config FRONTSWAP
>  
>  	  If unsure, say Y to enable frontswap.
>  
> +config ARCH_USES_THP_SWAP_CLUSTER
> +	bool
> +	default n
> +
> +config THP_SWAP_CLUSTER
> +	bool
> +	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
> +	default y
> +	help
> +	  Use one swap cluster to hold the contents of the THP
> +	  (Transparent Huge Page) swapped out.  The size of the swap
> +	  cluster will be same as that of THP.
> +
>  config CMA
>  	bool "Contiguous Memory Allocator"
>  	depends on HAVE_MEMBLOCK && MMU
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 8f1b97d..4b78402 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -196,7 +196,11 @@ static void discard_swap_cluster(struct swap_info_struct *si,
>  	}
>  }
>  
> +#ifdef CONFIG_THP_SWAP_CLUSTER
> +#define SWAPFILE_CLUSTER	(HPAGE_SIZE / PAGE_SIZE)

#define SWAPFILE_CLUSTER HPAGE_PMD_NR

Note, HPAGE_SIZE is not nessesary HPAGE_PMD_SIZE. I can imagine an arch
with multiple huge page sizes where HPAGE_SIZE differs from what is used
for THP.

> +#else
>  #define SWAPFILE_CLUSTER	256
> +#endif
>  #define LATENCY_LIMIT		256
>  
>  static inline void cluster_set_flag(struct swap_cluster_info *info,
> -- 
> 2.8.1
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
