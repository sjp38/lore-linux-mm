Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1F5E6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:17:17 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so2772357wjc.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 02:17:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si1466514wmd.35.2017.01.12.02.17.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 02:17:16 -0800 (PST)
Date: Thu, 12 Jan 2017 11:17:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, memcg: do not retry precharge charges
Message-ID: <20170112101712.GH2264@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 11-01-17 20:32:12, David Rientjes wrote:
[...]
> This also restructures mem_cgroup_wait_acct_move() since it is not
> possible for mc.moving_task to be current.

thinking about this some more, I do not think this is the right way to
go. It is true that we will not reach mem_cgroup_wait_acct_move if all
the charges from the task moving code path are __GFP_NORETRY but that
is quite subtle requirement IMHO.

> Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c | 32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1125,18 +1125,19 @@ static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
>  
>  static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>  {
> -	if (mc.moving_task && current != mc.moving_task) {
> -		if (mem_cgroup_under_move(memcg)) {
> -			DEFINE_WAIT(wait);
> -			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> -			/* moving charge context might have finished. */
> -			if (mc.moving_task)
> -				schedule();
> -			finish_wait(&mc.waitq, &wait);
> -			return true;
> -		}
> +	DEFINE_WAIT(wait);
> +
> +	if (likely(!mem_cgroup_under_move(memcg)))
> +		return false;
> +
> +	prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> +	/* moving charge context might have finished. */
> +	if (mc.moving_task) {
> +		WARN_ON_ONCE(mc.moving_task == current);
> +		schedule();
>  	}
> -	return false;
> +	finish_wait(&mc.waitq, &wait);
> +	return true;
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
