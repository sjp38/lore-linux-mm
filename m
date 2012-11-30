Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B88746B00BB
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:19:27 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so522096pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:19:27 -0800 (PST)
Date: Fri, 30 Nov 2012 07:19:22 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/4] memcg: prevent changes to move_charge_at_immigrate
 during task attach
Message-ID: <20121130151922.GC3873@htj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354282286-32278-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hello, Glauber.

On Fri, Nov 30, 2012 at 05:31:24PM +0400, Glauber Costa wrote:
> ---
>  mm/memcontrol.c | 64 +++++++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 51 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index feba87d..d80b6b5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -311,7 +311,13 @@ struct mem_cgroup {
>  	 * Should we move charges of a task when a task is moved into this
>  	 * mem_cgroup ? And what type of charges should we move ?
>  	 */
> -	unsigned long 	move_charge_at_immigrate;
> +	unsigned long	move_charge_at_immigrate;
> +        /*

Weird indentation (maybe spaces instead of a tab?)

> +	 * Tasks are being attached to this memcg.  Used mostly to prevent
> +	 * changes to move_charge_at_immigrate
> +	 */
> +        int attach_in_progress;

Ditto.

>  	/*
>  	 * set > 0 if pages under this cgroup are moving to other cgroup.
>  	 */
> @@ -4114,6 +4120,7 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  					struct cftype *cft, u64 val)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	int ret = -EAGAIN;
>  
>  	if (val >= (1 << NR_MOVE_TYPE))
>  		return -EINVAL;
> @@ -4123,10 +4130,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  	 * inconsistent.
>  	 */
>  	cgroup_lock();
> +	if (memcg->attach_in_progress)
> +		goto out;
>  	memcg->move_charge_at_immigrate = val;
> +	ret = 0;
> +out:
>  	cgroup_unlock();
> -
> -	return 0;
> +	return ret;

Unsure whether this is a good behavior.  It's a bit nasty to fail for
internal temporary reasons like this.  If it ever causes a problem,
the occurrences are likely to be far and between making it difficult
to debug.  Can't you determine to immigrate or not in ->can_attach(),
record whether to do that or not on the css, and finish it in
->attach() according to that.  There's no need to consult the config
multiple times.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
