Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1016F900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:52:56 -0400 (EDT)
Received: by obcva8 with SMTP id va8so10177798obc.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 09:52:55 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id e81si2414654oif.34.2015.03.11.09.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 09:52:55 -0700 (PDT)
Message-ID: <1426092728.17007.380.camel@misato.fc.hp.com>
Subject: Re: [PATCH 3/3] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 11 Mar 2015 10:52:08 -0600
In-Reply-To: <20150311070216.GD29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
	 <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
	 <20150311070216.GD29788@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, 2015-03-11 at 08:02 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > This patch adds an additional argument, *uniform, to
> 
> s/*uniform/'uniform'

Done.

> > mtrr_type_lookup(), which returns 1 when a given range is
> > either fully covered by a single MTRR entry or not covered
> > at all.
> 
> s/or not covered/or is not covered

Done.

> > pud_set_huge() and pmd_set_huge() are changed to check the
> > new uniform flag to see if it is safe to create a huge page
> 
> s/uniform/'uniform'

Done.

> > mapping to the range.  This allows them to create a huge page
> > mapping to a range covered by a single MTRR entry of any
> > memory type.  It also detects an unoptimal request properly.
> 
> s/unoptimal/non-optimal

Done.

> or nonoptimal
> 
> Also, some description in the changelog about what a 'non-optimal' 
> request is would be most userful.
> 
> > They continue to check with the WB type since the WB type has
> > no effect even if a request spans to multiple MTRR entries.
> 
> s/spans to/spans

Done.

> > -static inline u8 mtrr_type_lookup(u64 addr, u64 end)
> > +static inline u8 mtrr_type_lookup(u64 addr, u64 end, u8 *uniform)
> >  {
> >  	/*
> >  	 * Return no-MTRRs:
> >  	 */
> > +	*uniform = 1;
> >  	return 0xff;
> >  }
> >  #define mtrr_save_fixed_ranges(arg) do {} while (0)
> > diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
> > index cdb955f..aef238c 100644
> > --- a/arch/x86/kernel/cpu/mtrr/generic.c
> > +++ b/arch/x86/kernel/cpu/mtrr/generic.c
> > @@ -108,14 +108,19 @@ static int check_type_overlap(u8 *prev, u8 *curr)
> >   * *repeat == 1 implies [start:end] spanned across MTRR range and type returned
> >   *		corresponds only to [start:*partial_end].
> >   *		Caller has to lookup again for [*partial_end:end].
> > + * *uniform == 1 The requested range is either fully covered by a single MTRR
> > + *		 entry or not covered at all.
> >   */
> 
> So I think a better approach would be to count the number of separate 
> MTRR caching types a range is covered by, instead of this hard to 
> quality 'uniform' flag.
> 
> I.e. a 'nr_mtrr_types' count.
> 
> If for example a range partially intersects with an MTRR, then that 
> count would be 2: the MTRR, and the outside (default cache policy) 
> type.
> 
> ( Note that with this approach is not only easy to understand and easy 
>   to review, but could also be refined in the future, to count the 
>   number of _incompatible_ caching types present within a range. )

I agree that using a count is more flexible.  However, there are some
issues below.

 - MTRRs have both fixed and variable ranges. The first 1MB is covered
with 11 fixed-range registers with different sizes of granularity,
512KB, 128KB, and 32KB.  __mtrr_type_lookup() checks the memory type of
the range at 'start', but does not check if a requested range spans
multiple memory types.  This first 1MB can be handled as 'uniform = 0'
since processors do not create a huge page map in this 1MB range.
However, setting a correct value to 'nr_mtrr_types' requires a major
overhaul in this code.

 - mtrr_type_lookup() returns without walking through all MTRR entries
when check_type_overlap() returns 1, i.e. the overlap made the resulted
memory type UC.  In this case, the code cannot set a correct value to
'nr_mtrr_type'.

Since MTRRs are legacy, esp. the fixed range, there is not much benefit
from enhancing the functionality of mtrr_type_lookup() unless there is
an issue with the current platforms.  For this patch, we only need to
know whether the mapping count is 1 or >1.  So, I think using 'uniform'
makes sense for simplicity.

> > -static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> > +static u8 __mtrr_type_lookup(u64 start, u64 end,
> > +			     u64 *partial_end, int *repeat, u8 *uniform)
> >  {
> >  	int i;
> >  	u64 base, mask;
> >  	u8 prev_match, curr_match;
> >  
> >  	*repeat = 0;
> > +	*uniform = 1;
> > +
> >  	if (!mtrr_state_set)
> >  		return 0xFF;
> >  
> > @@ -128,6 +133,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  	/* Look in fixed ranges. Just return the type as per start */
> >  	if (mtrr_state.have_fixed && (start < 0x100000)) {
> >  		int idx;
> > +		*uniform = 0;
> 
> So this function scares me, because the code is clearly crap:
> 
>         if (mtrr_state.have_fixed && (start < 0x100000)) {
> 	...
>                 } else if (start < 0x1000000) {
> 	...
> 
> How can that 'else if' branch ever not be true?

This 'else if' is always true.  So, it can be simply 'else' without any
condition.

> Did it perhaps want to be the other way around:
> 
>         if (mtrr_state.have_fixed && (start < 0x1000000)) {
> 	...
>                 } else if (start < 0x100000) {
> 	...
> 
> or did it simply mess up the condition?

I think it was just paranoid to test the same condition twice...

> >  
> >  		if (start < 0x80000) {
> >  			idx = 0;
> > @@ -195,6 +201,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  
> >  			end = *partial_end - 1; /* end is inclusive */
> >  			*repeat = 1;
> > +			*uniform = 0;
> >  		}
> >  
> >  		if (!start_state)
> > @@ -206,6 +213,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  			continue;
> >  		}
> >  
> > +		*uniform = 0;
> >  		if (check_type_overlap(&prev_match, &curr_match))
> >  			return curr_match;
> >  	}
> 
> 
> > @@ -222,17 +230,21 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  }
> >  
> >  /*
> > - * Returns the effective MTRR type for the region
> > + * Returns the effective MTRR type for the region.  *uniform is set to 1
> > + * when a given range is either fully covered by a single MTRR entry or
> > + * not covered at all.
> > + *
> >   * Error return:
> >   * 0xFF - when MTRR is not enabled
> >   */
> > -u8 mtrr_type_lookup(u64 start, u64 end)
> > +u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
> >  {
> > -	u8 type, prev_type;
> > +	u8 type, prev_type, is_uniform, dummy;
> >  	int repeat;
> >  	u64 partial_end;
> >  
> > -	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> > +	type = __mtrr_type_lookup(start, end,
> > +				  &partial_end, &repeat, &is_uniform);
> >  
> >  	/*
> >  	 * Common path is with repeat = 0.
> > @@ -242,12 +254,18 @@ u8 mtrr_type_lookup(u64 start, u64 end)
> >  	while (repeat) {
> >  		prev_type = type;
> >  		start = partial_end;
> > -		type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> > +		is_uniform = 0;
> >  
> > -		if (check_type_overlap(&prev_type, &type))
> > +		type = __mtrr_type_lookup(start, end,
> > +					  &partial_end, &repeat, &dummy);
> > +
> > +		if (check_type_overlap(&prev_type, &type)) {
> > +			*uniform = 0;
> >  			return type;
> > +		}
> >  	}
> >  
> > +	*uniform = is_uniform;
> >  	return type;
> 
> So the MTRR code is from hell, it would be nice to first clean up the 
> whole code and the MTRR data structures before extending it with more 
> complexity ...

Good idea.  I will clean up the code (no functional change) before
making this change.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
