Date: Tue, 27 May 2008 04:24:08 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 14/23] hugetlb: introduce huge_pud
Message-ID: <20080527022408.GA21578@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143453.593888000@nick.local0.net> <Pine.LNX.4.64.0805261148130.3720@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805261148130.3720@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, May 26, 2008 at 12:09:05PM +0100, Hugh Dickins wrote:
> On Mon, 26 May 2008, npiggin@suse.de wrote:
> > Straight forward extensions for huge pages located in the PUD
> > instead of PMDs.
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Sorry, I've not looked through all these, but the subject of this one
> (which should say "pud_huge" rather than "huge_pud") led me to check:
> please take a look at commit aeed5fce37196e09b4dac3a1c00d8b7122e040ce,
> I believe your follow_page will need to try pud_huge before pud_bad.
 
Ah, you're right there, yes thanks.


> Though note in the comment to that commit, I'm dubious whether we
> can ever actually hit that case, or need follow_huge_pmd (or your
> follow_huge_pud) at all: please cross check, you might prefer to
> delete the huge pmd code there rather than add huge pud code,
> if you agree that there's actually no way we need it.

Haven't had a look yet, but I'll probably leave that for another
person or time to do.

Thanks,
Nick

> 
> Hugh
> 
> > --- linux-2.6.orig/mm/memory.c
> > +++ linux-2.6/mm/memory.c
> > @@ -998,7 +998,13 @@ struct page *follow_page(struct vm_area_
> >  	pud = pud_offset(pgd, address);
> >  	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> >  		goto no_page_table;
> > -	
> > +
> > +	if (pud_huge(*pud)) {
> > +		BUG_ON(flags & FOLL_GET);
> > +		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
> > +		goto out;
> > +	}
> > +
> >  	pmd = pmd_offset(pud, address);
> >  	if (pmd_none(*pmd))
> >  		goto no_page_table;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
