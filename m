Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D9BD96B0078
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 01:01:08 -0400 (EDT)
Date: Wed, 22 Sep 2010 13:59:07 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 04/10] hugetlb: hugepage migration core
Message-ID: <20100922045907.GC2538@spritzera.linux.bs1.fc.nec.co.jp>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1283908781-13810-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100920111054.GJ1998@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100920111054.GJ1998@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 20, 2010 at 12:10:55PM +0100, Mel Gorman wrote:
> On Wed, Sep 08, 2010 at 10:19:35AM +0900, Naoya Horiguchi wrote:
...
> > @@ -95,26 +96,34 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> >  	pte_t *ptep, pte;
> >   	spinlock_t *ptl;
> >  
> > - 	pgd = pgd_offset(mm, addr);
> > -	if (!pgd_present(*pgd))
> > -		goto out;
> > +	if (unlikely(PageHuge(new))) {
> > +		ptep = huge_pte_offset(mm, addr);
> > +		if (!ptep)
> > +			goto out;
> > +		ptl = &mm->page_table_lock;
> > +	} else {
> > +		pgd = pgd_offset(mm, addr);
> > +		if (!pgd_present(*pgd))
> > +			goto out;
> >  
> > -	pud = pud_offset(pgd, addr);
> > -	if (!pud_present(*pud))
> > -		goto out;
> > +		pud = pud_offset(pgd, addr);
> > +		if (!pud_present(*pud))
> > +			goto out;
> >  
> 
> Why are the changes to teh rest of the walkers necessary? Instead, why
> did you not identify which PTL lock you needed and then goto the point
> where spin_lock(ptl) is called? Similar to what page_check_address()
> does for example.

This is because Andi-san commented to avoid using goto sentense.
But honestly I'm not sure which is a clear way.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
