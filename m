Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4A66B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 13:51:14 -0400 (EDT)
Received: by oica37 with SMTP id a37so152729885oic.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 10:51:14 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id y9si10595848obm.40.2015.05.05.10.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 10:51:13 -0700 (PDT)
Message-ID: <1430847128.23761.276.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 05 May 2015 11:32:08 -0600
In-Reply-To: <20150505171114.GM3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
	 <20150505171114.GM3910@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-05 at 19:11 +0200, Borislav Petkov wrote:
> On Tue, Mar 24, 2015 at 04:08:36PM -0600, Toshi Kani wrote:
> > When an MTRR entry is inclusive to a requested range, i.e.
> > the start and end of the request are not within the MTRR
> > entry range but the range contains the MTRR entry entirely,
> > __mtrr_type_lookup() ignores such a case because both
> > start_state and end_state are set to zero.
> > 
> > This bug can cause the following issues:
> > 1) reserve_memtype() tracks an effective memory type in case
> >    a request type is WB (ex. /dev/mem blindly uses WB). Missing
> >    to track with its effective type causes a subsequent request
> >    to map the same range with the effective type to fail.
> > 2) pud_set_huge() and pmd_set_huge() check if a requested range
> >    has any overlap with MTRRs. Missing to detect an overlap may
> >    cause a performance penalty or undefined behavior.
> > 
> > This patch fixes the bug by adding a new flag, 'inclusive',
> > to detect the inclusive case.  This case is then handled in
> > the same way as (!start_state && end_state).  With this fix,
> > __mtrr_type_lookup() handles the inclusive case properly.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  arch/x86/kernel/cpu/mtrr/generic.c |   17 +++++++++--------
> >  1 file changed, 9 insertions(+), 8 deletions(-)
> > 
> > diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
> > index 7d74f7b..a82e370 100644
> > --- a/arch/x86/kernel/cpu/mtrr/generic.c
> > +++ b/arch/x86/kernel/cpu/mtrr/generic.c
> > @@ -154,7 +154,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  
> >  	prev_match = 0xFF;
> >  	for (i = 0; i < num_var_ranges; ++i) {
> > -		unsigned short start_state, end_state;
> > +		unsigned short start_state, end_state, inclusive;
> >  
> >  		if (!(mtrr_state.var_ranges[i].mask_lo & (1 << 11)))
> >  			continue;
> > @@ -166,15 +166,16 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  
> >  		start_state = ((start & mask) == (base & mask));
> >  		end_state = ((end & mask) == (base & mask));
> > +		inclusive = ((start < base) && (end > base));
> >  
> > -		if (start_state != end_state) {
> > +		if ((start_state != end_state) || inclusive) {
> >  			/*
> >  			 * We have start:end spanning across an MTRR.
> > -			 * We split the region into
> > -			 * either
> > -			 * (start:mtrr_end) (mtrr_end:end)
> > -			 * or
> > -			 * (start:mtrr_start) (mtrr_start:end)
> > +			 * We split the region into either
> > +			 * - start_state:1
> > +			 *     (start:mtrr_end) (mtrr_end:end)
> > +			 * - end_state:1 or inclusive:1
> > +			 *     (start:mtrr_start) (mtrr_start:end)
> 
> Ok, I'm confused. Shouldn't the inclusive:1 case be
> 
> 			(start:mtrr_start) (mtrr_start:mtrr_end) (mtrr_end:end)
> 
> ?
> 
> If so, this function would need more changes...

Yes, that's how it gets separated eventually.  Since *repeat is set in
this case, the code only needs to separate the first part at a time.
The 2nd part gets separated in the next call with the *repeat.


> >  			 * depending on kind of overlap.
> >  			 * Return the type for first region and a pointer to
> >  			 * the start of second region so that caller will
> > @@ -195,7 +196,7 @@ static u8 __mtrr_type_lookup(u64 start, u64 end, u64 *partial_end, int *repeat)
> >  			*repeat = 1;
> >  		}
> >  
> > -		if ((start & mask) != (base & mask))
> > +		if (!start_state)
> >  			continue;
> 
> That change actually makes the code more unreadable because you have to
> go and look up what start_state was and the previous version actually
> shows the check that start is within the range, exactly like it is
> documented in the CPU manuals.
> 
> And I'd leave it this way because gcc is smart enough to reload the
> result saved in start_state and not compute it again.

When I see such re-calculation, it makes me look at the code again to
see if there is a case that updates the parameters after the first
calculation...  That said, I am OK as long as gcc is smart enough to
reload the value.  I will put it back to the original.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
