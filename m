Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 26AD46B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 01:58:43 -0400 (EDT)
Date: Thu, 25 Mar 2010 14:55:01 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mmotm] [BUGFIX] pagemap: fix pfn calculation for
	hugepage
Message-ID: <20100325055501.GA3744@spritzerA.linux.bs1.fc.nec.co.jp>
References: <20100324054227.GB9336@spritzerA.linux.bs1.fc.nec.co.jp> <20100324145725.360bd13b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100324145725.360bd13b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 02:57:25PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 24 Mar 2010 14:42:27 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we look into pagemap using page-types with option -p, the value
> > of pfn for hugepages looks wrong (see below.)
> > This is because pte was evaluated only once for one vma
> > although it should be updated for each hugepage. This patch fixes it.
> > 
> >   $ page-types -p 3277 -Nl -b huge
> >   voffset   offset  len     flags
> >   7f21e8a00 11e400  1       ___U___________H_G________________
> >   7f21e8a01 11e401  1ff     ________________TG________________
> >                ^^^
> >   7f21e8c00 11e400  1       ___U___________H_G________________
> >   7f21e8c01 11e401  1ff     ________________TG________________
> >                ^^^
> > 
> > One hugepage contains 1 head page and 511 tail pages in x86_64 and
> > each two lines represent each hugepage. Voffset and offset mean
> > virtual address and physical address in the page unit, respectively.
> > The different hugepages should not have the same offset value.
> > 
> > With this patch applied:
> > 
> >   $ page-types -p 3386 -Nl -b huge
> >   voffset   offset   len    flags
> >   7fec7a600 112c00   1      ___UD__________H_G________________
> >   7fec7a601 112c01   1ff    ________________TG________________
> >                ^^^
> >   7fec7a800 113200   1      ___UD__________H_G________________
> >   7fec7a801 113201   1ff    ________________TG________________
> >                ^^^
> >                OK
> > 
> > Changelog:
> >  - add hugetlb entry walker in mm/pagewalk.c
> >    (the idea based on Kamezawa-san's patch)
> > 
> Seems good.
> 
> More info.

Thanks, I'll add this to patch description.

>  - This patch modifies walk_page_range()'s hugepage walker.
>    But the change only affects pagemap_read(), it's only caller of hugepage callback.
> 
>  - Before patch, hugetlb_entry() callback is called once per pgd. Then,
>    hugtlb_entry() has to walk pgd's contents by itself. 
>    This caused BUG.

I think there is misunderstanding on this part.
I would add this instead:
 - Without this patch, hugetlb_entry() callback is called once per vma,
   that doesn't match the natural expectation from its name.

> 
>  - After patch, hugetlb_entry() callback is called once per hugepte entry.
>    Then, callback will be much simpler.
> 
> 

...
> > +static int walk_hugetlb_range(struct vm_area_struct *vma,
> > +			      unsigned long addr, unsigned long end,
> > +			      struct mm_walk *walk)
> > +{
> > +	struct hstate *h = hstate_vma(vma);
> > +	unsigned long next;
> > +	unsigned long hmask = huge_page_mask(h);
> > +	pte_t *pte;
> > +	int err = 0;
> > +
> > +	do {
> > +		next = hugetlb_entry_end(h, addr, end);
> > +		pte = huge_pte_offset(walk->mm, addr & hmask);
> > +		if (pte && walk->hugetlb_entry)
> > +			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
> > +		if (err)
> > +			return err;
> > +	} while (addr = next, addr != end);
> > +
> > +	return err;
> > +}
> nitpick.
> 
> seems nicer than mine but "return 0" is ok if you add "return err" in the loop.
>
OK. I fixed it.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
