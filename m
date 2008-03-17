Message-ID: <47DDD6E6.8010306@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 11:26:46 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] charge/uncharge
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Because bit spin lock is removed and spinlock is added to page_cgroup.
> There are some amount of changes.
> 
> This patch does
> 	- modify charge/uncharge to adjust it to the new lock.
> 	- Added simple lock rule comments.
> 
> Major changes from current(-mm) version is
> 	- pc->refcnt is set as "1" after the charge is done.
> 
> Changelog
>   - Rebased to rc5-mm1
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
>  mm/memcontrol.c |  136 +++++++++++++++++++++++++-------------------------------
>  1 file changed, 62 insertions(+), 74 deletions(-)
> 
> Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> @@ -34,6 +34,16 @@
>  
>  #include <asm/uaccess.h>
>  
> +/*
> + * Lock Rule
> + * zone->lru_lcok (global LRU)
> + *	-> pc->lock (page_cgroup's lock)
> + *		-> mz->lru_lock (mem_cgroup's per_zone lock.)
> + *
> + * At least, mz->lru_lock and pc->lock should be acquired irq off.
> + *
> + */
> +
>  struct cgroup_subsys mem_cgroup_subsys;
>  static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
>  
> @@ -479,33 +489,22 @@ static int mem_cgroup_charge_common(stru
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
>  
> +	pc = get_page_cgroup(page, gfp_mask, true);
> +	if (!pc || IS_ERR(pc))
> +		return PTR_ERR(pc);
> +

If get_page_cgroup() returns NULL, you will end up return *sucesss* by
returning PTR_ERR(pc)

> +	spin_lock_irqsave(&pc->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
