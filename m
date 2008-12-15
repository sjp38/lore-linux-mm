Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kvack.org (Postfix) with SMTP id 7EC9B6B0072
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 03:40:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBF8fO1t000692
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Dec 2008 17:41:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8AD045DD7B
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 17:41:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97BDD45DD78
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 17:41:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D5901DB803F
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 17:41:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BB4B1DB803B
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 17:41:24 +0900 (JST)
Date: Mon, 15 Dec 2008 17:40:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak (v3)
Message-Id: <20081215174028.8baf7739.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081215083726.GH18403@balbir.in.ibm.com>
References: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com>
	<20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp>
	<46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com>
	<20081213160310.e9501cd9.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0812130935220.3611@blonde.anvils>
	<4409.10.75.179.62.1229164064.squirrel@webmail-b.css.fujitsu.com>
	<20081215160751.b6a944be.kamezawa.hiroyu@jp.fujitsu.com>
	<20081215083726.GH18403@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Dec 2008 14:07:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-15 16:07:51]:
> 
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Fix swapin charge operation of memcg.
> > 
> > Now, memcg has hooks to swap-out operation and checks SwapCache is really
> > unused or not. That check depends on contents of struct page.
> > I.e. If PageAnon(page) && page_mapped(page), the page is recoginized as
> > still-in-use.
> > 
> > Now, reuse_swap_page() calles delete_from_swap_cache() before establishment
> > of any rmap. Then, in followinig sequence
> > 
> > 	(Page fault with WRITE)
> > 	try_charge() (charge += PAGESIZE)
> > 	commit_charge() (Check page_cgroup is used or not..)
> > 	reuse_swap_page()
> > 		-> delete_from_swapcache()
> > 			-> mem_cgroup_uncharge_swapcache() (charge -= PAGESIZE)
> > 	......
> > New charge is uncharged soon....
> > To avoid this,  move commit_charge() after page_mapcount() goes up to 1.
> > By this,
> > 
> > 	try_charge()		(usage += PAGESIZE)
> > 	reuse_swap_page()	(may usage -= PAGESIZE if PCG_USED is set)
> > 	commit_charge()		(If page_cgroup is not marked as PCG_USED,
> > 				 add new charge.)
> > Accounting will be correct.
> > 
> > Changelog (v2) -> (v3)
> >   - fixed invalid charge to swp_entry==0.
> >   - updated documentation.
> > Changelog (v1) -> (v2)
> >   - fixed comment.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  Documentation/controllers/memcg_test.txt |   41 +++++++++++++++++++++++++++----
> >  mm/memcontrol.c                          |    7 +++--
> >  mm/memory.c                              |   11 ++++----
> >  3 files changed, 46 insertions(+), 13 deletions(-)
> > 
> > Index: mmotm-2.6.28-Dec12/mm/memory.c
> > ===================================================================
> > --- mmotm-2.6.28-Dec12.orig/mm/memory.c
> > +++ mmotm-2.6.28-Dec12/mm/memory.c
> > @@ -2428,22 +2428,23 @@ static int do_swap_page(struct mm_struct
> >  	 * while the page is counted on swap but not yet in mapcount i.e.
> >  	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
> >  	 * must be called after the swap_free(), or it will never succeed.
> > -	 * And mem_cgroup_commit_charge_swapin(), which uses the swp_entry
> > -	 * in page->private, must be called before reuse_swap_page(),
> > -	 * which may delete_from_swap_cache().
> > +	 * Because delete_from_swap_page() may be called by reuse_swap_page(),
> > +	 * mem_cgroup_commit_charge_swapin() may not be able to find swp_entry
> > +	 * in page->private. In this case, a record in swap_cgroup  is silently
> > +	 * discarded at swap_free().
> >  	 */
> > 
> > -	mem_cgroup_commit_charge_swapin(page, ptr);
> >  	inc_mm_counter(mm, anon_rss);
> >  	pte = mk_pte(page, vma->vm_page_prot);
> >  	if (write_access && reuse_swap_page(page)) {
> >  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> >  		write_access = 0;
> >  	}
> > -
> 
> Removal of unassociated lines, not sure if that is a good practice.
> 
my mistake...

> >  	flush_icache_page(vma, page);
> >  	set_pte_at(mm, address, page_table, pte);
> >  	page_add_anon_rmap(page, vma, address);
> > +	/* It's better to call commit-charge after rmap is established */
> > +	mem_cgroup_commit_charge_swapin(page, ptr);
> > 
> 
> Yes, it does make sense
> 
> >  	swap_free(entry);
> >  	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> > Index: mmotm-2.6.28-Dec12/Documentation/controllers/memcg_test.txt
> > ===================================================================
> > --- mmotm-2.6.28-Dec12.orig/Documentation/controllers/memcg_test.txt
> > +++ mmotm-2.6.28-Dec12/Documentation/controllers/memcg_test.txt
> > @@ -1,6 +1,6 @@
> >  Memory Resource Controller(Memcg)  Implementation Memo.
> > -Last Updated: 2008/12/10
> > -Base Kernel Version: based on 2.6.28-rc7-mm.
> > +Last Updated: 2008/12/15
> > +Base Kernel Version: based on 2.6.28-rc8-mm.
> > 
> >  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
> >  is complex. This is a document for memcg's internal behavior.
> > @@ -111,9 +111,40 @@ Under below explanation, we assume CONFI
> >  	(b) If the SwapCache has been mapped by processes, it has been
> >  	    charged already.
> > 
> > -	In case (a), we charge it. In case (b), we don't charge it.
> > -	(But racy state between (a) and (b) exists. We do check it.)
> > -	At charging, a charge recorded in swap_cgroup is moved to page_cgroup.
> > +	This swap-in is one of the most complicated work. In do_swap_page(),
> > +	following events occur when pte is unchanged.
> > +
> > +	(1) the page (SwapCache) is looked up.
> > +	(2) lock_page()
> > +	(3) try_charge_swapin()
> > +	(4) reuse_swap_page() (may call delete_swap_cache())
> > +	(5) commit_charge_swapin()
> > +	(6) swap_free().
> > +
> > +	Considering following situation for example.
> > +
> > +	(A) The page has not been charged before (2) and reuse_swap_page()
> > +	    doesn't call delete_from_swap_cache().
> > +	(B) The page has not been charged before (2) and reuse_swap_page()
> > +	    calls delete_from_swap_cache().
> > +	(C) The page has been charged before (2) and reuse_swap_page() doesn't
> > +	    call delete_from_swap_cache().
> > +	(D) The page has been charged before (2) and reuse_swap_page() calls
> > +	    delete_from_swap_cache().
> > +
> > +	    memory.usage/memsw.usage changes to this page/swp_entry will be
> > +	 Case          (A)      (B)       (C)     (D)
> > +         Event
> > +       Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
> > +          ===========================================
> > +          (3)        +1/+1    +1/+1     +1/+1   +1/+1
> > +          (4)          -       0/ 0       -     -1/ 0
> > +          (5)         0/ 1     0/-1     -1/-1    0/ 0
> > +          (6)          -        -         -      0/-1
> > +          ===========================================
> > +       Result         1/ 1     1/1       1/ 1    1/ 1
> > +
> > +       In any cases, charges to this page should be 1/ 1.
> > 
> 
> The documentation patch failed to apply for me
> 
Hmm... I'll check my queue again.

Thanks,
-Kame

> >  	4.2 Swap-out.
> >  	At swap-out, typical state transition is below.
> > Index: mmotm-2.6.28-Dec12/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.28-Dec12.orig/mm/memcontrol.c
> > +++ mmotm-2.6.28-Dec12/mm/memcontrol.c
> > @@ -1139,10 +1139,11 @@ void mem_cgroup_commit_charge_swapin(str
> >  	/*
> >  	 * Now swap is on-memory. This means this page may be
> >  	 * counted both as mem and swap....double count.
> > -	 * Fix it by uncharging from memsw. This SwapCache is stable
> > -	 * because we're still under lock_page().
> > +	 * Fix it by uncharging from memsw. Basically, this SwapCache is stable
> > +	 * under lock_page(). But in do_swap_page()::memory.c, reuse_swap_page()
> > +	 * may call delete_from_swap_cache() before reach here.
> >  	 */
> > -	if (do_swap_account) {
> > +	if (do_swap_account && PageSwapCache(page)) {
> >  		swp_entry_t ent = {.val = page_private(page)};
> >  		struct mem_cgroup *memcg;
> >  		memcg = swap_cgroup_record(ent, NULL);
> > 
> >
> 
> 
> Looks good to me
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> 
> Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com> 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
