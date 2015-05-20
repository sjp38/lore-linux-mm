Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 361DC6B0127
	for <linux-mm@kvack.org>; Wed, 20 May 2015 11:01:20 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so56001217wgb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 08:01:19 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id v3si1128512wix.97.2015.05.20.08.01.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 08:01:19 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so158265771wic.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 08:01:18 -0700 (PDT)
Date: Wed, 20 May 2015 17:01:14 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150520150114.GA19161@gmail.com>
References: <20150518190150.GC23618@pd.tnic>
 <1431977519.20569.15.camel@misato.fc.hp.com>
 <20150518200114.GE23618@pd.tnic>
 <1431980468.21019.11.camel@misato.fc.hp.com>
 <20150518205123.GI23618@pd.tnic>
 <1431985994.21526.12.camel@misato.fc.hp.com>
 <20150519114437.GF4641@pd.tnic>
 <20150519132307.GG4641@pd.tnic>
 <20150520115509.GA3489@gmail.com>
 <1432132451.700.4.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432132451.700.4.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Borislav Petkov <bp@alien8.de>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Wed, 2015-05-20 at 13:55 +0200, Ingo Molnar wrote:
> > * Borislav Petkov <bp@alien8.de> wrote:
> > 
> > > --- a/arch/x86/mm/pgtable.c
> > > +++ b/arch/x86/mm/pgtable.c
> > > @@ -566,19 +566,28 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> > >  /**
> > >   * pud_set_huge - setup kernel PUD mapping
> > >   *
> > > - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> > > - * this function does not set up a huge page when the range is covered
> > > - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> > > - * disabled.
> > > + * MTRRs can override PAT memory types with 4KiB granularity. Therefore, this
> > > + * function sets up a huge page only if any of the following conditions are met:
> > > + *
> > > + * - MTRRs are disabled, or
> > > + *
> > > + * - MTRRs are enabled and the range is completely covered by a single MTRR, or
> > > + *
> > > + * - MTRRs are enabled and the range is not completely covered by a single MTRR
> > > + *   but the memory type of the range is WB, even if covered by multiple MTRRs.
> > > + *
> > > + * Callers should try to decrease page size (1GB -> 2MB -> 4K) if the bigger
> > > + * page mapping attempt fails.
> > 
> > This comment should explain why it's ok in the WB case.
> > 
> > Also, the phrase 'the memory type of the range' is ambiguous: it might 
> > mean the partial MTRR's, or the memory type specified via PAT by the 
> > huge-pmd entry.
> 
> Agreed.  How about this sentence?
> 
>  - MTRRs are enabled and the corresponding MTRR memory type is WB, which
> has no effect to the requested PAT memory type.

s/effect to/effect on

sounds good otherwise!

Btw., if WB MTRR entries can never have an effect on Linux PAT 
specified attributes, why do we allow them to be created? I don't 
think we ever call into real mode for this to matter?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
