Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id DC26B6B0126
	for <linux-mm@kvack.org>; Wed, 20 May 2015 10:53:40 -0400 (EDT)
Received: by obfe9 with SMTP id e9so38482634obf.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 07:53:40 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id pm5si10793485oec.87.2015.05.20.07.53.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 07:53:40 -0700 (PDT)
Message-ID: <1432132451.700.4.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 20 May 2015 08:34:11 -0600
In-Reply-To: <20150520115509.GA3489@gmail.com>
References: <20150518133348.GA23618@pd.tnic>
	 <1431969759.19889.5.camel@misato.fc.hp.com>
	 <20150518190150.GC23618@pd.tnic>
	 <1431977519.20569.15.camel@misato.fc.hp.com>
	 <20150518200114.GE23618@pd.tnic>
	 <1431980468.21019.11.camel@misato.fc.hp.com>
	 <20150518205123.GI23618@pd.tnic>
	 <1431985994.21526.12.camel@misato.fc.hp.com>
	 <20150519114437.GF4641@pd.tnic> <20150519132307.GG4641@pd.tnic>
	 <20150520115509.GA3489@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Wed, 2015-05-20 at 13:55 +0200, Ingo Molnar wrote:
> * Borislav Petkov <bp@alien8.de> wrote:
> 
> > --- a/arch/x86/mm/pgtable.c
> > +++ b/arch/x86/mm/pgtable.c
> > @@ -566,19 +566,28 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
> >  /**
> >   * pud_set_huge - setup kernel PUD mapping
> >   *
> > - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> > - * this function does not set up a huge page when the range is covered
> > - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> > - * disabled.
> > + * MTRRs can override PAT memory types with 4KiB granularity. Therefore, this
> > + * function sets up a huge page only if any of the following conditions are met:
> > + *
> > + * - MTRRs are disabled, or
> > + *
> > + * - MTRRs are enabled and the range is completely covered by a single MTRR, or
> > + *
> > + * - MTRRs are enabled and the range is not completely covered by a single MTRR
> > + *   but the memory type of the range is WB, even if covered by multiple MTRRs.
> > + *
> > + * Callers should try to decrease page size (1GB -> 2MB -> 4K) if the bigger
> > + * page mapping attempt fails.
> 
> This comment should explain why it's ok in the WB case.
> 
> Also, the phrase 'the memory type of the range' is ambiguous: it might 
> mean the partial MTRR's, or the memory type specified via PAT by the 
> huge-pmd entry.

Agreed.  How about this sentence?

 - MTRRs are enabled and the corresponding MTRR memory type is WB, which
has no effect to the requested PAT memory type.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
