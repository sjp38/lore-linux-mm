Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9453A6B03B9
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:22:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f49so14034993wrf.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:22:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 41si15825285wrx.316.2017.06.21.02.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:22:46 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:22:36 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 07/11] x86/mm: Stop calling leave_mm() in idle code
In-Reply-To: <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211115580.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> diff --git a/drivers/idle/intel_idle.c b/drivers/idle/intel_idle.c
> index 216d7ec88c0c..2ae43f59091d 100644
> --- a/drivers/idle/intel_idle.c
> +++ b/drivers/idle/intel_idle.c
> @@ -912,16 +912,15 @@ static __cpuidle int intel_idle(struct cpuidle_device *dev,
>  	struct cpuidle_state *state = &drv->states[index];
>  	unsigned long eax = flg2MWAIT(state->flags);
>  	unsigned int cstate;
> -	int cpu = smp_processor_id();
>  
>  	cstate = (((eax) >> MWAIT_SUBSTATE_SIZE) & MWAIT_CSTATE_MASK) + 1;
>  
>  	/*
> -	 * leave_mm() to avoid costly and often unnecessary wakeups
> -	 * for flushing the user TLB's associated with the active mm.
> +	 * NB: if CPUIDLE_FLAG_TLB_FLUSHED is set, this idle transition
> +	 * will probably flush the TLB.  It's not guaranteed to flush
> +	 * the TLB, though, so it's not clear that we can do anything
> +	 * useful with this knowledge.

So my understanding here is:

      The C-state transition might flush the TLB, when cstate->flags has
      CPUIDLE_FLAG_TLB_FLUSHED set. The idle transition already took the
      CPU out of the set of CPUs which are remotely flushed, so the
      knowledge about this potential flush is not useful for the kernels
      view of the TLB state.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
