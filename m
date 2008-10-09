Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m996RCER014298
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Oct 2008 15:27:13 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A74DD2AC025
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:27:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75A8412C0A7
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:27:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 471241DB8040
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:27:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F00941DB8037
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:27:08 +0900 (JST)
Date: Thu, 9 Oct 2008 15:26:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] memcg: lazy lru freeing
Message-Id: <20081009152653.83b5ffac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081009143949.b3cf91b7.nishimura@mxp.nes.nec.co.jp>
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001170005.1997d7c8.kamezawa.hiroyu@jp.fujitsu.com>
	<20081009143949.b3cf91b7.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Oct 2008 14:39:49 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 1 Oct 2008 17:00:05 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Free page_cgroup from its LRU in batched manner.
> > 
> > When uncharge() is called, page is pushed onto per-cpu vector and
> > removed from LRU, later.. This routine resembles to global LRU's pagevec.
> > This patch is half of the whole patch and a set with following lazy LRU add
> > patch.
> > 
> > After this, a pc, which is PageCgroupLRU(pc)==true, is on LRU.
> > This LRU bit is guarded by lru_lock().
> > 
> >  PageCgroupUsed(pc) && PageCgroupLRU(pc) means "pc" is used and on LRU.
> >  This check makes sense only when both 2 locks, lock_page_cgroup()/lru_lock(),
> >  are aquired.
> > 
> >  PageCgroupUsed(pc) && !PageCgroupLRU(pc) means "pc" is used but not on LRU.
> >  !PageCgroupUsed(pc) && PageCgroupLRU(pc) means "pc" is unused but still on
> >  LRU. lru walk routine should avoid touching this.
> > 
> > Changelog (v5) => (v6):
> >  - Fixing race and added PCG_LRU bit
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> (snip)
> 
> > +static void
> > +__release_page_cgroup(struct memcg_percpu_vec *mpv)
> > +{
> > +	unsigned long flags;
> > +	struct mem_cgroup_per_zone *mz, *prev_mz;
> > +	struct page_cgroup *pc;
> > +	int i, nr;
> > +
> > +	local_irq_save(flags);
> > +	nr = mpv->nr;
> > +	mpv->nr = 0;
> > +	prev_mz = NULL;
> > +	for (i = nr - 1; i >= 0; i--) {
> > +		pc = mpv->vec[i];
> > +		mz = page_cgroup_zoneinfo(pc);
> > +		if (prev_mz != mz) {
> > +			if (prev_mz)
> > +				spin_unlock(&prev_mz->lru_lock);
> > +			prev_mz = mz;
> > +			spin_lock(&mz->lru_lock);
> > +		}
> > +		/*
> > +		 * this "pc" may be charge()->uncharge() while we are waiting
> > +		 * for this. But charge() path check LRU bit and remove this
> > +		 * from LRU if necessary.
> > +		 */
> > +		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
> > +			ClearPageCgroupLRU(pc);
> > +			__mem_cgroup_remove_list(mz, pc);
> > +			css_put(&pc->mem_cgroup->css);
> > +		}
> > +	}
> > +	if (prev_mz)
> > +		spin_unlock(&prev_mz->lru_lock);
> > +	local_irq_restore(flags);
> > +
> > +}
> > +
> I'm wondering if page_cgroup_zoneinfo is safe without lock_page_cgroup
> because it dereferences pc->mem_cgroup.
> I'm worring if the pc has been moved to another lru by re-charge(and re-uncharge),
> and __mem_cgroup_remove_list toches a wrong(old) group.
> 
> Hmm, there are many things to be done for re-charge and re-uncharge,
> so "if (!PageCgroupUsed(pc) && PageCgroupLRU(pc))" would be enough.
> (it can avoid race between re-charge.)
> 
It's safe just because  I added following check.

+	/*
+	 * This page_cgroup is not used but may be on LRU.
+	 */
+	if (unlikely(PageCgroupLRU(pc))) {
+		/*
+		 * pc->mem_cgroup has old information. force_empty() guarantee
+		 * that we never see stale mem_cgroup here.
+		 */
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		if (PageCgroupLRU(pc)) {
+			ClearPageCgroupLRU(pc);
+			__mem_cgroup_remove_list(mz, pc);
+			css_put(&pc->mem_cgroup->css);
+		}
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+	}
+	/* Here, PCG_LRU bit is cleared */

before reusing, LRU bit is unset.


> Another user of page_cgroup_zoneinfo without lock_page_cgroup is
> __mem_cgroup_move_lists called by mem_cgroup_isolate_pages,
> but mem_cgroup_isolate_pages handles pc which is actually on the mz->lru
> so it would be ok.
> (I think adding VM_BUG_ON(mz != page_cgroup_zoneifno(pc)) would make sense,
> or add new arg *mz to __mem_cgroup_move_lists?)
> 
ok, I'll add VM_BUG_ON().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
