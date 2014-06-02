Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 314FF6B009E
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:46:27 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so4714314pbb.17
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:46:26 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id xb6si17958090pab.45.2014.06.02.16.46.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 16:46:26 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so4409078pad.39
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:46:25 -0700 (PDT)
Date: Mon, 2 Jun 2014 16:44:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, memcg: periodically schedule when emptying page
 list
In-Reply-To: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1406021637170.5627@eggly.anvils>
References: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 2 Jun 2014, David Rientjes wrote:

> mem_cgroup_force_empty_list() can iterate a large number of pages on an lru and 
> mem_cgroup_move_parent() doesn't return an errno unless certain criteria, none 
> of which indicate that the iteration may be taking too long, is met.
> 
> We have encountered the following stack trace many times indicating
> "need_resched set for > 51000020 ns (51 ticks) without schedule", for example:
> 
> 	scheduler_tick()
> 	<timer irq>
> 	mem_cgroup_move_account+0x4d/0x1d5
> 	mem_cgroup_move_parent+0x8d/0x109
> 	mem_cgroup_reparent_charges+0x149/0x2ba
> 	mem_cgroup_css_offline+0xeb/0x11b
> 	cgroup_offline_fn+0x68/0x16b
> 	process_one_work+0x129/0x350
> 
> If this iteration is taking too long, indicated by need_resched(), then 
> periodically schedule and continue from where we last left off.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4764,6 +4764,7 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  	do {
>  		struct page_cgroup *pc;
>  		struct page *page;
> +		int ret;
>  
>  		spin_lock_irqsave(&zone->lru_lock, flags);
>  		if (list_empty(list)) {
> @@ -4781,8 +4782,13 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  
>  		pc = lookup_page_cgroup(page);
>  
> -		if (mem_cgroup_move_parent(page, pc, memcg)) {
> -			/* found lock contention or "pc" is obsolete. */
> +		ret = mem_cgroup_move_parent(page, pc, memcg);
> +		if (ret || need_resched()) {
> +			/*
> +			 * Couldn't grab the page reference, isolate the page,
> +			 * there was a pc mismatch, or we simply need to
> +			 * schedule because this is taking too long.
> +			 */
>  			busy = page;
>  			cond_resched();
>  		} else

Why not just move that cond_resched() down below the if/else?
No need to test need_resched() separately, and this page is not busy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
