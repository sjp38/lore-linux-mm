Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C38778E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 07:33:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 13-v6so17800293oiq.1
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 04:33:11 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d1-v6si4656016otc.152.2018.09.17.04.33.10
        for <linux-mm@kvack.org>;
        Mon, 17 Sep 2018 04:33:10 -0700 (PDT)
Date: Mon, 17 Sep 2018 12:33:28 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/5] ioremap: Rework pXd_free_pYd_page() API
Message-ID: <20180917113328.GC22717@arm.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
 <1536747974-25875-2-git-send-email-will.deacon@arm.com>
 <71baefb8e0838fba89ee06262bbb2456e9091c7a.camel@hpe.com>
 <db3f513bf3bfafb85b99f57f741f5bb07952af70.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db3f513bf3bfafb85b99f57f741f5bb07952af70.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Sep 14, 2018 at 09:10:49PM +0000, Kani, Toshi wrote:
> On Fri, 2018-09-14 at 14:36 -0600, Toshi Kani wrote:
> > On Wed, 2018-09-12 at 11:26 +0100, Will Deacon wrote:
> > > The recently merged API for ensuring break-before-make on page-table
> > > entries when installing huge mappings in the vmalloc/ioremap region is
> > > fairly counter-intuitive, resulting in the arch freeing functions
> > > (e.g. pmd_free_pte_page()) being called even on entries that aren't
> > > present. This resulted in a minor bug in the arm64 implementation, giving
> > > rise to spurious VM_WARN messages.
> > > 
> > > This patch moves the pXd_present() checks out into the core code,
> > > refactoring the callsites at the same time so that we avoid the complex
> > > conjunctions when determining whether or not we can put down a huge
> > > mapping.
> > > 
> > > Cc: Chintan Pandya <cpandya@codeaurora.org>
> > > Cc: Toshi Kani <toshi.kani@hpe.com>
> > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> > > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > 
> > Yes, this looks nicer.
> > 
> > Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
> 
> Sorry, I take it back since I got a question...
> 
> +static int ioremap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, phys_addr_t
> phys_addr,
> > +				pgprot_t prot)
> > +{
> > +	if (!ioremap_pmd_enabled())
> > +		return 0;
> > +
> > +	if ((end - addr) != PMD_SIZE)
> > +		return 0;
> > +
> > +	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
> > +		return 0;
> > +
> > +	if (pmd_present(*pmd) && !pmd_free_pte_page(pmd, addr))
> > +		return 0;
> 
> Is pm_present() a proper check here?  We probably do not have this case
> for iomap, but I wonder if one can drop p-bit while it has a pte page
> underneath.

For ioremap/vunmap the pXd_present() check is correct, yes. The vunmap()
code only ever clears leaf entries, leaving table entries intact. If it
did clear table entries, you'd be stuck here because you wouldn't have
the address of the table to free.

If somebody called pmd_mknotpresent() on a table entry, we may run into
problems, but it's only used for huge mappings afaict.

Will
