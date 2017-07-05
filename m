Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAA176B0338
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 08:18:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v26so204753901pfa.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 05:18:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e3si15223025pgu.37.2017.07.05.05.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 05:18:17 -0700 (PDT)
Date: Wed, 5 Jul 2017 14:18:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
Message-ID: <20170705121807.GF4941@worktop>
References: <cover.1498751203.git.luto@kernel.org>
 <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
> @@ -104,18 +140,20 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  
>  		/* Resume remote flushes and then read tlb_gen. */
>  		cpumask_set_cpu(cpu, mm_cpumask(next));

Barriers should have a comment... what is being ordered here against
what?

> +		smp_mb__after_atomic();
>  		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  
> +		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) <
> +		    next_tlb_gen) {
>  			/*
>  			 * Ideally, we'd have a flush_tlb() variant that
>  			 * takes the known CR3 value as input.  This would
>  			 * be faster on Xen PV and on hypothetical CPUs
>  			 * on which INVPCID is fast.
>  			 */
> +			this_cpu_write(cpu_tlbstate.ctxs[prev_asid].tlb_gen,
>  				       next_tlb_gen);
> +			write_cr3(__pa(next->pgd) | prev_asid);
>  			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
>  					TLB_FLUSH_ALL);
>  		}

> @@ -152,14 +190,25 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  		 * Start remote flushes and then read tlb_gen.
>  		 */
>  		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		smp_mb__after_atomic();

idem

>  		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  
> +		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
>  
> +		if (need_flush) {
> +			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
> +			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
> +			write_cr3(__pa(next->pgd) | new_asid);
> +			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
> +					TLB_FLUSH_ALL);
> +		} else {
> +			/* The new ASID is already up to date. */
> +			write_cr3(__pa(next->pgd) | new_asid | CR3_NOFLUSH);
> +			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, 0);
> +		}
> +
> +		this_cpu_write(cpu_tlbstate.loaded_mm, next);
> +		this_cpu_write(cpu_tlbstate.loaded_mm_asid, new_asid);
>  	}
>  
>  	load_mm_cr4(next);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
