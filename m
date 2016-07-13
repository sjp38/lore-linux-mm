Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8F2F6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:19:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so37259912wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:19:07 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id a2si1564375wjk.265.2016.07.13.08.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:19:06 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so6252190wme.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:19:06 -0700 (PDT)
Date: Wed, 13 Jul 2016 17:19:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] x86, swap: move swap offset/type up in PTE to work
 around erratum
Message-ID: <20160713151905.GB20693@dhcp22.suse.cz>
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001911.9A3FD2B6@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160708001911.9A3FD2B6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com

On Thu 07-07-16 17:19:11, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This erratum can result in Accessed/Dirty getting set by the hardware
> when we do not expect them to be (on !Present PTEs).
> 
> Instead of trying to fix them up after this happens, we just
> allow the bits to get set and try to ignore them.  We do this by
> shifting the layout of the bits we use for swap offset/type in
> our 64-bit PTEs.
> 
> It looks like this:
> 
> bitnrs: |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0|
> names:  |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P|
> before: |         OFFSET (9-63)          |0|X|X| TYPE(1-5) |0|
>  after: | OFFSET (14-63)  |  TYPE (9-13) |0|X|X|X| X| X|X|X|0|
> 
> Note that D was already a don't care (X) even before.  We just
> move TYPE up and turn its old spot (which could be hit by the
> A bit) into all don't cares.
> 
> We take 5 bits away from the offset, but that still leaves us
> with 50 bits which lets us index into a 62-bit swapfile (4 EiB).
> I think that's probably fine for the moment.  We could
> theoretically reclaim 5 of the bits (1, 2, 3, 4, 7) but it
> doesn't gain us anything.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Yes, this seems like a safest option. Feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  b/arch/x86/include/asm/pgtable_64.h |   26 ++++++++++++++++++++------
>  1 file changed, 20 insertions(+), 6 deletions(-)
> 
> diff -puN arch/x86/include/asm/pgtable_64.h~knl-strays-10-move-swp-pte-bits arch/x86/include/asm/pgtable_64.h
> --- a/arch/x86/include/asm/pgtable_64.h~knl-strays-10-move-swp-pte-bits	2016-07-07 17:17:43.556746185 -0700
> +++ b/arch/x86/include/asm/pgtable_64.h	2016-07-07 17:17:43.559746319 -0700
> @@ -140,18 +140,32 @@ static inline int pgd_large(pgd_t pgd) {
>  #define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
>  #define pte_unmap(pte) ((void)(pte))/* NOP */
>  
> -/* Encode and de-code a swap entry */
> +/*
> + * Encode and de-code a swap entry
> + *
> + * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
> + * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
> + * | OFFSET (14->63) | TYPE (10-13) |0|X|X|X| X| X|X|X|0| <- swp entry
> + *
> + * G (8) is aliased and used as a PROT_NONE indicator for
> + * !present ptes.  We need to start storing swap entries above
> + * there.  We also need to avoid using A and D because of an
> + * erratum where they can be incorrectly set by hardware on
> + * non-present PTEs.
> + */
> +#define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
>  #define SWP_TYPE_BITS 5
> -#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
> +/* Place the offset above the type: */
> +#define SWP_OFFSET_FIRST_BIT (SWP_TYPE_FIRST_BIT + SWP_TYPE_BITS + 1)
>  
>  #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
>  
> -#define __swp_type(x)			(((x).val >> (_PAGE_BIT_PRESENT + 1)) \
> +#define __swp_type(x)			(((x).val >> (SWP_TYPE_FIRST_BIT)) \
>  					 & ((1U << SWP_TYPE_BITS) - 1))
> -#define __swp_offset(x)			((x).val >> SWP_OFFSET_SHIFT)
> +#define __swp_offset(x)			((x).val >> SWP_OFFSET_FIRST_BIT)
>  #define __swp_entry(type, offset)	((swp_entry_t) { \
> -					 ((type) << (_PAGE_BIT_PRESENT + 1)) \
> -					 | ((offset) << SWP_OFFSET_SHIFT) })
> +					 ((type) << (SWP_TYPE_FIRST_BIT)) \
> +					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
>  #define __swp_entry_to_pte(x)		((pte_t) { .pte = (x).val })
>  
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
