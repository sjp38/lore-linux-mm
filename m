Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00F9A6B0389
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 14:38:01 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a15so29611728wrc.3
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 11:38:01 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y14si10899011wry.225.2017.02.12.11.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 12 Feb 2017 11:38:00 -0800 (PST)
Date: Sun, 12 Feb 2017 20:37:57 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 4/7] x86, mpx: context-switch new MPX address size
 MSR
In-Reply-To: <20170201232413.15540F7E@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1702122025550.3734@nanos>
References: <20170201232408.FA486473@viggo.jf.intel.com> <20170201232413.15540F7E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 1 Feb 2017, Dave Hansen wrote:
> +/*
> + * The MPX tables change sizes based on the size of the virtual
> + * (aka. linear) address space.  There is an MSR to tell the CPU
> + * whether we want the legacy-style ones or the larger ones when
> + * we are running with an eXtended virtual address space.
> + */
> +static inline void switch_mpx_bd(struct mm_struct *prev, struct mm_struct *next)
> +{
> +	/*
> +	 * Note: there is one and only one bit in use in the MSR
> +	 * at this time, so we do not have to be concerned with
> +	 * preserving any of the other bits.  Just write 0 or 1.
> +	 */
> +	u32 IA32_MPX_LAX_ENABLE_MASK = 0x00000001;
> +
> +	/*
> +	 * Avoid the MSR on CPUs without MPX, obviously:
> +	 */
> +	if (!cpu_feature_enabled(X86_FEATURE_MPX))
> +		return;
> +	/*
> +	 * FIXME: do we want a check here for the 5-level paging
> +	 * CR4 bit or CPUID bit, or is the mawa check below OK?
> +	 * It's not obvious what would be the fastest or if it
> +	 * matters.
> +	 */

Well, you could use a static key which is enabled when 5 level paging and
MPX is enabled.

> +	/*
> +	 * Avoid the relatively costly MSR if we are not changing
> +	 * MAWA state.  All processes not using MPX will have a
> +	 * mpx_mawa_shift()=0, so we do not need to check
> +	 * separately for whether MPX management is enabled.
> +	 */
> +	if (likely(mpx_bd_size_shift(prev) == mpx_bd_size_shift(next)))
> +		return;

So this switches back unconditionally if the previous task was using the
large tables even if the next task is not using MPX at all. It's probably a
non issue.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
