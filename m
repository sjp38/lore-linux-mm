Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0DD16B0003
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 16:24:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so5539273pld.23
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:24:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u123-v6si8308472pgb.414.2018.06.29.13.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Jun 2018 13:24:32 -0700 (PDT)
Subject: Re: [PATCH] mm: make DEFERRED_STRUCT_PAGE_INIT explicitly depend on
 SPARSEMEM
References: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e10d9623-3b66-2853-18c9-9d6eea273270@infradead.org>
Date: Fri, 29 Jun 2018 13:24:28 -0700
MIME-Version: 1.0
In-Reply-To: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 06/29/2018 06:35 AM, Mike Rapoport wrote:
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
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Thanks, I was running into that problem also.

Tested-by: Randy Dunlap <rdunlap@infradead.org>


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
> 


-- 
~Randy
