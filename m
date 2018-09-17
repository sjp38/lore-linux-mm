Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB27D8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 07:33:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id j65-v6so10474461otc.5
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 04:33:05 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g30-v6si4443223oth.207.2018.09.17.04.33.04
        for <linux-mm@kvack.org>;
        Mon, 17 Sep 2018 04:33:04 -0700 (PDT)
Date: Mon, 17 Sep 2018 12:33:22 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/5] x86: pgtable: Drop pXd_none() checks from
 pXd_free_pYd_table()
Message-ID: <20180917113321.GB22717@arm.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
 <1536747974-25875-4-git-send-email-will.deacon@arm.com>
 <dc8b03de1e3318e3dd577d80482260f99ab4e9a5.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc8b03de1e3318e3dd577d80482260f99ab4e9a5.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Sep 14, 2018 at 08:37:48PM +0000, Kani, Toshi wrote:
> On Wed, 2018-09-12 at 11:26 +0100, Will Deacon wrote:
> > Now that the core code checks this for us, we don't need to do it in the
> > backend.
> > 
> > Cc: Chintan Pandya <cpandya@codeaurora.org>
> > Cc: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > ---
> >  arch/x86/mm/pgtable.c | 6 ------
> >  1 file changed, 6 deletions(-)
> > 
> > diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> > index ae394552fb94..b4919c44a194 100644
> > --- a/arch/x86/mm/pgtable.c
> > +++ b/arch/x86/mm/pgtable.c
> > @@ -796,9 +796,6 @@ int pud_free_pmd_page(pud_t *pud, unsigned long addr)
> >  	pte_t *pte;
> >  	int i;
> >  
> > -	if (pud_none(*pud))
> > -		return 1;
> > -
> 
> Do we need to remove this safe guard?  I feel list this is same as
> kfree() accepting NULL.

I think two big differences with kfree() are (1) that this function has
exactly one caller in the tree and (2) it's implemented per-arch. Therefore
we're in a good position to give it some simple semantics and implement
those. Of course, if the x86 people would like to keep the redundant check,
that's up to them, but I think it makes the function more confusing and
tempts people into calling it for present entries.

Will
