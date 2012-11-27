Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id DB5ED6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 19:06:10 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 182F63EE0AE
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 09:06:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E0D5A45DE56
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 09:06:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5F2545DE4E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 09:06:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B61371DB8044
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 09:06:08 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64EB31DB803E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 09:06:08 +0900 (JST)
Message-ID: <50B403CA.501@jp.fujitsu.com>
Date: Tue, 27 Nov 2012 09:05:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from add_to_page_cache_locked
References: <20121122190526.390C7A28@pobox.sk> <20121122214249.GA20319@dhcp22.suse.cz> <20121122233434.3D5E35E6@pobox.sk> <20121123074023.GA24698@dhcp22.suse.cz> <20121123102137.10D6D653@pobox.sk> <20121123100438.GF24698@dhcp22.suse.cz> <20121125011047.7477BB5E@pobox.sk> <20121125120524.GB10623@dhcp22.suse.cz> <20121125135542.GE10623@dhcp22.suse.cz> <20121126013855.AF118F5E@pobox.sk> <20121126131837.GC17860@dhcp22.suse.cz>
In-Reply-To: <20121126131837.GC17860@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

(2012/11/26 22:18), Michal Hocko wrote:
> [CCing also Johannes - the thread started here:
> https://lkml.org/lkml/2012/11/21/497]
>
> On Mon 26-11-12 01:38:55, azurIt wrote:
>>> This is hackish but it should help you in this case. Kamezawa, what do
>>> you think about that? Should we generalize this and prepare something
>>> like mem_cgroup_cache_charge_locked which would add __GFP_NORETRY
>>> automatically and use the function whenever we are in a locked context?
>>> To be honest I do not like this very much but nothing more sensible
>>> (without touching non-memcg paths) comes to my mind.
>>
>>
>> I installed kernel with this patch, will report back if problem occurs
>> again OR in few weeks if everything will be ok. Thank you!
>
> Now that I am looking at the patch closer it will not work because it
> depends on other patch which is not merged yet and even that one would
> help on its own because __GFP_NORETRY doesn't break the charge loop.
> Sorry I have missed that...
>
> The patch bellow should help though. (it is based on top of the current
> -mm tree but I will send a backport to 3.2 in the reply as well)
> ---
>  From 7796f942d62081ad45726efd90b5292b80e7c690 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 26 Nov 2012 11:47:57 +0100
> Subject: [PATCH] memcg: do not trigger OOM from add_to_page_cache_locked
>
> memcg oom killer might deadlock if the process which falls down to
> mem_cgroup_handle_oom holds a lock which prevents other task to
> terminate because it is blocked on the very same lock.
> This can happen when a write system call needs to allocate a page but
> the allocation hits the memcg hard limit and there is nothing to reclaim
> (e.g. there is no swap or swap limit is hit as well and all cache pages
> have been reclaimed already) and the process selected by memcg OOM
> killer is blocked on i_mutex on the same inode (e.g. truncate it).
>
> Process A
> [<ffffffff811109b8>] do_truncate+0x58/0xa0		# takes i_mutex
> [<ffffffff81121c90>] do_last+0x250/0xa30
> [<ffffffff81122547>] path_openat+0xd7/0x440
> [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> [<ffffffff8110f950>] sys_open+0x20/0x30
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> Process B
> [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> [<ffffffff8111156a>] do_sync_write+0xea/0x130
> [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> [<ffffffff81112381>] sys_write+0x51/0x90
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> This is not a hard deadlock though because administrator can still
> intervene and increase the limit on the group which helps the writer to
> finish the allocation and release the lock.
>
> This patch heals the problem by forbidding OOM from page cache charges
> (namely add_ro_page_cache_locked). mem_cgroup_cache_charge_no_oom helper
> function is defined which adds GFP_MEMCG_NO_OOM to the gfp mask which
> then tells mem_cgroup_charge_common that OOM is not allowed for the
> charge. No OOM from this path, except for fixing the bug, also make some
> sense as we really do not want to cause an OOM because of a page cache
> usage.
> As a possibly visible result add_to_page_cache_lru might fail more often
> with ENOMEM but this is to be expected if the limit is set and it is
> preferable than OOM killer IMO.
>
> __GFP_NORETRY is abused for this memcg specific flag because it has been
> used to prevent from OOM already (since not-merged-yet "memcg: reclaim
> when more than one page needed"). The only difference is that the flag
> doesn't prevent from reclaim anymore which kind of makes sense because
> the global memory allocator triggers reclaim as well. The retry without
> any reclaim on __GFP_NORETRY doesn't make much sense anyway because this
> is effectively a busy loop with allowed OOM in this path.
>
> Reported-by: azurIt <azurit@pobox.sk>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

As a short term fix, I think this patch will work enough and seems simple enough.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reading discussion between you and Johannes, to release locks, I understand
the memcg need to return "RETRY" for a long term fix. Thinking a little,
it will be simple to return "RETRY" to all processes waited on oom kill queue
of a memcg and it can be done by a small fixes to memory.c.

Thank you.
-Kame

> ---
>   include/linux/gfp.h        |    3 +++
>   include/linux/memcontrol.h |   12 ++++++++++++
>   mm/filemap.c               |    8 +++++++-
>   mm/memcontrol.c            |    5 +----
>   4 files changed, 23 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 10e667f..aac9b21 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -152,6 +152,9 @@ struct vm_area_struct;
>   /* 4GB DMA on some platforms */
>   #define GFP_DMA32	__GFP_DMA32
>
> +/* memcg oom killer is not allowed */
> +#define GFP_MEMCG_NO_OOM	__GFP_NORETRY
> +
>   /* Convert GFP flags to their corresponding migrate type */
>   static inline int allocflags_to_migratetype(gfp_t gfp_flags)
>   {
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 095d2b4..1ad4bc6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -65,6 +65,12 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
>   extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>   					gfp_t gfp_mask);
>
> +static inline int mem_cgroup_cache_charge_no_oom(struct page *page,
> +					struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	return mem_cgroup_cache_charge(page, mm, gfp_mask | GFP_MEMCG_NO_OOM);
> +}
> +
>   struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>   struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
>
> @@ -215,6 +221,12 @@ static inline int mem_cgroup_cache_charge(struct page *page,
>   	return 0;
>   }
>
> +static inline int mem_cgroup_cache_charge_no_oom(struct page *page,
> +					struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	return 0;
> +}
> +
>   static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>   		struct page *page, gfp_t gfp_mask, struct mem_cgroup **memcgp)
>   {
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 83efee7..ef14351 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -447,7 +447,13 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
>   	VM_BUG_ON(!PageLocked(page));
>   	VM_BUG_ON(PageSwapBacked(page));
>
> -	error = mem_cgroup_cache_charge(page, current->mm,
> +	/*
> +	 * Cannot trigger OOM even if gfp_mask would allow that normally
> +	 * because we might be called from a locked context and that
> +	 * could lead to deadlocks if the killed process is waiting for
> +	 * the same lock.
> +	 */
> +	error = mem_cgroup_cache_charge_no_oom(page, current->mm,
>   					gfp_mask & GFP_RECLAIM_MASK);
>   	if (error)
>   		goto out;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 02ee2f7..b4754ba 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2430,9 +2430,6 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   	if (!(gfp_mask & __GFP_WAIT))
>   		return CHARGE_WOULDBLOCK;
>
> -	if (gfp_mask & __GFP_NORETRY)
> -		return CHARGE_NOMEM;
> -
>   	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>   	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>   		return CHARGE_RETRY;
> @@ -3713,7 +3710,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
>   {
>   	struct mem_cgroup *memcg = NULL;
>   	unsigned int nr_pages = 1;
> -	bool oom = true;
> +	bool oom = !(gfp_mask | GFP_MEMCG_NO_OOM);
>   	int ret;
>
>   	if (PageTransHuge(page)) {
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
