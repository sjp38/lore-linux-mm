Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9511A6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:58:02 -0400 (EDT)
Received: by oift201 with SMTP id t201so114877995oif.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 13:58:02 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id nz5si7715861obc.83.2015.05.11.13.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 13:58:02 -0700 (PDT)
Message-ID: <1431376726.23761.471.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 11 May 2015 14:38:46 -0600
In-Reply-To: <20150511201827.GI15636@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
	 <20150509090810.GB4452@pd.tnic>
	 <1431372316.23761.440.camel@misato.fc.hp.com>
	 <20150511201827.GI15636@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Mon, 2015-05-11 at 22:18 +0200, Borislav Petkov wrote:
> On Mon, May 11, 2015 at 01:25:16PM -0600, Toshi Kani wrote:
> > > > @@ -235,13 +240,19 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
> > > >   * Return Values:
> > > >   * MTRR_TYPE_(type)  - The effective MTRR type for the region
> > > >   * MTRR_TYPE_INVALID - MTRR is disabled
> > > > + *
> > > > + * Output Argument:
> > > > + * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
> > > > + *	     is fully covered by a single MTRR entry or the default type.
> > > 
> > > I'd call this "single_mtrr". "uniform" could also mean that the resulting
> > > type is uniform, i.e. of the same type but spanning multiple MTRRs.
> > 
> > Actually, that is the intend of "uniform" and the same type but spanning
> > multiple MTRRs should set "uniform" to 1.  The patch does not check such
> 
> So why does it say "is fully covered by a single MTRR entry or the
> default type." - the stress being on *single*
> 
> You need to make up your mind.

I will clarify the comment as follows.
===
uniform - Set to 1 when the region is not covered with multiple memory
types by MTRRs.  It is set for any return value.

NOTE: The current code sets 'uniform' to 1 when the region is fully
covered by a single MTRR entry or fully uncovered.  However, it does not
detect a uniform case that the region is covered by the same type but
spanning multiple MTRR entries for simplicity.
===

> > We need to set "uniform" to 1 when MTRRs are disabled since there is no
> > type conflict with MTRRs.
> 
> No, this is wrong.
> 
> When we return an *error*, "uniform" should be *undefined* because MTRRs
> are disabled and callers should be checking whether it returned an error
> first and only *then* look at uniform.

MTRRs disabled is not an error case as it could be a normal
configuration on some platforms / BIOS setups.  I clarified it in the
above comment that uniform is set for any return value.


> > The warning was suggested by reviewers in the previous review so that
> > driver writers will notice the issue.
> 
> No, we don't flood dmesg so that driver writers notice stuff. We better
> fix the callers.
> 
> > Returning 0 here will lead
> > ioremap() to use 4KB mappings, but does not cause ioremap() to fail.
> 
> I guess a pr_warn_once() should be better then. Flooding dmesg with
> error messages for which the user can't really do anything about doesn't
> bring us anything.

OK, I will change it to pr_warn_once().

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
