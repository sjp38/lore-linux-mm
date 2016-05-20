Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0E86B0253
	for <linux-mm@kvack.org>; Fri, 20 May 2016 11:09:21 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m138so11659456lfm.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:09:21 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ib3si26213420wjb.118.2016.05.20.08.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 08:09:19 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q62so1780847wmg.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:09:19 -0700 (PDT)
Date: Fri, 20 May 2016 17:09:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: fix mem_cgroup_out_of_memory() return value.
Message-ID: <20160520150917.GC5215@dhcp22.suse.cz>
References: <1463753327-5170-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463753327-5170-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Fri 20-05-16 23:08:47, Tetsuo Handa wrote:
> mem_cgroup_out_of_memory() is returning "true" if it finds a TIF_MEMDIE
> task after an eligible task was found, "false" if it found a TIF_MEMDIE
> task before an eligible task is found.
> 
> This difference confuses memory_max_write() which checks the return value
> of mem_cgroup_out_of_memory(). Since memory_max_write() wants to continue
> looping, mem_cgroup_out_of_memory() should return "true" in this case.
> 
> This patch sets a dummy pointer in order to return "true".
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Fixes: b6e6edcfa405 ("mm: memcontrol: reclaim and OOM kill when
shrinking memory.max below usage")

But I do not think this is really worth backporting to stable tree (once
it is established).

> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b3f16ab..ab574d8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1302,6 +1302,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				mem_cgroup_iter_break(memcg, iter);
>  				if (chosen)
>  					put_task_struct(chosen);
> +				/* Set a dummy value to return "true". */
> +				chosen = (void *) 1;
>  				goto unlock;
>  			case OOM_SCAN_OK:
>  				break;
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
