Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D74BB6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:13:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s21so4954284oie.5
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:13:05 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id z126si1182182oiz.119.2017.08.11.14.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:13:04 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id o9so24459852iod.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:13:04 -0700 (PDT)
Date: Fri, 11 Aug 2017 15:13:02 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
Message-ID: <20170811211302.limmjv4rmq23b25b@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
 <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

Hi Laura,

On Fri, Aug 11, 2017 at 10:25:14AM -0700, Laura Abbott wrote:
> On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> > From: Juerg Haefliger <juerg.haefliger@hpe.com>
> > 
> > XPFO (eXclusive Page Frame Ownership) doesn't support section mappings
> > yet, so disable it if XPFO is turned on.
> > 
> > Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> > Tested-by: Tycho Andersen <tycho@docker.com>
> > ---
> >  arch/arm64/mm/mmu.c | 14 +++++++++++++-
> >  1 file changed, 13 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > index f1eb15e0e864..38026b3ccb46 100644
> > --- a/arch/arm64/mm/mmu.c
> > +++ b/arch/arm64/mm/mmu.c
> > @@ -176,6 +176,18 @@ static void alloc_init_cont_pte(pmd_t *pmd, unsigned long addr,
> >  	} while (addr = next, addr != end);
> >  }
> >  
> > +static inline bool use_section_mapping(unsigned long addr, unsigned long next,
> > +				unsigned long phys)
> > +{
> > +	if (IS_ENABLED(CONFIG_XPFO))
> > +		return false;
> > +
> > +	if (((addr | next | phys) & ~SECTION_MASK) != 0)
> > +		return false;
> > +
> > +	return true;
> > +}
> > +
> >  static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
> >  		     phys_addr_t phys, pgprot_t prot,
> >  		     phys_addr_t (*pgtable_alloc)(void), int flags)
> > @@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
> >  		next = pmd_addr_end(addr, end);
> >  
> >  		/* try section mapping first */
> > -		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
> > +		if (use_section_mapping(addr, next, phys) &&
> >  		    (flags & NO_BLOCK_MAPPINGS) == 0) {
> >  			pmd_set_huge(pmd, phys, prot);
> >  
> > 
> 
> There is already similar logic to disable section mappings for
> debug_pagealloc at the start of map_mem, can you take advantage
> of that?

You're suggesting something like this instead? Seems to work fine.

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 38026b3ccb46..3b2c17bbbf12 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -434,6 +434,8 @@ static void __init map_mem(pgd_t *pgd)
 
 	if (debug_pagealloc_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
+	if (IS_ENABLED(CONFIG_XPFO))
+		flags |= NO_BLOCK_MAPPINGS;
 
 	/*
 	 * Take care not to create a writable alias for the

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
