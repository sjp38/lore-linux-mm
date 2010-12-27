Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 229A56B0088
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 22:39:50 -0500 (EST)
Date: Mon, 27 Dec 2010 12:35:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg: add valid check at allocating or freeing
 memory
Message-Id: <20101227123553.ed4a2576.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101224090927.GB4763@balbir.in.ibm.com>
References: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
	<20101224090927.GB4763@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

On Fri, 24 Dec 2010 14:39:27 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-12-24 09:31:31]:
> 
> > Hi,
> > 
> > I know we have many works to be done: THP, dirty limit, per-memcg background reclaim.
> > So, I'm not in hurry to push this patch.
> > 
> > This patch add checks at allocating or freeing a page whether the page is used
> > (iow, charged) from the view point of memcg. In fact, I've hit this check while
> > debugging a problem on RHEL6 kernel, which have stuck me these days and have not
> > been fixed unfortunately...
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > This patch add checks at allocating or freeing a page whether the page is used
> > (iow, charged) from the view point of memcg.
> > This check may be usefull in debugging a problem and we did a similar checks
> > before the commit 52d4b9ac(memcg: allocate all page_cgroup at boot).
> > 
> > This patch adds some overheads at allocating or freeing memory, so it's enabled
> > only when CONFIG_DEBUG_VM is enabled.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  include/linux/memcontrol.h |   12 +++++++++++
> >  mm/memcontrol.c            |   47 ++++++++++++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c            |    8 +++++-
> >  3 files changed, 65 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 067115c..04754c4 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -146,6 +146,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  						gfp_t gfp_mask);
> >  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> > 
> > +bool mem_cgroup_bad_page_check(struct page *page);
> > +void mem_cgroup_print_bad_page(struct page *page);
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> > 
> > @@ -336,6 +338,16 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> >  	return 0;
> >  }
> > 
> > +static inline bool
> > +mem_cgroup_bad_page_check(struct page *page)
> > +{
> > +	return false;
> > +}
> > +
> > +static void
> > +mem_cgroup_print_bad_page(struct page *page)
> > +{
> > +}
> >  #endif /* CONFIG_CGROUP_MEM_CONT */
> > 
> >  #endif /* _LINUX_MEMCONTROL_H */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 7d89517..21af8b2 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2971,6 +2971,53 @@ int mem_cgroup_shmem_charge_fallback(struct page *page,
> >  	return ret;
> >  }
> > 
> > +#ifdef CONFIG_DEBUG_VM
> > +static bool
> > +__mem_cgroup_bad_page_check(struct page *page, struct page_cgroup **pcp)
> > +{
> > +	struct page_cgroup *pc;
> > +	bool ret = false;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc))
> > +		goto out;
> > +
> > +	if (PageCgroupUsed(pc)) {
> > +		ret = true;
> > +		if (pcp)
> > +			*pcp = pc;
> > +	}
> > +out:
> > +	return ret;
> > +}
> > +
> > +bool mem_cgroup_bad_page_check(struct page *page)
> > +{
> > +	if (mem_cgroup_disabled())
> > +		return false;
> > +
> > +	return __mem_cgroup_bad_page_check(page, NULL);
> > +}
> > +
> > +void mem_cgroup_print_bad_page(struct page *page)
> > +{
> > +	struct page_cgroup *pc;
> > +
> > +	if (__mem_cgroup_bad_page_check(page, &pc))
> > +		printk(KERN_ALERT "pc:%p pc->flags:%ld pc->mem_cgroup:%p\n",
> > +			pc, pc->flags, pc->mem_cgroup);
> 
> I like the patch overall, I'm not sure if KERN_ALERT is the right
> level and I'd also like to see the pfn and page information printed.
Using the same level as dump_page() does would be better, IMHO.
And, I think this function should show information only about memcg. Information
about the page itself like pfn should be showed by dump_page().

> pc->mem_cgroup itself is a pointer and not very useful, how about
> printing pc->mem_cgroup.css->cgroup->dentry->d_name->name (Phew!)
> 
pc->mem_cgroup is enough to me(we can know path of it by using "crash" utility),
but I agree showing the path of it would be more informative.
I'll try it as mem_cgroup_print_oom_info() does.

> > +}
> > +#else
> > +bool mem_cgroup_bad_page_check(struct page *page)
> > +{
> > +	return false;
> > +}
> > +
> > +void mem_cgroup_print_bad_page(struct page *page)
> > +{
> > +}
> > +#endif
> > +
> >  static DEFINE_MUTEX(set_limit_mutex);
> > 
> >  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 7650ceb..5caeda8 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -53,6 +53,7 @@
> >  #include <linux/compaction.h>
> >  #include <trace/events/kmem.h>
> >  #include <linux/ftrace_event.h>
> > +#include <linux/memcontrol.h>
> > 
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -570,7 +571,8 @@ static inline int free_pages_check(struct page *page)
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> >  		(atomic_read(&page->_count) != 0) |
> > -		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
> > +		(page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
> > +		(mem_cgroup_bad_page_check(page)))) {
> >  		bad_page(page);
> >  		return 1;
> >  	}
> > @@ -755,7 +757,8 @@ static inline int check_new_page(struct page *page)
> >  	if (unlikely(page_mapcount(page) |
> >  		(page->mapping != NULL)  |
> >  		(atomic_read(&page->_count) != 0)  |
> > -		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
> > +		(page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
> > +		(mem_cgroup_bad_page_check(page)))) {
> >  		bad_page(page);
> >  		return 1;
> >  	}
> > @@ -5627,4 +5630,5 @@ void dump_page(struct page *page)
> >  		page, atomic_read(&page->_count), page_mapcount(page),
> >  		page->mapping, page->index);
> >  	dump_page_flags(page->flags);
> > +	mem_cgroup_print_bad_page(page);
> >  }
> 
> Overall, it is a good debugging aid
> 
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>  
Thanks!

Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
