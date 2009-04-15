Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9365F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 23:06:49 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3FE4cro003406
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 00:04:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3F36mmd1183894
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:06:48 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3F36mEE003000
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:06:48 +1000
Date: Wed, 15 Apr 2009 08:36:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] Add file RSS accounting to the memory resource
	controller
Message-ID: <20090415030606.GR7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090414180706.GQ7082@balbir.in.ibm.com> <20090415090130.26813449.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090415090130.26813449.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-15 09:01:30]:

> I think your concept is good. A few comments below.
>

Thanks,
 
> On Tue, 14 Apr 2009 23:37:06 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > Feature: Add file RSS tracking per memory cgroup
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Testing
> > 
> > 1. Feature enabled, built and booted the kernel. Mounted the memory
> > resource controller and verified the statistics
> > 2. Compiled with CGROUP_MEM_RES_CTLR disabled
> > 
> > We currently don't track file RSS, the RSS we report is actually anon RSS.
> > All the file mapped pages, come in through the page cache and get accounted
> > there. This patch adds support for accounting file RSS pages. It should
> > 
> > 1. Help improve the metrics reported by the memory resource controller
> > 2. Will form the basis for a future shared memory accounting heuristic
> >    that has been proposed by Kamezawa.
> > 
> > Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> > to "anon_rss". We however, add "file_rss" data and hope to educate the end
> > user through documentation.
> > ---
> > 
> >  include/linux/memcontrol.h |    7 +++++++
> >  include/linux/rmap.h       |    4 ++--
> >  mm/filemap_xip.c           |    2 +-
> >  mm/fremap.c                |    2 +-
> >  mm/memcontrol.c            |   34 +++++++++++++++++++++++++++++++++-
> >  mm/memory.c                |    8 ++++----
> >  mm/migrate.c               |    2 +-
> >  mm/rmap.c                  |   13 ++++++++-----
> >  8 files changed, 57 insertions(+), 15 deletions(-)
> > 
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 18146c9..c844a13 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -116,6 +116,8 @@ static inline bool mem_cgroup_disabled(void)
> >  }
> >  
> >  extern bool mem_cgroup_oom_called(struct task_struct *task);
> > +extern void
> > +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val);
> >  
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> > @@ -264,6 +266,11 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  {
> >  }
> >  
> > +static inline void
> > +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val)
> > +{
> > +}
> > +
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> >  
> >  #endif /* _LINUX_MEMCONTROL_H */
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index b35bc0e..01b4af1 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -68,8 +68,8 @@ void __anon_vma_link(struct vm_area_struct *);
> >   */
> >  void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
> >  void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
> > -void page_add_file_rmap(struct page *);
> > -void page_remove_rmap(struct page *);
> > +void page_add_file_rmap(struct page *, struct vm_area_struct *);
> > +void page_remove_rmap(struct page *, struct vm_area_struct *);
> >  
> >  #ifdef CONFIG_DEBUG_VM
> >  void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
> > diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> > index 427dfe3..e8b2b18 100644
> > --- a/mm/filemap_xip.c
> > +++ b/mm/filemap_xip.c
> > @@ -193,7 +193,7 @@ retry:
> >  			/* Nuke the page table entry. */
> >  			flush_cache_page(vma, address, pte_pfn(*pte));
> >  			pteval = ptep_clear_flush_notify(vma, address, pte);
> > -			page_remove_rmap(page);
> > +			page_remove_rmap(page, vma);
> >  			dec_mm_counter(mm, file_rss);
> >  			BUG_ON(pte_dirty(pteval));
> >  			pte_unmap_unlock(pte, ptl);
> > diff --git a/mm/fremap.c b/mm/fremap.c
> > index b6ec85a..01ea2da 100644
> > --- a/mm/fremap.c
> > +++ b/mm/fremap.c
> > @@ -37,7 +37,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		if (page) {
> >  			if (pte_dirty(pte))
> >  				set_page_dirty(page);
> > -			page_remove_rmap(page);
> > +			page_remove_rmap(page, vma);
> >  			page_cache_release(page);
> >  			update_hiwater_rss(mm);
> >  			dec_mm_counter(mm, file_rss);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e44fb0f..d903b61 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -62,7 +62,8 @@ enum mem_cgroup_stat_index {
> >  	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> >  	 */
> >  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> > -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> > +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > +	MEM_CGROUP_STAT_FILE_RSS,  /* # of pages charged as file rss */
> 
> I don't like the word "FILE RSS". MAPPED FILE PAGES or some will be more straigtforward.
> (IIUC, meminfo shows this information as MAPPED_FILE)

OK, I'll call it mapped_file

> 
> >  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  
> > @@ -321,6 +322,33 @@ static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> >  	return css_is_removed(&mem->css);
> >  }
> >  
> > +/*
> > + * Currently used to update file_rss statistics, but the routine can be
> > + * generalized to update other statistics as well.
> > + */
> > +void
> > +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val)
> > +{
> 
> Hmm. "mem_cgroup_update_statistics()" have wider meaning than what it does..
> Could you 
>   - modify function name for showing "this function counts MAPPED_FILE"

I thought about this, but made it more generic. How about
mem_cgroup_update_mapped_file_stat()

>  or
>   - add a function argument as "Which counter should be modified."
> 
> 
> > +	struct mem_cgroup *mem;
> > +	struct mem_cgroup_stat *stat;
> > +	struct mem_cgroup_stat_cpu *cpustat;
> > +	int cpu = get_cpu();
> > +
> > +	if (!page_is_file_cache(page))
> > +		return;
> > +
> > +	if (unlikely(!mm))
> > +		mm = &init_mm;
> > +
> > +	mem = try_get_mem_cgroup_from_mm(mm);
> > +	if (!mem)
> > +		return;
> > +
> > +	stat = &mem->stat;
> > +	cpustat = &stat->cpustat[cpu];
> > +
> > +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_RSS, val);
> > +}
> >  
> >  /*
> >   * Call callback function against all cgroup under hierarchy tree.
> > @@ -2051,6 +2079,7 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
> >  enum {
> >  	MCS_CACHE,
> >  	MCS_RSS,
> > +	MCS_FILE_RSS,
> >  	MCS_PGPGIN,
> >  	MCS_PGPGOUT,
> >  	MCS_INACTIVE_ANON,
> > @@ -2071,6 +2100,7 @@ struct {
> >  } memcg_stat_strings[NR_MCS_STAT] = {
> >  	{"cache", "total_cache"},
> >  	{"rss", "total_rss"},
> > +	{"file_rss", "total_file_rss"},
> >  	{"pgpgin", "total_pgpgin"},
> >  	{"pgpgout", "total_pgpgout"},
> >  	{"inactive_anon", "total_inactive_anon"},
> > @@ -2091,6 +2121,8 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> >  	s->stat[MCS_RSS] += val * PAGE_SIZE;
> > +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_FILE_RSS);
> > +	s->stat[MCS_FILE_RSS] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
> >  	s->stat[MCS_PGPGIN] += val;
> >  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
> 
> IIUC, you have to add hook to force_empty() and move FILE_RSS counter to the parent.
> I hope there is no terrible race around force empty...
> 
> Thanks,
> -Kame
>

Good catch, I'll do the necessary changes in
mem_cgroup_move_account(). I don't see any dirty race occuring, since
the counters are per-cpu. I'll double check however.
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
