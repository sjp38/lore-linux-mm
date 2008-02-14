Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
In-Reply-To: Your message of "Wed, 13 Feb 2008 20:42:42 +0530"
	<20080213151242.7529.79924.sendpatchset@localhost.localdomain>
References: <20080213151242.7529.79924.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080214102758.D2CD91E3C58@siro.lan>
Date: Thu, 14 Feb 2008 19:27:58 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, hugh@veritas.com, a.p.zijlstra@chello.nl, menage@google.com, Lee.Schermerhorn@hp.com, herbert@13thfloor.at, ebiederm@xmission.com, rientjes@google.com, xemul@openvz.org, nickpiggin@yahoo.com.au, riel@redhat.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> +/*
> + * Free all control groups, which are over their soft limit
> + */
> +unsigned long mem_cgroup_pushback_groups_over_soft_limit(struct zone **zones,
> +								gfp_t gfp_mask)
> +{
> +	struct mem_cgroup *mem;
> +	unsigned long nr_pages;
> +	long long nr_bytes_over_sl;
> +	unsigned long ret = 0;
> +	unsigned long flags;
> +	struct list_head reclaimed_groups;
>  
> +	INIT_LIST_HEAD(&reclaimed_groups);
> +	read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
> +	while (!list_empty(&mem_cgroup_sl_exceeded_list)) {
> +		mem = list_first_entry(&mem_cgroup_sl_exceeded_list,
> +				struct mem_cgroup, sl_exceeded_list);
> +		list_move(&mem->sl_exceeded_list, &reclaimed_groups);
> +		read_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
> +
> +		nr_bytes_over_sl = res_counter_sl_excess(&mem->res);
> +		if (nr_bytes_over_sl <= 0)
> +			goto next;
> +		nr_pages = (nr_bytes_over_sl >> PAGE_SHIFT);
> +		ret += try_to_free_mem_cgroup_pages(mem, gfp_mask, nr_pages,
> +							zones);
> +next:
> +		read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
> +	}

what prevents the cgroup 'mem' from disappearing while we are dropping
mem_cgroup_sl_list_lock?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
