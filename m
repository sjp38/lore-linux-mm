Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CEF756B0099
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 14:33:51 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBPIsOMp022093
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 00:24:24 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBPJXfgm3260558
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 01:03:41 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBPJXexT009519
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 06:33:40 +1100
Date: Fri, 24 Dec 2010 14:39:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg: add valid check at allocating or freeing
 memory
Message-ID: <20101224090927.GB4763@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-12-24 09:31:31]:

> Hi,
> 
> I know we have many works to be done: THP, dirty limit, per-memcg background reclaim.
> So, I'm not in hurry to push this patch.
> 
> This patch add checks at allocating or freeing a page whether the page is used
> (iow, charged) from the view point of memcg. In fact, I've hit this check while
> debugging a problem on RHEL6 kernel, which have stuck me these days and have not
> been fixed unfortunately...
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> This patch add checks at allocating or freeing a page whether the page is used
> (iow, charged) from the view point of memcg.
> This check may be usefull in debugging a problem and we did a similar checks
> before the commit 52d4b9ac(memcg: allocate all page_cgroup at boot).
> 
> This patch adds some overheads at allocating or freeing memory, so it's enabled
> only when CONFIG_DEBUG_VM is enabled.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  include/linux/memcontrol.h |   12 +++++++++++
>  mm/memcontrol.c            |   47 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c            |    8 +++++-
>  3 files changed, 65 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 067115c..04754c4 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -146,6 +146,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> 
> +bool mem_cgroup_bad_page_check(struct page *page);
> +void mem_cgroup_print_bad_page(struct page *page);
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
> 
> @@ -336,6 +338,16 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
>  	return 0;
>  }
> 
> +static inline bool
> +mem_cgroup_bad_page_check(struct page *page)
> +{
> +	return false;
> +}
> +
> +static void
> +mem_cgroup_print_bad_page(struct page *page)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7d89517..21af8b2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2971,6 +2971,53 @@ int mem_cgroup_shmem_charge_fallback(struct page *page,
>  	return ret;
>  }
> 
> +#ifdef CONFIG_DEBUG_VM
> +static bool
> +__mem_cgroup_bad_page_check(struct page *page, struct page_cgroup **pcp)
> +{
> +	struct page_cgroup *pc;
> +	bool ret = false;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc))
> +		goto out;
> +
> +	if (PageCgroupUsed(pc)) {
> +		ret = true;
> +		if (pcp)
> +			*pcp = pc;
> +	}
> +out:
> +	return ret;
> +}
> +
> +bool mem_cgroup_bad_page_check(struct page *page)
> +{
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	return __mem_cgroup_bad_page_check(page, NULL);
> +}
> +
> +void mem_cgroup_print_bad_page(struct page *page)
> +{
> +	struct page_cgroup *pc;
> +
> +	if (__mem_cgroup_bad_page_check(page, &pc))
> +		printk(KERN_ALERT "pc:%p pc->flags:%ld pc->mem_cgroup:%p\n",
> +			pc, pc->flags, pc->mem_cgroup);

I like the patch overall, I'm not sure if KERN_ALERT is the right
level and I'd also like to see the pfn and page information printed.
pc->mem_cgroup itself is a pointer and not very useful, how about
printing pc->mem_cgroup.css->cgroup->dentry->d_name->name (Phew!)

> +}
> +#else
> +bool mem_cgroup_bad_page_check(struct page *page)
> +{
> +	return false;
> +}
> +
> +void mem_cgroup_print_bad_page(struct page *page)
> +{
> +}
> +#endif
> +
>  static DEFINE_MUTEX(set_limit_mutex);
> 
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7650ceb..5caeda8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -53,6 +53,7 @@
>  #include <linux/compaction.h>
>  #include <trace/events/kmem.h>
>  #include <linux/ftrace_event.h>
> +#include <linux/memcontrol.h>
> 
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -570,7 +571,8 @@ static inline int free_pages_check(struct page *page)
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
>  		(atomic_read(&page->_count) != 0) |
> -		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
> +		(page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
> +		(mem_cgroup_bad_page_check(page)))) {
>  		bad_page(page);
>  		return 1;
>  	}
> @@ -755,7 +757,8 @@ static inline int check_new_page(struct page *page)
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
>  		(atomic_read(&page->_count) != 0)  |
> -		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
> +		(page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
> +		(mem_cgroup_bad_page_check(page)))) {
>  		bad_page(page);
>  		return 1;
>  	}
> @@ -5627,4 +5630,5 @@ void dump_page(struct page *page)
>  		page, atomic_read(&page->_count), page_mapcount(page),
>  		page->mapping, page->index);
>  	dump_page_flags(page->flags);
> +	mem_cgroup_print_bad_page(page);
>  }

Overall, it is a good debugging aid


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
