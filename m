Date: Fri, 26 Sep 2008 18:24:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/12] memcg add function to move account
Message-Id: <20080926182442.91fbcb54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926163050.b510d4ad.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925152722.7a678ea1.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926163050.b510d4ad.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 16:30:50 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -444,9 +445,14 @@ void mem_cgroup_move_lists(struct page *
> >  
> >  	pc = page_get_page_cgroup(page);
> >  	if (pc) {
> > +		mem = pc->mem_cgroup;
> >  		mz = page_cgroup_zoneinfo(pc);
> >  		spin_lock_irqsave(&mz->lru_lock, flags);
> > -		__mem_cgroup_move_lists(pc, lru);
> > +		/*
> > +		 * check against the race with move_account.
> > +		 */
> > +		if (likely(mem == pc->mem_cgroup))
> > +			__mem_cgroup_move_lists(pc, lru);
> 
> (snip)
> 
> > @@ -754,16 +824,24 @@ __mem_cgroup_uncharge_common(struct page
> >  	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> >  	    && ((PageCgroupCache(pc) || page_mapped(page))))
> >  		goto unlock;
> > -
> > +retry:
> > +	mem = pc->mem_cgroup;
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	spin_lock_irqsave(&mz->lru_lock, flags);
> > +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED &&
> > +	    unlikely(mem != pc->mem_cgroup)) {
> > +		/* MAPPED account can be done without lock_page().
> > +		   Check race with mem_cgroup_move_account() */
> > +		spin_unlock_irqrestore(&mz->lru_lock, flags);
> > +		goto retry;
> > +	}
> 
> I'm sorry, but I've not been convinced yet why these checks are needed here.
> (Those checks are removed by [9/12] anyway.)
> 
> IIUC, pc->mem_cgroup is moved to another group only by mem_cgroup_move_account
> under lock_page_cgroup( and mz->lru_lock).
> And those two above(mem_cgroup_move_lists and __mem_cgroup_uncharge_common) sets
> mem = pc->mem_cgroup under lock_page_cgroup, so I don't think those checks
> (mem != pc->mem_cgroup) is needed.
> 
you're right.

Thanks,
-Kame



> 
> Thanks,
> Daisuke Nishimura.
> 
> > +/**
> > + * mem_cgroup_move_account - move account of the page
> > + * @page ... the target page of being moved.
> > + * @pc   ... page_cgroup of the page.
> > + * @from ... mem_cgroup which the page is moved from.
> > + * @to   ... mem_cgroup which the page is moved to.
> > + *
> > + * The caller must confirm following.
> > + * 1. disable irq.
> > + * 2. lru_lock of old mem_cgroup should be held.
> > + * 3. pc is guaranteed to be valid and on mem_cgroup's LRU.
> > + *
> > + * Because we cannot call try_to_free_page() here, the caller must guarantee
> > + * this moving of charge never fails. (if charge fails, this call fails.)
> > + * Currently this is called only against root cgroup.
> > + * which has no limitation of resource.
> > + * Returns 0 at success, returns 1 at failure.
> > + */
> > +int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
> > +	struct mem_cgroup *from, struct mem_cgroup *to)
> > +{
> > +	struct mem_cgroup_per_zone *from_mz, *to_mz;
> > +	int nid, zid;
> > +	int ret = 1;
> > +
> > +	VM_BUG_ON(!irqs_disabled());
> > +
> > +	nid = page_to_nid(page);
> > +	zid = page_zonenum(page);
> > +	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
> > +	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
> > +
> > +	if (res_counter_charge(&to->res, PAGE_SIZE)) {
> > +		/* Now, we assume no_limit...no failure here. */
> > +		return ret;
> > +	}
> > +	if (!try_lock_page_cgroup(page)) {
> > +		res_counter_uncharge(&to->res, PAGE_SIZE);
> > +		return ret;
> > +	}
> > +
> > +	if (page_get_page_cgroup(page) != pc) {
> > +		res_counter_uncharge(&to->res, PAGE_SIZE);
> > +		goto out;
> > +	}
> > +
> > +	if (spin_trylock(&to_mz->lru_lock)) {
> > +		__mem_cgroup_remove_list(from_mz, pc);
> > +		css_put(&from->css);
> > +		res_counter_uncharge(&from->res, PAGE_SIZE);
> > +		pc->mem_cgroup = to;
> > +		css_get(&to->css);
> > +		__mem_cgroup_add_list(to_mz, pc);
> > +		ret = 0;
> > +		spin_unlock(&to_mz->lru_lock);
> > +	} else {
> > +		res_counter_uncharge(&to->res, PAGE_SIZE);
> > +	}
> > +out:
> > +	unlock_page_cgroup(page);
> > +
> > +	return ret;
> > +}
> > +
> >  /*
> >   * Charge the memory controller for page usage.
> >   * Return
> >  	__mem_cgroup_remove_list(mz, pc);
> >  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> >  
> >  	page_assign_page_cgroup(page, NULL);
> >  	unlock_page_cgroup(page);
> >  
> > -	mem = pc->mem_cgroup;
> > +
> >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> >  	css_put(&mem->css);
> >  
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
