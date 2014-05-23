Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 946466B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 09:20:47 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so3590360eek.15
        for <linux-mm@kvack.org>; Fri, 23 May 2014 06:20:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z47si6750760eel.67.2014.05.23.06.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 06:20:45 -0700 (PDT)
Date: Fri, 23 May 2014 15:20:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/9] mm: memcontrol: remove ordering between
 pc->mem_cgroup and PageCgroupUsed
Message-ID: <20140523132043.GB22135@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:40, Johannes Weiner wrote:
> There is a write barrier between setting pc->mem_cgroup and
> PageCgroupUsed, which was added to allow LRU operations to lookup the
> memcg LRU list of a page without acquiring the page_cgroup lock.  But
> ever since 38c5d72f3ebe ("memcg: simplify LRU handling by new rule"),
> pages are ensured to be off-LRU while charging, so nobody else is
> changing LRU state while pc->mem_cgroup is being written.

This is quite confusing. Why do we have the lrucare path then?
The code is quite tricky so this deserves a more detailed explanation
IMO.

There are only 3 paths which check both the flag and mem_cgroup (
without page_cgroup_lock) get_mctgt_type* and mem_cgroup_page_lruvec AFAICS.
None of them have rmb so there was no guarantee about ordering anyway.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Anyway, the change is welcome
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 34407d99262a..c528ae9ac230 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2823,14 +2823,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  	}
>  
>  	pc->mem_cgroup = memcg;
> -	/*
> -	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> -	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
> -	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
> -	 * before USED bit, we need memory barrier here.
> -	 * See mem_cgroup_add_lru_list(), etc.
> -	 */
> -	smp_wmb();
>  	SetPageCgroupUsed(pc);
>  
>  	if (lrucare) {
> @@ -3609,7 +3601,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  	for (i = 1; i < HPAGE_PMD_NR; i++) {
>  		pc = head_pc + i;
>  		pc->mem_cgroup = memcg;
> -		smp_wmb();/* see __commit_charge() */
>  		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
>  	}
>  	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
> -- 
> 1.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
