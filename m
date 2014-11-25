Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id B8C576B006E
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:28:33 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id v63so313271oia.15
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:28:33 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id x5si758294oel.64.2014.11.25.04.28.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:28:32 -0800 (PST)
Received: by mail-ob0-f171.google.com with SMTP id uz6so330981obc.16
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:28:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416852146-9781-5-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-5-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 25 Nov 2014 16:28:12 +0400
Message-ID: <CAA6XgkFQ-uHc=Wv0RosXi0J6_ZKu3FU2hFo08=Ahr_uH+D41ig@mail.gmail.com>
Subject: Re: [PATCH v7 04/12] mm: page_alloc: add kasan hooks on alloc and
 free paths
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

LGTM

On Mon, Nov 24, 2014 at 9:02 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
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
> index a857225..a5c8e84 100644
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
> @@ -61,6 +62,7 @@ static void map_pages(struct list_head *list)
>         list_for_each_entry(page, list, lru) {
>                 arch_alloc_page(page, 0);
>                 kernel_map_pages(page, 1, 1);
> +               kasan_alloc_pages(page, 0);
>         }
>  }
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index f77be01..b336073 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -247,6 +247,20 @@ static __always_inline void check_memory_region(unsigned long addr,
>         kasan_report(addr, size, write);
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
> index 6da1d78..2a6a961 100644
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
> index 56a2089..8ac3b6b 100644
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
> @@ -78,6 +81,10 @@ static void print_address_description(struct access_info *info)
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
> index b0e6eab..3829589 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -58,6 +58,7 @@
>  #include <linux/page-debug-flags.h>
>  #include <linux/hugetlb.h>
>  #include <linux/sched/rt.h>
> +#include <linux/kasan.h>
>
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -758,6 +759,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>
>         trace_mm_page_free(page, order);
>         kmemcheck_free_shadow(page, order);
> +       kasan_free_pages(page, order);
>
>         if (PageAnon(page))
>                 page->mapping = NULL;
> @@ -940,6 +942,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
>
>         arch_alloc_page(page, order);
>         kernel_map_pages(page, 1 << order, 1);
> +       kasan_alloc_pages(page, order);
>
>         if (gfp_flags & __GFP_ZERO)
>                 prep_zero_page(page, order, gfp_flags);
> --
> 2.1.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
