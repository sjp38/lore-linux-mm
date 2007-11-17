Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAHGDlfE006941
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 11:13:47 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAHGC9mn130002
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 11:12:09 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAHGC9RY002786
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 11:12:09 -0500
Message-ID: <473F12D6.8030607@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 21:42:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10]
 calculate mapped ratio for memory cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116191844.319b2754.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116191844.319b2754.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Define function for calculating mapped_ratio in memory cgroup.
> 

Could you explain what the ratio is used for? Is it for reclaim
later?

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 



>  include/linux/memcontrol.h |   11 ++++++++++-
>  mm/memcontrol.c            |   13 +++++++++++++
>  2 files changed, 23 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
> +++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
> @@ -423,6 +423,19 @@ void mem_cgroup_move_lists(struct page_c
>  	spin_unlock(&mem->lru_lock);
>  }
> 
> +/*
> + * Calculate mapped_ratio under memory controller.
> + */
> +int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
> +{
> +	s64 total, rss;
> +
> +	/* usage is recorded in bytes */
> +	total = mem->res.usage >> PAGE_SHIFT;
> +	rss = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> +	return (rss * 100) / total;

Never tried 64 bit division on a 32 bit system. I hope we don't
have to resort to do_div() sort of functionality.

> +}
> +
>  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> Index: linux-2.6.24-rc2-mm1/include/linux/memcontrol.h
> ===================================================================
> --- linux-2.6.24-rc2-mm1.orig/include/linux/memcontrol.h
> +++ linux-2.6.24-rc2-mm1/include/linux/memcontrol.h
> @@ -61,6 +61,12 @@ extern int mem_cgroup_prepare_migration(
>  extern void mem_cgroup_end_migration(struct page *page);
>  extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
> 
> +/*
> + * For memory reclaim.
> + */
> +extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
> +
> +
>  #else /* CONFIG_CGROUP_MEM_CONT */
>  static inline void mm_init_cgroup(struct mm_struct *mm,
>  					struct task_struct *p)
> @@ -132,7 +138,10 @@ mem_cgroup_page_migration(struct page *p
>  {
>  }
> 
> -
> +static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
