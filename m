Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5306B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 21:51:15 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so2613753pab.6
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 18:51:15 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id jd9si12843905pbd.114.2014.10.21.18.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 18:51:14 -0700 (PDT)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BCDAC3EE0BB
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:51:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id CBA79AC06F3
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:51:11 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6645E1DB803C
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:51:11 +0900 (JST)
Message-ID: <54470D61.7040803@jp.fujitsu.com>
Date: Wed, 22 Oct 2014 10:50:25 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/4] mm: memcontrol: remove unnecessary PCG_MEMSW memory+swap
 charge flag
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org> <1413818532-11042-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413818532-11042-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/10/21 0:22), Johannes Weiner wrote:
> Now that mem_cgroup_swapout() fully uncharges the page, every page
> that is still in use when reaching mem_cgroup_uncharge() is known to
> carry both the memory and the memory+swap charge.  Simplify the
> uncharge path and remove the PCG_MEMSW page flag accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   include/linux/page_cgroup.h |  1 -
>   mm/memcontrol.c             | 34 ++++++++++++----------------------
>   2 files changed, 12 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 5c831f1eca79..da62ee2be28b 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -5,7 +5,6 @@ enum {
>   	/* flags for mem_cgroup */
>   	PCG_USED = 0x01,	/* This page is charged to a memcg */
>   	PCG_MEM = 0x02,		/* This page holds a memory charge */
> -	PCG_MEMSW = 0x04,	/* This page holds a memory+swap charge */
>   };
>   
>   struct pglist_data;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7709f17347f3..9bab35fc3e9e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2606,7 +2606,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>   	 *   have the page locked
>   	 */
>   	pc->mem_cgroup = memcg;
> -	pc->flags = PCG_USED | PCG_MEM | (do_swap_account ? PCG_MEMSW : 0);
> +	pc->flags = PCG_USED | PCG_MEM;
>   
>   	if (lrucare)
>   		unlock_page_lru(page, isolated);
> @@ -5815,7 +5815,6 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>   	if (!PageCgroupUsed(pc))
>   		return;
>   
> -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
>   	memcg = pc->mem_cgroup;
>   
>   	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> @@ -6010,17 +6009,16 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
>   }
>   
>   static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
> -			   unsigned long nr_mem, unsigned long nr_memsw,
>   			   unsigned long nr_anon, unsigned long nr_file,
>   			   unsigned long nr_huge, struct page *dummy_page)
>   {
> +	unsigned long nr_pages = nr_anon + nr_file;
>   	unsigned long flags;
>   
>   	if (!mem_cgroup_is_root(memcg)) {
> -		if (nr_mem)
> -			page_counter_uncharge(&memcg->memory, nr_mem);
> -		if (nr_memsw)
> -			page_counter_uncharge(&memcg->memsw, nr_memsw);
> +		page_counter_uncharge(&memcg->memory, nr_pages);
> +		if (do_swap_account)
> +			page_counter_uncharge(&memcg->memsw, nr_pages);
>   		memcg_oom_recover(memcg);
>   	}
>   
> @@ -6029,23 +6027,21 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>   	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
>   	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
>   	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
> -	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
> +	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
>   	memcg_check_events(memcg, dummy_page);
>   	local_irq_restore(flags);
>   
>   	if (!mem_cgroup_is_root(memcg))
> -		css_put_many(&memcg->css, max(nr_mem, nr_memsw));
> +		css_put_many(&memcg->css, nr_pages);
>   }
>   
>   static void uncharge_list(struct list_head *page_list)
>   {
>   	struct mem_cgroup *memcg = NULL;
> -	unsigned long nr_memsw = 0;
>   	unsigned long nr_anon = 0;
>   	unsigned long nr_file = 0;
>   	unsigned long nr_huge = 0;
>   	unsigned long pgpgout = 0;
> -	unsigned long nr_mem = 0;
>   	struct list_head *next;
>   	struct page *page;
>   
> @@ -6072,10 +6068,9 @@ static void uncharge_list(struct list_head *page_list)
>   
>   		if (memcg != pc->mem_cgroup) {
>   			if (memcg) {
> -				uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
> -					       nr_anon, nr_file, nr_huge, page);
> -				pgpgout = nr_mem = nr_memsw = 0;
> -				nr_anon = nr_file = nr_huge = 0;
> +				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> +					       nr_huge, page);
> +				pgpgout = nr_anon = nr_file = nr_huge = 0;
>   			}
>   			memcg = pc->mem_cgroup;
>   		}
> @@ -6091,18 +6086,14 @@ static void uncharge_list(struct list_head *page_list)
>   		else
>   			nr_file += nr_pages;
>   
> -		if (pc->flags & PCG_MEM)
> -			nr_mem += nr_pages;
> -		if (pc->flags & PCG_MEMSW)
> -			nr_memsw += nr_pages;
>   		pc->flags = 0;
>   
>   		pgpgout++;
>   	} while (next != page_list);
>   
>   	if (memcg)
> -		uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
> -			       nr_anon, nr_file, nr_huge, page);
> +		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> +			       nr_huge, page);
>   }
>   
>   /**
> @@ -6187,7 +6178,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>   		return;
>   
>   	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> -	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
>   
>   	if (lrucare)
>   		lock_page_lru(oldpage, &isolated);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
