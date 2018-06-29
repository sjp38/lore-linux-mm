Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D35FB6B0010
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:48:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j11-v6so3005389edr.15
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 06:48:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8-v6si4628875edl.95.2018.06.29.06.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 06:48:07 -0700 (PDT)
Date: Fri, 29 Jun 2018 15:48:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: make DEFERRED_STRUCT_PAGE_INIT explicitly depend on
 SPARSEMEM
Message-ID: <20180629134806.GE5963@dhcp22.suse.cz>
References: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri 29-06-18 16:35:08, Mike Rapoport wrote:
> The deferred memory initialization relies on section definitions, e.g
> PAGES_PER_SECTION, that are only available when CONFIG_SPARSEMEM=y on most
> architectures.
> 
> Initially DEFERRED_STRUCT_PAGE_INIT depended on explicit
> ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT configuration option, but since the
> commit 2e3ca40f03bb13709df4 ("mm: relax deferred struct page requirements")
> this requirement was relaxed and now it is possible to enable
> DEFERRED_STRUCT_PAGE_INIT on architectures that support DISCONTINGMEM and
> NO_BOOTMEM which causes build failures.
> 
> For instance, setting SMP=y and DEFERRED_STRUCT_PAGE_INIT=y on arc causes
> the following build failure:
> 
>   CC      mm/page_alloc.o
> mm/page_alloc.c: In function 'update_defer_init':
> mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION'
> undeclared (first use in this function); did you mean 'USEC_PER_SEC'?
>       (pfn & (PAGES_PER_SECTION - 1)) == 0) {
>               ^~~~~~~~~~~~~~~~~
>               USEC_PER_SEC
> mm/page_alloc.c:321:14: note: each undeclared
> identifier is reported only once for each function it appears in
> In file included from include/linux/cache.h:5:0,
>                  from include/linux/printk.h:9,
>                  from include/linux/kernel.h:14,
>                  from
> include/asm-generic/bug.h:18,
>                  from
> arch/arc/include/asm/bug.h:32,
>                  from include/linux/bug.h:5,
>                  from include/linux/mmdebug.h:5,
>                  from include/linux/mm.h:9,
>                  from mm/page_alloc.c:18:
> mm/page_alloc.c: In function 'deferred_grow_zone':
> mm/page_alloc.c:1624:52: error:
> 'PAGES_PER_SECTION' undeclared (first use in this function); did you mean
> 'USEC_PER_SEC'?
>   unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
>                                                     ^
> include/uapi/linux/kernel.h:11:47: note: in
> definition of macro '__ALIGN_KERNEL_MASK'
>  #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
>                                                ^~~~
> include/linux/kernel.h:58:22: note: in expansion
> of macro '__ALIGN_KERNEL'
>  #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
>                       ^~~~~~~~~~~~~~
> mm/page_alloc.c:1624:34: note: in expansion of
> macro 'ALIGN'
>   unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
>                                   ^~~~~
> In file included from
> include/asm-generic/bug.h:18:0,
>                  from
> arch/arc/include/asm/bug.h:32,
>                  from include/linux/bug.h:5,
>                  from include/linux/mmdebug.h:5,
>                  from include/linux/mm.h:9,
>                  from mm/page_alloc.c:18:
> mm/page_alloc.c: In function
> 'free_area_init_node':
> mm/page_alloc.c:6379:50: error:
> 'PAGES_PER_SECTION' undeclared (first use in this function); did you mean
> 'USEC_PER_SEC'?
>   pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
>                                                   ^
> include/linux/kernel.h:812:22: note: in definition
> of macro '__typecheck'
>    (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
>                       ^
> include/linux/kernel.h:836:24: note: in expansion
> of macro '__safe_cmp'
>   __builtin_choose_expr(__safe_cmp(x, y), \
>                         ^~~~~~~~~~
> include/linux/kernel.h:904:27: note: in expansion
> of macro '__careful_cmp'
>  #define min_t(type, x, y) __careful_cmp((type)(x), (type)(y), <)
>                            ^~~~~~~~~~~~~
> mm/page_alloc.c:6379:29: note: in expansion of
> macro 'min_t'
>   pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
>                              ^~~~~
> include/linux/kernel.h:836:2: error: first
> argument to '__builtin_choose_expr' not a constant
>   __builtin_choose_expr(__safe_cmp(x, y), \
>   ^
> include/linux/kernel.h:904:27: note: in expansion
> of macro '__careful_cmp'
>  #define min_t(type, x, y) __careful_cmp((type)(x), (type)(y), <)
>                            ^~~~~~~~~~~~~
> mm/page_alloc.c:6379:29: note: in expansion of
> macro 'min_t'
>   pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
>                              ^~~~~
> scripts/Makefile.build:317: recipe for target
> 'mm/page_alloc.o' failed
> 
> Let's make the DEFERRED_STRUCT_PAGE_INIT explicitly depend on SPARSEMEM as
> the systems that support DISCONTIGMEM do not seem to have that huge
> amounts of memory that would make DEFERRED_STRUCT_PAGE_INIT relevant.

OK, I do not see any reasonable large machine would use DISCONTIGMEM.
So this makes sense to me.

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index ce95491..94af022 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -635,7 +635,7 @@ config DEFERRED_STRUCT_PAGE_INIT
>  	bool "Defer initialisation of struct pages to kthreads"
>  	default n
>  	depends on NO_BOOTMEM
> -	depends on !FLATMEM
> +	depends on SPARSEMEM
>  	depends on !NEED_PER_CPU_KM
>  	help
>  	  Ordinarily all struct pages are initialised during early boot in a
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
