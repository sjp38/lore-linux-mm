Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id DDDD86B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 04:06:07 -0400 (EDT)
Date: Mon, 16 Jul 2012 10:06:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm] mm, oom: reduce dependency on tasklist_lock: fix
Message-ID: <20120716080603.GA14664@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com>
 <20120713143206.GA4511@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207160039120.3936@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207160039120.3936@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 16-07-12 00:42:37, Hugh Dickins wrote:
> Slab poisoning gave me a General Protection Fault on the
> 	atomic_dec(&__task_cred(p)->user->processes);
> line of release_task() called from wait_task_zombie(),
> every time my dd to USB testing generated a memcg OOM.

Just curious, was it with the wait-on-pagereclaim patch?

> oom_kill_process() now does the put_task_struct(),
> mem_cgroup_out_of_memory() should not repeat it.

Good catch. I have missed that during review - my bad...

> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/memcontrol.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- mmotm/mm/memcontrol.c	2012-07-11 14:50:29.808349013 -0700
> +++ linux/mm/memcontrol.c	2012-07-15 12:21:26.234289161 -0700
> @@ -1533,7 +1533,6 @@ void mem_cgroup_out_of_memory(struct mem
>  	points = chosen_points * 1000 / totalpages;
>  	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
>  			 NULL, "Memory cgroup out of memory");
> -	put_task_struct(chosen);
>  }
>  
>  static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
