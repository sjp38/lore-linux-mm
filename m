Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A36756B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:44:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v68so158677725pfi.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:44:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m88si5768237pfa.226.2017.07.25.07.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 07:44:19 -0700 (PDT)
Date: Tue, 25 Jul 2017 16:44:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6] x86/mm: Improve TLB flush documentation
Message-ID: <20170725144412.iaxl4um6c42ydtbw@hirez.programming.kicks-ass.net>
References: <b994bd38fd8dbed15e3bf8a0a23dde207b2297c0.1500991817.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b994bd38fd8dbed15e3bf8a0a23dde207b2297c0.1500991817.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, Jul 25, 2017 at 07:10:44AM -0700, Andy Lutomirski wrote:
> Improve comments as requested by PeterZ and also add some
> documentation at the top of the file.
> 
> This adds and removes some smp_mb__after_atomic() calls to make the
> code correct even in the absence of x86's extra-strong atomics.

The main point being that this better documents on which specific
ordering we rely.

> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> 
> Changes from v5:
>  - Fix blatantly wrong docs (PeterZ, Nadav)
>  - Remove the smp_mb__...._atomic() I was supposed to remove, not the one
>    I did remove (found by turning on brain and re-reading PeterZ's email)
> 
> arch/x86/include/asm/tlbflush.h |  2 --
>  arch/x86/mm/tlb.c               | 45 ++++++++++++++++++++++++++++++++---------
>  2 files changed, 35 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index d23e61dc0640..eb2b44719d57 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -67,9 +67,7 @@ static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
>  	 * their read of mm_cpumask after their writes to the paging
>  	 * structures.
>  	 */
> -	smp_mb__before_atomic();
>  	new_tlb_gen = atomic64_inc_return(&mm->context.tlb_gen);
> -	smp_mb__after_atomic();
>  
>  	return new_tlb_gen;
>  }

Right, as atomic*_inc_return() already implies a MB on either side.

> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index ce104b962a17..0a2e9d0b5503 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -15,17 +15,24 @@
>  #include <linux/debugfs.h>
>  
>  /*
> + * The code in this file handles mm switches and TLB flushes.
>   *
> + * An mm's TLB state is logically represented by a totally ordered sequence
> + * of TLB flushes.  Each flush increments the mm's tlb_gen.
>   *
> + * Each CPU that might have an mm in its TLB (and that might ever use
> + * those TLB entries) will have an entry for it in its cpu_tlbstate.ctxs
> + * array.  The kernel maintains the following invariant: for each CPU and
> + * for each mm in its cpu_tlbstate.ctxs array, the CPU has performed all
> + * flushes in that mms history up to the tlb_gen in cpu_tlbstate.ctxs
> + * or the CPU has performed an equivalent set of flushes.
>   *
> + * For this purpose, an equivalent set is a set that is at least as strong.
> + * So, for example, if the flush history is a full flush at time 1,
> + * a full flush after time 1 is sufficient, but a full flush before time 1
> + * is not.  Similarly, any number of flushes can be replaced by a single
> + * full flush so long as that replacement flush is after all the flushes
> + * that it's replacing.
>   */
>  
>  atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
> @@ -138,8 +145,18 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  			return;
>  		}
>  
> +		/*
> +		 * Resume remote flushes and then read tlb_gen.  The
> +		 * barrier synchronizes with inc_mm_tlb_gen() like
> +		 * this:
> +		 *
> +		 * switch_mm_irqs_off():	flush request:
> +		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
> +		 *  MB				 MB
> +		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
> +		 */
>  		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		smp_mb__after_atomic();
>  		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  
>  		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) <
> @@ -186,9 +203,17 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
>  
>  		/*
> +		 * Start remote flushes and then read tlb_gen.  As
> +		 * above, the barrier synchronizes with
> +		 * inc_mm_tlb_gen() like this:
> +		 *
> +		 * switch_mm_irqs_off():	flush request:
> +		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
> +		 *  MB				 MB
> +		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
>  		 */
>  		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		smp_mb__after_atomic();
>  		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  
>  		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);

Arguably one could make a helper function of those few lines, not sure
it makes sense, but this duplication seems wasteful.

So we either see the increment or the CPU set, but can not have neither.

Should not arch_tlbbatch_add_mm() also have this same comment? It too
seems to increment and then read the mask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
