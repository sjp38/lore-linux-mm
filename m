Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 542766B0089
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 02:27:45 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so6065082wes.7
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 23:27:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hv4si96732wib.3.2014.06.02.23.27.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 23:27:43 -0700 (PDT)
Date: Tue, 3 Jun 2014 08:27:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] mm, memcg: periodically schedule when emptying page
 list
Message-ID: <20140603062742.GA1321@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1406021749590.13910@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406021749590.13910@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 02-06-14 17:51:25, David Rientjes wrote:
> From: Hugh Dickins <hughd@google.com>
> 
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
> If this iteration is taking too long, we still need to do cond_resched() even 
> when an individual page is not busy.
> 
> [rientjes@google.com: changelog]
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  v2: always reschedule if needed, "page" itself may not have a pc mismatch
>      or been unable to isolate.
> 
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4784,9 +4784,9 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  		if (mem_cgroup_move_parent(page, pc, memcg)) {
>  			/* found lock contention or "pc" is obsolete. */
>  			busy = page;
> -			cond_resched();
>  		} else
>  			busy = NULL;
> +		cond_resched();
>  	} while (!list_empty(list));
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
