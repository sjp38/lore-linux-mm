Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0666B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 09:46:37 -0400 (EDT)
Date: Tue, 23 Aug 2011 15:46:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110823134630.GB9837@tiehlicka.suse.cz>
References: <20110823073101.6426.77745.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823073101.6426.77745.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On Tue 23-08-11 11:31:01, Konstantin Khlebnikov wrote:
> All frozen tasks are unkillable, and if one of them has TIF_MEMDIE
> we must kill something else to avoid deadlock.

This is a livelock rather than a deadlock, isn't it? We are picking the
same process all the time and cannot do any progress.

> After this patch select_bad_process() will skip frozen task before
> checking TIF_MEMDIE.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Anyway the patch looks good to me.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 626303b..931ab20 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -138,6 +138,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>  		return true;
>  	if (p->flags & PF_KTHREAD)
>  		return true;
> +	if (p->flags & PF_FROZEN)
> +		return true;
>  
>  	/* When mem_cgroup_out_of_memory() and p is not member of the group */
>  	if (mem && !task_in_mem_cgroup(p, mem))
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
