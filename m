Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3EE96B03B8
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:01:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u30so10115525wrc.9
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:01:48 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r41si15763588wrb.298.2017.06.21.02.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:01:47 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:01:35 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
In-Reply-To: <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211033340.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> -/*
> - * The flush IPI assumes that a thread switch happens in this order:
> - * [cpu0: the cpu that switches]
> - * 1) switch_mm() either 1a) or 1b)
> - * 1a) thread switch to a different mm
> - * 1a1) set cpu_tlbstate to TLBSTATE_OK
> - *	Now the tlb flush NMI handler flush_tlb_func won't call leave_mm
> - *	if cpu0 was in lazy tlb mode.
> - * 1a2) update cpu active_mm
> - *	Now cpu0 accepts tlb flushes for the new mm.
> - * 1a3) cpu_set(cpu, new_mm->cpu_vm_mask);
> - *	Now the other cpus will send tlb flush ipis.
> - * 1a4) change cr3.
> - * 1a5) cpu_clear(cpu, old_mm->cpu_vm_mask);
> - *	Stop ipi delivery for the old mm. This is not synchronized with
> - *	the other cpus, but flush_tlb_func ignore flush ipis for the wrong
> - *	mm, and in the worst case we perform a superfluous tlb flush.
> - * 1b) thread switch without mm change
> - *	cpu active_mm is correct, cpu0 already handles flush ipis.
> - * 1b1) set cpu_tlbstate to TLBSTATE_OK
> - * 1b2) test_and_set the cpu bit in cpu_vm_mask.
> - *	Atomically set the bit [other cpus will start sending flush ipis],
> - *	and test the bit.
> - * 1b3) if the bit was 0: leave_mm was called, flush the tlb.
> - * 2) switch %%esp, ie current
> - *
> - * The interrupt must handle 2 special cases:
> - * - cr3 is changed before %%esp, ie. it cannot use current->{active_,}mm.
> - * - the cpu performs speculative tlb reads, i.e. even if the cpu only
> - *   runs in kernel space, the cpu could load tlb entries for user space
> - *   pages.
> - *
> - * The good news is that cpu_tlbstate is local to each cpu, no
> - * write/read ordering problems.

While the new code is really well commented, it would be a good thing to
have a single place where all of this including the ordering constraints
are documented.

> @@ -215,12 +200,13 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
>  	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
>  		   loaded_mm->context.ctx_id);
>  
> -	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> +	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
>  		/*
> -		 * leave_mm() is adequate to handle any type of flush, and
> -		 * we would prefer not to receive further IPIs.
> +		 * We're in lazy mode -- don't flush.  We can get here on
> +		 * remote flushes due to races and on local flushes if a
> +		 * kernel thread coincidentally flushes the mm it's lazily
> +		 * still using.

Ok. That's more informative.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
