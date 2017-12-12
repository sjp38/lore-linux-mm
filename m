Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF216B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 06:39:25 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v69so12178207wrb.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 03:39:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j53sor7271528ede.4.2017.12.12.03.39.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 03:39:23 -0800 (PST)
Date: Tue, 12 Dec 2017 14:39:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
Message-ID: <20171212113920.zlcs2p7jxypmwyiy@node.shutemov.name>
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
 <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
 <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
 <20171204163445.qt5dqcrrkilnhowz@black.fi.intel.com>
 <20171204173931.pjnmfdutys7cnesx@black.fi.intel.com>
 <55400fe3-a605-b86f-e14c-c5dd08738fd7@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55400fe3-a605-b86f-e14c-c5dd08738fd7@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 08, 2017 at 08:37:43AM -0600, Tom Lendacky wrote:
> On 12/4/2017 11:39 AM, Kirill A. Shutemov wrote:
> > On Mon, Dec 04, 2017 at 04:34:45PM +0000, Kirill A. Shutemov wrote:
> > > On Mon, Dec 04, 2017 at 04:00:26PM +0000, Tom Lendacky wrote:
> > > > On 12/4/2017 8:57 AM, Kirill A. Shutemov wrote:
> > > > > On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
> > > > > > On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> > > > > > > sme_populate_pgd() open-codes a lot of things that are not needed to be
> > > > > > > open-coded.
> > > > > > > 
> > > > > > > Let's rewrite it in a more stream-lined way.
> > > > > > > 
> > > > > > > This would also buy us boot-time switching between support between
> > > > > > > paging modes, when rest of the pieces will be upstream.
> > > > > > 
> > > > > > Hi Kirill,
> > > > > > 
> > > > > > Unfortunately, some of these can't be changed.  The use of p4d_offset(),
> > > > > > pud_offset(), etc., use non-identity mapped virtual addresses which cause
> > > > > > failures at this point of the boot process.
> > > > > 
> > > > > Wat? Virtual address is virtual address. p?d_offset() doesn't care about
> > > > > what mapping you're using.
> > > > 
> > > > Yes it does.  For example, pmd_offset() issues a pud_page_addr() call,
> > > > which does a __va() returning a non-identity mapped address (0xffff88...).
> > > > Only identity mapped virtual addresses have been setup at this point, so
> > > > the use of that virtual address panics the kernel.
> > > 
> > > Stupid me. You are right.
> > > 
> > > What about something like this:
> > 
> > sme_pgtable_calc() also looks unnecessary complex.
> 
> I have no objections to improving this (although I just submitted a patch
> that modifies this area, so this will have to be updated now).

I'll post patchset on top of your "SME: BSP/SME microcode update fix"

> > Any objections on this:
> > 
> > diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> > index 65e0d68f863f..59b7d7ba9b37 100644
> > --- a/arch/x86/mm/mem_encrypt.c
> > +++ b/arch/x86/mm/mem_encrypt.c
> > @@ -548,8 +548,7 @@ static void __init *sme_populate_pgd(pgd_t *pgd_base, void *pgtable_area,
> >   static unsigned long __init sme_pgtable_calc(unsigned long len)
> >   {
> > -	unsigned long p4d_size, pud_size, pmd_size;
> > -	unsigned long total;
> > +	unsigned long entries, tables;
> >   	/*
> >   	 * Perform a relatively simplistic calculation of the pagetable
> > @@ -559,41 +558,25 @@ static unsigned long __init sme_pgtable_calc(unsigned long len)
> >   	 * mappings. Incrementing the count for each covers the case where
> >   	 * the addresses cross entries.
> >   	 */
> > -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> > -		p4d_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
> > -		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
> > -		pud_size = (ALIGN(len, P4D_SIZE) / P4D_SIZE) + 1;
> > -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> > -	} else {
> > -		p4d_size = 0;
> > -		pud_size = (ALIGN(len, PGDIR_SIZE) / PGDIR_SIZE) + 1;
> > -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> > -	}
> > -	pmd_size = (ALIGN(len, PUD_SIZE) / PUD_SIZE) + 1;
> > -	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
> > -	total = p4d_size + pud_size + pmd_size;
> > +        entries = (DIV_ROUND_UP(len, PGDIR_SIZE) + 1) * PAGE_SIZE;
> 
> I stayed away from using PAGE_SIZE directly because other areas/files used
> the sizeof() * PTRS_PER_ and I was trying to be consistent. Not that the
> size of a page table is ever likely to change, but maybe defining a macro
> (similar to the one in mm/pgtable.c) would be best rather than using
> PAGE_SIZE directly.  Not required, just my opinion.

I've rewritten this with PTRS_PER_, although I don't think it matters much.

> > +        if (PTRS_PER_P4D > 1)
> > +                entries += (DIV_ROUND_UP(len, P4D_SIZE) + 1) * PAGE_SIZE;
> > +        entries += (DIV_ROUND_UP(len, PUD_SIZE) + 1) * PAGE_SIZE;
> > +        entries += (DIV_ROUND_UP(len, PMD_SIZE) + 1) * PAGE_SIZE;
> >   	/*
> >   	 * Now calculate the added pagetable structures needed to populate
> >   	 * the new pagetables.
> >   	 */
> > -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> > -		p4d_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
> > -		p4d_size *= sizeof(p4d_t) * PTRS_PER_P4D;
> > -		pud_size = ALIGN(total, P4D_SIZE) / P4D_SIZE;
> > -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> > -	} else {
> > -		p4d_size = 0;
> > -		pud_size = ALIGN(total, PGDIR_SIZE) / PGDIR_SIZE;
> > -		pud_size *= sizeof(pud_t) * PTRS_PER_PUD;
> > -	}
> > -	pmd_size = ALIGN(total, PUD_SIZE) / PUD_SIZE;
> > -	pmd_size *= sizeof(pmd_t) * PTRS_PER_PMD;
> > -	total += p4d_size + pud_size + pmd_size;
> > +        tables = DIV_ROUND_UP(entries, PGDIR_SIZE) * PAGE_SIZE;
> > +        if (PTRS_PER_P4D > 1)
> > +                tables += DIV_ROUND_UP(entries, P4D_SIZE) * PAGE_SIZE;
> > +        tables += DIV_ROUND_UP(entries, PUD_SIZE) * PAGE_SIZE;
> > +        tables += DIV_ROUND_UP(entries, PMD_SIZE) * PAGE_SIZE;
> > -	return total;
> > +	return entries + tables;
> >   }
> 
> It all looks reasonable, but I won't be able to test for the next few
> days, though.

No worries. Test when you'll get time for this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
