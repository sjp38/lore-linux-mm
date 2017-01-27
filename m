Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 409406B0260
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:31:27 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so45146337wjc.4
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:31:27 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id a16si5064682wra.331.2017.01.27.00.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 00:31:25 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id r126so56484960wmr.3
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:31:25 -0800 (PST)
Date: Fri, 27 Jan 2017 09:31:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 4/4] x86, mpx: context-switch new MPX address size
 MSR
Message-ID: <20170127083122.GC25162@gmail.com>
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
 <20170126224010.3534C154@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126224010.3534C154@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> + * The MPX tables change sizes based on the size of the virtual
> + * (aka. linear) address space.  There is an MSR to tell the CPU
> + * whether we want the legacy-style ones or the larger ones when
> + * we are running with an eXtended virtual address space.
> + */
> +static void switch_mawa(struct mm_struct *prev, struct mm_struct *next)
> +{
> +	/*
> +	 * Note: there is one and only one bit in use in the MSR
> +	 * at this time, so we do not have to be concerned with
> +	 * preseving any of the other bits.  Just write 0 or 1.
> +	 */
> +	unsigned IA32_MPX_LAX_ENABLE_MASK = 0x00000001;
> +
> +	if (!cpu_feature_enabled(X86_FEATURE_MPX))
> +		return;
> +	/*
> +	 * FIXME: do we want a check here for the 5-level paging
> +	 * CR4 bit or CPUID bit, or is the mawa check below OK?
> +	 * It's not obvious what would be the fastest or if it
> +	 * matters.
> +	 */
> +
> +	/*
> +	 * Avoid the relatively costly MSR if we are not changing
> +	 * MAWA state.  All processes not using MPX will have a
> +	 * mpx_mawa_shift()=0, so we do not need to check
> +	 * separately for whether MPX management is enabled.
> +	 */
> +	if (mpx_mawa_shift(prev) == mpx_mawa_shift(next))
> +		return;

Please stop the senseless looking wrappery - if the field is name sensibly then it 
can be accessed directly through mm_struct.

> +
> +	if (mpx_mawa_shift(next)) {
> +		wrmsr(MSR_IA32_MPX_LAX, IA32_MPX_LAX_ENABLE_MASK, 0x0);
> +	} else {
> +		/* clear the enable bit: */
> +		wrmsr(MSR_IA32_MPX_LAX, 0x0, 0x0);
> +	}
> +}
> +
>  void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  			struct task_struct *tsk)
>  {
> @@ -136,6 +177,7 @@ void switch_mm_irqs_off(struct mm_struct
>  		/* Load per-mm CR4 state */
>  		load_mm_cr4(next);
>  
> +		switch_mawa(prev, next);

This implementation adds about 4-5 unnecessary instructions to the context 
switching hot path of every non-MPX task, even on non-MPX hardware.

Please make sure that this is something like:

	if (unlikely(prev->mpx_msr_val != next->mpx_msr_val))
		switch_mpx(prev, next);

... which reduces the hot path overhead to something like 2 instruction (if we are 
lucky).

This can be put into switch_mpx() and can be inlined - just make sure that on a 
defconfig the generated machine code is sane.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
