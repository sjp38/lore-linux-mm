Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 45F146B00A7
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 21:02:39 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2522abs000866
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Mar 2010 11:02:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 337D645DE54
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:02:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0755145DE51
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:02:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A501DB803F
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:02:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D165E18002
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:02:35 +0900 (JST)
Date: Fri, 5 Mar 2010 10:58:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100305105855.9b53176c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100305101234.909001e8.nishimura@mxp.nes.nec.co.jp>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-4-git-send-email-arighi@develer.com>
	<20100305101234.909001e8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Mar 2010 10:12:34 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu,  4 Mar 2010 11:40:14 +0100, Andrea Righi <arighi@develer.com> wrote:
> > Infrastructure to account dirty pages per cgroup and add dirty limit
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >  	int *val = data;
> > @@ -1275,34 +1423,70 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >  
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update file cache's status for memcg.
> > + *
> > + * Before calling this, mapping->tree_lock should be held and preemption is
> > + * disabled.  Then, it's guarnteed that the page is not uncharged while we
> > + * access page_cgroup. We can make use of that.
> >   */
> IIUC, mapping->tree_lock is held with irq disabled, so I think "mapping->tree_lock
> should be held with irq disabled" would be enouth.
> And, as far as I can see, callers of this function have not ensured this yet in [4/4].
> 
> how about:
> 
> 	void mem_cgroup_update_stat_locked(...)
> 	{
> 		...
> 	}
> 
> 	void mem_cgroup_update_stat_unlocked(mapping, ...)
> 	{
> 		spin_lock_irqsave(mapping->tree_lock, ...);
> 		mem_cgroup_update_stat_locked();
> 		spin_unlock_irqrestore(...);
> 	}
>
Rather than tree_lock, lock_page_cgroup() can be used if tree_lock is not held.

		lock_page_cgroup();
		mem_cgroup_update_stat_locked();
		unlock_page_cgroup();

Andrea-san, FILE_MAPPED is updated without treelock, at least. You can't depend
on migration_lock about FILE_MAPPED.


 
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> I preffer "void mem_cgroup_update_page_stat(struct page *, enum mem_cgroup_page_stat_item, ..)"
> as I said above.
> 
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> >  
> > +	if (mem_cgroup_disabled())
> > +		return;
> >  	pc = lookup_page_cgroup(page);
> > -	if (unlikely(!pc))
> > +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> >  		return;
> >  
> > -	lock_page_cgroup(pc);
> > -	mem = pc->mem_cgroup;
> > -	if (!mem)
> > -		goto done;
> > -
> > -	if (!PageCgroupUsed(pc))
> > -		goto done;
> > -
> > +	lock_page_cgroup_migrate(pc);
> >  	/*
> > -	 * Preemption is already disabled. We can use __this_cpu_xxx
> > -	 */
> > -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> > -
> > -done:
> > -	unlock_page_cgroup(pc);
> > +	* It's guarnteed that this page is never uncharged.
> > +	* The only racy problem is moving account among memcgs.
> > +	*/
> > +	switch (idx) {
> > +	case MEM_CGROUP_STAT_FILE_MAPPED:
> > +		if (val > 0)
> > +			SetPageCgroupFileMapped(pc);
> > +		else
> > +			ClearPageCgroupFileMapped(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_FILE_DIRTY:
> > +		if (val > 0)
> > +			SetPageCgroupDirty(pc);
> > +		else
> > +			ClearPageCgroupDirty(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WRITEBACK:
> > +		if (val > 0)
> > +			SetPageCgroupWriteback(pc);
> > +		else
> > +			ClearPageCgroupWriteback(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WRITEBACK_TEMP:
> > +		if (val > 0)
> > +			SetPageCgroupWritebackTemp(pc);
> > +		else
> > +			ClearPageCgroupWritebackTemp(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_UNSTABLE_NFS:
> > +		if (val > 0)
> > +			SetPageCgroupUnstableNFS(pc);
> > +		else
> > +			ClearPageCgroupUnstableNFS(pc);
> > +		break;
> > +	default:
> > +		BUG();
> > +		break;
> > +	}
> > +	mem = pc->mem_cgroup;
> > +	if (likely(mem))
> > +		__this_cpu_add(mem->stat->count[idx], val);
> > +	unlock_page_cgroup_migrate(pc);
> >  }
> > +EXPORT_SYMBOL_GPL(mem_cgroup_update_stat);
> >  
> >  /*
> >   * size of first charge trial. "32" comes from vmscan.c's magic value.
> > @@ -1701,6 +1885,45 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  	memcg_check_events(mem, pc->page);
> >  }
> >  
> > +/*
> > + * Update file cache accounted statistics on task migration.
> > + *
> > + * TODO: We don't move charges of file (including shmem/tmpfs) pages for now.
> > + * So, at the moment this function simply returns without updating accounted
> > + * statistics, because we deal only with anonymous pages here.
> > + */
> This function is not unique to task migration. It's called from rmdir() too.
> So this comment isn't needed.
> 
> > +static void __mem_cgroup_update_file_stat(struct page_cgroup *pc,
> > +	struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> > +	struct page *page = pc->page;
> > +
> > +	if (!page_mapped(page) || PageAnon(page))
> > +		return;
> > +
> > +	if (PageCgroupFileMapped(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +	}
> > +	if (PageCgroupDirty(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_DIRTY]);
> > +	}
> > +	if (PageCgroupWriteback(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WRITEBACK]);
> > +	}
> > +	if (PageCgroupWritebackTemp(pc)) {
> > +		__this_cpu_dec(
> > +			from->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WRITEBACK_TEMP]);
> > +	}
> > +	if (PageCgroupUnstableNFS(pc)) {
> > +		__this_cpu_dec(
> > +			from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +	}
> > +}
> > +
> >  /**
> >   * __mem_cgroup_move_account - move account of the page
> >   * @pc:	page_cgroup of the page.
> > @@ -1721,22 +1944,16 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> > -	struct page *page;
> > -
> >  	VM_BUG_ON(from == to);
> >  	VM_BUG_ON(PageLRU(pc->page));
> >  	VM_BUG_ON(!PageCgroupLocked(pc));
> >  	VM_BUG_ON(!PageCgroupUsed(pc));
> >  	VM_BUG_ON(pc->mem_cgroup != from);
> >  
> > -	page = pc->page;
> > -	if (page_mapped(page) && !PageAnon(page)) {
> > -		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> > -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> > -	}
> > +	preempt_disable();
> > +	lock_page_cgroup_migrate(pc);
> > +	__mem_cgroup_update_file_stat(pc, from, to);
> > +
> >  	mem_cgroup_charge_statistics(from, pc, false);
> >  	if (uncharge)
> >  		/* This is not "cancel", but cancel_charge does all we need. */
> > @@ -1745,6 +1962,8 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
> >  	/* caller should have done css_get */
> >  	pc->mem_cgroup = to;
> >  	mem_cgroup_charge_statistics(to, pc, true);
> > +	unlock_page_cgroup_migrate(pc);
> > +	preempt_enable();
> Glad to see this cleanup :)
> But, hmm, I don't think preempt_disable/enable() is enough(and bit_spin_lock/unlock()
> does it anyway). lock/unlock_page_cgroup_migrate() can be called under irq context
> (e.g. end_page_writeback()), so I think we must local_irq_disable()/enable() here.
> 
Ah, hmm, yes. irq-disable is required.

Thanks,
-Kame

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
