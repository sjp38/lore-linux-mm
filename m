Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1446B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 20:27:23 -0400 (EDT)
Date: Mon, 11 May 2009 09:22:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/2] memcg fix stale swap cache account leak v6
Message-Id: <20090511092241.f332a1d6.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090508165636.GD4630@balbir.in.ibm.com>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
	<20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090508165636.GD4630@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 8 May 2009 22:26:36 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-08 14:09:10]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > In general, Linux's swp_entry handling is done by combination of lazy techniques
> > and global LRU. It works well but when we use mem+swap controller, some more
> > strict control is appropriate. Otherwise, swp_entry used by a cgroup will be
> > never freed until global LRU works. In a system where memcg is well-configured,
> > global LRU doesn't work frequently.
> > 
> >   Example A) Assume a swap cache which is not mapped.
> >               CPU0                            CPU1
> > 	   zap_pte()....                  shrink_page_list()
> > 	    free_swap_and_cache()           lock_page()
> > 		page seems busy.
> > 
> >   Example B) Assume swapin-readahead.
> > 	      CPU0			      CPU1
> > 	   zap_pte()			  read_swap_cache_async()
> > 					  swap_duplicate().
> >            swap_entry_free() = 1
> > 	   find_get_page()=> NULL.
> > 					  add_to_swap_cache().
> > 					  issue swap I/O. 
> > 
> > There are many patterns of this kind of race (but no problems).
> > 
> > free_swap_and_cache() is called for freeing swp_entry. But it is a best-effort
> > function. If the swp_entry/page seems busy, swp_entry is not freed.
> > This is not a problem because global-LRU will find SwapCache at page reclaim.
> > 
> > If memcg is used, on the other hand, global LRU may not work. Then, above
> > unused SwapCache will not be freed.
> > (unmapped SwapCache occupy swp_entry but never be freed if not on memcg's LRU)
> > 
> > So, even if there are no tasks in a cgroup, swp_entry usage still remains.
> > In bad case, OOM by mem+swap controller is triggered by this "leak" of
> > swp_entry as Nishimura reported.
> > 
> > Considering this issue, swapin-readahead itself is not very good for memcg.
> > It read swap cache which will not be used. (and _unused_ swapcache will
> > not be accounted.) Even if we account swap cache at add_to_swap_cache(),
> > we need to account page to several _unrelated_ memcg. This is bad.
> > 
> > This patch tries to fix racy case of free_swap_and_cache() and page status.
> > 
> > After this patch applied, following test works well.
> > 
> >   # echo 1-2M > ../memory.limit_in_bytes
> >   # run tasks under memcg.
> >   # kill all tasks and make memory.tasks empty
> >   # check memory.memsw.usage_in_bytes == memory.usage_in_bytes and
> >     there is no _used_ swp_entry.
> > 
> > What this patch does is
> >  - avoid swapin-readahead when memcg is activated.
> >  - try to free swapcache immediately after Writeback is done.
> >  - Handle racy case of __remove_mapping() in vmscan.c
> > 
> > TODO:
> >  - tmpfs should use real readahead rather than swapin readahead...
> > 
> > Changelog: v5 -> v6
> >  - works only when memcg is activated.
> >  - check after I/O works only after writeback.
> >  - avoid swapin-readahead when memcg is activated.
> >  - fixed page refcnt issue.
> > Changelog: v4->v5
> >  - completely new design.
> > 
> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I know we discussed readahead changes this in the past
> 
> 1. the memcg_activated() check should be memcg_swap_activated(), no?
>    In type 1, the problem can be solved by unaccounting the pages
>    in swap_entry_free
>    Type 2 is not a problem, since the accounting is already correct
>    Hence my assertion that this problem occurs only when swapaccount
>    is enabled.
No.
Both type-1 and type-2 have the problem that swp_entry is not freed correctly.
This problem has nothing to do with whether mem+swap controller is enabled or not.

Thanks,
Daisuke Nishimura.

> 2. I don't mind adding space overhead to swap_cgroup, if this problem
>    can be fought that way. The approaches so far have made my head go
>    round.
> 3. Disabling readahead is a big decision and will need loads of
>    review/data before we can decide to go this route.
> 
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
