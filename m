Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8C39490002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 03:02:22 -0400 (EDT)
Received: by wiwl15 with SMTP id l15so9073148wiw.0
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:02:22 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id v7si3126465wiz.62.2015.03.11.00.02.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 00:02:20 -0700 (PDT)
Received: by wggy19 with SMTP id y19so7006753wgg.2
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:02:20 -0700 (PDT)
Date: Wed, 11 Mar 2015 08:02:16 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] mtrr, mm, x86: Enhance MTRR checks for KVA huge page
 mapping
Message-ID: <20150311070216.GD29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
 <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> This patch adds an additional argument, *uniform, to

s/*uniform/'uniform'

> mtrr_type_lookup(), which returns 1 when a given range is
> either fully covered by a single MTRR entry or not covered
> at all.

s/or not covered/or is not covered

> pud_set_huge() and pmd_set_huge() are changed to check the
> new uniform flag to see if it is safe to create a huge page

s/uniform/'uniform'

> mapping to the range.  This allows them to create a huge page
> mapping to a range covered by a single MTRR entry of any
> memory type.  It also detects an unoptimal request properly.

s/unoptimal/non-optimal

or nonoptimal

Also, some description in the changelog about what a 'non-optimal' 
request is would be most userful.

> They continue to check with the WB type since the WB type has
> no effect even if a request spans to multiple MTRR entries.

s/spans to/spans

> -static inline u8 mtrr_type_lookup(u64 addr, u64 end)
> +static inline u8 mtrr_type_lookup(u64 addr, u64 end, u8 *uniform)
>  {
>  	/*
>  	 * Return no-MTRRs:
>  	 */
> +	*uniform = 1;
>  	return 0xff;
>  }
>  #define mtrr_save_fixed_ranges(arg) do {} while (0)
> diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
> index cdb955f..aef238c 100644
> --- a/arch/x86/kernel/cpu/mtrr/generic.c
> +++ b/arch/x86/kernel/cpu/mtrr/generic.c
> @@ -108,14 +108,19 @@ static int check_type_overlap(u8 *prev, u8 *curr)
>   * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
>   *		corresponds only to [start:*partial_end].
>   *		Caller has to lookup again for [*partial_end:end].
> + * *uniform == 1 The requested range is either fully covered by a single MTRR
> + *		 entry or not covered at all.
>   */

So I think a better approach would be to count the number of separate 
MTRR caching types a range is covered by, instead of this hard to 
quality 'uniform' flag.

I.e. a 'nr_mtrr_types' count.

If for example a range partially intersects with an MTRR, then that 
count would be 2: the MTRR, and the outside (default cache policy) 
type.

( Note that with this approach is not only easy to understand and easy 
  to review, but could also be refined in the future, to count the 
  number of _incompatible_ caching types present within a range. )


> -static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> +static u8 __mtrr_type_lookup(u64 start, u64 end,
> +			     u64 *partial_end, int *repeat, u8 *uniform)
>  {
>  	int i;
>  	u64 base, mask;
>  	u8 prev_match, curr_match;
>  
>  	*repeat = 0;
> +	*uniform = 1;
> +
>  	if (!mtrr_state_set)
>  		return 0xFF;
>  
> @@ -128,6 +133,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
>  	/* Look in fixed ranges. Just return the type as per start */
>  	if (mtrr_state.have_fixed && (start < 0x100000)) {
>  		int idx;
> +		*uniform = 0;

So this function scares me, because the code is clearly crap:

        if (mtrr_state.have_fixed && (start < 0x100000)) {
	...
                } else if (start < 0x1000000) {
	...

How can that 'else if' branch ever not be true?

Did it perhaps want to be the other way around:

        if (mtrr_state.have_fixed && (start < 0x1000000)) {
	...
                } else if (start < 0x100000) {
	...

or did it simply mess up the condition?

>  
>  		if (start < 0x80000) {
>  			idx = 0;
> @@ -195,6 +201,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
>  
>  			end = *partial_end - 1; /* end is inclusive */
>  			*repeat = 1;
> +			*uniform = 0;
>  		}
>  
>  		if (!start_state)
> @@ -206,6 +213,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
>  			continue;
>  		}
>  
> +		*uniform = 0;
>  		if (check_type_overlap(&prev_match, &curr_match))
>  			return curr_match;
>  	}


> @@ -222,17 +230,21 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
>  }
>  
>  /*
> - * Returns the effective MTRR type for the region
> + * Returns the effective MTRR type for the region.  *uniform is set to 1
> + * when a given range is either fully covered by a single MTRR entry or
> + * not covered at all.
> + *
>   * Error return:
>   * 0xFF - when MTRR is not enabled
>   */
> -u8 mtrr_type_lookup(u64 start, u64 end)
> +u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
>  {
> -	u8 type, prev_type;
> +	u8 type, prev_type, is_uniform, dummy;
>  	int repeat;
>  	u64 partial_end;
>  
> -	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> +	type = __mtrr_type_lookup(start, end,
> +				  &partial_end, &repeat, &is_uniform);
>  
>  	/*
>  	 * Common path is with repeat = 0.
> @@ -242,12 +254,18 @@ u8 mtrr_type_lookup(u64 start, u64 end)
>  	while (repeat) {
>  		prev_type = type;
>  		start = partial_end;
> -		type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> +		is_uniform = 0;
>  
> -		if (check_type_overlap(&prev_type, &type))
> +		type = __mtrr_type_lookup(start, end,
> +					  &partial_end, &repeat, &dummy);
> +
> +		if (check_type_overlap(&prev_type, &type)) {
> +			*uniform = 0;
>  			return type;
> +		}
>  	}
>  
> +	*uniform = is_uniform;
>  	return type;

So the MTRR code is from hell, it would be nice to first clean up the 
whole code and the MTRR data structures before extending it with more 
complexity ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
