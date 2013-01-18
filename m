Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A73886B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 09:16:42 -0500 (EST)
Date: Fri, 18 Jan 2013 15:16:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 1/7] memcg: prevent changes to
 move_charge_at_immigrate during task attach
Message-ID: <20130118141637.GE10701@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357897527-15479-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri 11-01-13 13:45:21, Glauber Costa wrote:
> Currently, we rely on the cgroup_lock() to prevent changes to
> move_charge_at_immigrate during task migration. However, this is only
> needed because the current strategy keeps checking this value throughout
> the whole process. Since all we need is serialization, one needs only to
> guarantee that whatever decision we made in the beginning of a specific
> migration is respected throughout the process.
> 
> We can achieve this by just saving it in mc. By doing this, no kind of
> locking is needed.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

I would probably prefer to use a different name so that we know that
move_charge_at_immigrate is a property of the cgroup while the other
immigrate_flags (or whatever) is a temporal state when greping the code.
But nothing serious.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 26 +++++++++++++++++---------
>  1 file changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 09255ec..18f4e76 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -412,6 +412,7 @@ static struct move_charge_struct {
>  	spinlock_t	  lock; /* for from, to */
>  	struct mem_cgroup *from;
>  	struct mem_cgroup *to;
> +	unsigned long move_charge_at_immigrate;
>  	unsigned long precharge;
>  	unsigned long moved_charge;
>  	unsigned long moved_swap;
> @@ -425,13 +426,13 @@ static struct move_charge_struct {
>  static bool move_anon(void)
>  {
>  	return test_bit(MOVE_CHARGE_TYPE_ANON,
> -					&mc.to->move_charge_at_immigrate);
> +					&mc.move_charge_at_immigrate);
>  }
>  
>  static bool move_file(void)
>  {
>  	return test_bit(MOVE_CHARGE_TYPE_FILE,
> -					&mc.to->move_charge_at_immigrate);
> +					&mc.move_charge_at_immigrate);
>  }
>  
>  /*
> @@ -5146,15 +5147,14 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
>  
>  	if (val >= (1 << NR_MOVE_TYPE))
>  		return -EINVAL;
> +
>  	/*
> -	 * We check this value several times in both in can_attach() and
> -	 * attach(), so we need cgroup lock to prevent this value from being
> -	 * inconsistent.
> +	 * No kind of locking is needed in here, because ->can_attach() will
> +	 * check this value once in the beginning of the process, and then carry
> +	 * on with stale data. This means that changes to this value will only
> +	 * affect task migrations starting after the change.
>  	 */
> -	cgroup_lock();
>  	memcg->move_charge_at_immigrate = val;
> -	cgroup_unlock();
> -
>  	return 0;
>  }
>  #else
> @@ -6530,8 +6530,15 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
>  	struct task_struct *p = cgroup_taskset_first(tset);
>  	int ret = 0;
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
> +	unsigned long move_charge_at_immigrate;
>  
> -	if (memcg->move_charge_at_immigrate) {
> +	/*
> +	 * We are now commited to this value whatever it is. Changes in this
> +	 * tunable will only affect upcoming migrations, not the current one.
> +	 * So we need to save it, and keep it going.
> +	 */
> +	move_charge_at_immigrate  = memcg->move_charge_at_immigrate;
> +	if (move_charge_at_immigrate) {
>  		struct mm_struct *mm;
>  		struct mem_cgroup *from = mem_cgroup_from_task(p);
>  
> @@ -6551,6 +6558,7 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
>  			spin_lock(&mc.lock);
>  			mc.from = from;
>  			mc.to = memcg;
> +			mc.move_charge_at_immigrate = move_charge_at_immigrate;
>  			spin_unlock(&mc.lock);
>  			/* We set mc.moving_task later */
>  
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
