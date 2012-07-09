Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id AF9F66B005C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:01:24 -0400 (EDT)
Date: Mon, 9 Jul 2012 14:01:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcg: return -EBUSY when oom-kill-disable modified
 and memcg use_hierarchy, has children
Message-ID: <20120709120121.GB4627@tiehlicka.suse.cz>
References: <1341485708-14221-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341485708-14221-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 05-07-12 18:55:08, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> When oom-kill-disable modified by the user and current memcg use_hierarchy,
> the change can occur, provided the current memcg has no children. If it
> has children, return -EBUSY is enough.

I do not think EBUSY makes any difference. I would much rather see the
test go away...

> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/memcontrol.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 63e36e7..4b64fe0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4521,11 +4521,14 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  
>  	cgroup_lock();
>  	/* oom-kill-disable is a flag for subhierarchy. */
> -	if ((parent->use_hierarchy) ||
> -	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +	if (parent->use_hierarchy) {
>  		cgroup_unlock();
>  		return -EINVAL;
> +	} else if (memcg->use_hierarchy && !list_empty(&cgrp->children)) {
> +		cgroup_unlock();
> +		return -EBUSY;
>  	}
> +
>  	memcg->oom_kill_disable = val;
>  	if (!val)
>  		memcg_oom_recover(memcg);
> -- 
> 1.7.5.4
> 

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
