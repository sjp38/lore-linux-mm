Date: Mon, 30 Jun 2008 16:33:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
In-Reply-To: <20080627151906.31664.7247.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080627151906.31664.7247.sendpatchset@balbir-laptop>
Message-Id: <20080630161657.37E3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

this code survive stress testing?


> +		while (count-- &&
> +			((mem = heap_delete_max(&mem_cgroup_heap)) != NULL)) {
> +			BUG_ON(!mem->on_heap);
> +			spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
> +			nr_reclaimed += try_to_free_mem_cgroup_pages(mem,
> +								gfp_mask);
> +			cond_resched();
> +			spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
> +			mem->on_heap = 0;
> +			/*
> +			 * What should be the basis of breaking out?
> +			 */
> +			if (nr_reclaimed)
> +				goto done;

doubtful shortcut.
we shouldn't assume we need only one page.



>  #endif /* _LINUX_MEMCONTROL_H */
> diff -puN mm/vmscan.c~memory-controller-soft-limit-reclaim-on-contention mm/vmscan.c
> diff -puN mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention mm/page_alloc.c
> --- linux-2.6.26-rc5/mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
> +++ linux-2.6.26-rc5-balbir/mm/page_alloc.c	2008-06-27 20:43:10.000000000 +0530
> @@ -1669,7 +1669,14 @@ nofail_alloc:
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> +	/*
> +	 * First try to reclaim from memory control groups that have
> +	 * exceeded their soft limit
> +	 */
> +	did_some_progress = mem_cgroup_reclaim_on_contention(gfp_mask);
> +	if (!did_some_progress)
> +		did_some_progress = try_to_free_pages(zonelist, order,
> +							gfp_mask);

try_to_free_mem_cgroup_pages() assume memcg need only one page.
but this code break it.

if anyone need several continuous memory, mem_cgroup_reclaim_on_contention() reclaim 
one or a very few page and return >0, then cause page allocation failure.

shouldn't we extend try_to_free_mem_cgroup_pages() agruments?


in addition, if we don't assume try_to_free_mem_cgroup_pages() need one page,
we should implement lumpy reclaim to mem_cgroup_isolate_pages().
otherwise, cpu wasting significant increase.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
