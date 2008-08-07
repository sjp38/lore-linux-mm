Received: from edge04.upc.biz ([192.168.13.239]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080807133612.MIVB16026.viefep17-int.chello.at@edge04.upc.biz>
          for <linux-mm@kvack.org>; Thu, 7 Aug 2008 15:36:12 +0200
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080806082046.349BE5A5F@siro.lan>
References: <20080711175213.dc69f068.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080806082046.349BE5A5F@siro.lan>
Content-Type: text/plain
Date: Thu, 07 Aug 2008 15:36:08 +0200
Message-Id: <1218116168.8625.38.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-06 at 17:20 +0900, YAMAMOTO Takashi wrote:
> hi,
> 
> > On Fri, 11 Jul 2008 17:34:46 +0900 (JST)
> > yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > 
> > > hi,
> > > 
> > > > > my patch penalizes heavy-writer cgroups as task_dirty_limit does
> > > > > for heavy-writer tasks.  i don't think that it's necessary to be
> > > > > tied to the memory subsystem because i merely want to group writers.
> > > > > 
> > > > Hmm, maybe what I need is different from this ;)
> > > > Does not seem to be a help for memory reclaim under memcg.
> > > 
> > > to implement what you need, i think that we need to keep track of
> > > the numbers of dirty-pages in each memory cgroups as a first step.
> > > do you agree?
> > > 
> > yes, I think so, now.
> > 
> > may be not difficult but will add extra overhead ;( Sigh..
> 
> the following is a patch to add the overhead. :)
> any comments?
> 
> YAMAMOTO Takashi

It _might_ (depends on the uglyness of the result) make sense to try and
stick the mem_cgroup_*_page_dirty() stuff into the *PageDirty() macros.


> @@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  		if (PageUnevictable(page) ||
>  		    (PageActive(page) && !active) ||
>  		    (!PageActive(page) && active)) {
> -			__mem_cgroup_move_lists(pc, page_lru(page));
> +			if (try_lock_page_cgroup(page)) {
> +				__mem_cgroup_move_lists(pc, page_lru(page));
> +				unlock_page_cgroup(page);
> +			}
>  			continue;
>  		}

This chunk seems unrelated and lost....


> @@ -772,6 +792,38 @@ void mem_cgroup_end_migration(struct page *newpage)
>  		mem_cgroup_uncharge_page(newpage);
>  }
>  
> +void mem_cgroup_set_page_dirty(struct page *pg)
> +{
> +	struct page_cgroup *pc;
> +
> +	lock_page_cgroup(pg);
> +	pc = page_get_page_cgroup(pg);
> +	if (pc != NULL && (pc->flags & PAGE_CGROUP_FLAG_DIRTY) == 0) {
> +		struct mem_cgroup *mem = pc->mem_cgroup;
> +		struct mem_cgroup_stat *stat = &mem->stat;
> +
> +		pc->flags |= PAGE_CGROUP_FLAG_DIRTY;
> +		__mem_cgroup_stat_add(stat, MEM_CGROUP_STAT_DIRTY, 1);
> +	}
> +	unlock_page_cgroup(pg);
> +}
> +
> +void mem_cgroup_clear_page_dirty(struct page *pg)
> +{
> +	struct page_cgroup *pc;
> +
> +	lock_page_cgroup(pg);
> +	pc = page_get_page_cgroup(pg);
> +	if (pc != NULL && (pc->flags & PAGE_CGROUP_FLAG_DIRTY) != 0) {
> +		struct mem_cgroup *mem = pc->mem_cgroup;
> +		struct mem_cgroup_stat *stat = &mem->stat;
> +
> +		pc->flags &= ~PAGE_CGROUP_FLAG_DIRTY;
> +		__mem_cgroup_stat_add(stat, MEM_CGROUP_STAT_DIRTY, -1);
> +	}
> +	unlock_page_cgroup(pg);
> +}
> +
>  /*
>   * A call to try to shrink memory usage under specified resource controller.
>   * This is typically used for page reclaiming for shmem for reducing side


I presonally dislike the != 0, == 0 comparisons for bitmask operations,
they seem to make it harder to read somewhow. I prefer to write !(flags
& mask) and (flags & mask), instead.

I guess taste differs,...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
