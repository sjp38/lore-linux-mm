Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 6DE1D6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 19:51:21 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7BAD83EE0BB
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:51:19 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD2CF45DE52
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:51:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E89345DE4D
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:51:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9141D1DB8037
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:51:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F9331DB802F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:51:18 +0900 (JST)
Date: Mon, 5 Dec 2011 09:50:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-Id: <20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111202120849.GA1295@cmpxchg.org>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20111202120849.GA1295@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org

On Fri, 2 Dec 2011 13:08:49 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Dec 02, 2011 at 07:06:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > I'm now testing this patch, removing PCG_ACCT_LRU, onto mmotm.
> > How do you think ?
> 
> > @@ -1024,18 +1026,8 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
> >  		return;
> >  
> >  	pc = lookup_page_cgroup(page);
> > -	/*
> > -	 * root_mem_cgroup babysits uncharged LRU pages, but
> > -	 * PageCgroupUsed is cleared when the page is about to get
> > -	 * freed.  PageCgroupAcctLRU remembers whether the
> > -	 * LRU-accounting happened against pc->mem_cgroup or
> > -	 * root_mem_cgroup.
> > -	 */
> > -	if (TestClearPageCgroupAcctLRU(pc)) {
> > -		VM_BUG_ON(!pc->mem_cgroup);
> > -		memcg = pc->mem_cgroup;
> > -	} else
> > -		memcg = root_mem_cgroup;
> > +	memcg = pc->mem_cgroup ? pc->mem_cgroup : root_mem_cgroup;
> > +	VM_BUG_ON(memcg != pc->mem_cgroup_lru);
> >  	mz = page_cgroup_zoneinfo(memcg, page);
> >  	/* huge page split is done under lru_lock. so, we have no races. */
> >  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> 
> Nobody clears pc->mem_cgroup upon uncharge, so this may end up
> mistakenly lru-unaccount a page that was never charged against the
> stale pc->mem_cgroup (e.g. a swap readahead page that has not been
> charged yet gets isolated by reclaim).
> 
> On the other hand, pages that were uncharged just before the lru_del
> MUST be lru-unaccounted against pc->mem_cgroup.
> 
> PageCgroupAcctLRU made it possible to tell those two scenarios apart.
> 
> A possible solution could be to clear pc->mem_cgroup when the page is
> finally freed so that only pages that have been charged since their
> last allocation have pc->mem_cgroup set.  But this means that the page
> freeing hotpath will have to grow a lookup_page_cgroup(), amortizing
> the winnings at least to some extent.
> 

Hmm. IMHO, we have 2 easy ways.

 - Ignore PCG_USED bit at LRU handling.
   2 problems.
   1. memory.stat may show very wrong statistics if swapin is too often.
   2. need careful use of mem_cgroup_charge_lrucare().

 - Clear pc->mem_cgroup at swapin-readahead.
   A problem.
   1. we need a new hook.

I'll try to clear pc->mem_cgroup at swapin. 

Thank you for pointing out.

Regards,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
