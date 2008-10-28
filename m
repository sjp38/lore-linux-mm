Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9S0H3QA004800
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 09:17:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D01E2AC025
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:17:03 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E4A412C047
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:17:03 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id EA0B21DB803C
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:17:02 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 869B71DB8042
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:17:02 +0900 (JST)
Date: Tue, 28 Oct 2008 09:16:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 11/11] memcg: mem+swap controler core
Message-Id: <20081028091633.ed7f7655.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081027203751.b3b5a607.nishimura@mxp.nes.nec.co.jp>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181611.367d9f07.kamezawa.hiroyu@jp.fujitsu.com>
	<20081027203751.b3b5a607.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Oct 2008 20:37:51 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 23 Oct 2008 18:16:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >  static struct mem_cgroup init_mem_cgroup;
> >  
> > @@ -148,6 +158,7 @@ enum charge_type {
> >  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> >  	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
> >  	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
> > +	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* used by force_empty */
> comment should be modified :)
> 
sure.

> >  	NR_CHARGE_TYPE,
> >  };
<snip>
> > +int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> > +		struct page *page, gfp_t mask, struct mem_cgroup **ptr)
> > +{
> > +	struct mem_cgroup *mem;
> > +	swp_entry_t	ent;
> > +
> > +	if (mem_cgroup_subsys.disabled)
> > +		return 0;
> >  
> > +	if (!do_swap_account)
> > +		goto charge_cur_mm;
> > +
> > +	ent.val = page_private(page);
> > +
> > +	mem = lookup_swap_cgroup(ent);
> > +	if (!mem || mem->obsolete)
> > +		goto charge_cur_mm;
> > +	*ptr = mem;
> > +	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
> > +charge_cur_mm:
> > +	if (unlikely(!mm))
> > +		mm = &init_mm;
> > +	return __mem_cgroup_try_charge(mm, mask, ptr, true);
> >  }
> >  
> hmm... this function is not called from any functions.
> Should do_swap_page()->mem_cgroup_try_charge() and unuse_pte()->mem_cgroup_try_charge()
> are changed to mem_cgroup_try_charge_swapin()?
> 
yes. Hmm...patch order is confusing ? I'll look into again.



> >  	lock_page_cgroup(pc);
> > +	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> > +		if (PageAnon(page)) {
> > +			if (page_mapped(page)) {
> > +				unlock_page_cgroup(pc);
> > +				return NULL;
> > +			}
> > +		} else if (page->mapping && !page_is_file_cache(page)) {
> > +			/* This is on radix-tree. */
> > +			unlock_page_cgroup(pc);
> > +			return NULL;
> > +		}
> > +	}
> >  	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && page_mapped(page))
> >  	     || !PageCgroupUsed(pc)) {
> Isn't check for PCG_USED needed when MEM_CGROUP_CHARGE_TYPE_SWAPOUT?
> 
Ah, seems problematic. thanks.

> >  		/* This happens at race in zap_pte_range() and do_swap_page()*/
> >  		unlock_page_cgroup(pc);
> > -		return;
> > +		return NULL;
> >  	}
> >  	ClearPageCgroupUsed(pc);
> >  	mem = pc->mem_cgroup;
> > @@ -1063,9 +1197,11 @@ __mem_cgroup_uncharge_common(struct page
> >  	 * unlock this.
> >  	 */
> >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +	if (do_swap_account && ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> > +		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> >  	unlock_page_cgroup(pc);
> >  	release_page_cgroup(pc);
> > -	return;
> > +	return mem;
> >  }
> >  
> Now, anon pages are not uncharge if PageSwapCache,
> I think "if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)" at
> mem_cgroup_end_migration() should be removed. Otherwise oldpage
> is not uncharged if it is on swapcache, isn't it?
> 
oldpage's swapcache bit is dropped at that stage.
I'll add comment.

Thank you for review.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
