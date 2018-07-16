Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C98E6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:39:06 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q9-v6so6441504lfc.3
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 08:39:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2-v6sor6601789ljd.36.2018.07.16.08.39.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 08:39:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180716151630.770-1-pasha.tatashin@oracle.com>
References: <20180716151630.770-1-pasha.tatashin@oracle.com>
From: Matt Hart <matt@mattface.org>
Date: Mon, 16 Jul 2018 16:39:03 +0100
Message-ID: <CAJsfgeVfazk-5hdhB4u+fJPVv92Hh2TZjiMgj9rfQyQvfm2Rcw@mail.gmail.com>
Subject: Re: [PATCH] mm: don't do zero_resv_unavail if memmap is not allocated
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org

On 16 July 2018 at 16:16, Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> Moving zero_resv_unavail before memmap_init_zone(), caused a regression on
> x86-32.

Automated bisection on my boards in KernelCI spotted this regression,
so I did a manual test with this patch and confirm it fixes boots on
my i386 devices.

>
> The cause is that we access struct pages before they are allocated when
> CONFIG_FLAT_NODE_MEM_MAP is used.
>
> free_area_init_nodes()
>   zero_resv_unavail()
>     mm_zero_struct_page(pfn_to_page(pfn)); <- struct page is not alloced
>   free_area_init_node()
>     if CONFIG_FLAT_NODE_MEM_MAP
>       alloc_node_mem_map()
>         memblock_virt_alloc_node_nopanic() <- struct page alloced here
>
> On the other hand memblock_virt_alloc_node_nopanic() zeroes all the memory
> that it returns, so we do not need to do zero_resv_unavail() here.
>
> Fixes: e181ae0c5db9 ("mm: zero unavailable pages before memmap init")
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Tested-by: Matt Hart <matt@mattface.org>

> ---
>  include/linux/mm.h | 2 +-
>  mm/page_alloc.c    | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9ffe380..3982c83fdcbf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2132,7 +2132,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
>                                         struct mminit_pfnnid_cache *state);
>  #endif
>
> -#ifdef CONFIG_HAVE_MEMBLOCK
> +#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
>  void zero_resv_unavail(void);
>  #else
>  static inline void zero_resv_unavail(void) {}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d800d61ddb7..a790ef4be74e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6383,7 +6383,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>         free_area_init_core(pgdat);
>  }
>
> -#ifdef CONFIG_HAVE_MEMBLOCK
> +#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
>  /*
>   * Only struct pages that are backed by physical memory are zeroed and
>   * initialized by going through __init_single_page(). But, there are some
> @@ -6421,7 +6421,7 @@ void __paginginit zero_resv_unavail(void)
>         if (pgcnt)
>                 pr_info("Reserved but unavailable: %lld pages", pgcnt);
>  }
> -#endif /* CONFIG_HAVE_MEMBLOCK */
> +#endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
>
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>
> --
> 2.18.0
>



-- 
Matt Hart
