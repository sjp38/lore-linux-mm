Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id AE4256B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 02:06:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D7F223EE0C1
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:06:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B17D145DE54
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:06:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AABF45DE50
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:06:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8940D1DB8041
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:06:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 365111DB802F
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:06:29 +0900 (JST)
Message-ID: <4F827BF9.2090205@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 15:04:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 07/14] memcg: Add HugeTLB extension
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/07 3:50), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch implements a memcg extension that allows us to control HugeTLB
> allocations via memory controller. The extension allows to limit the
> HugeTLB usage per control group and enforces the controller limit during
> page fault. Since HugeTLB doesn't support page reclaim, enforcing the limit
> at page fault time implies that, the application will get SIGBUS signal if it
> tries to access HugeTLB pages beyond its limit. This requires the application
> to know beforehand how much HugeTLB pages it would require for its use.
> 
> The charge/uncharge calls will be added to HugeTLB code in later patch.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


Hmm, seems ok to me. please explain 'this patch doesn't include updates
for memcg destroying, it will be in patch 12/14' or some...

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


BTW, you don't put res_counter for hugeltb under CONFIG_MEM_RES_CTLR_HUGETLB...
do you think we need the config ?



> ---
>  include/linux/hugetlb.h    |    1 +
>  include/linux/memcontrol.h |   42 ++++++++++++++
>  init/Kconfig               |    8 +++
>  mm/hugetlb.c               |    2 +-
>  mm/memcontrol.c            |  132 ++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 184 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 46c6cbd..995c238 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -226,6 +226,7 @@ struct hstate *size_to_hstate(unsigned long size);
>  #define HUGE_MAX_HSTATE 1
>  #endif
>  
> +extern int hugetlb_max_hstate;
>  extern struct hstate hstates[HUGE_MAX_HSTATE];
>  extern unsigned int default_hstate_idx;
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f94efd2..1d07e14 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -448,5 +448,47 @@ static inline void sock_release_memcg(struct sock *sk)
>  {
>  }
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +extern int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> +					  struct mem_cgroup **ptr);
> +extern void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
> +					     struct mem_cgroup *memcg,
> +					     struct page *page);
> +extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
> +					     struct page *page);
> +extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
> +					      struct mem_cgroup *memcg);
> +
> +#else
> +static inline int
> +mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> +						 struct mem_cgroup **ptr)
> +{
> +	return 0;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
> +				 struct mem_cgroup *memcg,
> +				 struct page *page)
> +{
> +	return;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
> +				 struct page *page)
> +{
> +	return;
> +}
> +
> +static inline void
> +mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
> +				  struct mem_cgroup *memcg)
> +{
> +	return;
> +}
> +#endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  #endif /* _LINUX_MEMCONTROL_H */
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index 72f33fa..a3b5665 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -716,6 +716,14 @@ config CGROUP_PERF
>  
>  	  Say N if unsure.
>  
> +config MEM_RES_CTLR_HUGETLB
> +	bool "Memory Resource Controller HugeTLB Extension (EXPERIMENTAL)"
> +	depends on CGROUP_MEM_RES_CTLR && HUGETLB_PAGE && EXPERIMENTAL
> +	default n
> +	help
> +	  Add HugeTLB management to memory resource controller. When you
> +	  enable this, you can put a per cgroup limit on HugeTLB usage.
> +
>  menuconfig CGROUP_SCHED
>  	bool "Group CPU scheduler"
>  	default n
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a3ac624..8cd89b4 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -35,7 +35,7 @@ const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
>  
> -static int hugetlb_max_hstate;
> +int hugetlb_max_hstate;
>  unsigned int default_hstate_idx;
>  struct hstate hstates[HUGE_MAX_HSTATE];
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d28359c..1a2e041 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -252,6 +252,10 @@ struct mem_cgroup {
>  	};
>  
>  	/*
> +	 * the counter to account for hugepages from hugetlb.
> +	 */
> +	struct res_counter hugepage[HUGE_MAX_HSTATE];
> +	/*
>  	 * Per cgroup active and inactive list, similar to the
>  	 * per zone LRU lists.
>  	 */
> @@ -3213,6 +3217,114 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  }
>  #endif
>  
> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +{
> +	int idx;
> +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> +		if ((res_counter_read_u64(&memcg->hugepage[idx], RES_USAGE)) > 0)
> +			return 1;
> +	}
> +	return 0;
> +}
> +
> +int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> +				   struct mem_cgroup **ptr)
> +{
> +	int ret = 0;
> +	struct mem_cgroup *memcg = NULL;
> +	struct res_counter *fail_res;
> +	unsigned long csize = nr_pages * PAGE_SIZE;
> +
> +	if (mem_cgroup_disabled())
> +		goto done;
> +again:
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (!memcg)
> +		memcg = root_mem_cgroup;
> +
> +	if (!css_tryget(&memcg->css)) {
> +		rcu_read_unlock();
> +		goto again;
> +	}
> +	rcu_read_unlock();
> +
> +	ret = res_counter_charge(&memcg->hugepage[idx], csize, &fail_res);
> +	css_put(&memcg->css);
> +done:
> +	*ptr = memcg;
> +	return ret;
> +}
> +
> +void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
> +				      struct mem_cgroup *memcg,
> +				      struct page *page)
> +{
> +	struct page_cgroup *pc;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(page);
> +	lock_page_cgroup(pc);
> +	if (unlikely(PageCgroupUsed(pc))) {
> +		unlock_page_cgroup(pc);
> +		mem_cgroup_hugetlb_uncharge_memcg(idx, nr_pages, memcg);
> +		return;
> +	}
> +	pc->mem_cgroup = memcg;
> +	SetPageCgroupUsed(pc);
> +	unlock_page_cgroup(pc);
> +	return;
> +}
> +
> +void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
> +				      struct page *page)
> +{
> +	struct page_cgroup *pc;
> +	struct mem_cgroup *memcg;
> +	unsigned long csize = nr_pages * PAGE_SIZE;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!PageCgroupUsed(pc)))
> +		return;
> +
> +	lock_page_cgroup(pc);
> +	if (!PageCgroupUsed(pc)) {
> +		unlock_page_cgroup(pc);
> +		return;
> +	}
> +	memcg = pc->mem_cgroup;
> +	pc->mem_cgroup = root_mem_cgroup;
> +	ClearPageCgroupUsed(pc);
> +	unlock_page_cgroup(pc);
> +
> +	res_counter_uncharge(&memcg->hugepage[idx], csize);
> +	return;
> +}
> +
> +void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
> +				       struct mem_cgroup *memcg)
> +{
> +	unsigned long csize = nr_pages * PAGE_SIZE;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	res_counter_uncharge(&memcg->hugepage[idx], csize);
> +	return;
> +}
> +#else
> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
> +
>  /*
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
> @@ -4962,6 +5074,7 @@ err_cleanup:
>  static struct cgroup_subsys_state * __ref
>  mem_cgroup_create(struct cgroup *cont)
>  {
> +	int idx;
>  	struct mem_cgroup *memcg, *parent;
>  	long error = -ENOMEM;
>  	int node;
> @@ -5004,9 +5117,22 @@ mem_cgroup_create(struct cgroup *cont)
>  		 * mem_cgroup(see mem_cgroup_put).
>  		 */
>  		mem_cgroup_get(parent);
> +		/*
> +		 * We could get called before hugetlb init is called.
> +		 * Use HUGE_MAX_HSTATE as the max index.
> +		 */
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&memcg->hugepage[idx],
> +					 &parent->hugepage[idx]);
>  	} else {
>  		res_counter_init(&memcg->res, NULL);
>  		res_counter_init(&memcg->memsw, NULL);
> +		/*
> +		 * We could get called before hugetlb init is called.
> +		 * Use HUGE_MAX_HSTATE as the max index.
> +		 */
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&memcg->hugepage[idx], NULL);
>  	}
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);
> @@ -5026,6 +5152,12 @@ free_out:
>  static int mem_cgroup_pre_destroy(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	/*
> +	 * Don't allow memcg removal if we have HugeTLB resource
> +	 * usage.
> +	 */
> +	if (mem_cgroup_have_hugetlb_usage(memcg))
> +		return -EBUSY;
>  



>  	return mem_cgroup_force_empty(memcg, false);
>  }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
