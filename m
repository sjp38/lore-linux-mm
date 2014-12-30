Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 154306B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 09:22:06 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so1079684wes.30
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:22:05 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com. [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id bk1si78989830wjb.171.2014.12.30.06.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 06:22:05 -0800 (PST)
Received: by mail-we0-f173.google.com with SMTP id q58so1092354wes.18
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:22:05 -0800 (PST)
Date: Tue, 30 Dec 2014 15:22:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix destination cgroup leak on task charges
 migration
Message-ID: <20141230142202.GC15546@dhcp22.suse.cz>
References: <1419868483-30612-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419868483-30612-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-12-14 18:54:43, Vladimir Davydov wrote:
> We are supposed to take one css reference per each memory page and per
> each swap entry accounted to a memory cgroup. However, during task
> charges migration we take a reference to the destination cgroup twice
> per each swap entry: first in mem_cgroup_do_precharge()->try_charge()
> and then in mem_cgroup_move_swap_account(), permanently leaking the
> destination cgroup.

Very well spotted!

> The hunk taking the second reference seems to be a leftover from the
> pre-00501b531c472 ("mm: memcontrol: rewrite charge API") era. Remove it
> to fix the leak.

This seems to be a fallout from e8ea14cc6ead (mm: memcontrol: take a
css reference for each charged page) because we only took per-charge
reference for swapped out pages before. In order to keep the balance
correct we had to do that ugly css_get() in mem_cgroup_move_swap_account
and uncharge the origin later on in __mem_cgroup_clear_mc.

The uncharge part for the from memcg should be OK because we do so from
the page counter directly and that doesn't involve reference counting
and then we do css_put_many explicitly.

So unless I have missed something the culrpit is different and so it
doesn't have to go to stable just should appear in a later 3.19 rc.

Fixes: e8ea14cc6ead (mm: memcontrol: take a css reference for each charged page)
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ef91e856c7e4..d62c335dfef4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3043,18 +3043,6 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
>  		mem_cgroup_swap_statistics(from, false);
>  		mem_cgroup_swap_statistics(to, true);
> -		/*
> -		 * This function is only called from task migration context now.
> -		 * It postpones page_counter and refcount handling till the end
> -		 * of task migration(mem_cgroup_clear_mc()) for performance
> -		 * improvement. But we cannot postpone css_get(to)  because if
> -		 * the process that has been moved to @to does swap-in, the
> -		 * refcount of @to might be decreased to 0.
> -		 *
> -		 * We are in attach() phase, so the cgroup is guaranteed to be
> -		 * alive, so we can just call css_get().
> -		 */
> -		css_get(&to->css);
>  		return 0;
>  	}
>  	return -EINVAL;
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
