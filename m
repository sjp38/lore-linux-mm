Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6C7FF6B004D
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 23:06:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 026BE3EE0BC
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:06:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCDE445DE55
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:06:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8690745DE53
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:06:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 79FCA1DB8040
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:06:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E2621DB803B
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:06:37 +0900 (JST)
Message-ID: <4F66A258.5060301@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 12:04:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 09/10] memcg: move HugeTLB resource count to parent
 cgroup on memcg removal
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331919570-2264-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/03/17 2:39), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add support for memcg removal with HugeTLB resource usage.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


seems ok for now.

Now, Tejun and Costa, and I are discussing removeing -EBUSY from rmdir().
We're now considering 'if use_hierarchy=false and parent seems full, 
reclaim all or move charges to the root cgroup.' then -EBUSY will go away.

Is it accesptable for hugetlb ? Do you have another idea ?

Thanks,
-Kame 


> ---
>  include/linux/hugetlb.h    |    6 ++++
>  include/linux/memcontrol.h |   15 +++++++++-
>  mm/hugetlb.c               |   41 ++++++++++++++++++++++++++
>  mm/memcontrol.c            |   68 +++++++++++++++++++++++++++++++++++++------
>  4 files changed, 119 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6919100..32e948c 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -349,11 +349,17 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
>  #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
>  extern int register_hugetlb_memcg_files(struct cgroup *cgroup,
>  					struct cgroup_subsys *ss);
> +extern int hugetlb_force_memcg_empty(struct cgroup *cgroup);
>  #else
>  static inline int register_hugetlb_memcg_files(struct cgroup *cgroup,
>  					       struct cgroup_subsys *ss)
>  {
>  	return 0;
>  }
> +
> +static inline int hugetlb_force_memcg_empty(struct cgroup *cgroup)
> +{
> +	return 0;
> +}
>  #endif
>  #endif /* _LINUX_HUGETLB_H */
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 73900b9..0980122 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -441,7 +441,9 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
>  extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  					      struct mem_cgroup *memcg);
>  extern int mem_cgroup_hugetlb_file_init(int idx);
> -
> +extern int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
> +					  struct page *page);
> +extern bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup);
>  #else
>  static inline int
>  mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> @@ -477,6 +479,17 @@ static inline int mem_cgroup_hugetlb_file_init(int idx)
>  	return 0;
>  }
>  
> +static inline int
> +mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
> +			       struct page *page)
> +{
> +	return 0;
> +}
> +
> +static inline bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
> +{
> +	return 0;
> +}
>  #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  #endif /* _LINUX_MEMCONTROL_H */
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8fd465d..685f0d5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1842,6 +1842,47 @@ int register_hugetlb_memcg_files(struct cgroup *cgroup,
>  	}
>  	return ret;
>  }
> +
> +/*
> + * Force the memcg to empty the hugetlb resources by moving them to
> + * the parent cgroup. We can fail if the parent cgroup's limit prevented
> + * the charging. This should only happen if use_hierarchy is not set.
> + */
> +int hugetlb_force_memcg_empty(struct cgroup *cgroup)
> +{
> +	struct hstate *h;
> +	struct page *page;
> +	int ret = 0, idx = 0;
> +
> +	do {
> +		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
> +			goto out;
> +		/*
> +		 * If the task doing the cgroup_rmdir got a signal
> +		 * we don't really need to loop till the hugetlb resource
> +		 * usage become zero.
> +		 */
> +		if (signal_pending(current)) {
> +			ret = -EINTR;
> +			goto out;
> +		}
> +		for_each_hstate(h) {
> +			spin_lock(&hugetlb_lock);
> +			list_for_each_entry(page, &h->hugepage_activelist, lru) {
> +				ret = mem_cgroup_move_hugetlb_parent(idx, cgroup, page);
> +				if (ret) {
> +					spin_unlock(&hugetlb_lock);
> +					goto out;
> +				}
> +			}
> +			spin_unlock(&hugetlb_lock);
> +			idx++;
> +		}
> +		cond_resched();
> +	} while (mem_cgroup_have_hugetlb_usage(cgroup));
> +out:
> +	return ret;
> +}
>  #endif
>  
>  /* Should be called on processing a hugepagesz=... option */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4900b72..e29d86d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3171,9 +3171,11 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  #endif
>  
>  #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> -static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
>  {
>  	int idx;
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
> +
>  	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
>  		if (memcg->hugepage[idx].usage > 0)
>  			return 1;
> @@ -3285,10 +3287,57 @@ void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  		res_counter_uncharge(&memcg->hugepage[idx], csize);
>  	return;
>  }
> -#else
> -static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> +
> +int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
> +				   struct page *page)
>  {
> -	return 0;
> +	struct page_cgroup *pc;
> +	int csize,  ret = 0;
> +	struct res_counter *fail_res;
> +	struct cgroup *pcgrp = cgroup->parent;
> +	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
> +	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
> +
> +	if (!get_page_unless_zero(page))
> +		goto out;
> +
> +	pc = lookup_page_cgroup(page);
> +	lock_page_cgroup(pc);
> +	if (!PageCgroupUsed(pc) || pc->mem_cgroup != memcg)
> +		goto err_out;
> +
> +	csize = PAGE_SIZE << compound_order(page);
> +	/*
> +	 * uncharge from child and charge the parent. If we have
> +	 * use_hierarchy set, we can never fail here. In-order to make
> +	 * sure we don't get -ENOMEM on parent charge, we first uncharge
> +	 * the child and then charge the parent.
> +	 */
> +	if (parent->use_hierarchy) {
> +		res_counter_uncharge(&memcg->hugepage[idx], csize);
> +		if (!mem_cgroup_is_root(parent))
> +			ret = res_counter_charge(&parent->hugepage[idx],
> +						 csize, &fail_res);
> +	} else {
> +		if (!mem_cgroup_is_root(parent)) {
> +			ret = res_counter_charge(&parent->hugepage[idx],
> +						 csize, &fail_res);
> +			if (ret) {
> +				ret = -EBUSY;
> +				goto err_out;
> +			}
> +		}
> +		res_counter_uncharge(&memcg->hugepage[idx], csize);
> +	}
> +	/*
> +	 * caller should have done css_get
> +	 */
> +	pc->mem_cgroup = parent;
> +err_out:
> +	unlock_page_cgroup(pc);
> +	put_page(page);
> +out:
> +	return ret;
>  }
>  #endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  
> @@ -3806,6 +3855,11 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>  	/* should free all ? */
>  	if (free_all)
>  		goto try_to_free;
> +
> +	/* move the hugetlb charges */
> +	ret = hugetlb_force_memcg_empty(cgrp);
> +	if (ret)
> +		goto out;
>  move_account:
>  	do {
>  		ret = -EBUSY;
> @@ -5103,12 +5157,6 @@ static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
>  					struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> -	/*
> -	 * Don't allow memcg removal if we have HugeTLB resource
> -	 * usage.
> -	 */
> -	if (mem_cgroup_have_hugetlb_usage(memcg))
> -		return -EBUSY;
>  
>  	return mem_cgroup_force_empty(memcg, false);
>  }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
