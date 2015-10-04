Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 43715680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 07:03:00 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so84372285wic.0
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 04:02:59 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id my8si9809821wic.19.2015.10.04.04.02.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 04:02:58 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so83930206wic.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 04:02:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
References: <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
 <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com> <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Sun, 4 Oct 2015 14:02:38 +0300
Message-ID: <CALq1K=JTWq+p0M+45nKm4yMs06k=Mt3y7+hbv6Usx+eX+=2MLQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Oct 4, 2015 at 9:18 AM, Geliang Tang <geliangtang@163.com> wrote:
> BUG_ON() already contain an unlikely compiler flag. Drop it.
It is not the case if CONFIG_BUG and HAVE_ARCH_BUG_ON are not set.

>
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  mm/nommu.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 1e0f168..92be862 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -578,16 +578,16 @@ static noinline void validate_nommu_regions(void)
>                 return;
>
>         last = rb_entry(lastp, struct vm_region, vm_rb);
> -       BUG_ON(unlikely(last->vm_end <= last->vm_start));
> -       BUG_ON(unlikely(last->vm_top < last->vm_end));
> +       BUG_ON(last->vm_end <= last->vm_start);
> +       BUG_ON(last->vm_top < last->vm_end);
>
>         while ((p = rb_next(lastp))) {
>                 region = rb_entry(p, struct vm_region, vm_rb);
>                 last = rb_entry(lastp, struct vm_region, vm_rb);
>
> -               BUG_ON(unlikely(region->vm_end <= region->vm_start));
> -               BUG_ON(unlikely(region->vm_top < region->vm_end));
> -               BUG_ON(unlikely(region->vm_start < last->vm_top));
> +               BUG_ON(region->vm_end <= region->vm_start);
> +               BUG_ON(region->vm_top < region->vm_end);
> +               BUG_ON(region->vm_start < last->vm_top);
>
>                 lastp = p;
>         }
> --
> 2.5.0
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
