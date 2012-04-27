Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id BB5796B00F8
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:00:48 -0400 (EDT)
Date: Fri, 27 Apr 2012 21:00:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] mm, thp: drop page_table_lock to uncharge memcg pages
Message-ID: <20120427190040.GL23980@redhat.com>
References: <alpine.DEB.2.00.1204261556100.15785@chino.kir.corp.google.com>
 <20120426163922.4879dcb1.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1204261642190.15785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204261642190.15785@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu, Apr 26, 2012 at 04:44:16PM -0700, David Rientjes wrote:
> On Thu, 26 Apr 2012, Andrew Morton wrote:
> 
> > > mm->page_table_lock is hotly contested for page fault tests and isn't
> > > necessary to do mem_cgroup_uncharge_page() in do_huge_pmd_wp_page().
> > > 
> > > ...
> > >
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -968,8 +968,10 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  	spin_lock(&mm->page_table_lock);
> > >  	put_page(page);
> > >  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> > > +		spin_unlock(&mm->page_table_lock);
> > >  		mem_cgroup_uncharge_page(new_page);
> > >  		put_page(new_page);
> > > +		goto out;
> > >  	} else {
> > >  		pmd_t entry;
> > >  		VM_BUG_ON(!PageHead(page));
> > 
> > But this is on the basically-never-happens race path and will surely have no
> > measurable benefit?
> > 

Even if it has no measurable benefit, it's still an ok
microoptimization as it can't slow down anything, it introduces a
slight different jump for the slow path but it shouldn't matter. So it
looks ok to me.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

> It happens more often than you may think on page fault tests; how 
> representative pft has ever been of actual workloads, especially with thp 
> where the benfits of allocating the hugepage usually result in better 
> performance in the long-term even for a short-term performance loss, is 
> debatable.  However, all other thp code has always dropped 
> mm->page_table_lock before calling mem_cgroup_uncharge_page() and this one 
> seems to have been missed.  Worth correcting, in my opinion.

If we take single threaded programs into account too, THP gives a
major boosts to the page faults too, a memset on a uninitialized area
with THP enabled on some CPUs it can run more than twice as fast
depending on the CPU cache sizes. If the access is random and not
sequential cache effects can make it slightly slower though.

I certainly agree the main focus here is not the page fault, but it's
still worth to optimize the page fault of course.

With concurrent threads and THP faults, the increased contention on
the page_table_lock on large-CPU systems could be mitigated with a
per-pmd lock but it would still be as coarse as 1G and it would
complicate the code a bit. If each thread address space is very big
and the threads aren't sharing much memory, it would make their page
faults SMP scale nicely though. Just an idea.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
