Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id C21F76B0010
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 14:36:33 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b70-v6so3428368ywh.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:36:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u128-v6sor2775961ywf.2.2018.10.10.11.36.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 11:36:32 -0700 (PDT)
Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com. [209.85.219.171])
        by smtp.gmail.com with ESMTPSA id x133-v6sm17518867ywg.66.2018.10.10.11.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 11:36:30 -0700 (PDT)
Received: by mail-yb1-f171.google.com with SMTP id 5-v6so2619495ybf.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:36:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181010152736.99475-1-jannh@google.com>
References: <20181010152736.99475-1-jannh@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 Oct 2018 11:36:29 -0700
Message-ID: <CAGXu5j+h-ExvLS4dqDir8--eM8Zz7JDbVvg-U0wS1PrTyse3Og@mail.gmail.com>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with MAP_FIXED_NOREPLACE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michal Hocko <mhocko@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?Q?Edward_Tomasz_Napiera=C5=82a?= <trasz@freebsd.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>

On Wed, Oct 10, 2018 at 8:27 AM, Jann Horn <jannh@google.com> wrote:
> Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
> application causes that application to randomly crash. The existing check
> for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
> overlaps or follows the requested region, and then bails out if that VMA
> overlaps *the start* of the requested region. It does not bail out if the
> VMA only overlaps another part of the requested region.
>
> Fix it by checking that the found VMA only starts at or after the end of
> the requested region, in which case there is no overlap.
>
> Reported-by: Daniel Micay <danielmicay@gmail.com>
> Fixes: a4ff8e8620d3 ("mm: introduce MAP_FIXED_NOREPLACE")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Acked-by: Kees Cook <keescook@chromium.org>

Thanks for forwarding this!

Andrew, any chance we can get this into 4.19? (It'll end up in -stable
anyway, but it'd be nice to get it fixed now too.)

-Kees

> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 5f2b2b184c60..f7cd9cb966c0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>         if (flags & MAP_FIXED_NOREPLACE) {
>                 struct vm_area_struct *vma = find_vma(mm, addr);
>
> -               if (vma && vma->vm_start <= addr)
> +               if (vma && vma->vm_start < addr + len)
>                         return -EEXIST;
>         }
>
> --
> 2.19.0.605.g01d371f741-goog
>



-- 
Kees Cook
Pixel Security
