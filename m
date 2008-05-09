Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m496MrXA022944
	for <linux-mm@kvack.org>; Fri, 9 May 2008 16:22:53 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m496RLph114818
	for <linux-mm@kvack.org>; Fri, 9 May 2008 16:27:21 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m496NHV0021537
	for <linux-mm@kvack.org>; Fri, 9 May 2008 16:23:18 +1000
Message-ID: <4823EDD0.2050009@linux.vnet.ibm.com>
Date: Fri, 09 May 2008 11:53:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: avoid unnecessary initialization
References: <20080509145941.f68e8f66.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080509145941.f68e8f66.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> An easy cut out from memcg: performance improvement patch set.
> Tested on: x86-64/linux-2.6.26-rc1-git6
> 
> Thanks,
> -Kame
> ==
> * remove over-killing initialization (in fast path)
> * makeing the condition for PAGE_CGROUP_FLAG_ACTIVE be more obvious.
> 
> Signed-off-by: KAMEAZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.26-rc1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.26-rc1.orig/mm/memcontrol.c
> +++ linux-2.6.26-rc1/mm/memcontrol.c
> @@ -296,7 +296,7 @@ static void __mem_cgroup_remove_list(str
>  		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
> 
>  	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
> -	list_del_init(&pc->lru);
> +	list_del(&pc->lru);
>  }
> 
>  static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
> @@ -559,7 +559,7 @@ retry:
>  	}
>  	unlock_page_cgroup(page);
> 
> -	pc = kmem_cache_zalloc(page_cgroup_cache, gfp_mask);
> +	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
>  	if (pc == NULL)
>  		goto err;
> 
> @@ -606,9 +606,14 @@ retry:
>  	pc->ref_cnt = 1;
>  	pc->mem_cgroup = mem;
>  	pc->page = page;
> -	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> +	/*
> +	 * If a page is accounted as a page cache, insert to inactive list.
> +	 * If anon, insert to active list.
> +	 */
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
>  		pc->flags = PAGE_CGROUP_FLAG_CACHE;
> +	else
> +		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> 
>  	lock_page_cgroup(page);
>  	if (page_get_page_cgroup(page)) {


Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>


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
