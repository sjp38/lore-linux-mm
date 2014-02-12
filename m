Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id DB32D6B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 10:40:51 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so14070482qaq.39
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 07:40:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l52si15508900qge.135.2014.02.12.07.40.50
        for <linux-mm@kvack.org>;
        Wed, 12 Feb 2014 07:40:50 -0800 (PST)
Date: Wed, 12 Feb 2014 10:40:36 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52fb9602.37618c0a.a2aa.fffffd78SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140212053956.GA2912@lge.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140212053956.GA2912@lge.com>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi Joonsoo,

On Wed, Feb 12, 2014 at 02:39:56PM +0900, Joonsoo Kim wrote:
...
> > diff --git v3.14-rc2.orig/mm/pagewalk.c v3.14-rc2/mm/pagewalk.c
> > index 2beeabf502c5..4770558feea8 100644
> > --- v3.14-rc2.orig/mm/pagewalk.c
> > +++ v3.14-rc2/mm/pagewalk.c
> > @@ -3,29 +3,58 @@
> >  #include <linux/sched.h>
> >  #include <linux/hugetlb.h>
> >  
> > -static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> > -			  struct mm_walk *walk)
> > +/*
> > + * Check the current skip status of page table walker.
> > + *
> > + * Here what I mean by skip is to skip lower level walking, and that was
> > + * determined for each entry independently. For example, when walk_pmd_range
> > + * handles a pmd_trans_huge we don't have to walk over ptes under that pmd,
> > + * and the skipping does not affect the walking over ptes under other pmds.
> > + * That's why we reset @walk->skip after tested.
> > + */
> > +static bool skip_lower_level_walking(struct mm_walk *walk)
> > +{
> > +	if (walk->skip) {
> > +		walk->skip = 0;
> > +		return true;
> > +	}
> > +	return false;
> > +}
> > +
> > +static int walk_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> >  {
> > +	struct mm_struct *mm = walk->mm;
> >  	pte_t *pte;
> > +	pte_t *orig_pte;
> > +	spinlock_t *ptl;
> >  	int err = 0;
> >  
> > -	pte = pte_offset_map(pmd, addr);
> > -	for (;;) {
> > +	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +	do {
> > +		if (pte_none(*pte)) {
> > +			if (walk->pte_hole)
> > +				err = walk->pte_hole(addr, addr + PAGE_SIZE,
> > +							walk);
> > +			if (err)
> > +				break;
> > +			continue;
> 
> Hello, Naoya.
> 
> I know that this is too late for review, but I have some opinion about this.
> 
> How about removing walk->pte_hole() function pointer and related code on generic
> walker? walk->pte_hole() is only used by task_mmu.c and maintaining pte_hole code
> only for task_mmu.c just give us maintanance overhead and bad readability on
> generic code. With removing it, we can get more simpler generic walker.

Yes, this can be possible, I think.

> We can implement it without pte_hole() on generic walker like as below.
> 
>   walk->dont_skip_hole = 1
>   if (pte_none(*pte) && !walk->dont_skip_hole)
>   	  continue;

Currently walk->pte_hole can be called also by walk_p(g|u|m)d_range(),
so this ->dont_skip_hole switch had better be controlled by caller
(i.e. pagemap_read()).

>   call proper entry callback function which can handle pte_hole cases.

yes, we can do hole handling in each level of callbacks.

Now I'm preparing next series of cleanup patches following this patchset.
So I'll add a patch implementing this idea on it.

...
> > @@ -86,13 +114,58 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
> >  				break;
> >  			continue;
> >  		}
> > -		if (walk->pud_entry)
> > +
> > +		if (walk->pud_entry) {
> >  			err = walk->pud_entry(pud, addr, next, walk);
> > -		if (!err && (walk->pmd_entry || walk->pte_entry))
> > +			if (skip_lower_level_walking(walk))
> > +				continue;
> > +			if (err)
> > +				break;
> 
> Why do you check skip_lower_level_walking() prior to err check?

No specific reason. I assumed that the callback (walk->pud_entry() in this
example) shouldn't do both of setting walk->skip and returning non-zero value
at one time. I'll add comment about that.

> I look through all patches roughly and find that this doesn't cause any problem,
> since err is 0 whenver walk->skip = 1. But, checking err first would be better.

I agree, it looks safer (we can avoid misbehavior like Null pointer access.)
I'll add it in next patchset. Thank you very much.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
