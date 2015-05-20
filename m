Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id AC9306B0129
	for <linux-mm@kvack.org>; Wed, 20 May 2015 11:21:47 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so4577046obb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 08:21:47 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id l1si10873845obn.71.2015.05.20.08.21.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 08:21:47 -0700 (PDT)
Message-ID: <1432134143.908.12.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 20 May 2015 09:02:23 -0600
In-Reply-To: <20150520150114.GA19161@gmail.com>
References: <20150518190150.GC23618@pd.tnic>
	 <1431977519.20569.15.camel@misato.fc.hp.com>
	 <20150518200114.GE23618@pd.tnic>
	 <1431980468.21019.11.camel@misato.fc.hp.com>
	 <20150518205123.GI23618@pd.tnic>
	 <1431985994.21526.12.camel@misato.fc.hp.com>
	 <20150519114437.GF4641@pd.tnic> <20150519132307.GG4641@pd.tnic>
	 <20150520115509.GA3489@gmail.com> <1432132451.700.4.camel@misato.fc.hp.com>
	 <20150520150114.GA19161@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Wed, 2015-05-20 at 17:01 +0200, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > On Wed, 2015-05-20 at 13:55 +0200, Ingo Molnar wrote:
> > > * Borislav Petkov <bp@alien8.de> wrote:
> > > 
> > > > --- a/arch/x86/mm/pgtable.c
> > > > +++ b/arch/x86/mm/pgtable.c
> > > > @@ -566,19 +566,28 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> > > >  /**
> > > >   * pud_set_huge - setup kernel PUD mapping
> > > >   *
> > > > - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> > > > - * this function does not set up a huge page when the range is covered
> > > > - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> > > > - * disabled.
> > > > + * MTRRs can override PAT memory types with 4KiB granularity. Therefore, this
> > > > + * function sets up a huge page only if any of the following conditions are met:
> > > > + *
> > > > + * - MTRRs are disabled, or
> > > > + *
> > > > + * - MTRRs are enabled and the range is completely covered by a single MTRR, or
> > > > + *
> > > > + * - MTRRs are enabled and the range is not completely covered by a single MTRR
> > > > + *   but the memory type of the range is WB, even if covered by multiple MTRRs.
> > > > + *
> > > > + * Callers should try to decrease page size (1GB -> 2MB -> 4K) if the bigger
> > > > + * page mapping attempt fails.
> > > 
> > > This comment should explain why it's ok in the WB case.
> > > 
> > > Also, the phrase 'the memory type of the range' is ambiguous: it might 
> > > mean the partial MTRR's, or the memory type specified via PAT by the 
> > > huge-pmd entry.
> > 
> > Agreed.  How about this sentence?
> > 
> >  - MTRRs are enabled and the corresponding MTRR memory type is WB, which
> > has no effect to the requested PAT memory type.
> 
> s/effect to/effect on
> 
> sounds good otherwise!

Great!

Boris, can you update the patch, or do you want me to send you a patch
for this update?

> Btw., if WB MTRR entries can never have an effect on Linux PAT 
> specified attributes, why do we allow them to be created? I don't 
> think we ever call into real mode for this to matter?

MTRRs have the default memory type, which is used when the given range
is not covered by any MTRR entries.  There are two types of BIOS setup:

1) Default UC
 - BIOS sets the default type to UC, and covers all WB accessible ranges
with MTRR entries of WB.

2) Default WB
 - BIOS sets the default type to WB, and covers non-WB accessible range
with MTRR entries of other memory types, such as UC.

In both cases, WB type can be returned.  In case of 1), the requested
range may overlap with multiple MTRR entries of WB type, which is still
safe.

Thanks,
-Toshi


Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
