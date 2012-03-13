Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 9A1126B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:19:57 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 946793EE0BD
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:19:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F0A245DEB4
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:19:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55E5845DEB2
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:19:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47DBE1DB803B
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:19:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E8F261DB803F
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:19:54 +0900 (JST)
Date: Tue, 13 Mar 2012 14:18:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix behavior of shard anon pages at task_move
 (Was Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120313141823.18daeeed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1203091225440.19372@eggly.anvils>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203081816170.18242@eggly.anvils>
	<20120309122448.92931dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20120309150109.51ba8ea1.nishimura@mxp.nes.nec.co.jp>
	<20120309162357.71c8c573.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203091225440.19372@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri, 9 Mar 2012 13:05:05 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Fri, 9 Mar 2012, KAMEZAWA Hiroyuki wrote:
> > From 1012e97e3b123fb80d0ec6b1f5d3dbc87a5a5139 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> > Suggested-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Yes, this is much like what I had in mind (well, on disk):
> I'm glad we are in agreement now.
> 
> But first priority, I think, should be to revert to the silly "> 2"
> test for 3.3 final, so it behaves just like 2.6.35 through 3.2:
> I'll send Andrew and Linus a patch for that shortly.
> 
> > ---
> >  Documentation/cgroups/memory.txt |   10 ++++++++--
> >  include/linux/swap.h             |    9 ---------
> >  mm/memcontrol.c                  |   15 +++------------
> >  mm/swapfile.c                    |   31 -------------------------------
> >  4 files changed, 11 insertions(+), 54 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 4c95c00..16bc9f2 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -185,6 +185,9 @@ behind this approach is that a cgroup that aggressively uses a shared
> >  page will eventually get charged for it (once it is uncharged from
> >  the cgroup that brought it in -- this will happen on memory pressure).
> >  
> > +(*)See section 8.2. At task moving, you can recharge mapped pages to other
> > +   cgroup.
> > +
> 
> Perhaps:
> 
> But see section 8.2: when moving a task to another cgroup, its pages may
> be recharged to the new cgroup, if move_charge_at_immigrate has been chosen.
> 
> (I've intentionally omitted the word "mapped" there because it can move
> even unmapped file pages and swapped-out anon pages.)
> 

Sure.


> >  Exception: If CONFIG_CGROUP_CGROUP_MEM_RES_CTLR_SWAP is not used.
> >  When you do swapoff and make swapped-out pages of shmem(tmpfs) to
> >  be backed into memory in force, charges for pages are accounted against the
> > @@ -623,8 +626,8 @@ memory cgroup.
> >    bit | what type of charges would be moved ?
> >   -----+------------------------------------------------------------------------
> >     0  | A charge of an anonymous page(or swap of it) used by the target task.
> > -      | Those pages and swaps must be used only by the target task. You must
> > -      | enable Swap Extension(see 2.4) to enable move of swap charges.
> > +      | Even if it's shared, it will be moved in force(*). You must enable Swap
> 
> What is this "force"?  I solved the Documentation problem by simply
> removing one sentence, but you have tried harder.
> 

Ok, I remove the force (Sorry, I was not enough logical.)



> > +      | Extension(see 2.4) to enable move of swap charges.
> >   -----+------------------------------------------------------------------------
> >     1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
> >        | and swaps of tmpfs file) mmapped by the target task. Unlike the case of
> > @@ -635,6 +638,9 @@ memory cgroup.
> >        | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
> >        | enable move of swap charges.
> >  
> > +(*) Because of this, fork() -> move -> exec() will move all parent's page
> > +    to the target cgroup. Please be careful.
> > +
> 
> It only moves those pages which were in the old cgroup.
> 


You're right.

I'll consinder simpler one.



> >  8.3 TODO
> >  
> >  - Implement madvise(2) to let users decide the vma to be moved or not to be
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index f7df3ea..13c8d6f 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -390,7 +390,6 @@ static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  extern void
> >  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
> > -extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
> >  #else
> >  static inline void
> >  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
> > @@ -535,14 +534,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> >  {
> >  }
> >  
> > -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > -static inline int
> > -mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep)
> > -{
> > -	return 0;
> > -}
> > -#endif
> > -
> >  #endif /* CONFIG_SWAP */
> >  #endif /* __KERNEL__*/
> >  #endif /* _LINUX_SWAP_H */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c83aeb5..e7e4e3d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5100,12 +5100,9 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> >  
> >  	if (!page || !page_mapped(page))
> >  		return NULL;
> > -	if (PageAnon(page)) {
> > -		/* we don't move shared anon */
> > -		if (!move_anon() || page_mapcount(page) > 2)
> > -			return NULL;
> > +	if (PageAnon(page) && !move_anon()) {
> > +		return NULL;
> >  	} else if (!move_file())
> > -		/* we ignore mapcount for file pages */
> >  		return NULL;
> 
> Doesn't that need to be
> 
> 	if (PageAnon(page)) {
> 		if (!move_anon())
> 			return NULL;
> 	} else if (!move_file())
> 		return NULL;
> 
> I think what you've written there makes treatment of anon pages
> in the move_anon() case dependent on move_file(), doesn't it?
> 

will rewrite.



> >  	if (!get_page_unless_zero(page))
> >  		return NULL;
> > @@ -5116,18 +5113,12 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> >  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
> >  			unsigned long addr, pte_t ptent, swp_entry_t *entry)
> >  {
> > -	int usage_count;
> >  	struct page *page = NULL;
> >  	swp_entry_t ent = pte_to_swp_entry(ptent);
> >  
> >  	if (!move_anon() || non_swap_entry(ent))
> >  		return NULL;
> > -	usage_count = mem_cgroup_count_swap_user(ent, &page);
> > -	if (usage_count > 1) { /* we don't move shared anon */
> > -		if (page)
> > -			put_page(page);
> > -		return NULL;
> > -	}
> > +	page = lookup_swap_cache(ent);
> 
> It's annoying, but there's a tiny reason why that line needs to be
> 
> #ifdef CONFIG_SWAP
> 	page = find_get_page(&swapper_space, ent.val);
> #endif
> 
> because lookup_swap_cache() updates some antiquated swap lookup stats
> (which I do sometimes look at), which a straight find_get_page() avoids,
> rightly in this case; but swapper_space only defined when CONFIG_SWAP=y.
> 
> I was about to propose that we just add an arg to lookup_swap_cache(),
> for updating those stats or not; but see that mincore.c would like a
> little more than that to avoid its CONFIG_SWAPs, not sure quite what.
> 
> So for now, please just use the #ifdef CONFIG_SWAP find_get_page()
> that we use elsewhere, and I'll try to remove those warts later on.
> 

Okay, I will do that.


> >  	if (do_swap_account)
> >  		entry->val = ent.val;
> >  
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index fa3c519..85b4548 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -720,37 +720,6 @@ int free_swap_and_cache(swp_entry_t entry)
> >  	return p != NULL;
> >  }
> >  
> > -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > -/**
> > - * mem_cgroup_count_swap_user - count the user of a swap entry
> > - * @ent: the swap entry to be checked
> > - * @pagep: the pointer for the swap cache page of the entry to be stored
> > - *
> > - * Returns the number of the user of the swap entry. The number is valid only
> > - * for swaps of anonymous pages.
> > - * If the entry is found on swap cache, the page is stored to pagep with
> > - * refcount of it being incremented.
> > - */
> > -int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep)
> > -{
> > -	struct page *page;
> > -	struct swap_info_struct *p;
> > -	int count = 0;
> > -
> > -	page = find_get_page(&swapper_space, ent.val);
> > -	if (page)
> > -		count += page_mapcount(page);
> > -	p = swap_info_get(ent);
> > -	if (p) {
> > -		count += swap_count(p->swap_map[swp_offset(ent)]);
> > -		spin_unlock(&swap_lock);
> > -	}
> > -
> > -	*pagep = page;
> > -	return count;
> > -}
> > -#endif
> > -
> 
> Exactly, delete delete delete!
> 
 :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
