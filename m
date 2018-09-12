Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 275C58E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:14:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o27-v6so1407648pfj.6
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:14:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d13-v6si1502227pll.337.2018.09.12.10.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 10:14:46 -0700 (PDT)
Date: Wed, 12 Sep 2018 10:14:34 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [PATCH 4/5] lib/ioremap: Ensure phys_addr actually corresponds
 to a physical address
Message-ID: <20180912171434.GA31712@linux.intel.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
 <1536747974-25875-5-git-send-email-will.deacon@arm.com>
 <20180912150939.GA30274@linux.intel.com>
 <20180912163914.GA16071@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912163914.GA16071@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org

On Wed, Sep 12, 2018 at 05:39:14PM +0100, Will Deacon wrote:
> Hi Sean,
> 
> Thanks for looking at the patch.
> 
> On Wed, Sep 12, 2018 at 08:09:39AM -0700, Sean Christopherson wrote:
> > On Wed, Sep 12, 2018 at 11:26:13AM +0100, Will Deacon wrote:
> > > The current ioremap() code uses a phys_addr variable at each level of
> > > page table, which is confusingly offset by subtracting the base virtual
> > > address being mapped so that adding the current virtual address back on
> > > when iterating through the page table entries gives back the corresponding
> > > physical address.
> > > 
> > > This is fairly confusing and results in all users of phys_addr having to
> > > add the current virtual address back on. Instead, this patch just updates
> > > phys_addr when iterating over the page table entries, ensuring that it's
> > > always up-to-date and doesn't require explicit offsetting.
> > > 
> > > Cc: Chintan Pandya <cpandya@codeaurora.org>
> > > Cc: Toshi Kani <toshi.kani@hpe.com>
> > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > > ---
> > >  lib/ioremap.c | 28 ++++++++++++----------------
> > >  1 file changed, 12 insertions(+), 16 deletions(-)
> > > 
> > > diff --git a/lib/ioremap.c b/lib/ioremap.c
> > > index 6c72764af19c..fc834a59c90c 100644
> > > --- a/lib/ioremap.c
> > > +++ b/lib/ioremap.c
> > > @@ -101,19 +101,18 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
> > >  	pmd_t *pmd;
> > >  	unsigned long next;
> > >  
> > > -	phys_addr -= addr;
> > >  	pmd = pmd_alloc(&init_mm, pud, addr);
> > >  	if (!pmd)
> > >  		return -ENOMEM;
> > >  	do {
> > >  		next = pmd_addr_end(addr, end);
> > >  
> > > -		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr + addr, prot))
> > > +		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr, prot))
> > >  			continue;
> > >  
> > > -		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
> > > +		if (ioremap_pte_range(pmd, addr, next, phys_addr, prot))
> > >  			return -ENOMEM;
> > > -	} while (pmd++, addr = next, addr != end);
> > > +	} while (pmd++, addr = next, phys_addr += PMD_SIZE, addr != end);
> > 
> > I think bumping phys_addr by PXX_SIZE is wrong if phys_addr and addr
> > start unaligned with respect to PXX_SIZE.  The addresses must be
> > PAGE_ALIGNED, which lets ioremap_pte_range() do a simple calculation,
> > but that doesn't hold true for the upper levels, i.e. phys_addr needs
> > to be adjusted using an algorithm similar to pxx_addr_end().
> > 
> > Using a 2mb page as an example (lower 32 bits only): 
> > 
> > pxx_size  = 0x00020000
> > pxx_mask  = 0xfffe0000
> > addr      = 0x1000
> > end       = 0x00040000
> > phys_addr = 0x1000
> > 
> > Loop 1:
> >    addr = 0x1000
> >    phys = 0x1000
> > 
> > Loop 2:
> >    addr = 0x20000
> >    phys = 0x21000
> 
> Yes, I think you're completely right, however I also don't think this
> can happen with the current code (and I've failed to trigger it in my
> testing). The virtual addresses allocated for VM_IOREMAP allocations
> are aligned to the order of the allocation, which means that the virtual
> address at the start of the mapping is aligned such that when we hit the
> end of a pXd, we know we've mapped the previous PXD_SIZE bytes.
> 
> Having said that, this is clearly a change from the current code and I
> haven't audited architectures other than arm64 (where IOREMAP_MAX_ORDER
> corresponds to the maximum size of our huge mappings), so it would be
> much better not to introduce this funny behaviour in a patch that aims
> to reduce confusion in the first place!
> 
> Fixing this using the pxx_addr_end() macros is a bit strange, since we
> don't have a physical end variable (nor do we need one), so perhaps
> something like changing the while condition to be:
> 
> 	do {
> 		...
> 	} while (pmd++, phys_addr += (next - addr), addr = next, addr != end);
> 
> would do the trick. What do you reckon?

LGTM.  I like that there isn't a separate calculation for phys_addr's offset.
