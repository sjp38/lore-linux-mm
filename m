Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BD8BE6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 02:18:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4E99E3EE0C0
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:18:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32C5745DE58
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:18:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01ED545DE50
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:18:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E67F91DB8043
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:18:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 901E71DB803B
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 15:18:04 +0900 (JST)
Message-ID: <4F827EAD.9080300@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 15:16:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 12/14] memcg: move HugeTLB resource count to parent
 cgroup on memcg removal
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/07 3:50), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This add support for memcg removal with HugeTLB resource usage.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


Hmm 


> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
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
> +#endif
> +
>  /* Should be called on processing a hugepagesz=... option */
>  void __init hugetlb_add_hstate(unsigned order)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7d3330e..7b6e79a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3228,9 +3228,11 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
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
>  		if ((res_counter_read_u64(&memcg->hugepage[idx], RES_USAGE)) > 0)
>  			return 1;
> @@ -3328,10 +3330,57 @@ void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
>  	res_counter_uncharge(&memcg->hugepage[idx], csize);
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


Ah, why is !mem_cgroup_is_root() checked ? no res_counter update for
root cgroup ?

I think it's better to have res_counter_move_parent()...to do ops in atomic.
(I'll post a patch for that for my purpose). OR, just ignore res->usage if
parent->use_hierarchy == 1.

uncharge->charge will have a race.

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


Just a notice. Recently, Tejun changed failure of pre_destory() to show WARNING.
Then, I'd like to move the usage to the root cgroup if use_hierarchy=0.
Will it work for you ?

> +	/*
> +	 * caller should have done css_get
> +	 */


Could you explain meaning of this comment ?


Thanks,
-Kame

> +	pc->mem_cgroup = parent;
> +err_out:
> +	unlock_page_cgroup(pc);
> +	put_page(page);
> +out:
> +	return ret;
>  }
>  #endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
>  
> @@ -3852,6 +3901,11 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
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
> @@ -5172,12 +5226,6 @@ free_out:
>  static int mem_cgroup_pre_destroy(struct cgroup *cont)
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
