Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3337A6B4E6E
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 20:13:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x19-v6so3699883pfh.15
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 17:13:58 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id b8-v6si4874546pls.392.2018.08.29.17.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 17:13:56 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Date: Thu, 30 Aug 2018 00:13:50 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075012B090CA3@us01wembx1.internal.synopsys.com>
References: <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
 <20180827110017.GO24142@hirez.programming.kicks-ass.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Nicholas Piggin <npiggin@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>

On 08/27/2018 04:00 AM, Peter Zijlstra wrote:=0A=
>=0A=
> The one obvious thing SH and ARM want is a sensible default for=0A=
> tlb_start_vma(). (also: https://lkml.org/lkml/2004/1/15/6 )=0A=
>=0A=
> The below make tlb_start_vma() default to flush_cache_range(), which=0A=
> should be right and sufficient. The only exceptions that I found where=0A=
> (oddly):=0A=
>=0A=
>   - m68k-mmu=0A=
>   - sparc64=0A=
>   - unicore=0A=
>=0A=
> Those architectures appear to have a non-NOP flush_cache_range(), but=0A=
> their current tlb_start_vma() does not call it.=0A=
=0A=
So indeed we follow the DaveM's insight from 2004 about tlb_{start,end}_vma=
() and=0A=
those are No-ops for ARC for the general case. For the historic VIPT aliasi=
ng=0A=
dcache they are what they should be per 2004 link above - I presume that is=
 all=0A=
hunky dory with you ?=0A=
=0A=
> Furthermore, I think tlb_flush() is broken on arc and parisc; in=0A=
> particular they don't appear to have any TLB invalidate for the=0A=
> shift_arg_pages() case, where we do not call tlb_*_vma() and fullmm=3D0.=
=0A=
=0A=
Care to explain this issue a bit more ?=0A=
And that is independent of the current discussion.=0A=
=0A=
> Possibly shift_arg_pages() should be fixed instead.=0A=
>=0A=
> Some archs (nds32,sparc32) avoid this by having an unconditional=0A=
> flush_tlb_mm() in tlb_flush(), which seems somewhat suboptimal if you=0A=
> have flush_tlb_range().  TLB_FLUSH_VMA() might be an option, however=0A=
> hideous it is.=0A=
>=0A=
> ---=0A=
>=0A=
> diff --git a/arch/arc/include/asm/tlb.h b/arch/arc/include/asm/tlb.h=0A=
> index a9db5f62aaf3..7af2b373ebe7 100644=0A=
> --- a/arch/arc/include/asm/tlb.h=0A=
> +++ b/arch/arc/include/asm/tlb.h=0A=
> @@ -23,15 +23,6 @@ do {						\=0A=
>   *=0A=
>   * Note, read http://lkml.org/lkml/2004/1/15/6=0A=
>   */=0A=
> -#ifndef CONFIG_ARC_CACHE_VIPT_ALIASING=0A=
> -#define tlb_start_vma(tlb, vma)=0A=
> -#else=0A=
> -#define tlb_start_vma(tlb, vma)						\=0A=
> -do {									\=0A=
> -	if (!tlb->fullmm)						\=0A=
> -		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\=0A=
> -} while(0)=0A=
> -#endif=0A=
>  =0A=
>  #define tlb_end_vma(tlb, vma)						\=0A=
>  do {									\=0A=
=0A=
[snip..]=0A=
=0A=
> 				      \=0A=
> diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h=0A=
> index e811ef7b8350..1d037fd5bb7a 100644=0A=
> --- a/include/asm-generic/tlb.h=0A=
> +++ b/include/asm-generic/tlb.h=0A=
> @@ -181,19 +181,21 @@ static inline void tlb_remove_check_page_size_chang=
e(struct mmu_gather *tlb,=0A=
>   * the vmas are adjusted to only cover the region to be torn down.=0A=
>   */=0A=
>  #ifndef tlb_start_vma=0A=
> -#define tlb_start_vma(tlb, vma) do { } while (0)=0A=
> +#define tlb_start_vma(tlb, vma)						\=0A=
> +do {									\=0A=
> +	if (!tlb->fullmm)						\=0A=
> +		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\=0A=
> +} while (0)=0A=
>  #endif=0A=
=0A=
So for non aliasing arches to be not affected, this relies on flush_cache_r=
ange()=0A=
to be no-op ?=0A=
=0A=
> -#define __tlb_end_vma(tlb, vma)					\=0A=
> -	do {							\=0A=
> -		if (!tlb->fullmm && tlb->end) {			\=0A=
> -			tlb_flush(tlb);				\=0A=
> -			__tlb_reset_range(tlb);			\=0A=
> -		}						\=0A=
> -	} while (0)=0A=
> -=0A=
>  #ifndef tlb_end_vma=0A=
> -#define tlb_end_vma	__tlb_end_vma=0A=
> +#define tlb_end_vma(tlb, vma)						\=0A=
> +	do {								\=0A=
> +		if (!tlb->fullmm && tlb->end) {				\=0A=
> +			tlb_flush(tlb);					\=0A=
> +			__tlb_reset_range(tlb);				\=0A=
> +		}							\=0A=
> +	} while (0)=0A=
>  #endif=0A=
>  =0A=
>  #ifndef __tlb_remove_tlb_entry=0A=
=0A=
And this one is for shift_arg_pages() but will also cause extraneous flushe=
s for=0A=
other cases - not happening currently !=0A=
=0A=
-Vineet=0A=
=0A=
