Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 903028299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:50:09 -0400 (EDT)
Received: by oiav63 with SMTP id v63so22002655oia.9
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:50:09 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id o8si1656481oem.102.2015.03.13.14.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:50:08 -0700 (PDT)
Received: by oifz81 with SMTP id z81so6451602oif.6
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426242602-52804-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426242602-52804-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sat, 14 Mar 2015 08:20:08 +1030
Message-ID: <CAFk90B_Y_yRebJ5W+ACXmrM9U=QKTr14yGidvi71ucN3NC6H8w@mail.gmail.com>
Subject: Re: [PATCH] parisc: fix pmd accounting with 3-level page tables
From: Graham Gower <graham.gower@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc <linux-parisc@vger.kernel.org>, John David Anglin <dave.anglin@bell.net>, Aaro Koskinen <aaro.koskinen@iki.fi>, Domenico Andreoli <cavokz@gmail.com>

This fixes the problem on my C8000.

Tested-by: graham.gower@gmail.com

On 13 March 2015 at 21:00, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> There's hack in pgd_alloc() on parisc to initialize one pmd, which is
> not accounted. It leads to underflow on exit.
>
> Let's adjust nr_pmds on pgd_alloc() to get accounting correct.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: John David Anglin <dave.anglin@bell.net>
> Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
> Cc: Graham Gower <graham.gower@gmail.com>
> Cc: Domenico Andreoli <cavokz@gmail.com>
> ---
>  arch/parisc/include/asm/pgalloc.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
> index 55ad8be9b7f3..068b2fb9a47c 100644
> --- a/arch/parisc/include/asm/pgalloc.h
> +++ b/arch/parisc/include/asm/pgalloc.h
> @@ -38,6 +38,7 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
>                 /* The first pmd entry also is marked with _PAGE_GATEWAY as
>                  * a signal that this pmd may not be freed */
>                 __pgd_val_set(*pgd, PxD_FLAG_ATTACHED);
> +               mm_inc_nr_pmds(mm);
>  #endif
>         }
>         return actual_pgd;
> --
> 2.1.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
