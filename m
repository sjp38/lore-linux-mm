Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC1436B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:50:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so12101673wrc.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:50:46 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r15si3990360wrr.99.2017.06.23.04.50.45
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 04:50:45 -0700 (PDT)
Date: Fri, 23 Jun 2017 13:50:26 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Message-ID: <20170623115026.qqy5mpyihymocaet@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 20, 2017 at 10:22:16PM -0700, Andy Lutomirski wrote:
> We can use PCID if the CPU has PCID and PGE and we're not on Xen.
> 
> By itself, this has no effect.  The next patch will start using
> PCID.
> 
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h |  8 ++++++++
>  arch/x86/kernel/cpu/common.c    | 15 +++++++++++++++
>  arch/x86/xen/enlighten_pv.c     |  6 ++++++
>  3 files changed, 29 insertions(+)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 87b13e51e867..57b305e13c4c 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -243,6 +243,14 @@ static inline void __flush_tlb_all(void)
>  		__flush_tlb_global();
>  	else
>  		__flush_tlb();
> +
> +	/*
> +	 * Note: if we somehow had PCID but not PGE, then this wouldn't work --
> +	 * we'd end up flushing kernel translations for the current ASID but
> +	 * we might fail to flush kernel translations for other cached ASIDs.
> +	 *
> +	 * To avoid this issue, we force PCID off if PGE is off.
> +	 */
>  }
>  
>  static inline void __flush_tlb_one(unsigned long addr)
> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index 904485e7b230..01caf66b270f 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -1143,6 +1143,21 @@ static void identify_cpu(struct cpuinfo_x86 *c)
>  	setup_smep(c);
>  	setup_smap(c);
>  
> +	/* Set up PCID */
> +	if (cpu_has(c, X86_FEATURE_PCID)) {
> +		if (cpu_has(c, X86_FEATURE_PGE)) {

What are we protecting ourselves here against? Funny virtualization guests?

Because PGE should be ubiquitous by now. Or have you heard something?

> +			cr4_set_bits(X86_CR4_PCIDE);
> +		} else {
> +			/*
> +			 * flush_tlb_all(), as currently implemented, won't
> +			 * work if PCID is on but PGE is not.  Since that
> +			 * combination doesn't exist on real hardware, there's
> +			 * no reason to try to fully support it.
> +			 */
> +			clear_cpu_cap(c, X86_FEATURE_PCID);
> +		}
> +	}

This whole in setup_pcid() I guess, like the rest of the features.

> +
>  	/*
>  	 * The vendor-specific functions might have changed features.
>  	 * Now we do "generic changes."
> diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
> index f33eef4ebd12..a136aac543c3 100644
> --- a/arch/x86/xen/enlighten_pv.c
> +++ b/arch/x86/xen/enlighten_pv.c
> @@ -295,6 +295,12 @@ static void __init xen_init_capabilities(void)
>  	setup_clear_cpu_cap(X86_FEATURE_ACC);
>  	setup_clear_cpu_cap(X86_FEATURE_X2APIC);
>  
> +	/*
> +	 * Xen PV would need some work to support PCID: CR3 handling as well
> +	 * as xen_flush_tlb_others() would need updating.
> +	 */
> +	setup_clear_cpu_cap(X86_FEATURE_PCID);
> +
>  	if (!xen_initial_domain())
>  		setup_clear_cpu_cap(X86_FEATURE_ACPI);
>  
> -- 
> 2.9.4
> 

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
