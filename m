Date: Wed, 20 Feb 2008 15:50:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080220.152753.98212356.taka@valinux.co.jp>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<20080220.152753.98212356.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: hugh@veritas.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:27:53 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> > Unlike the unsafeties of force_empty, this is liable to hit anyone
> > running with MEM_CONT compiled in, they don't have to be consciously
> > using mem_cgroups at all.
> 
> As for force_empty, though this may not be the main topic here,
> mem_cgroup_force_empty_list() can be implemented simpler.
> It is possible to make the function just call mem_cgroup_uncharge_page()
> instead of releasing page_cgroups by itself. The tips is to call get_page()
> before invoking mem_cgroup_uncharge_page() so the page won't be released
> during this function.
> 
> Kamezawa-san, you may want look into the attached patch.
> I think you will be free from the weired complexity here.
> 
> This code can be optimized but it will be enough since this function
> isn't critical.
> 
> Thanks.
> 
> 
> Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>
> 
> --- mm/memcontrol.c.ORG	2008-02-12 18:44:45.000000000 +0900
> +++ mm/memcontrol.c 2008-02-20 14:23:38.000000000 +0900
> @@ -837,7 +837,7 @@ mem_cgroup_force_empty_list(struct mem_c
>  {
>  	struct page_cgroup *pc;
>  	struct page *page;
> -	int count;
> +	int count = FORCE_UNCHARGE_BATCH;
>  	unsigned long flags;
>  	struct list_head *list;
>  
> @@ -846,30 +846,21 @@ mem_cgroup_force_empty_list(struct mem_c
>  	else
>  		list = &mz->inactive_list;
>  
> -	if (list_empty(list))
> -		return;
> -retry:
> -	count = FORCE_UNCHARGE_BATCH;
>  	spin_lock_irqsave(&mz->lru_lock, flags);
> -
> -	while (--count && !list_empty(list)) {
> +	while (!list_empty(list)) {
>  		pc = list_entry(list->prev, struct page_cgroup, lru);
>  		page = pc->page;
> -		/* Avoid race with charge */
> -		atomic_set(&pc->ref_cnt, 0);
> -		if (clear_page_cgroup(page, pc) == pc) {
> -			css_put(&mem->css);
> -			res_counter_uncharge(&mem->res, PAGE_SIZE);
> -			__mem_cgroup_remove_list(pc);
> -			kfree(pc);
> -		} else 	/* being uncharged ? ...do relax */
> -			break;
> +		get_page(page);
> +		spin_unlock_irqrestore(&mz->lru_lock, flags);
> +		mem_cgroup_uncharge_page(page);
> +		put_page(page);
> +		if (--count <= 0) {
> +			count = FORCE_UNCHARGE_BATCH;
> +			cond_resched();
> +		}
> +		spin_lock_irqsave(&mz->lru_lock, flags);
>  	}
Seems simple. But isn't there following case ?

==in force_empty==

pc1 = list_entry(list->prev, struct page_cgroup, lru);
page = pc1->page;
get_page(page)
spin_unlock_irqrestore(&mz->lru_lock, flags)
mem_cgroup_uncharge_page(page);
	=> lock_page_cgroup(page);
		=> pc2 = page_get_page_cgroup(page);

Here, pc2 != pc1 and pc2->mem_cgroup != pc1->mem_cgroup.
maybe need some check.

But maybe yours is good direction.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
