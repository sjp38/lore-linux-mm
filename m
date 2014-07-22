Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1346B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:58:49 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so7494061iec.2
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:58:48 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id d9si33039684igo.13.2014.07.21.17.58.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 17:58:48 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so3457444igb.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:58:48 -0700 (PDT)
Date: Mon, 21 Jul 2014 17:58:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
In-Reply-To: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
Message-ID: <alpine.DEB.2.02.1407211754350.7042@chino.kir.corp.google.com>
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>

On Thu, 17 Jul 2014, Max Filippov wrote:

> From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
> 
> Provide hooks that allow architectures with aliasing cache to align
> mapping address of high pages according to their color. Such architectures
> may enforce similar coloring of low- and high-memory page mappings and
> reuse existing cache management functions to support highmem.
> 

Typically a change like this would be proposed along with a change to an 
architecture which would define this new ARCH_PKMAP_COLORING and have its 
own overriding definitions.  Based on who you sent this patch to, it looks 
like that would be mips and xtensa.  Now the only question is where are 
those patches to add the alternate definitions for those platforms?

> Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
> [ Max: extract architecture-independent part of the original patch, clean
>   up checkpatch and build warnings. ]
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
> ---
> Changes v1->v2:
> - fix description
> 
>  mm/highmem.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/highmem.c b/mm/highmem.c
> index b32b70c..6898a8b 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -44,6 +44,14 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
>   */
>  #ifdef CONFIG_HIGHMEM
>  
> +#ifndef ARCH_PKMAP_COLORING
> +#define set_pkmap_color(pg, cl)		/* */

This is typically done with do {} while (0).

> +#define get_last_pkmap_nr(p, cl)	(p)
> +#define get_next_pkmap_nr(p, cl)	(((p) + 1) & LAST_PKMAP_MASK)
> +#define is_no_more_pkmaps(p, cl)	(!(p))

That's not gramatically proper.

> +#define get_next_pkmap_counter(c, cl)	((c) - 1)
> +#endif
> +
>  unsigned long totalhigh_pages __read_mostly;
>  EXPORT_SYMBOL(totalhigh_pages);
>  
> @@ -161,19 +169,24 @@ static inline unsigned long map_new_virtual(struct page *page)
>  {
>  	unsigned long vaddr;
>  	int count;
> +	int color __maybe_unused;
> +
> +	set_pkmap_color(page, color);
> +	last_pkmap_nr = get_last_pkmap_nr(last_pkmap_nr, color);
>  
>  start:
>  	count = LAST_PKMAP;
>  	/* Find an empty entry */
>  	for (;;) {
> -		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
> -		if (!last_pkmap_nr) {
> +		last_pkmap_nr = get_next_pkmap_nr(last_pkmap_nr, color);
> +		if (is_no_more_pkmaps(last_pkmap_nr, color)) {
>  			flush_all_zero_pkmaps();
>  			count = LAST_PKMAP;
>  		}
>  		if (!pkmap_count[last_pkmap_nr])
>  			break;	/* Found a usable entry */
> -		if (--count)
> +		count = get_next_pkmap_counter(count, color);

And that's not equivalent at all, --count decrements the auto variable and 
then tests it for being non-zero.  Your get_next_pkmap_counter() never 
decrements count.

> +		if (count > 0)
>  			continue;
>  
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
