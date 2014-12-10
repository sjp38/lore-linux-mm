Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 97F226B0073
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 12:06:11 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so11893393wiv.12
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:06:11 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id yz5si8456519wjc.119.2014.12.10.09.06.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 09:06:10 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so5871139wiv.14
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:06:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
	<20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
	<35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
	<20141208114601.GA28846@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
Date: Wed, 10 Dec 2014 21:06:05 +0400
Message-ID: <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
Subject: Re: [RFC V5] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>

On Tue, Dec 9, 2014 at 6:24 AM, Wang, Yalin <Yalin.Wang@sonymobile.com> wrote:
> This patch add KPF_ZERO_PAGE flag for zero_page,
> so that userspace process can notice zero_page from
> /proc/kpageflags, and then do memory analysis more accurately.
>
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

Ack. Looks good.

> ---
>  Documentation/vm/pagemap.txt           |  8 ++++++++
>  fs/proc/page.c                         | 16 +++++++++++++---
>  include/linux/huge_mm.h                | 12 ++++++++++++
>  include/uapi/linux/kernel-page-flags.h |  1 +
>  mm/huge_memory.c                       |  7 +------
>  tools/vm/page-types.c                  |  1 +
>  6 files changed, 36 insertions(+), 9 deletions(-)
>
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index 5948e45..6fbd55e 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -62,6 +62,8 @@ There are three components to pagemap:
>      20. NOPAGE
>      21. KSM
>      22. THP
> +    23. BALLOON
> +    24. ZERO_PAGE
>
>  Short descriptions to the page flags:
>
> @@ -102,6 +104,12 @@ Short descriptions to the page flags:
>  22. THP
>      contiguous pages which construct transparent hugepages
>
> +23. BALLOON
> +    balloon compaction page
> +
> +24. ZERO_PAGE
> +    zero page for pfn_zero or huge_zero page
> +
>      [IO related page flags]
>   1. ERROR     IO error occurred
>   3. UPTODATE  page has up-to-date data
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 1e3187d..7eee2d8 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -5,6 +5,7 @@
>  #include <linux/ksm.h>
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
> +#include <linux/huge_mm.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/hugetlb.h>
> @@ -121,9 +122,18 @@ u64 stable_page_flags(struct page *page)
>          * just checks PG_head/PG_tail, so we need to check PageLRU/PageAnon
>          * to make sure a given page is a thp, not a non-huge compound page.
>          */
> -       else if (PageTransCompound(page) && (PageLRU(compound_head(page)) ||
> -                                            PageAnon(compound_head(page))))
> -               u |= 1 << KPF_THP;
> +       else if (PageTransCompound(page)) {
> +               struct page *head = compound_head(page);
> +
> +               if (PageLRU(head) || PageAnon(head))
> +                       u |= 1 << KPF_THP;
> +               else if (is_huge_zero_page(head)) {
> +                       u |= 1 << KPF_ZERO_PAGE;
> +                       u |= 1 << KPF_THP;
> +               }
> +       } else if (is_zero_pfn(page_to_pfn(page)))
> +               u |= 1 << KPF_ZERO_PAGE;
> +
>
>         /*
>          * Caveats on high order pages: page->_count will only be set
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index ad9051b..f10b20f 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -157,6 +157,13 @@ static inline int hpage_nr_pages(struct page *page)
>  extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>                                 unsigned long addr, pmd_t pmd, pmd_t *pmdp);
>
> +extern struct page *huge_zero_page;
> +
> +static inline bool is_huge_zero_page(struct page *page)
> +{
> +       return ACCESS_ONCE(huge_zero_page) == page;
> +}
> +
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> @@ -206,6 +213,11 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
>         return 0;
>  }
>
> +static inline bool is_huge_zero_page(struct page *page)
> +{
> +       return false;
> +}
> +
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>
>  #endif /* _LINUX_HUGE_MM_H */
> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> index 2f96d23..a6c4962 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -32,6 +32,7 @@
>  #define KPF_KSM                        21
>  #define KPF_THP                        22
>  #define KPF_BALLOON            23
> +#define KPF_ZERO_PAGE          24
>
>
>  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index de98415..d7bc7a5 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -171,12 +171,7 @@ static int start_khugepaged(void)
>  }
>
>  static atomic_t huge_zero_refcount;
> -static struct page *huge_zero_page __read_mostly;
> -
> -static inline bool is_huge_zero_page(struct page *page)
> -{
> -       return ACCESS_ONCE(huge_zero_page) == page;
> -}
> +struct page *huge_zero_page __read_mostly;
>
>  static inline bool is_huge_zero_pmd(pmd_t pmd)
>  {
> diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
> index 264fbc2..8bdf16b 100644
> --- a/tools/vm/page-types.c
> +++ b/tools/vm/page-types.c
> @@ -133,6 +133,7 @@ static const char * const page_flag_names[] = {
>         [KPF_KSM]               = "x:ksm",
>         [KPF_THP]               = "t:thp",
>         [KPF_BALLOON]           = "o:balloon",
> +       [KPF_ZERO_PAGE]         = "z:zero_page",
>
>         [KPF_RESERVED]          = "r:reserved",
>         [KPF_MLOCKED]           = "m:mlocked",
> --
> 2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
