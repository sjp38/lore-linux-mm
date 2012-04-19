Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 496396B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 09:12:57 -0400 (EDT)
Date: Thu, 19 Apr 2012 15:12:11 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
Message-ID: <20120419131211.GA1759@cmpxchg.org>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
 <20120418163330.ca1518c7.akpm@linux-foundation.org>
 <4F8F6368.2090005@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F8F6368.2090005@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 19, 2012 at 09:59:20AM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/04/19 8:33), Andrew Morton wrote:
> 
> > On Wed, 18 Apr 2012 11:21:55 -0700
> > Ying Han <yinghan@google.com> wrote:
> >>  static void __free_pages_ok(struct page *page, unsigned int order)
> >>  {
> >>  	unsigned long flags;
> >> -	int wasMlocked = __TestClearPageMlocked(page);
> >> +	bool locked;
> >>  
> >>  	if (!free_pages_prepare(page, order))
> >>  		return;
> >>  
> >>  	local_irq_save(flags);
> >> -	if (unlikely(wasMlocked))
> >> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> > 
> > hm, what's going on here.  The page now has a zero refcount and is to
> > be returned to the buddy.  But mem_cgroup_begin_update_page_stat()
> > assumes that the page still belongs to a memcg.  I'd have thought that
> > any page_cgroup backreferences would have been torn down by now?
> > 
> >> +	if (unlikely(__TestClearPageMlocked(page)))
> >>  		free_page_mlock(page);
> > 
> 
> 
> Ah, this is problem. Now, we have following code.
> ==
> 
> > struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
> >                                        enum lru_list lru)
> > {
> >         struct mem_cgroup_per_zone *mz;
> >         struct mem_cgroup *memcg;
> >         struct page_cgroup *pc;
> > 
> >         if (mem_cgroup_disabled())
> >                 return &zone->lruvec;
> > 
> >         pc = lookup_page_cgroup(page);
> >         memcg = pc->mem_cgroup;
> > 
> >         /*
> >          * Surreptitiously switch any uncharged page to root:
> >          * an uncharged page off lru does nothing to secure
> >          * its former mem_cgroup from sudden removal.
> >          *
> >          * Our caller holds lru_lock, and PageCgroupUsed is updated
> >          * under page_cgroup lock: between them, they make all uses
> >          * of pc->mem_cgroup safe.
> >          */
> >         if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
> >                 pc->mem_cgroup = memcg = root_mem_cgroup;
> 
> ==
> 
> Then, accessing pc->mem_cgroup without checking PCG_USED bit is dangerous.
> It may trigger #GP because of suddern removal of memcg or because of above
> code, mis-accounting will happen... pc->mem_cgroup may be overwritten already.
>
> Proposal from me is calling TestClearPageMlocked(page) via mem_cgroup_uncharge().
> 
> Like this.
> ==
>         mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
> 
> 	/*
>          * Pages reach here when it's fully unmapped or dropped from file cache.
> 	 * we are under lock_page_cgroup() and have no race with memcg activities.
>          */
> 	if (unlikely(PageMlocked(page))) {
> 		if (TestClearPageMlocked())
> 			decrement counter.
> 	}
> 
>         ClearPageCgroupUsed(pc);
> ==
> But please check performance impact...

This makes the lifetime rules of mlocked anon really weird.

Plus this code runs for ALL uncharges, the unlikely() and preliminary
flag testing don't make it okay.  It's bad that we have this in the
allocator, but at least it would be good to hook into that branch and
not add another one.

pc->mem_cgroup stays intact after the uncharge.  Could we make the
memcg removal path wait on the mlock counter to drop to zero instead
and otherwise keep Ying's version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
