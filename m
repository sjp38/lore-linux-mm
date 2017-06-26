Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 598A46B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:58:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b20so829794wmd.6
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:58:56 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id m133si125133wmd.43.2017.06.26.08.58.54
        for <linux-mm@kvack.org>;
        Mon, 26 Jun 2017 08:58:54 -0700 (PDT)
Date: Mon, 26 Jun 2017 17:58:29 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
Message-ID: <20170626155829.4t2axppz7gwf7trd@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:17PM -0700, Andy Lutomirski wrote:
> PCID is a "process context ID" -- it's what other architectures call
> an address space ID.  Every non-global TLB entry is tagged with a
> PCID, only TLB entries that match the currently selected PCID are
> used, and we can switch PGDs without flushing the TLB.  x86's
> PCID is 12 bits.
> 
> This is an unorthodox approach to using PCID.  x86's PCID is far too
> short to uniquely identify a process, and we can't even really
> uniquely identify a running process because there are monster
> systems with over 4096 CPUs.  To make matters worse, past attempts
> to use all 12 PCID bits have resulted in slowdowns instead of
> speedups.
> 
> This patch uses PCID differently.  We use a PCID to identify a
> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
> binding at all; instead, we give it a fresh PCID each time it's
> loaded except in cases where we want to preserve the TLB, in which
> case we reuse a recent value.
> 
> This seems to save about 100ns on context switches between mms.

"... with my microbenchmark of ping-ponging." :)

> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/mmu_context.h     |  3 ++
>  arch/x86/include/asm/processor-flags.h |  2 +
>  arch/x86/include/asm/tlbflush.h        | 18 +++++++-
>  arch/x86/mm/init.c                     |  1 +
>  arch/x86/mm/tlb.c                      | 82 ++++++++++++++++++++++++++--------
>  5 files changed, 86 insertions(+), 20 deletions(-)

...

> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 57b305e13c4c..a9a5aa6f45f7 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -82,6 +82,12 @@ static inline u64 bump_mm_tlb_gen(struct mm_struct *mm)
>  #define __flush_tlb_single(addr) __native_flush_tlb_single(addr)
>  #endif
>  
> +/*
> + * 6 because 6 should be plenty and struct tlb_state will fit in
> + * two cache lines.
> + */
> +#define NR_DYNAMIC_ASIDS 6

TLB_NR_DYN_ASIDS

Properly prefixed, I guess.

The rest later, when you're done experimenting. :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
