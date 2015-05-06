Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 293276B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 12:19:39 -0400 (EDT)
Received: by oign205 with SMTP id n205so11614517oig.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 09:19:39 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id s7si12227477oei.66.2015.05.06.09.19.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 09:19:38 -0700 (PDT)
Message-ID: <1430928030.23761.328.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 6/7] mtrr, x86: Clean up mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 06 May 2015 10:00:30 -0600
In-Reply-To: <20150506134127.GE22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-7-git-send-email-toshi.kani@hp.com>
	 <20150506134127.GE22949@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, 2015-05-06 at 15:41 +0200, Borislav Petkov wrote:
> On Tue, Mar 24, 2015 at 04:08:40PM -0600, Toshi Kani wrote:
> > MTRRs contain fixed and variable entries.  mtrr_type_lookup()
> > may repeatedly call __mtrr_type_lookup() to handle a request
> > that overlaps with variable entries.  However,
> > __mtrr_type_lookup() also handles the fixed entries, which
> > do not have to be repeated.  Therefore, this patch creates
> > separate functions, mtrr_type_lookup_fixed() and
> > mtrr_type_lookup_variable(), to handle the fixed and variable
> > ranges respectively.
> > 
> > The patch also updates the function headers to clarify the
> > return values and output argument.  It updates comments to
> > clarify that the repeating is necessary to handle overlaps
> > with the default type, since overlaps with multiple entries
> > alone can be handled without such repeating.
> > 
> > There is no functional change in this patch.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  arch/x86/kernel/cpu/mtrr/generic.c |  137 +++++++++++++++++++++++-------------
> >  1 file changed, 86 insertions(+), 51 deletions(-)
> > 
> > diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
> > index 8bd1298..3652e2b 100644
> > --- a/arch/x86/kernel/cpu/mtrr/generic.c
> > +++ b/arch/x86/kernel/cpu/mtrr/generic.c
> > @@ -102,55 +102,69 @@ static int check_type_overlap(u8 *prev, u8 *curr)
> >  	return 0;
> >  }
> >  
> > -/*
> > - * Error/Semi-error returns:
> > - * MTRR_TYPE_INVALID - when MTRR is not enabled
> > - * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
> > - *		corresponds only to [start:*partial_end].
> > - *		Caller has to lookup again for [*partial_end:end].
> > +/**
> > + * mtrr_type_lookup_fixed - look up memory type in MTRR fixed entries
> > + *
> > + * MTRR fixed entries are divided into the following ways:
> > + *  0x00000 - 0x7FFFF : This range is divided into eight 64KB sub-ranges
> > + *  0x80000 - 0xBFFFF : This range is divided into sixteen 16KB sub-ranges
> > + *  0xC0000 - 0xFFFFF : This range is divided into sixty-four 4KB sub-ranges
> 
> No need for those - simply a pointer to either the SDM or APM manuals'
> section suffices as they both describe it good.

Ingo asked me to describe this info here in his review...

> > + *
> > + * Return Values:
> > + * MTRR_TYPE_(type)  - Matched memory type
> > + * MTRR_TYPE_INVALID - Unmatched or fixed entries are disabled
> >   */
> > -static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> > +static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
> > +{
> > +	int idx;
> > +
> > +	if (start >= 0x100000)
> > +		return MTRR_TYPE_INVALID;
> > +
> > +	if (!(mtrr_state.have_fixed) ||
> > +	    !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> > +		return MTRR_TYPE_INVALID;
> > +
> > +	if (start < 0x80000) {		/* 0x0 - 0x7FFFF */
> > +		idx = 0;
> > +		idx += (start >> 16);
> > +		return mtrr_state.fixed_ranges[idx];
> > +
> > +	} else if (start < 0xC0000) {	/* 0x80000 - 0xBFFFF */
> > +		idx = 1 * 8;
> > +		idx += ((start - 0x80000) >> 14);
> > +		return mtrr_state.fixed_ranges[idx];
> > +	}
> > +
> > +	/* 0xC0000 - 0xFFFFF */
> > +	idx = 3 * 8;
> > +	idx += ((start - 0xC0000) >> 12);
> > +	return mtrr_state.fixed_ranges[idx];
> > +}
> > +
> > +/**
> > + * mtrr_type_lookup_variable - look up memory type in MTRR variable entries
> > + *
> > + * Return Value:
> > + * MTRR_TYPE_(type) - Matched memory type or default memory type (unmatched)
> > + *
> > + * Output Argument:
> > + * repeat - Set to 1 when [start:end] spanned across MTRR range and type
> > + *	    returned corresponds only to [start:*partial_end].  Caller has
> > + *	    to lookup again for [*partial_end:end].
> > + */
> > +static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
> > +				    int *repeat)
> >  {
> >  	int i;
> >  	u64 base, mask;
> >  	u8 prev_match, curr_match;
> >  
> >  	*repeat = 0;
> > -	if (!mtrr_state_set)
> > -		return MTRR_TYPE_INVALID;
> > -
> > -	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
> > -		return MTRR_TYPE_INVALID;
> >  
> >  	/* Make end inclusive end, instead of exclusive */
> >  	end--;
> >  
> > -	/* Look in fixed ranges. Just return the type as per start */
> > -	if ((start < 0x100000) &&
> > -	    (mtrr_state.have_fixed) &&
> > -	    (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED)) {
> > -		int idx;
> > -
> > -		if (start < 0x80000) {
> > -			idx = 0;
> > -			idx += (start >> 16);
> > -			return mtrr_state.fixed_ranges[idx];
> > -		} else if (start < 0xC0000) {
> > -			idx = 1 * 8;
> > -			idx += ((start - 0x80000) >> 14);
> > -			return mtrr_state.fixed_ranges[idx];
> > -		} else {
> > -			idx = 3 * 8;
> > -			idx += ((start - 0xC0000) >> 12);
> > -			return mtrr_state.fixed_ranges[idx];
> > -		}
> > -	}
> > -
> > -	/*
> > -	 * Look in variable ranges
> > -	 * Look of multiple ranges matching this address and pick type
> > -	 * as per MTRR precedence
> > -	 */
> >  	prev_match = MTRR_TYPE_INVALID;
> >  	for (i = 0; i < num_var_ranges; ++i) {
> >  		unsigned short start_state, end_state, inclusive;
> > @@ -179,7 +193,8 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  			 * Return the type for first region and a pointer to
> >  			 * the start of second region so that caller will
> >  			 * lookup again on the second region.
> > -			 * Note: This way we handle multiple overlaps as well.
> > +			 * Note: This way we handle overlaps with multiple
> > +			 * entries and the default type properly.
> >  			 */
> >  			if (start_state)
> >  				*partial_end = base + get_mtrr_size(mask);
> > @@ -208,21 +223,18 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  			return curr_match;
> >  	}
> >  
> > -	if (mtrr_tom2) {
> > -		if (start >= (1ULL<<32) && (end < mtrr_tom2))
> > -			return MTRR_TYPE_WRBACK;
> > -	}
> > -
> >  	if (prev_match != MTRR_TYPE_INVALID)
> >  		return prev_match;
> >  
> >  	return mtrr_state.def_type;
> >  }
> >  
> > -/*
> > - * Returns the effective MTRR type for the region
> > - * Error return:
> > - * MTRR_TYPE_INVALID - when MTRR is not enabled
> > +/**
> > + * mtrr_type_lookup - look up memory type in MTRR
> > + *
> > + * Return Values:
> > + * MTRR_TYPE_(type)  - The effective MTRR type for the region
> > + * MTRR_TYPE_INVALID - MTRR is disabled
> >   */
> >  u8 mtrr_type_lookup(u64 start, u64 end)
> >  {
> > @@ -230,22 +242,45 @@ u8 mtrr_type_lookup(u64 start, u64 end)
> >  	int repeat;
> >  	u64 partial_end;
> >  
> > -	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> > +	if (!mtrr_state_set)
> > +		return MTRR_TYPE_INVALID;
> > +
> > +	if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
> > +		return MTRR_TYPE_INVALID;
> > +
> > +	/*
> > +	 * Look up the fixed ranges first, which take priority over
> > +	 * the variable ranges.
> > +	 */
> > +	type = mtrr_type_lookup_fixed(start, end);
> > +	if (type != MTRR_TYPE_INVALID)
> > +		return type;
> 
> Huh, why are we not looking at start?
> 
> I mean, fixed MTRRs cover the first 1MB so we can simply do:
> 
>         if ((start < 0x100000) &&
>             (mtrr_state.have_fixed) &&
>             (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> 		return mtrr_type_lookup_fixed(start, end);

mtrr_type_lookup_fixed() checks the above conditions at entry, and
returns immediately with TYPE_INVALID.  I think it is safer to have such
checks in mtrr_type_lookup_fixed() in case there will be multiple
callers.

> and for all the other ranges we would do the variable lookup:
> 
> 	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
> 	...
> 
> ?
> 
> Although I don't know what the code is supposed to do when a region
> starts in the fixed range and overlaps its end, i,e, something like
> that:
> 
> 	[ start ... 0x100000 ... end ]
> 
> The current code would return a fixed range index and that would be not
> really correct.
> 
> OTOH, this has been like this forever so maybe we don't care...

Right, and there is more.  As the original code had comment "Just return
the type as per start", which I noticed that I had accidentally removed,
the code only returns the type of the start address.  The fixed ranges
have multiple entries with different types.  Hence, a given range may
overlap with multiple fixed entries.  I will restore the comment in the
function header to clarify this limitation.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
