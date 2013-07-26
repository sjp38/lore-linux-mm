Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 855006B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 14:54:14 -0400 (EDT)
Date: Fri, 26 Jul 2013 14:54:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/6] mm: memcg: enable memcg OOM killer only for user
 faults
Message-ID: <20130726185407.GC17975@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-6-git-send-email-hannes@cmpxchg.org>
 <20130726141642.GG17761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726141642.GG17761@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 26, 2013 at 04:16:42PM +0200, Michal Hocko wrote:
> On Thu 25-07-13 18:25:37, Johannes Weiner wrote:
> > System calls and kernel faults (uaccess, gup) can handle an out of
> > memory situation gracefully and just return -ENOMEM.
> > 
> > Enable the memcg OOM killer only for user faults, where it's really
> > the only option available.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> It looks OK to me, but I have few comments bellow. Nothing really huge
> but I do not like mem_cgroup_xchg_may_oom for !MEMCG.

:-)

> > ---
> >  include/linux/memcontrol.h | 23 +++++++++++++++++++++++
> >  include/linux/sched.h      |  3 +++
> >  mm/filemap.c               | 11 ++++++++++-
> >  mm/memcontrol.c            |  2 +-
> >  mm/memory.c                | 40 ++++++++++++++++++++++++++++++----------
> >  5 files changed, 67 insertions(+), 12 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 7b4d9d7..9bb5eeb 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -125,6 +125,24 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >  extern void mem_cgroup_replace_page_cache(struct page *oldpage,
> >  					struct page *newpage);
> >  
> > +/**
> > + * mem_cgroup_xchg_may_oom - toggle the memcg OOM killer for a task
> > + * @p: task
> 
> Is this ever safe to call on !current? If not then I wouldn't allow to
> give p as a parameter.

Makes sense, I removed the parameter.

> > @@ -1634,10 +1639,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> >  		 * We found the page, so try async readahead before
> >  		 * waiting for the lock.
> >  		 */
> > +		may_oom = mem_cgroup_xchg_may_oom(current, 0);
> 
> s/0/false/
> 
> below ditto

Oops, updated both sites.

> >  		do_async_mmap_readahead(vma, ra, file, page, offset);
> > +		mem_cgroup_xchg_may_oom(current, may_oom);
> >  	} else if (!page) {
> >  		/* No page in the page cache at all */
> > +		may_oom = mem_cgroup_xchg_may_oom(current, 0);
> >  		do_sync_mmap_readahead(vma, ra, file, offset);
> > +		mem_cgroup_xchg_may_oom(current, may_oom);
> >  		count_vm_event(PGMAJFAULT);
> >  		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> >  		ret = VM_FAULT_MAJOR;
> [...]
> > diff --git a/mm/memory.c b/mm/memory.c
> > index f2ab2a8..5ea7b47 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> [...]
> > @@ -3851,6 +3843,34 @@ retry:
> >  	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
> >  }
> >  
> > +int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > +		    unsigned long address, unsigned int flags)
> > +{
> > +	int ret;
> > +
> > +	__set_current_state(TASK_RUNNING);
> > +
> > +	count_vm_event(PGFAULT);
> > +	mem_cgroup_count_vm_event(mm, PGFAULT);
> > +
> > +	/* do counter updates before entering really critical section. */
> > +	check_sync_rss_stat(current);
> > +
> > +	/*
> > +	 * Enable the memcg OOM handling for faults triggered in user
> > +	 * space.  Kernel faults are handled more gracefully.
> > +	 */
> > +	if (flags & FAULT_FLAG_USER)
> > +		WARN_ON(mem_cgroup_xchg_may_oom(current, true) == true);
> > +
> > +	ret = __handle_mm_fault(mm, vma, address, flags);
> > +
> > +	if (flags & FAULT_FLAG_USER)
> > +		WARN_ON(mem_cgroup_xchg_may_oom(current, false) == false);
> 
> Ohh, I see why you used !new in mem_cgroup_xchg_may_oom for !MEMCG case
> above. This could be fixed easily if you add mem_cgroup_{enable,disable}_oom
> which would be empty for !MEMCG.

You're right, it's much cleaner this way.  I added the enable/disable
functions, which has the advantage that the memcg-specific WARN_ON is
also not in generic code but encapsulated nicely.

Thanks for your feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
