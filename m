Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id CB63B6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 19:13:28 -0500 (EST)
Received: by iapp10 with SMTP id p10so8599166iap.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 16:13:28 -0800 (PST)
Date: Mon, 5 Dec 2011 16:13:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
In-Reply-To: <20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1112051552210.3938@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com> <20111202120849.GA1295@cmpxchg.org> <20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 5 Dec 2011, KAMEZAWA Hiroyuki wrote:
> On Fri, 2 Dec 2011 13:08:49 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Fri, Dec 02, 2011 at 07:06:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > > I'm now testing this patch, removing PCG_ACCT_LRU, onto mmotm.
> > > How do you think ?
> > 
> > > @@ -1024,18 +1026,8 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
> > >  		return;
> > >  
> > >  	pc = lookup_page_cgroup(page);
> > > -	/*
> > > -	 * root_mem_cgroup babysits uncharged LRU pages, but
> > > -	 * PageCgroupUsed is cleared when the page is about to get
> > > -	 * freed.  PageCgroupAcctLRU remembers whether the
> > > -	 * LRU-accounting happened against pc->mem_cgroup or
> > > -	 * root_mem_cgroup.
> > > -	 */
> > > -	if (TestClearPageCgroupAcctLRU(pc)) {
> > > -		VM_BUG_ON(!pc->mem_cgroup);
> > > -		memcg = pc->mem_cgroup;
> > > -	} else
> > > -		memcg = root_mem_cgroup;
> > > +	memcg = pc->mem_cgroup ? pc->mem_cgroup : root_mem_cgroup;
> > > +	VM_BUG_ON(memcg != pc->mem_cgroup_lru);
> > >  	mz = page_cgroup_zoneinfo(memcg, page);
> > >  	/* huge page split is done under lru_lock. so, we have no races. */
> > >  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> > 
> > Nobody clears pc->mem_cgroup upon uncharge, so this may end up
> > mistakenly lru-unaccount a page that was never charged against the
> > stale pc->mem_cgroup (e.g. a swap readahead page that has not been
> > charged yet gets isolated by reclaim).
> > 
> > On the other hand, pages that were uncharged just before the lru_del
> > MUST be lru-unaccounted against pc->mem_cgroup.
> > 
> > PageCgroupAcctLRU made it possible to tell those two scenarios apart.
> > 
> > A possible solution could be to clear pc->mem_cgroup when the page is
> > finally freed so that only pages that have been charged since their
> > last allocation have pc->mem_cgroup set.  But this means that the page
> > freeing hotpath will have to grow a lookup_page_cgroup(), amortizing
> > the winnings at least to some extent.
> > 
> 
> Hmm. IMHO, we have 2 easy ways.
> 
>  - Ignore PCG_USED bit at LRU handling.
>    2 problems.
>    1. memory.stat may show very wrong statistics if swapin is too often.
>    2. need careful use of mem_cgroup_charge_lrucare().
> 
>  - Clear pc->mem_cgroup at swapin-readahead.
>    A problem.
>    1. we need a new hook.
> 
> I'll try to clear pc->mem_cgroup at swapin. 
> 
> Thank you for pointing out.

Ying and I found PageCgroupAcctLRU very hard to grasp, even despite
the comments Hannes added to explain it.  In moving the LRU locking
from zone to memcg, we needed to depend upon pc->mem_cgroup: that
was difficult while the interpretation of pc->mem_cgroup depended
upon two flags also; and very tricky when pages were liable to shift
underneath you from one LRU to another, as flags came and went.
So we already eliminated PageCgroupAcctLRU here.

I'm fairly happy with what we have now, and have ported it forward
to 3.2.0-rc3-next-20111202: with a few improvements on top of what
we've got internally - Hannes's remark above about "amortizing the
winnings" in the page freeing hotpath has prompted me to improve
on what we had there, needs more testing but seems good so far.

However, I've hardly begun splitting the changes up into a series:
had intended to do so last week, but day followed day...  If you'd
like to see the unpolished uncommented rollup, I can post that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
