Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8D93E6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:02:31 -0500 (EST)
Received: by wmec201 with SMTP id c201so40296565wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:02:31 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id b127si31924026wmh.67.2015.12.08.10.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:02:30 -0800 (PST)
Date: Tue, 8 Dec 2015 19:01:33 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 16/34] x86, mm: simplify get_user_pages() PTE bit
 handling
In-Reply-To: <20151204011446.DDC6435F@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081839471.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011446.DDC6435F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The current get_user_pages() code is a wee bit more complicated
> than it needs to be for pte bit checking.  Currently, it establishes
> a mask of required pte _PAGE_* bits and ensures that the pte it
> goes after has all those bits.
> 
> This consolidates the three identical copies of this code.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/arch/x86/mm/gup.c |   45 ++++++++++++++++++++++++++++-----------------
>  1 file changed, 28 insertions(+), 17 deletions(-)
> 
> diff -puN arch/x86/mm/gup.c~pkeys-16-gup-swizzle arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c~pkeys-16-gup-swizzle	2015-12-03 16:21:25.148649631 -0800
> +++ b/arch/x86/mm/gup.c	2015-12-03 16:21:25.151649767 -0800
> @@ -63,6 +63,30 @@ retry:
>  #endif
>  }
>  
> +static inline int pte_allows_gup(pte_t pte, int write)
> +{
> +	/*
> +	 * 'pte' can reall be a pte, pmd or pud.  We only check
> +	 * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which
> +	 * are the same value on all 3 types.
> +	 */
> +	if (!(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_USER)))
> +		return 0;
> +	if (write && !(pte_write(pte)))
> +		return 0;
> +	return 1;
> +}
> +
> +static inline int pmd_allows_gup(pmd_t pmd, int write)
> +{
> +	return pte_allows_gup(*(pte_t *)&pmd, write);
> +}
> +
> +static inline int pud_allows_gup(pud_t pud, int write)
> +{
> +	return pte_allows_gup(*(pte_t *)&pud, write);
> +}

This still puzzles me. And the only reason it compiles is because we
have -fno-strict-aliasing set ...

All this operates on the pteval or even just on the pte_flags(). Even
the new arch_pte_access_permitted() thingy which you add later is only
interrested in pte_flags() and its just a wrapper around
__pkru_allows_pkey().

So for readability and simplicity sake, can we please do something
like this (pkey check already added):

/*
 * 'pteval' can reall be a pte, pmd or pud.  We only check
 * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which
 * are the same value on all 3 types.
 */
static inline int pte_allows_gup(unsigned long pteval, int write)
{
	unsigned long mask = _PAGE_PRESENT|_PAGE_USER;

	if (write)
		mask |= _PAGE_RW;

	if ((pteval & mask) != mask)
		return 0;

	if (!__pkru_allows_pkey(pte_flags_pkey(pteval), write))
	   	return 0;
	return 1;
}

and at the callsites do:

    if (pte_allows_gup(pte_val(pte, write))

    if (pte_allows_gup(pmd_val(pmd, write))

    if (pte_allows_gup(pud_val(pud, write))

Hmm?


	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
