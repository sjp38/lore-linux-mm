Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id CD2286B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:44:31 -0400 (EDT)
Received: by oica37 with SMTP id a37so113269448oic.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 12:44:31 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id s9si7654039obu.3.2015.05.11.12.44.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 12:44:31 -0700 (PDT)
Message-ID: <1431372316.23761.440.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 11 May 2015 13:25:16 -0600
In-Reply-To: <20150509090810.GB4452@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
	 <20150509090810.GB4452@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Sat, 2015-05-09 at 11:08 +0200, Borislav Petkov wrote:
> On Tue, Mar 24, 2015 at 04:08:41PM -0600, Toshi Kani wrote:
 :
> > @@ -235,13 +240,19 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
> >   * Return Values:
> >   * MTRR_TYPE_(type)  - The effective MTRR type for the region
> >   * MTRR_TYPE_INVALID - MTRR is disabled
> > + *
> > + * Output Argument:
> > + * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
> > + *	     is fully covered by a single MTRR entry or the default type.
> 
> I'd call this "single_mtrr". "uniform" could also mean that the resulting
> type is uniform, i.e. of the same type but spanning multiple MTRRs.

Actually, that is the intend of "uniform" and the same type but spanning
multiple MTRRs should set "uniform" to 1.  The patch does not check such
case for simplicity since we do not need to maximize the performance
with MTRRs for every corner case since they are legacy and their use is
expected to be phased out.  It makes sure that a type conflict with
MTRRs is detected so that huge page mappings are made safely.

Also, in most of the cases, "uniform" is set to 1 because there is no
MTRR entry that covers the range, i.e. the default type.


> >   */
> > -u8 mtrr_type_lookup(u64 start, u64 end)
> > +u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
> >  {
> > -	u8 type, prev_type;
> > +	u8 type, prev_type, is_uniform, dummy;
> >  	int repeat;
> >  	u64 partial_end;
> >  
> > +	*uniform = 1;
> > +
> 
> You're setting it here...
> 
> >  	if (!mtrr_state_set)
> >  		return MTRR_TYPE_INVALID;
> 
> ... but if you return here, you would've changed the thing uniform
> points to needlessly as you're returning an error.

We need to set "uniform" to 1 when MTRRs are disabled since there is no
type conflict with MTRRs. 


> > @@ -253,14 +264,17 @@ u8 mtrr_type_lookup(u64 start, u64 end)
> >  	 * the variable ranges.
> >  	 */
> >  	type = mtrr_type_lookup_fixed(start, end);
> > -	if (type != MTRR_TYPE_INVALID)
> > +	if (type != MTRR_TYPE_INVALID) {
> > +		*uniform = 0;
> >  		return type;
> > +	}
> >  
> >  	/*
> >  	 * Look up the variable ranges.  Look of multiple ranges matching
> >  	 * this address and pick type as per MTRR precedence.
> >  	 */
> > -	type = mtrr_type_lookup_variable(start, end, &partial_end, &repeat);
> > +	type = mtrr_type_lookup_variable(start, end, &partial_end,
> > +					 &repeat, &is_uniform);
> >  
> >  	/*
> >  	 * Common path is with repeat = 0.
> > @@ -271,16 +285,21 @@ u8 mtrr_type_lookup(u64 start, u64 end)
> >  	while (repeat) {
> >  		prev_type = type;
> >  		start = partial_end;
> > +		is_uniform = 0;
> 
> So I think it would be better if you added an out: label where you do
> exit from the function and set return values there.
> 
> So something like that, I'm pasting the whole function here so that you
> can follow better:
 :
> 
> This way you're setting the uniform pointer in a single location and you're
> working with the local variable inside the function.
> 
> Much easier to follow.

With the label, the above check will be:

        if (!mtrr_state_set) {
		is_uniform = 1;
                type = MTRR_TYPE_INVALID;
		goto out;
	}

I can follow your suggestion of using the label if you still prefer
using it.


> >   */
> >  int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
> >  {
> > -	u8 mtrr;
> > +	u8 mtrr, uniform;
> >  
> > -	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> > -	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != MTRR_TYPE_INVALID))
> > +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE, &uniform);
> > +	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK)) {
> > +		pr_warn("pmd_set_huge: requesting [mem %#010llx-%#010llx], which spans more than a single MTRR entry\n",
> > +				addr, addr + PMD_SIZE);
> >  		return 0;
> 
> So this returns 0, i.e. failure already. Why do we even have to warn?
> Caller already knows it failed.
> 
> And this warning would flood dmesg needlessly.

The warning was suggested by reviewers in the previous review so that
driver writers will notice the issue.  Returning 0 here will lead
ioremap() to use 4KB mappings, but does not cause ioremap() to fail.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
