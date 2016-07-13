Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBB7A6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:23:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so38050694wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:23:31 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id dc8si1586812wjb.44.2016.07.13.08.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:23:30 -0700 (PDT)
Date: Wed, 13 Jul 2016 17:23:27 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 4/4] x86: use pte_none() to test for empty PTE
In-Reply-To: <20160713151820.GA20693@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607131722440.2959@hadrien>
References: <20160708001909.FB2443E2@viggo.jf.intel.com> <20160708001915.813703D9@viggo.jf.intel.com> <20160713151820.GA20693@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com



On Wed, 13 Jul 2016, Michal Hocko wrote:

> [CCing Julia]
>
> On Thu 07-07-16 17:19:15, Dave Hansen wrote:
> >
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> > The page table manipulation code seems to have grown a couple of
> > sites that are looking for empty PTEs.  Just in case one of these
> > entries got a stray bit set, use pte_none() instead of checking
> > for a zero pte_val().
>
> This looks like something that coccinelle could help with and automate.
> Especially when the patch seems interesting for applying to older kernel
> code streams.
>
> Julia would it be hard to generate a metapatch which would check the
> {pte,pmd}_val() usage in conditions and replace them with {pte,pmd}_none
> equivalents?

Thanks for forwarding.  A priori, it looks quite trivial.  I will do the
obvious thing and send the results for verification.

julia

> > The use pte_same() makes me a bit nervous.  If we were doing a
> > pte_same() check against two cleared entries and one of them had
> > a stray bit set, it might fail the pte_same() check.  But, I
> > don't think we ever _do_ pte_same() for cleared entries.  It is
> > almost entirely used for checking for races in fault-in paths.
> >
> > Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>
> Other than that looks good to me. Feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> > ---
> >
> >  b/arch/x86/mm/init_64.c    |   12 ++++++------
> >  b/arch/x86/mm/pageattr.c   |    2 +-
> >  b/arch/x86/mm/pgtable_32.c |    2 +-
> >  3 files changed, 8 insertions(+), 8 deletions(-)
> >
> > diff -puN arch/x86/mm/init_64.c~knl-strays-50-pte_val-cleanups arch/x86/mm/init_64.c
> > --- a/arch/x86/mm/init_64.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.942808493 -0700
> > +++ b/arch/x86/mm/init_64.c	2016-07-07 17:17:44.949808807 -0700
> > @@ -354,7 +354,7 @@ phys_pte_init(pte_t *pte_page, unsigned
> >  		 * pagetable pages as RO. So assume someone who pre-setup
> >  		 * these mappings are more intelligent.
> >  		 */
> > -		if (pte_val(*pte)) {
> > +		if (!pte_none(*pte)) {
> >  			if (!after_bootmem)
> >  				pages++;
> >  			continue;
> > @@ -396,7 +396,7 @@ phys_pmd_init(pmd_t *pmd_page, unsigned
> >  			continue;
> >  		}
> >
> > -		if (pmd_val(*pmd)) {
> > +		if (!pmd_none(*pmd)) {
> >  			if (!pmd_large(*pmd)) {
> >  				spin_lock(&init_mm.page_table_lock);
> >  				pte = (pte_t *)pmd_page_vaddr(*pmd);
> > @@ -470,7 +470,7 @@ phys_pud_init(pud_t *pud_page, unsigned
> >  			continue;
> >  		}
> >
> > -		if (pud_val(*pud)) {
> > +		if (!pud_none(*pud)) {
> >  			if (!pud_large(*pud)) {
> >  				pmd = pmd_offset(pud, 0);
> >  				last_map_addr = phys_pmd_init(pmd, addr, end,
> > @@ -673,7 +673,7 @@ static void __meminit free_pte_table(pte
> >
> >  	for (i = 0; i < PTRS_PER_PTE; i++) {
> >  		pte = pte_start + i;
> > -		if (pte_val(*pte))
> > +		if (!pte_none(*pte))
> >  			return;
> >  	}
> >
> > @@ -691,7 +691,7 @@ static void __meminit free_pmd_table(pmd
> >
> >  	for (i = 0; i < PTRS_PER_PMD; i++) {
> >  		pmd = pmd_start + i;
> > -		if (pmd_val(*pmd))
> > +		if (!pmd_none(*pmd))
> >  			return;
> >  	}
> >
> > @@ -710,7 +710,7 @@ static bool __meminit free_pud_table(pud
> >
> >  	for (i = 0; i < PTRS_PER_PUD; i++) {
> >  		pud = pud_start + i;
> > -		if (pud_val(*pud))
> > +		if (!pud_none(*pud))
> >  			return false;
> >  	}
> >
> > diff -puN arch/x86/mm/pageattr.c~knl-strays-50-pte_val-cleanups arch/x86/mm/pageattr.c
> > --- a/arch/x86/mm/pageattr.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.944808582 -0700
> > +++ b/arch/x86/mm/pageattr.c	2016-07-07 17:17:44.950808852 -0700
> > @@ -1185,7 +1185,7 @@ repeat:
> >  		return __cpa_process_fault(cpa, address, primary);
> >
> >  	old_pte = *kpte;
> > -	if (!pte_val(old_pte))
> > +	if (pte_none(old_pte))
> >  		return __cpa_process_fault(cpa, address, primary);
> >
> >  	if (level == PG_LEVEL_4K) {
> > diff -puN arch/x86/mm/pgtable_32.c~knl-strays-50-pte_val-cleanups arch/x86/mm/pgtable_32.c
> > --- a/arch/x86/mm/pgtable_32.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.946808672 -0700
> > +++ b/arch/x86/mm/pgtable_32.c	2016-07-07 17:17:44.950808852 -0700
> > @@ -47,7 +47,7 @@ void set_pte_vaddr(unsigned long vaddr,
> >  		return;
> >  	}
> >  	pte = pte_offset_kernel(pmd, vaddr);
> > -	if (pte_val(pteval))
> > +	if (!pte_none(pteval))
> >  		set_pte_at(&init_mm, vaddr, pte, pteval);
> >  	else
> >  		pte_clear(&init_mm, vaddr, pte);
> > _
>
> --
> Michal Hocko
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
