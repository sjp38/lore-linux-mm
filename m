Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 20B6B6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 09:18:20 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so31816916wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 06:18:19 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id d2si8154331wjw.157.2015.07.31.06.18.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 06:18:12 -0700 (PDT)
Date: Fri, 31 Jul 2015 15:18:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Message-ID: <20150731131802.GW25159@twins.programming.kicks-ass.net>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, hpa@zytor.com, bp@alien8.de, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, mcgrof@suse.com, toshi.kani@hp.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-tip-commits@vger.kernel.org

On Wed, May 27, 2015 at 07:19:05AM -0700, tip-bot for Toshi Kani wrote:
> +/**
> + * mtrr_type_lookup - look up memory type in MTRR
> + *
> + * Return Values:
> + * MTRR_TYPE_(type)  - The effective MTRR type for the region
> + * MTRR_TYPE_INVALID - MTRR is disabled
>   */
>  u8 mtrr_type_lookup(u64 start, u64 end)
>  {

>  	int repeat;
>  	u64 partial_end;
>  
> +	if (!mtrr_state_set)
> +		return MTRR_TYPE_INVALID;
> +
> +	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
> +		return MTRR_TYPE_INVALID;
> +
> +	/*
> +	 * Look up the fixed ranges first, which take priority over
> +	 * the variable ranges.
> +	 */
> +	if ((start < 0x100000) &&
> +	    (mtrr_state.have_fixed) &&
> +	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> +		return mtrr_type_lookup_fixed(start, end);
> +
> +	/*
> +	 * Look up the variable ranges.  Look of multiple ranges matching
> +	 * this address and pick type as per MTRR precedence.
> +	 */
> +	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
>  
>  	/*
>  	 * Common path is with repeat = 0.
>  	 * However, we can have cases where [start:end] spans across some
> +	 * MTRR ranges and/or the default type.  Do repeated lookups for
> +	 * that case here.
>  	 */
>  	while (repeat) {
>  		prev_type = type;
>  		start = partial_end;
> +		type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
>  
>  		if (check_type_overlap(&prev_type, &type))
>  			return type;
>  	}
>  
> +	if (mtrr_tom2 && (start >= (1ULL<<32)) && (end < mtrr_tom2))
> +		return MTRR_TYPE_WRBACK;
> +
>  	return type;
>  }

So I got staring at this MTRR horror show because I _really_ _Really_
want to kill stop_machine_from_inactive_cpu().

But I wondered about these lookup functions, should they not have an
assertion that preemption is disabled?

Using these functions with preemption enabled is racy against MTRR
updates. And if that race is ok, at the very least explain that it is
indeed racy and why this is not a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
