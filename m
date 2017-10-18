Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 914016B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 19:39:55 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a132so1583759lfa.17
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 16:39:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a67sor1963974lfl.43.2017.10.18.16.39.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 16:39:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171016144410.z3vcx3mddb53l3sq@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20170929140821.37654-3-kirill.shutemov@linux.intel.com> <CAPkvG_c3=78Yd5kQOeZM_yiv89HowjEthhZtysoGmxcDZMwunQ@mail.gmail.com>
 <20171016144410.z3vcx3mddb53l3sq@node.shutemov.name>
From: Nitin Gupta <ngupta@vflare.org>
Date: Wed, 18 Oct 2017 16:39:52 -0700
Message-ID: <CAPkvG_cO68SU8Hyu2iXn2gL+-3+HokTm9r4ArSNX15jYryS5ow@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Mon, Oct 16, 2017 at 7:44 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Fri, Oct 13, 2017 at 05:00:12PM -0700, Nitin Gupta wrote:
>> On Fri, Sep 29, 2017 at 7:08 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > With boot-time switching between paging mode we will have variable
>> > MAX_PHYSMEM_BITS.
>> >
>> > Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
>> > configuration to define zsmalloc data structures.
>> >
>> > The patch introduces MAX_POSSIBLE_PHYSMEM_BITS to cover such case.
>> > It also suits well to handle PAE special case.
>> >
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > Cc: Minchan Kim <minchan@kernel.org>
>> > Cc: Nitin Gupta <ngupta@vflare.org>
>> > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
>> > ---
>> >  arch/x86/include/asm/pgtable-3level_types.h |  1 +
>> >  arch/x86/include/asm/pgtable_64_types.h     |  2 ++
>> >  mm/zsmalloc.c                               | 13 +++++++------
>> >  3 files changed, 10 insertions(+), 6 deletions(-)
>> >
>> > diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
>> > index b8a4341faafa..3fe1d107a875 100644
>> > --- a/arch/x86/include/asm/pgtable-3level_types.h
>> > +++ b/arch/x86/include/asm/pgtable-3level_types.h
>> > @@ -43,5 +43,6 @@ typedef union {
>> >   */
>> >  #define PTRS_PER_PTE   512
>> >
>> > +#define MAX_POSSIBLE_PHYSMEM_BITS      36
>> >
>> >  #endif /* _ASM_X86_PGTABLE_3LEVEL_DEFS_H */
>> > diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
>> > index 06470da156ba..39075df30b8a 100644
>> > --- a/arch/x86/include/asm/pgtable_64_types.h
>> > +++ b/arch/x86/include/asm/pgtable_64_types.h
>> > @@ -39,6 +39,8 @@ typedef struct { pteval_t pte; } pte_t;
>> >  #define P4D_SIZE       (_AC(1, UL) << P4D_SHIFT)
>> >  #define P4D_MASK       (~(P4D_SIZE - 1))
>> >
>> > +#define MAX_POSSIBLE_PHYSMEM_BITS      52
>> > +
>> >  #else /* CONFIG_X86_5LEVEL */
>> >
>> >  /*
>> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> > index 7c38e850a8fc..7bde01c55c90 100644
>> > --- a/mm/zsmalloc.c
>> > +++ b/mm/zsmalloc.c
>> > @@ -82,18 +82,19 @@
>> >   * This is made more complicated by various memory models and PAE.
>> >   */
>> >
>> > -#ifndef MAX_PHYSMEM_BITS
>> > -#ifdef CONFIG_HIGHMEM64G
>> > -#define MAX_PHYSMEM_BITS 36
>> > -#else /* !CONFIG_HIGHMEM64G */
>> > +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
>> > +#ifdef MAX_PHYSMEM_BITS
>> > +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
>> > +#else
>> >  /*
>> >   * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
>> >   * be PAGE_SHIFT
>> >   */
>> > -#define MAX_PHYSMEM_BITS BITS_PER_LONG
>> > +#define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
>> >  #endif
>> >  #endif
>> > -#define _PFN_BITS              (MAX_PHYSMEM_BITS - PAGE_SHIFT)
>> > +
>> > +#define _PFN_BITS              (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
>> >
>>
>>
>> I think we can avoid using this new constant in zsmalloc.
>>
>> The reason for trying to save on MAX_PHYSMEM_BITS is just to gain more
>> bits for OBJ_INDEX_BITS which would reduce ZS_MIN_ALLOC_SIZE. However,
>> for all practical values of ZS_MAX_PAGES_PER_ZSPAGE, this min size
>> would remain 32 bytes.
>>
>> So, we can unconditionally use MAX_PHYSMEM_BITS = BITS_PER_LONG and
>> thus OBJ_INDEX_BITS = PAGE_SHIFT.
>
> As you understand the topic better than me, could you prepare the patch?
>


Actually no changes are necessary.

As long as physical address bits <= BITS_PER_LONG, then setting
_PFN_BITS to the most conservative value of BITS_PER_LONG is
fine. AFAIK, this condition does not hold on x86 PAE where PA
bits (36) > BITS_PER_LONG (32), so only that case need special
handling to make sure PFN bits are not lost when encoding
allocated object location in an unsigned long.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
