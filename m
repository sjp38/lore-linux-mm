Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 816126B00B7
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:40:44 -0400 (EDT)
Date: Fri, 19 Mar 2010 17:37:51 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-ID: <20100319083751.GB13107@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 04:10:23PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 19 Mar 2010 15:26:36 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we look into pagemap using page-types with option -p, the value
> > of pfn for hugepages looks wrong (see below.)
> > This is because pte was evaluated only once for one vma
> > although it should be updated for each hugepage. This patch fixes it.
> > 
> > $ page-types -p 3277 -Nl -b huge
> > voffset   offset  len     flags
> > 7f21e8a00 11e400  1       ___U___________H_G________________
> > 7f21e8a01 11e401  1ff     ________________TG________________
> > 7f21e8c00 11e400  1       ___U___________H_G________________
> > 7f21e8c01 11e401  1ff     ________________TG________________
> >              ^^^
> >              should not be the same
> > 
> > With this patch applied:
> > 
> > $ page-types -p 3386 -Nl -b huge
> > voffset   offset   len    flags
> > 7fec7a600 112c00   1      ___UD__________H_G________________
> > 7fec7a601 112c01   1ff    ________________TG________________
> > 7fec7a800 113200   1      ___UD__________H_G________________
> > 7fec7a801 113201   1ff    ________________TG________________
> >              ^^^
> >              OK
> > 
> Hmm. Is this bug ? To me, it's just shown in hugepage's pagesize, by design.
> 
> _And_, Doesn't this patch change behavior of walk_pagemap_range() implicitly ?

No. It just fixes the bug of wrong offset calculation.

> No influence to other users ? (as memcontrol.c. in mmotm. Ask Nishimura-san ;)
> 

I asked him for double-check.

> 
> some nitpicks.
> 
> 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  fs/proc/task_mmu.c |   37 +++++++++++++++++++------------------
> >  include/linux/mm.h |    4 ++--
> >  mm/pagewalk.c      |   14 ++++----------
> >  3 files changed, 25 insertions(+), 30 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 2a3ef17..cc14479 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -662,31 +662,32 @@ static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
> >  	return pme;
> >  }
> >  
> > -static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
> > +/* This function walks only within @vma */
> > +static int pagemap_hugetlb_range(struct vm_area_struct *vma, unsigned long addr,
> >  				 unsigned long end, struct mm_walk *walk)
> >  {
> > -	struct vm_area_struct *vma;
> > +	struct mm_struct *mm = walk->mm;
> >  	struct pagemapread *pm = walk->private;
> >  	struct hstate *hs = NULL;
> >  	int err = 0;
> > -
> > -	vma = find_vma(walk->mm, addr);
> > -	if (vma)
> > -		hs = hstate_vma(vma);
> > +	pte_t *pte = NULL;
> > +
> > +	BUG_ON(!mm);
> > +	BUG_ON(!vma || !is_vm_hugetlb_page(vma));
> > +	BUG_ON(addr < vma->vm_start || addr >= vma->vm_end);
> 
> This is my personal opinion, may not be popular.
> 
> When you add BUG_ON(), please confirm "you have real concern about this."
> After reading this, code reader will take care of avoiding calling this
> function with above condition. yes.
> 
> But, this function itself is only for pagemap_read() and it seems no
> other one will call this function externally in future.
> Above 3 BUG_ON will never happen because of simple logic around this.
> Then, it seems unnecessary noise to me.
> 

OK. It sounds reasonable.

> If your changes in walk_page_range() causes concerns to add above BUG_ON()s,
> please avoid such changes. 

There is no concern about it.  I'll turn off BUG_ON()s.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
