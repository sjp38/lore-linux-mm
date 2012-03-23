Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id A3A836B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:54:20 -0400 (EDT)
Date: Fri, 23 Mar 2012 09:54:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 3/3] memcg: atomic update of memcg pointer and other
 bits.
Message-ID: <20120323085416.GA2816@tiehlicka.suse.cz>
References: <4F66E6A5.10804@jp.fujitsu.com>
 <4F66E85E.6030000@jp.fujitsu.com>
 <20120322133820.GE18665@tiehlicka.suse.cz>
 <4F6BCBD1.1030602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F6BCBD1.1030602@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On Fri 23-03-12 10:03:13, KAMEZAWA Hiroyuki wrote:
> (2012/03/22 22:38), Michal Hocko wrote:
[...]
> >>  	if (lrucare) {
> >>  		if (was_on_lru) {
> >> @@ -2529,7 +2518,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
> >>  
> >>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >>  
> >> -#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MIGRATION))
> >>  /*
> >>   * Because tail pages are not marked as "used", set it. We're under
> >>   * zone->lru_lock, 'splitting on pmd' and compound_lock.
> >> @@ -2547,9 +2535,7 @@ void mem_cgroup_split_huge_fixup(struct page *head)
> >>  		return;
> >>  	for (i = 1; i < HPAGE_PMD_NR; i++) {
> >>  		pc = head_pc + i;
> >> -		pc_set_mem_cgroup(pc, memcg);
> >> -		smp_wmb();/* see __commit_charge() */
> >> -		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
> >> +		pc_set_mem_cgroup(pc, memcg, BIT(PCG_USED));
> > 
> > Maybe it would be cleaner to remove PCGF_NOCOPY_AT_SPLIT in a separate patch with 
> > VM_BUG_ON(!head_pc->flags & BIT(PCG_USED))?
> > 
> 
> 
> Hm, ok. I'll divide this patch.

Thanks!

> 
> >>  	}
> >>  }
> >>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >> @@ -2616,7 +2602,7 @@ static int mem_cgroup_move_account(struct page *page,
> >>  		__mem_cgroup_cancel_charge(from, nr_pages);
> >>  
> >>  	/* caller should have done css_get */
> >> -	pc_set_mem_cgroup(pc, to);
> >> +	pc_set_mem_cgroup(pc, to, BIT(PCG_USED) | BIT(PCG_LOCK));
> > 
> > Same here.
> > 
> 
> 
> pc_set_mem_cgroup_flags() ?

This sounds like we set only flags but to be honest I didn't come to a
better name which wouldn't be terribly long as well.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
