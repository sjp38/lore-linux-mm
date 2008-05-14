Message-ID: <482A9FB5.4020202@cn.fujitsu.com>
Date: Wed, 14 May 2008 16:15:49 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 4/6] memcg: shmem reclaim helper
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com> <20080514171025.2f0fb1ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080514171025.2f0fb1ca.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> A new call, mem_cgroup_shrink_usage() is added for shmem handling
> and removing not usual usage of mem_cgroup_charge/uncharge.
> 
> Now, shmem calls mem_cgroup_charge() just for reclaim some pages from
> mem_cgroup. In general, shmem is used by some process group and not for
> global resource (like file caches). So, it's reasonable to reclaim pages from
> mem_cgroup where shmem is mainly used.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> Index: linux-2.6.26-rc2/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.26-rc2.orig/mm/memcontrol.c
> +++ linux-2.6.26-rc2/mm/memcontrol.c
> @@ -783,6 +783,30 @@ static void mem_cgroup_drop_all_pages(st
>  }
>  
>  /*
> + * A call to try to shrink memory usage under specified resource controller.
> + * This is typically used for page reclaiming for shmem for reducing side
> + * effect of page allocation from shmem, which is used by some mem_cgroup.
> + */
> +int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	struct mem_cgroup *mem;
> +	int progress = 0;
> +	int retry = MEM_CGROUP_RECLAIM_RETRIES;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	css_get(&mem->css);
> +	rcu_read_unlock();
> +
> +	while(!progress && --retry) {
> +		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
> +	}

This is wrong. How about:
	do {
		...
	} while (!progress && --retry);

> +	if (!retry)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +/*
>   * This routine traverse page_cgroup in given list and drop them all.
>   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
>   */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
