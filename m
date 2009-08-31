From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] memcg: uncharge in batched manner
Date: Mon, 31 Aug 2009 17:40:08 +0530
Message-ID: <20090831121008.GL4770@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com> <20090831110204.GG4770@balbir.in.ibm.com> <119e8331d1210b1f56d0f6416863bfbc.squirrel@webmail-b.css.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752329AbZHaMKY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <119e8331d1210b1f56d0f6416863bfbc.squirrel@webmail-b.css.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-Id: linux-mm.kvack.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-31 20:59:18]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> > 13:24:38]:
> 
> >> +	}
> >> +	if (!batch || batch->memcg != mem) {
> >> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> >> +		if (uncharge_memsw)
> >> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> >
> > Could you please add a comment stating that if memcg is different that
> > we do a direct uncharge else we batch.
> >
> really necessary ?. ok. I'll do.
> 


I think it will help new readers of the code.

> >> +	} else {
> >> +		batch->pages += PAGE_SIZE;
> >> +		if (uncharge_memsw)
> >> +			batch->memsw += PAGE_SIZE;
> >> +	}
> >> +	return soft_limit_excess;
> >> +}
> >>  /*
> >>   * uncharge if !page_mapped(page)
> >>   */
> >> @@ -1886,12 +1914,8 @@ __mem_cgroup_uncharge_common(struct page
> >>  		break;
> >>  	}
> >>
> >> -	if (!mem_cgroup_is_root(mem)) {
> >> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> >> -		if (do_swap_account &&
> >> -				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> >> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> >> -	}
> >> +	if (!mem_cgroup_is_root(mem))
> >> +		__do_batch_uncharge(mem, ctype);
> >
> > Now I am beginning to think we need a cond_mem_cgroup_is_not_root()
> > function.
> >

> I can't catch waht cond_mem_cgroup_is_not_root() means.
>

It is something like cond_resched(), checks if mem_cgroup is not root,
if so executes. Just a nit-pick
 
> 
> >>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> >>  		mem_cgroup_swap_statistics(mem, true);
> >>  	mem_cgroup_charge_statistics(mem, pc, false);
> >> @@ -1938,6 +1962,40 @@ void mem_cgroup_uncharge_cache_page(stru
> >>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> >>  }
> >>
> >> +void mem_cgroup_uncharge_batch_start(void)
> >> +{
> >> +	VM_BUG_ON(current->memcg_batch.do_batch);
> >> +	/* avoid batch if killed by OOM */
> >> +	if (test_thread_flag(TIF_MEMDIE))
> >> +		return;
> >> +	current->memcg_batch.do_batch = 1;
> >> +	current->memcg_batch.memcg = NULL;
> >> +	current->memcg_batch.pages = 0;
> >> +	current->memcg_batch.memsw = 0;
> >> +}
> >> +
> >> +void mem_cgroup_uncharge_batch_end(void)
> >> +{
> >> +	struct mem_cgroup *mem;
> >> +
> >> +	if (!current->memcg_batch.do_batch)
> >> +		return;
> >> +
> >> +	current->memcg_batch.do_batch = 0;
> >> +
> >> +	mem = current->memcg_batch.memcg;
> >> +	if (!mem)
> >> +		return;
> >> +	if (current->memcg_batch.pages)
> >> +		res_counter_uncharge(&mem->res,
> >> +				     current->memcg_batch.pages, NULL);
> >> +	if (current->memcg_batch.memsw)
> >> +		res_counter_uncharge(&mem->memsw,
> >> +				     current->memcg_batch.memsw, NULL);
> >> +	/* we got css's refcnt */
> >> +	cgroup_release_and_wakeup_rmdir(&mem->css);
> >
> >
> > Does this effect deleting of a group and delay it by a large amount?
> >
> plz see what cgroup_release_and_xxxx  fixed. This is not for delay
> but for race-condition, which makes rmdir sleep permanently.
>

I've seen those patches, where rmdir() can hang. My conern was time
elapsed since we do css_get() and do a cgroup_release_and_wake_rmdir() 

-- 
	Balbir
