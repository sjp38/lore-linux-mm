Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5CA16B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:40:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so13405128wme.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:40:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o94si10378529wrc.320.2017.01.13.00.40.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 00:40:16 -0800 (PST)
Date: Fri, 13 Jan 2017 09:40:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, memcg: do not retry precharge charges
Message-ID: <20170113084014.GB25212@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701121446130.12738@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 12-01-17 14:46:34, David Rientjes wrote:
> When memory.move_charge_at_immigrate is enabled and precharges are
> depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
> increase the size of the precharge.
> 
> This can be allowed to do reclaim, but should not call the oom killer to
> oom kill a process.  It's better to fail the attach rather than oom kill
> a process attached to the memcg hierarchy.

This is not the case though since 3812c8c8f395 ("mm: memcg: do not trap
chargers with full callstack on OOM") - 3.12. Only the page fault path
is allowed to trigger the oom killer. 

> Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
> probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
> pointless as written.
> 
> Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
> Signed-off-by: David Rientjes <rientjes@google.com>

Without the note about the oom killer you can add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4353,9 +4353,12 @@ static int mem_cgroup_do_precharge(unsigned long count)
>  		return ret;
>  	}
>  
> -	/* Try charges one by one with reclaim */
> +	/*
> +	 * Try charges one by one with reclaim, but do not retry.  This avoids
> +	 * calling the oom killer when the precharge should just fail.
> +	 */
>  	while (count--) {
> -		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
> +		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
>  		if (ret)
>  			return ret;
>  		mc.precharge++;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
