Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA62D6B03B6
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:49:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so28451567wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:49:14 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id f23si9641556wrf.148.2017.06.21.01.49.13
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 01:49:13 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:49:02 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
Message-ID: <20170621084902.vy7nvkon4krc7v3q@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:07PM -0700, Andy Lutomirski wrote:
> It was historically possible to have two concurrent TLB flushes
> targetting the same CPU: one initiated locally and one initiated
> remotely.  This can now cause an OOPS in leave_mm() at
> arch/x86/mm/tlb.c:47:
> 
>         if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>                 BUG();
> 
> with this call trace:
>  flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
>  flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317

These line numbers would most likely mean nothing soon. I think you
should rather explain why the bug can happen so that future lookers at
that code can find the spot...

> 
> Without reentrancy, this OOPS is impossible: leave_mm() is only
> called if we're not in TLBSTATE_OK, but then we're unexpectedly
> in TLBSTATE_OK in leave_mm().
> 
> This can be caused by flush_tlb_func_remote() happening between
> the two checks and calling leave_mm(), resulting in two consecutive
> leave_mm() calls on the same CPU with no intervening switch_mm()
> calls.

...like this, for example. That should be more future-code-changes-proof.

> We never saw this OOPS before because the old leave_mm()
> implementation didn't put us back in TLBSTATE_OK, so the assertion
> didn't fire.
> 
> Nadav noticed the reentrancy issue in a different context, but
> neither of us realized that it caused a problem yet.
> 
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Reported-by: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
> Fixes: 3d28ebceaffa ("x86/mm: Rework lazy TLB to track the actual loaded mm")
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/mm/tlb.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 2a5e851f2035..f06239c6919f 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -208,6 +208,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  static void flush_tlb_func_common(const struct flush_tlb_info *f,
>  				  bool local, enum tlb_flush_reason reason)
>  {
> +	/* This code cannot presently handle being reentered. */
> +	VM_WARN_ON(!irqs_disabled());
> +
>  	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
>  		leave_mm(smp_processor_id());
>  		return;
> @@ -313,8 +316,12 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  		info.end = TLB_FLUSH_ALL;
>  	}
>  
> -	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm))
> +	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
> +		local_irq_disable();
>  		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> +		local_irq_enable();
> +	}

I'm assuming this is going away in a future patch, as disabling IRQs
around a TLB flush is kinda expensive. I guess I'll see if I continue
reading...

:)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
