From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Date: Mon, 18 May 2015 21:01:50 +0200
Message-ID: <20150518190150.GC23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
 <20150518133348.GA23618@pd.tnic>
 <1431969759.19889.5.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431969759.19889.5.camel@misato.fc.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com
List-Id: linux-mm.kvack.org

On Mon, May 18, 2015 at 11:22:39AM -0600, Toshi Kani wrote:
> > diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> > index c30f9819786b..f1894daa79ee 100644
> > --- a/arch/x86/mm/pgtable.c
> > +++ b/arch/x86/mm/pgtable.c
> > @@ -566,19 +566,24 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> >  /**
> >   * pud_set_huge - setup kernel PUD mapping
> >   *
> > - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> > - * this function does not set up a huge page when the range is covered
> > - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> > - * disabled.
> > + * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
> > + * this function sets up a huge page only if all of the following
> > + * conditions are met:
> 
> It should be "if any of the following condition is met".  Or, does NOT
> setup if all of ...
> 
> > + *
> > + *  - MTRRs are disabled.
> > + *  - The range is mapped uniformly by an MTRR, i.e. the range is
> > + *    fully covered by a single MTRR entry or the default type.
> > + *  - The MTRR memory type is WB.

Hmm, ok, so this is kinda like "any" but they also depend on each other.
So it is

If
	- MTRRs are disabled

	or

	- MTRRs are enabled and the range is completely covered by a single MTRR

	or

	 - MTRRs are enabled and the range is not completely covered by a
	 single MTRR but the memory type of the range is WB, even if covered by
	 multiple MTRRs.

Right?

So tell me this: why do we need to repeat that over those KVA helpers?
It's not like the callers can do anything about it, can they?

So maybe that comment - expanded into more detail - should be over
mtrr_type_lookup() only. That'll be better, methinks.

Hmm.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
