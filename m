Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E66F6B00B9
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 03:10:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B8AQx3014490
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 17:10:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE23645DE54
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:10:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FDF045DE52
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:10:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F861DB803A
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:10:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CCCEBE78007
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:10:24 +0900 (JST)
Date: Thu, 11 Mar 2010 17:06:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100311170646.13cf8f05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311165020.86ac904b.nishimura@mxp.nes.nec.co.jp>
References: <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
	<20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
	<20100311134908.48d8b0fc.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311135847.990eee62.nishimura@mxp.nes.nec.co.jp>
	<20100311141300.90b85391.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311151511.579aa8d1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165020.86ac904b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, Vivek Goyal <vgoyal@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 16:50:20 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 11 Mar 2010 15:15:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 11 Mar 2010 14:13:00 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Thu, 11 Mar 2010 13:58:47 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > I'll consider yet another fix for race in account migration if I can.
> > > > > 
> > > > me too.
> > > > 
> > > 
> > > How about this ? Assume that the race is very rare.
> > > 
> > > 	1. use trylock when updating statistics.
> > > 	   If trylock fails, don't account it.
> > > 
> > > 	2. add PCG_FLAG for all status as
> > > 
> > > +	PCG_ACCT_FILE_MAPPED, /* page is accounted as file rss*/
> > > +	PCG_ACCT_DIRTY, /* page is dirty */
> > > +	PCG_ACCT_WRITEBACK, /* page is being written back to disk */
> > > +	PCG_ACCT_WRITEBACK_TEMP, /* page is used as temporary buffer for FUSE */
> > > +	PCG_ACCT_UNSTABLE_NFS, /* NFS page not yet committed to the server */
> > > 
> > > 	3. At reducing counter, check PCG_xxx flags by
> > > 	TESTCLEARPCGFLAG()
> > > 
> > > This is similar to an _used_ method of LRU accounting. And We can think this
> > > method's error-range never go too bad number. 
> > > 
> I agree with you. I've been thinking whether we can remove page cgroup lock
> in update_stat as we do in lru handling codes.
> 
> > > I think this kind of fuzzy accounting is enough for writeback status.
> > > Does anyone need strict accounting ?
> > > 
> > 
> IMHO, we don't need strict accounting.
> 
> > How this looks ?
> I agree to this direction. One concern is we re-introduce "trylock" again..
> 
Yes, it's my concern, too.


> Some comments are inlined.

> > +	switch (idx) {
> > +	case MEMCG_NR_FILE_MAPPED:
> > +		if (charge) {
> > +			if (!PageCgroupFileMapped(pc))
> > +				SetPageCgroupFileMapped(pc);
> > +			else
> > +				val = 0;
> > +		} else {
> > +			if (PageCgroupFileMapped(pc))
> > +				ClearPageCgroupFileMapped(pc);
> > +			else
> > +				val = 0;
> > +		}
> Using !TestSetPageCgroupFileMapped(pc) or TestClearPageCgroupFileMapped(pc) is better ?
> 

I used this style because we're under lock. (IOW, to show we're guarded by lock.)


> > +		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> > +		break;
> > +	default:
> > +		BUG();
> > +		break;
> > +	}
> >  	/*
> >  	 * Preemption is already disabled. We can use __this_cpu_xxx
> >  	 */
> > -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> > +	__this_cpu_add(mem->stat->count[idx], val);
> > +}
> >  
> > -done:
> > -	unlock_page_cgroup(pc);
> > +void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
> > +{
> > +	struct page_cgroup *pc;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc))
> > +		return;
> > +
> > +	if (trylock_page_cgroup(pc)) {
> > +		__mem_cgroup_update_stat(pc, idx, charge);
> > +		unlock_page_cgroup(pc);
> > +	}
> > +	return;
> > +}
> > +
> > +static void mem_cgroup_migrate_stat(struct page_cgroup *pc,
> > +	struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> > +	preempt_disable();
> > +	if (PageCgroupFileMapped(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +	}
> > +	preempt_enable();
> > +}
> > +
> I think preemption is already disabled here too(by lock_page_cgroup()).
> 
Ah, yes. 


> > +static void
> > +__mem_cgroup_stat_fixup(struct page_cgroup *pc, struct mem_cgroup *mem)
> > +{
> > +	/* We'are in uncharge() and lock_page_cgroup */
> > +	if (PageCgroupFileMapped(pc)) {
> > +		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > +		ClearPageCgroupFileMapped(pc);
> > +	}
> >  }
> >  
> ditto.
> 
ok.

> >  /*
> > @@ -1810,13 +1859,7 @@ static void __mem_cgroup_move_account(st
> >  	VM_BUG_ON(pc->mem_cgroup != from);
> >  
> >  	page = pc->page;
> > -	if (page_mapped(page) && !PageAnon(page)) {
> > -		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> > -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> > -	}
> > +	mem_cgroup_migrate_stat(pc, from, to);
> >  	mem_cgroup_charge_statistics(from, pc, false);
> >  	if (uncharge)
> >  		/* This is not "cancel", but cancel_charge does all we need. */
> I welcome this fixup. IIUC, we have stat leak in current implementation.
> 

If necessary, I'd like to prepare fixed one as independent patch for mmotm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
