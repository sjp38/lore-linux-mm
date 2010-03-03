Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 370DA6B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 01:19:32 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o236JTFg007278
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 15:19:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B6C245DE51
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 15:19:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2325E45DE4F
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 15:19:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE171DB803B
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 15:19:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7B66E38001
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 15:19:28 +0900 (JST)
Date: Wed, 3 Mar 2010 15:15:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 15:01:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 3 Mar 2010 12:29:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 3 Mar 2010 11:12:38 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > > index fe09e51..f85acae 100644
> > > > --- a/mm/filemap.c
> > > > +++ b/mm/filemap.c
> > > > @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
> > > >  	 * having removed the page entirely.
> > > >  	 */
> > > >  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> > > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
> > > >  		dec_zone_page_state(page, NR_FILE_DIRTY);
> > > >  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > > >  	}
> > > (snip)
> > > > @@ -1096,6 +1113,7 @@ int __set_page_dirty_no_writeback(struct page *page)
> > > >  void account_page_dirtied(struct page *page, struct address_space *mapping)
> > > >  {
> > > >  	if (mapping_cap_account_dirty(mapping)) {
> > > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, 1);
> > > >  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> > > >  		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > > >  		task_dirty_inc(current);
> > > As long as I can see, those two functions(at least) calls mem_cgroup_update_state(),
> > > which acquires page cgroup lock, under mapping->tree_lock.
> > > But as I fixed before in commit e767e056, page cgroup lock must not acquired under
> > > mapping->tree_lock.
> > > hmm, we should call those mem_cgroup_update_state() outside mapping->tree_lock,
> > > or add local_irq_save/restore() around lock/unlock_page_cgroup() to avoid dead-lock.
> > > 
> > Ah, good catch! But hmmmmmm...
> > This account_page_dirtted() seems to be called under IRQ-disabled.
> > About  __remove_from_page_cache(), I think page_cgroup should have its own DIRTY flag,
> > then, mem_cgroup_uncharge_page() can handle it automatically.
> > 
> > But. there are no guarantee that following never happens. 
> > 	lock_page_cgroup()
> > 	    <=== interrupt.
> > 	    -> mapping->tree_lock()
> > Even if mapping->tree_lock is held with IRQ-disabled.
> > Then, if we add local_irq_save(), we have to add it to all lock_page_cgroup().
> > 
> > Then, hm...some kind of new trick ? as..
> > (Follwoing patch is not tested!!)
> > 
> If we can verify that all callers of mem_cgroup_update_stat() have always either aquired
> or not aquired tree_lock, this direction will work fine.
> But if we can't, we have to add local_irq_save() to lock_page_cgroup() like below.
> 

Agreed.
Let's try how we can write a code in clean way. (we have time ;)
For now, to me, IRQ disabling while lock_page_cgroup() seems to be a little
over killing. What I really want is lockless code...but it seems impossible
under current implementation.

I wonder the fact "the page is never unchareged under us" can give us some chances
...Hmm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
