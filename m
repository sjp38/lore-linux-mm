Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 680366B02C9
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:43:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e18-v6so615813pgt.3
        for <linux-mm@kvack.org>; Tue, 15 May 2018 13:43:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r16-v6si749448pgu.219.2018.05.15.13.43.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 13:43:48 -0700 (PDT)
Date: Tue, 15 May 2018 22:43:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5] mm: don't allow deferred pages with NEED_PER_CPU_KM
Message-ID: <20180515204340.GL12670@dhcp22.suse.cz>
References: <20180515175124.1770-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180515175124.1770-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Tue 15-05-18 13:51:24, Pavel Tatashin wrote:
> It is unsafe to do virtual to physical translations before mm_init() is
> called if struct page is needed in order to determine the memory section
> number (see SECTION_IN_PAGE_FLAGS). This is because only in mm_init() we
> initialize struct pages for all the allocated memory when deferred struct
> pages are used.
> 
> My recent fix exposed this problem, because it greatly reduced number of
> pages that are initialized before mm_init(), but the problem existed even
> before my fix, as Fengguang Wu found.
> 
> Below is a more detailed explanation of the problem.
> 
> We initialize struct pages in four places:
> 
> 1. Early in boot a small set of struct pages is initialized to fill
> the first section, and lower zones.
> 2. During mm_init() we initialize "struct pages" for all the memory
> that is allocated, i.e reserved in memblock.
> 3. Using on-demand logic when pages are allocated after mm_init call (when
> memblock is finished)
> 4. After smp_init() when the rest free deferred pages are initialized.
> 
> The problem occurs if we try to do va to phys translation of a memory
> between steps 1 and 2. Because we have not yet initialized struct pages for
> all the reserved pages, it is inherently unsafe to do va to phys if the
> translation itself requires access of "struct page" as in case of this
> combination: CONFIG_SPARSE && !CONFIG_SPARSE_VMEMMAP
> 
> The following path exposes the problem:
> 
> start_kernel()
>  trap_init()
>   setup_cpu_entry_areas()
>    setup_cpu_entry_area(cpu)
>     get_cpu_gdt_paddr(cpu)
>      per_cpu_ptr_to_phys(addr)
>       pcpu_addr_to_page(addr)
>        virt_to_page(addr)
>         pfn_to_page(__pa(addr) >> PAGE_SHIFT)
> 
> We disable this path by not allowing NEED_PER_CPU_KM with deferred struct
> pages feature.
> 
> The problems are discussed in these threads:
> http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
> http://lkml.kernel.org/r/20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com
> http://lkml.kernel.org/r/20180426202619.2768-1-pasha.tatashin@oracle.com
> 
> Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks a lot!

> ---
>  mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5004d82a1d6..e14c01513bfd 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -636,6 +636,7 @@ config DEFERRED_STRUCT_PAGE_INIT
>  	default n
>  	depends on NO_BOOTMEM
>  	depends on !FLATMEM
> +	depends on !NEED_PER_CPU_KM
>  	help
>  	  Ordinarily all struct pages are initialised during early boot in a
>  	  single thread. On very large machines this can take a considerable
> -- 
> 2.17.0

-- 
Michal Hocko
SUSE Labs
