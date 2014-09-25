Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 43FD76B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:05:15 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id k15so4752404qaq.32
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:05:14 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id r10si3115203qck.17.2014.09.25.10.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 10:05:14 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id n8so4859337qaq.22
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:05:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411562649-28231-6-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com> <1411562649-28231-6-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Sep 2014 10:04:53 -0700
Message-ID: <CACT4Y+Z5yCkdc9=R331vYJd-WMdM1zRy+KCEa5cESsjNRe9onA@mail.gmail.com>
Subject: Re: [PATCH v3 05/13] mm: page_alloc: add kasan hooks on alloc and
 free paths
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org

On Wed, Sep 24, 2014 at 5:44 AM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Add kernel address sanitizer hooks to mark allocated page's addresses
> as accessible in corresponding shadow region.
> Mark freed pages as inaccessible.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  include/linux/kasan.h |  6 ++++++
>  mm/compaction.c       |  2 ++
>  mm/kasan/kasan.c      | 14 ++++++++++++++
>  mm/kasan/kasan.h      |  1 +
>  mm/kasan/report.c     |  7 +++++++
>  mm/page_alloc.c       |  3 +++
>  6 files changed, 33 insertions(+)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 01c99fe..9714fba 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -30,6 +30,9 @@ static inline void kasan_disable_local(void)
>
>  void kasan_unpoison_shadow(const void *address, size_t size);
>
> +void kasan_alloc_pages(struct page *page, unsigned int order);
> +void kasan_free_pages(struct page *page, unsigned int order);
> +
>  #else /* CONFIG_KASAN */
>
>  static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
> @@ -37,6 +40,9 @@ static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
>  static inline void kasan_enable_local(void) {}
>  static inline void kasan_disable_local(void) {}
>
> +static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
> +static inline void kasan_free_pages(struct page *page, unsigned int order) {}
> +
>  #endif /* CONFIG_KASAN */
>
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 92075d5..686b5c2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -16,6 +16,7 @@
>  #include <linux/sysfs.h>
>  #include <linux/balloon_compaction.h>
>  #include <linux/page-isolation.h>
> +#include <linux/kasan.h>
>  #include "internal.h"
>
>  #ifdef CONFIG_COMPACTION
> @@ -59,6 +60,7 @@ static void map_pages(struct list_head *list)
>         list_for_each_entry(page, list, lru) {
>                 arch_alloc_page(page, 0);
>                 kernel_map_pages(page, 1, 1);
> +               kasan_alloc_pages(page, 0);
>         }
>  }
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 454df8d..7cfc1fe 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -251,6 +251,20 @@ static __always_inline void check_memory_region(unsigned long addr,
>         kasan_report_error(&info);
>  }
>
> +void kasan_alloc_pages(struct page *page, unsigned int order)
> +{
> +       if (likely(!PageHighMem(page)))
> +               kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
> +}
> +
> +void kasan_free_pages(struct page *page, unsigned int order)
> +{
> +       if (likely(!PageHighMem(page)))
> +               kasan_poison_shadow(page_address(page),
> +                               PAGE_SIZE << order,
> +                               KASAN_FREE_PAGE);
> +}
> +
>  void __asan_load1(unsigned long addr)
>  {
>         check_memory_region(addr, 1, false);
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 5895e31..5e61799 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -6,6 +6,7 @@
>  #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>
> +#define KASAN_FREE_PAGE         0xFF  /* page was freed */
>  #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
>
>  struct access_info {
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index bf559fa..f9d4e8d 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -57,6 +57,9 @@ static void print_error_description(struct access_info *info)
>         case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
>                 bug_type = "out of bounds access";
>                 break;
> +       case KASAN_FREE_PAGE:
> +               bug_type = "use after free";
> +               break;
>         case KASAN_SHADOW_GAP:
>                 bug_type = "wild memory access";
>                 break;
> @@ -75,6 +78,10 @@ static void print_address_description(struct access_info *info)
>         page = virt_to_head_page((void *)info->access_addr);
>
>         switch (shadow_val) {
> +       case KASAN_FREE_PAGE:
> +               dump_page(page, "kasan error");
> +               dump_stack();
> +               break;
>         case KASAN_SHADOW_GAP:
>                 pr_err("No metainfo is available for this access.\n");
>                 dump_stack();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ee95d0a..ef3604a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -59,6 +59,7 @@
>  #include <linux/page-debug-flags.h>
>  #include <linux/hugetlb.h>
>  #include <linux/sched/rt.h>
> +#include <linux/kasan.h>
>
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -755,6 +756,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>
>         trace_mm_page_free(page, order);
>         kmemcheck_free_shadow(page, order);
> +       kasan_free_pages(page, order);
>
>         if (PageAnon(page))
>                 page->mapping = NULL;
> @@ -941,6 +943,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
>
>         arch_alloc_page(page, order);
>         kernel_map_pages(page, 1 << order, 1);
> +       kasan_alloc_pages(page, order);
>
>         if (gfp_flags & __GFP_ZERO)
>                 prep_zero_page(page, order, gfp_flags);
> --
> 2.1.1
>


Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
