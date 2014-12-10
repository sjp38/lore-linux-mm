Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7916B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:02:48 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so6561038igb.5
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 07:02:48 -0800 (PST)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id qg1si3376788igb.22.2014.12.10.07.02.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 07:02:47 -0800 (PST)
Received: by mail-ie0-f174.google.com with SMTP id rl12so2810308iec.19
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 07:02:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <000001cffe5e$44893f60$cd9bbe20$%yang@samsung.com>
References: <000001cffe5e$44893f60$cd9bbe20$%yang@samsung.com>
Date: Wed, 10 Dec 2014 23:02:46 +0800
Message-ID: <CAL1ERfM3gn25gt-yf_MgVgZCkPyecQBB+cw32SR2XLNDWmnCQQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: mincore: use PAGE_SIZE instead of PAGE_CACHE_SIZE
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

ping. Any comments?

On Wed, Nov 12, 2014 at 5:50 PM, Weijie Yang <weijie.yang@samsung.com> wrote:
> This is a RFC patch, because current PAGE_SIZE is equal to PAGE_CACHE_SIZE,
> there isn't any difference and issue when running.
>
> However, the current code mixes these two aligned_size inconsistently, and if
> they are not equal in future mincore_unmapped_range() would check more file
> pages than wanted.
>
> According to man-page, mincore uses PAGE_SIZE as its size unit, so this patch
> uses PAGE_SIZE instead of PAGE_CACHE_SIZE.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  mm/mincore.c |   19 +++++++++++++------
>  1 files changed, 13 insertions(+), 6 deletions(-)
>
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 725c809..8c19bce 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -102,11 +102,18 @@ static void mincore_unmapped_range(struct vm_area_struct *vma,
>         int i;
>
>         if (vma->vm_file) {
> -               pgoff_t pgoff;
> +               pgoff_t pgoff, pgoff_end;
> +               int j, count;
> +               unsigned char res;
>
> +               count = 1 << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>                 pgoff = linear_page_index(vma, addr);
> -               for (i = 0; i < nr; i++, pgoff++)
> -                       vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
> +               pgoff_end = linear_page_index(vma, end);
> +               for (i = 0; pgoff < pgoff_end; pgoff++) {
> +                       res = mincore_page(vma->vm_file->f_mapping, pgoff);
> +                       for (j = 0; j < count; j++)
> +                               vec[i++] = res;
> +               }
>         } else {
>                 for (i = 0; i < nr; i++)
>                         vec[i] = 0;
> @@ -258,7 +265,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>   * return values:
>   *  zero    - success
>   *  -EFAULT - vec points to an illegal address
> - *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE
> + *  -EINVAL - addr is not a multiple of PAGE_SIZE
>   *  -ENOMEM - Addresses in the range [addr, addr + len] are
>   *             invalid for the address space of this process, or
>   *             specify one or more pages which are not currently
> @@ -273,14 +280,14 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
>         unsigned char *tmp;
>
>         /* Check the start address: needs to be page-aligned.. */
> -       if (start & ~PAGE_CACHE_MASK)
> +       if (start & ~PAGE_MASK)
>                 return -EINVAL;
>
>         /* ..and we need to be passed a valid user-space range */
>         if (!access_ok(VERIFY_READ, (void __user *) start, len))
>                 return -ENOMEM;
>
> -       /* This also avoids any overflows on PAGE_CACHE_ALIGN */
> +       /* This also avoids any overflows on PAGE_ALIGN */
>         pages = len >> PAGE_SHIFT;
>         pages += (len & ~PAGE_MASK) != 0;
>
> --
> 1.7.0.4
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
