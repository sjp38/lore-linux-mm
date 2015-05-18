Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8526B0085
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:51:22 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so138979677obb.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:51:21 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id k63si7042929oif.98.2015.05.18.12.51.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:51:21 -0700 (PDT)
Message-ID: <1431977519.20569.15.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 18 May 2015 13:31:59 -0600
In-Reply-To: <20150518190150.GC23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
	 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	 <20150518133348.GA23618@pd.tnic>
	 <1431969759.19889.5.camel@misato.fc.hp.com>
	 <20150518190150.GC23618@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Mon, 2015-05-18 at 21:01 +0200, Borislav Petkov wrote:
> On Mon, May 18, 2015 at 11:22:39AM -0600, Toshi Kani wrote:
> > > diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> > > index c30f9819786b..f1894daa79ee 100644
> > > --- a/arch/x86/mm/pgtable.c
> > > +++ b/arch/x86/mm/pgtable.c
> > > @@ -566,19 +566,24 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> > >  /**
> > >   * pud_set_huge - setup kernel PUD mapping
> > >   *
> > > - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> > > - * this function does not set up a huge page when the range is covered
> > > - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> > > - * disabled.
> > > + * MTRRs can override PAT memory types with 4KiB granularity. Therefore,
> > > + * this function sets up a huge page only if all of the following
> > > + * conditions are met:
> > 
> > It should be "if any of the following condition is met".  Or, does NOT
> > setup if all of ...
> > 
> > > + *
> > > + *  - MTRRs are disabled.
> > > + *  - The range is mapped uniformly by an MTRR, i.e. the range is
> > > + *    fully covered by a single MTRR entry or the default type.
> > > + *  - The MTRR memory type is WB.
> 
> Hmm, ok, so this is kinda like "any" but they also depend on each other.
> So it is
> 
> If
> 	- MTRRs are disabled
> 
> 	or
> 
> 	- MTRRs are enabled and the range is completely covered by a single MTRR
> 
> 	or
> 
> 	 - MTRRs are enabled and the range is not completely covered by a
> 	 single MTRR but the memory type of the range is WB, even if covered by
> 	 multiple MTRRs.
> 
> Right?

Well, #2 and #3 are independent. That is, uniform can be set regardless
of a type value, and WB can be returned regardless of a uniform value.  

#1 is a new condition added per your comment that uniform no longer
covers the MTRR disabled case.  Yes, #2 and #3 depend on #1 being false.

> So tell me this: why do we need to repeat that over those KVA helpers?
> It's not like the callers can do anything about it, can they?
>
> So maybe that comment - expanded into more detail - should be over
> mtrr_type_lookup() only. That'll be better, methinks.

The caller is responsible for verifying the conditions that are safe to
create huge page.  So, I think the comments are needed here to state
such conditions.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
