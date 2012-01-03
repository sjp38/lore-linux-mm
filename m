Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3A2726B0087
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 15:09:11 -0500 (EST)
Message-ID: <4F035FF6.7020206@ah.jp.nec.com>
Date: Tue, 03 Jan 2012 15:07:18 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com> <4EFD3266.4080701@gmail.com>
In-Reply-To: <4EFD3266.4080701@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Hi,

Thank you for your reviewing.

On Thu, Dec 29, 2011 at 10:39:18PM -0500, KOSAKI Motohiro wrote:
...
> > --- 3.2-rc5.orig/fs/proc/task_mmu.c
> > +++ 3.2-rc5/fs/proc/task_mmu.c
> > @@ -600,6 +600,9 @@ struct pagemapread {
> >   	u64 *buffer;
> >   };
> > 
> > +#define PAGEMAP_WALK_SIZE	(PMD_SIZE)
> > +#define PAGEMAP_WALK_MASK	(PMD_MASK)
> > +
> >   #define PM_ENTRY_BYTES      sizeof(u64)
> >   #define PM_STATUS_BITS      3
> >   #define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
> > @@ -658,6 +661,22 @@ static u64 pte_to_pagemap_entry(pte_t pte)
> >   	return pme;
> >   }
> > 
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +static u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> > +{
> > +	u64 pme = 0;
> > +	if (pte_present(pte))
> 
> When does pte_present() return 0?

It does when the page pointed to by pte is swapped-out, under page migration,
or HWPOISONed. But currenly it can't happen on thp because thp will be
splitted before these operations are processed.
So this if-sentense is not necessary for now, but I think it's not a bad idea
to put it now to prepare for future implementation.

>
> > +		pme = PM_PFRAME(pte_pfn(pte) + offset)
> > +			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> > +	return pme;
> > +}
> > +#else
> > +static inline u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >   static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >   			     struct mm_walk *walk)
> >   {
> > @@ -665,14 +684,34 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >   	struct pagemapread *pm = walk->private;
> >   	pte_t *pte;
> >   	int err = 0;
> > -
> > -	split_huge_page_pmd(walk->mm, pmd);
> > +	u64 pfn = PM_NOT_PRESENT;
> > 
> >   	/* find the first VMA at or above 'addr' */
> >   	vma = find_vma(walk->mm, addr);
> > -	for (; addr != end; addr += PAGE_SIZE) {
> > -		u64 pfn = PM_NOT_PRESENT;
> > 
> > +	spin_lock(&walk->mm->page_table_lock);
> > +	if (pmd_trans_huge(*pmd)) {
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +		} else {
> > +			for (; addr != end; addr += PAGE_SIZE) {
> > +				int offset = (addr&  ~PAGEMAP_WALK_MASK)
> > +					>>  PAGE_SHIFT;
> 
> implicit narrowing conversion. offset should be unsigned long.

OK.

> 
> 
> > +				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> > +							       offset);
> 
> This (pte_t*) cast looks introduce new implicit assumption. Please don't
> put x86 assumption here directly.

OK, I think it's better to write a separate patch for this job because
similar assumption is used in smaps_pte_range() and gather_pte_stats().

> 
> 
> > +				err = add_to_pagemap(addr, pfn, pm);
> > +				if (err)
> > +					break;
> > +			}
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			return err;
> > +		}
> > +	} else {
> > +		spin_unlock(&walk->mm->page_table_lock);
> > +	}
> 
> coding standard violation. plz run check_patch.pl.

checkpatch.pl says nothing for here. According to Documentation/CodingStyle,
"no braces for single statement" rule is not applicable for else-blocks with
one statement if corresponding if-blocks have multiple statements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
