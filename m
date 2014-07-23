Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 020336B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:17:24 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rd18so1494364iec.14
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 14:17:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gj19si9388202icb.4.2014.07.23.14.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 14:17:23 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:17:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
Message-Id: <20140723141721.d6a58555f124a7024d010067@linux-foundation.org>
In-Reply-To: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>

On Thu, 17 Jul 2014 21:03:18 +0400 Max Filippov <jcmvbkbc@gmail.com> wrote:

> From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
> 
> Provide hooks that allow architectures with aliasing cache to align
> mapping address of high pages according to their color. Such architectures
> may enforce similar coloring of low- and high-memory page mappings and
> reuse existing cache management functions to support highmem.
> 
> ...
>
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -44,6 +44,14 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
>   */
>  #ifdef CONFIG_HIGHMEM
>  
> +#ifndef ARCH_PKMAP_COLORING
> +#define set_pkmap_color(pg, cl)		/* */
> +#define get_last_pkmap_nr(p, cl)	(p)
> +#define get_next_pkmap_nr(p, cl)	(((p) + 1) & LAST_PKMAP_MASK)
> +#define is_no_more_pkmaps(p, cl)	(!(p))
> +#define get_next_pkmap_counter(c, cl)	((c) - 1)
> +#endif

This is the old-school way of doing things.  The new Linus-approved way is

#ifndef set_pkmap_color
#define set_pkmap_color ...
#define get_last_pkmap_nr ...
#endif

so we don't need to add yet another symbol and to avoid typos, etc.

Secondly, please identify which per-arch header file is responsible for
defining these symbols.  Document that here and make sure that
mm/highmem.c is directly including that file.  Otherwise we end up with
different architectures using different header files and it's all a big
mess.

Thirdly, macros are nasty things.  It would be nicer to do

#ifndef set_pkmap_color
static inline void set_pkmap_color(...)
{
	...
}
#define set_pkmap_color set_pkmap_color

...

#endif

Fourthly, please document these proposed interfaces with code comments.

Fifthly, it would be very useful to publish the performance testing
results for at least one architecture so that we can determine the
patchset's desirability.  And perhaps to motivate other architectures
to implement this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
