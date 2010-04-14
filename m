Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 98DD96B0219
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:44:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E5iAVZ020520
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 14:44:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6735D45DE4E
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:44:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 43E0B45DE51
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:44:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AB131DB805A
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:44:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A53A91DB8038
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 14:44:09 +0900 (JST)
Date: Wed, 14 Apr 2010 14:40:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414144015.0a0d2bd2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100414143132.179edc6e.nishimura@mxp.nes.nec.co.jp>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
	<20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414105608.d40c70ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414120622.0a5c2983.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414143132.179edc6e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 14:31:32 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    6 +-
> >  mm/memcontrol.c            |   95 ++++++++++++++++++++++++---------------------
> >  mm/migrate.c               |    2 
> >  3 files changed, 56 insertions(+), 47 deletions(-)
> > 
> > Index: mmotm-temp/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-temp.orig/mm/memcontrol.c
> > +++ mmotm-temp/mm/memcontrol.c
> > @@ -2501,10 +2501,12 @@ static inline int mem_cgroup_move_swap_a
> >   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
> >   * page belongs to.
> >   */
> > -int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> > +int mem_cgroup_prepare_migration(struct page *page,
> > +	struct page *newpage, struct mem_cgroup **ptr)
> >  {
> >  	struct page_cgroup *pc;
> >  	struct mem_cgroup *mem = NULL;
> > +	enum charge_type ctype;
> >  	int ret = 0;
> >  
> >  	if (mem_cgroup_disabled())
> > @@ -2517,65 +2519,70 @@ int mem_cgroup_prepare_migration(struct 
> >  		css_get(&mem->css);
> >  	}
> >  	unlock_page_cgroup(pc);
> > -
> > -	if (mem) {
> > -		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> > -		css_put(&mem->css);
> > -	}
> > -	*ptr = mem;
> > +	/*
> > +	 * If the page is uncharged before migration (removed from radix-tree)
> > +	 * we return here.
> > +	 */
> > +	if (!mem)
> > +		return 0;
> > +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> > +	css_put(&mem->css); /* drop extra refcnt */
> it should be:
> 
> 	*ptr = mem;
> 	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
> 	css_put(&mem->css);
> 
> as Andrea has fixed already.
> 
Ah, yes. I'll rebase this onto Andrea's fix.



> > +	if (ret)
> > +		return ret;
> > +	/*
> > + 	 * The old page is under lock_page().
> > + 	 * If the old_page is uncharged and freed while migration, page migration
> > + 	 * will fail and newpage will properly uncharged by end_migration.
> > + 	 * And commit_charge against newpage never fails.
> > +  	 */
> > +	pc = lookup_page_cgroup(newpage);
> > +	if (PageAnon(page))
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> > +	else if (!PageSwapBacked(page))
> I think using page_is_file_cache() would be better.
> 
Right.



> > +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +	else
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > +	__mem_cgroup_commit_charge(mem, pc, ctype);
> > +	/* FILE_MAPPED of this page will be updated at remap routine */
> >  	return ret;
> >  }
> >  
> >  /* remove redundant charge if migration failed*/
> >  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> > -		struct page *oldpage, struct page *newpage)
> > +	struct page *oldpage, struct page *newpage)
> >  {
> > -	struct page *target, *unused;
> > -	struct page_cgroup *pc;
> > -	enum charge_type ctype;
> > +	struct page *used, *unused;
> >  
> >  	if (!mem)
> >  		return;
> >  	cgroup_exclude_rmdir(&mem->css);
> > +
> > +
> unnecessary extra line :)
> 
will remove.



> >  	/* at migration success, oldpage->mapping is NULL. */
> >  	if (oldpage->mapping) {
> > -		target = oldpage;
> > -		unused = NULL;
> > +		used = oldpage;
> > +		unused = newpage;
> >  	} else {
> > -		target = newpage;
> > +		used = newpage;
> >  		unused = oldpage;
> >  	}
> > -
> > -	if (PageAnon(target))
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> > -	else if (page_is_file_cache(target))
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > -	else
> > -		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > -
> > -	/* unused page is not on radix-tree now. */
> > -	if (unused)
> > -		__mem_cgroup_uncharge_common(unused, ctype);
> > -
> > -	pc = lookup_page_cgroup(target);
> > -	/*
> > -	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> > -	 * So, double-counting is effectively avoided.
> > -	 */
> > -	__mem_cgroup_commit_charge(mem, pc, ctype);
> > -
> > +	/* PageCgroupUsed() flag check will do all we want */
> > +	mem_cgroup_uncharge_page(unused);
> hmm... using mem_cgroup_uncharge_page() would be enough, but I think it doesn't
> show what we want: we must uncharge "unused" by all means in PageCgroupUsed case,
> and I feel it strange a bit to uncharge "unused" by mem_cgroup_uncharge_page(),
> if it *was* a cache page.
> So I think __mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE)
> would be better, otherwise we need more comments to explain why
> mem_cgroup_uncharge_page() is enough.
> 

Hmm. ok. consider this part again.



> >  	/*
> > -	 * Both of oldpage and newpage are still under lock_page().
> > -	 * Then, we don't have to care about race in radix-tree.
> > -	 * But we have to be careful that this page is unmapped or not.
> > -	 *
> > -	 * There is a case for !page_mapped(). At the start of
> > -	 * migration, oldpage was mapped. But now, it's zapped.
> > -	 * But we know *target* page is not freed/reused under us.
> > -	 * mem_cgroup_uncharge_page() does all necessary checks.
> > -	 */
> > -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > -		mem_cgroup_uncharge_page(target);
> > + 	 * If old page was file cache, and removed from radix-tree
> > + 	 * before lock_page(), perepare_migration doesn't charge and we never
> > + 	 * reach here.
> > + 	 *
> And if newpage was removed from radix-tree after unlock_page(),
> the context which removed it from radix-tree uncharges it properly, because
> it is charged at prepare_migration.
> 
> right?
> 
yes. I'll add more texts.




> > + 	 * Considering ANON pages, we can't depend on lock_page.
> > + 	 * If a page may be unmapped before it's remapped, new page's
> > + 	 * mapcount will not increase. (case that mapcount 0->1 never occur.)
> > + 	 * PageCgroupUsed() and SwapCache checks will be done.
> > + 	 *
> > + 	 * Once mapcount goes to 1, our hook to page_remove_rmap will do
> > + 	 * enough jobs.
> > + 	 */
> > +	if (PageAnon(used) && !page_mapped(used))
> > +		mem_cgroup_uncharge_page(used);
> mem_cgroup_uncharge_page() does the same check :)
> 
Ok. I'll fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
