Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBA386B0253
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 08:25:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so51940949wmv.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 05:25:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si5943160wrw.208.2017.01.27.05.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 05:25:05 -0800 (PST)
Subject: Re: [PATCHv2 03/29] asm-generic: introduce __ARCH_USE_5LEVEL_HACK
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-4-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ed79cc79-8ea6-c2c3-189f-919004711d3f@suse.cz>
Date: Fri, 27 Jan 2017 14:24:58 +0100
MIME-Version: 1.0
In-Reply-To: <20161227015413.187403-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/27/2016 02:53 AM, Kirill A. Shutemov wrote:
> We are going to introduce <asm-generic/pgtable-nop4d.h> to provide
> abstraction for properly (in opposite to 5level-fixup.h hack) folded
> p4d level. The new header will be included from pgtable-nopud.h.
>
> If an architecture uses <asm-generic/nop*d.h>, we cannot use
> 5level-fixup.h directly to quickly convert the architecture to 5-level
> paging as it would conflict with pgtable-nop4d.h.
>
> With this patch an architecture can define __ARCH_USE_5LEVEL_HACK before
> inclusion <asm-genenric/nop*d.h> to 5level-fixup.h.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/asm-generic/pgtable-nop4d-hack.h | 62 ++++++++++++++++++++++++++++++++

At risk of bikeshedding and coming from somebody not familiar with this code... 
IMHO it would be somewhat more intuitive and consistent to name the file 
"pgtable-nopud-hack.h" as it's about the pud stuff, not p4d stuff, and acts as 
an alternative implementation to pgtable-nopud.h, not pgtable-nop4d.h

Thanks,
Vlastimil

>  include/asm-generic/pgtable-nopud.h      |  5 +++
>  2 files changed, 67 insertions(+)
>  create mode 100644 include/asm-generic/pgtable-nop4d-hack.h
>
> diff --git a/include/asm-generic/pgtable-nop4d-hack.h b/include/asm-generic/pgtable-nop4d-hack.h
> new file mode 100644
> index 000000000000..752fb7511750
> --- /dev/null
> +++ b/include/asm-generic/pgtable-nop4d-hack.h
> @@ -0,0 +1,62 @@
> +#ifndef _PGTABLE_NOP4D_HACK_H
> +#define _PGTABLE_NOP4D_HACK_H
> +
> +#ifndef __ASSEMBLY__
> +#include <asm-generic/5level-fixup.h>
> +
> +#define __PAGETABLE_PUD_FOLDED
> +
> +/*
> + * Having the pud type consist of a pgd gets the size right, and allows
> + * us to conceptually access the pgd entry that this pud is folded into
> + * without casting.
> + */
> +typedef struct { pgd_t pgd; } pud_t;
> +
> +#define PUD_SHIFT	PGDIR_SHIFT
> +#define PTRS_PER_PUD	1
> +#define PUD_SIZE	(1UL << PUD_SHIFT)
> +#define PUD_MASK	(~(PUD_SIZE-1))
> +
> +/*
> + * The "pgd_xxx()" functions here are trivial for a folded two-level
> + * setup: the pud is never bad, and a pud always exists (as it's folded
> + * into the pgd entry)
> + */
> +static inline int pgd_none(pgd_t pgd)		{ return 0; }
> +static inline int pgd_bad(pgd_t pgd)		{ return 0; }
> +static inline int pgd_present(pgd_t pgd)	{ return 1; }
> +static inline void pgd_clear(pgd_t *pgd)	{ }
> +#define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
> +
> +#define pgd_populate(mm, pgd, pud)		do { } while (0)
> +/*
> + * (puds are folded into pgds so this doesn't get actually called,
> + * but the define is needed for a generic inline function.)
> + */
> +#define set_pgd(pgdptr, pgdval)	set_pud((pud_t *)(pgdptr), (pud_t) { pgdval })
> +
> +static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
> +{
> +	return (pud_t *)pgd;
> +}
> +
> +#define pud_val(x)				(pgd_val((x).pgd))
> +#define __pud(x)				((pud_t) { __pgd(x) })
> +
> +#define pgd_page(pgd)				(pud_page((pud_t){ pgd }))
> +#define pgd_page_vaddr(pgd)			(pud_page_vaddr((pud_t){ pgd }))
> +
> +/*
> + * allocating and freeing a pud is trivial: the 1-entry pud is
> + * inside the pgd, so has no extra memory associated with it.
> + */
> +#define pud_alloc_one(mm, address)		NULL
> +#define pud_free(mm, x)				do { } while (0)
> +#define __pud_free_tlb(tlb, x, a)		do { } while (0)
> +
> +#undef  pud_addr_end
> +#define pud_addr_end(addr, end)			(end)
> +
> +#endif /* __ASSEMBLY__ */
> +#endif /* _PGTABLE_NOP4D_HACK_H */
> diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
> index 810431d8351b..5e49430a30a4 100644
> --- a/include/asm-generic/pgtable-nopud.h
> +++ b/include/asm-generic/pgtable-nopud.h
> @@ -3,6 +3,10 @@
>
>  #ifndef __ASSEMBLY__
>
> +#ifdef __ARCH_USE_5LEVEL_HACK
> +#include <asm-generic/pgtable-nop4d-hack.h>
> +#else
> +
>  #define __PAGETABLE_PUD_FOLDED
>
>  /*
> @@ -58,4 +62,5 @@ static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
>  #define pud_addr_end(addr, end)			(end)
>
>  #endif /* __ASSEMBLY__ */
> +#endif /* !__ARCH_USE_5LEVEL_HACK */
>  #endif /* _PGTABLE_NOPUD_H */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
