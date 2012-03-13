Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 14DF56B0083
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:15:43 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 1/3] memcg: clean up existing move charge code
Date: Tue, 13 Mar 2012 18:15:29 -0400
Message-Id: <1331676929-25774-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120313144501.d031f25d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 02:45:01PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 12 Mar 2012 18:30:54 -0400
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > We'll introduce the thp variant of move charge code in later patches,
> > but before doing that let's start with refactoring existing code.
> > Here we replace lengthy function name is_target_pte_for_mc() with
> > shorter one in order to avoid ugly line breaks.
> > And for better readability, we explicitly use MC_TARGET_* instead of
> > simply using integers.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Thanks.
> 
> Seems ok to me.
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.futjisu.com>

Thank you.

> Hmm. some nitpicks.
> 
> > ---
> >  mm/memcontrol.c |   20 ++++++++++----------
> >  1 files changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git linux-next-20120307.orig/mm/memcontrol.c linux-next-20120307/mm/memcontrol.c
> > index a288855..3d16618 100644
> > --- linux-next-20120307.orig/mm/memcontrol.c
> > +++ linux-next-20120307/mm/memcontrol.c
> > @@ -5069,7 +5069,7 @@ one_by_one:
> >  }
> >  
> >  /**
> > - * is_target_pte_for_mc - check a pte whether it is valid for move charge
> > + * get_mctgt_type - get target type of moving charge
> >   * @vma: the vma the pte to be checked belongs
> >   * @addr: the address corresponding to the pte to be checked
> >   * @ptent: the pte to be checked
> > @@ -5092,7 +5092,7 @@ union mc_target {
> >  };
> >  
> >  enum mc_target_type {
> > -	MC_TARGET_NONE,	/* not used */
> > +	MC_TARGET_NONE, 
> 
> How about
> 
> 	MC_TARGET_NONE = 0,

Sounds good.

> Becasue you use 
> 	if (get_mctgt_type()) 
> later.

In previous discussion, I got the feedback to compare the returned value
of get_mctgt_type() with MC_TARGET_*.
If we obey the advice, if (get_mctgt_type() == MC_TARGET_NONE)" is better,
but here we define MC_TARGET_NONE as 0 explicitly, so I think it's OK to
use the short form you suggest.

> 
> >  	MC_TARGET_PAGE,
> >  	MC_TARGET_SWAP,
> >  };
> > @@ -5173,12 +5173,12 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
> >  	return page;
> >  }
> >  
> > -static int is_target_pte_for_mc(struct vm_area_struct *vma,
> > +static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
> >  		unsigned long addr, pte_t ptent, union mc_target *target)
> 
> I admit old name is too long. But...Hm...get_mctgt_type()...how about
> 
> 	move_charge_type() or
> 	mctgt_type() or
> 	mc_type() ?
> 
> I don't have good sense of naming ;(

Shorter one is generally good, but too short one doesn't show what it does.
The first one appears to say it moves something. Latter two looks unclear to
me because they don't contain any verbs. So I'm afraid I like the current one.

> >  {
> >  	struct page *page = NULL;
> >  	struct page_cgroup *pc;
> > -	int ret = 0;
> > +	enum mc_target_type ret = MC_TARGET_NONE;
> >  	swp_entry_t ent = { .val = 0 };
> >  
> >  	if (pte_present(ptent))
> > @@ -5189,7 +5189,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> >  		page = mc_handle_file_pte(vma, addr, ptent, &ent);
> >  
> >  	if (!page && !ent.val)
> > -		return 0;
> > +		return ret;
> >  	if (page) {
> >  		pc = lookup_page_cgroup(page);
> >  		/*
> > @@ -5206,7 +5206,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> >  			put_page(page);
> >  	}
> >  	/* There is a swap entry and a page doesn't exist or isn't charged */
> > -	if (ent.val && !ret &&
> > +	if (ent.val && ret != MC_TARGET_NONE &&
> 
> If you do MC_TARGET_NONE = 0 in above, using !ret seems ok to me.

OK. It's clearer.

> >  			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
> >  		ret = MC_TARGET_SWAP;
> >  		if (target)
> > @@ -5227,7 +5227,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >  
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  	for (; addr != end; pte++, addr += PAGE_SIZE)
> > -		if (is_target_pte_for_mc(vma, addr, *pte, NULL))
> > +		if (get_mctgt_type(vma, addr, *pte, NULL))
> >  			mc.precharge++;	/* increment precharge temporarily */
> >  	pte_unmap_unlock(pte - 1, ptl);
> >  	cond_resched();
> > @@ -5397,8 +5397,8 @@ retry:
> >  		if (!mc.precharge)
> >  			break;
> >  
> > -		type = is_target_pte_for_mc(vma, addr, ptent, &target);
> > -		switch (type) {
> > +		target_type = get_mctgt_type(vma, addr, ptent, &target);
> > +		switch (target_type) {
> 
> It 'target_type' is unused later
>  
> 	switch(get_mctgt_type(vma, addr, ptent, &target))
> 
> is ok ?

Yes. That's OK.

So I attach the revised patch below.
The applied changes do not affect later patches.

Thanks,
Naoya Horiguchi
---
