Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7092F6B0171
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 00:50:47 -0400 (EDT)
Received: by iwn1 with SMTP id 1so3259021iwn.14
        for <linux-mm@kvack.org>; Sat, 16 Oct 2010 21:50:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101016043331.GA3177@darkstar>
References: <20101016043331.GA3177@darkstar>
Date: Sun, 17 Oct 2010 13:50:45 +0900
Message-ID: <AANLkTik8Sn9Pr+C32Wd6-XgXu=21NQ56C8D+WqsqoK5j@mail.gmail.com>
Subject: Re: [PATCH 1/2] Add vzalloc shortcut
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 16, 2010 at 1:33 PM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> Add vzalloc for convinience of vmalloc-then-memset-zero case
>
> Use __GFP_ZERO in vzalloc to zero fill the allocated memory.
Looks good to me.

There are many place we need this.
Although it affects meta pages for vmalloc as well as data pages, it's
not a big.
In this case, Maintaining code simple is better than little bit
performance overhead.

>
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Isn't it useful in nommu, either?


> ---
> =A0include/linux/vmalloc.h | =A0 =A01 +
> =A0mm/vmalloc.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 13 +++++++++++++
> =A02 files changed, 14 insertions(+)
>
> --- linux-2.6.orig/include/linux/vmalloc.h =A0 =A0 =A02010-08-22 15:31:38=
.000000000 +0800
> +++ linux-2.6/include/linux/vmalloc.h =A0 2010-10-16 10:50:54.739996121 +=
0800
> @@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
> =A0#endif
>
> =A0extern void *vmalloc(unsigned long size);
> +extern void *vzalloc(unsigned long size);
> =A0extern void *vmalloc_user(unsigned long size);
> =A0extern void *vmalloc_node(unsigned long size, int node);
> =A0extern void *vmalloc_exec(unsigned long size);
> --- linux-2.6.orig/mm/vmalloc.c 2010-08-22 15:31:39.000000000 +0800
> +++ linux-2.6/mm/vmalloc.c =A0 =A0 =A02010-10-16 10:51:57.126665918 +0800
> @@ -1604,6 +1604,19 @@ void *vmalloc(unsigned long size)
> =A0EXPORT_SYMBOL(vmalloc);
>
> =A0/**
> + * =A0 =A0 vzalloc =A0- =A0allocate virtually contiguous memory with zer=
o filled
> + * =A0 =A0 @size: =A0 =A0 =A0 =A0 =A0allocation size
> + * =A0 =A0 Allocate enough pages to cover @size from the page level
> + * =A0 =A0 allocator and map them into contiguous kernel virtual space.
> + */
> +void *vzalloc(unsigned long size)
> +{
> + =A0 =A0 =A0 return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM |=
 __GFP_ZERO,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PAGE_KERNEL=
, -1, __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(vzalloc);
> +
> +/**
> =A0* vmalloc_user - allocate zeroed virtually contiguous memory for users=
pace
> =A0* @size: allocation size
> =A0*
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
