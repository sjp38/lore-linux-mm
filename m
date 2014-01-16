Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 76ED66B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 02:06:00 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so1049775bkb.12
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 23:05:59 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id kk9si4516369bkb.321.2014.01.15.23.05.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 23:05:59 -0800 (PST)
Date: Thu, 16 Jan 2014 02:05:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch -mm] mm, oom: prefer thread group leaders for display
 purposes
Message-ID: <20140116070549.GL6963@cmpxchg.org>
References: <alpine.DEB.2.02.1401151837560.1835@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401151837560.1835@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 15, 2014 at 06:40:41PM -0800, David Rientjes wrote:
> When two threads have the same badness score, it's preferable to kill the 
> thread group leader so that the actual process name is printed to the 
> kernel log rather than the thread group name which may be shared amongst 
> several processes.
> 
> This was the behavior when select_bad_process() used to do 
> for_each_process(), but it now iterates threads instead and leads to 
> ambiguity.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c | 18 +++++++++++-------
>  mm/oom_kill.c   | 12 ++++++++----
>  2 files changed, 19 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a815686..b482f49 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1841,13 +1841,17 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				break;
>  			};
>  			points = oom_badness(task, memcg, NULL, totalpages);
> -			if (points > chosen_points) {
> -				if (chosen)
> -					put_task_struct(chosen);
> -				chosen = task;
> -				chosen_points = points;
> -				get_task_struct(chosen);

Where did that GET go?

> -			}
> +			if (points < chosen_points)
> +				continue;
> +			/* Prefer thread group leaders for display purposes */
> +			if (points == chosen_points &&
> +			    thread_group_leader(chosen))
> +				continue;
> +
> +			if (chosen)
> +				put_task_struct(chosen);

...boom.

> +			chosen = task;
> +			chosen_points = points;
>  		}
>  		css_task_iter_end(&it);
>  	}
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 054ff47..1dca3d8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -327,10 +327,14 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			break;
>  		};
>  		points = oom_badness(p, NULL, nodemask, totalpages);
> -		if (points > chosen_points) {
> -			chosen = p;
> -			chosen_points = points;
> -		}
> +		if (points < chosen_points)
> +			continue;
> +		/* Prefer thread group leaders for display purposes */
> +		if (points == chosen_points && thread_group_leader(chosen))
> +			continue;
> +
> +		chosen = p;
> +		chosen_points = points;
>  	}
>  	if (chosen)
>  		get_task_struct(chosen);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
