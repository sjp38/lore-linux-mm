Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C1B8E6B005A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:08:53 -0400 (EDT)
Date: Tue, 9 Oct 2012 17:08:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 08/14] res_counter: return amount of charges after
 res_counter_uncharge
Message-ID: <20121009150845.GC7655@dhcp22.suse.cz>
References: <1349690780-15988-1-git-send-email-glommer@parallels.com>
 <1349690780-15988-9-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349690780-15988-9-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>

On Mon 08-10-12 14:06:14, Glauber Costa wrote:
[...]
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index ad581aa..7b3d6dc 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -86,33 +86,39 @@ int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
>  	return __res_counter_charge(counter, val, limit_fail_at, true);
>  }
>  
> -void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> +u64 res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
>  {
>  	if (WARN_ON(counter->usage < val))
>  		val = counter->usage;
>  
>  	counter->usage -= val;
> +	return counter->usage;
>  }
>  
> -void res_counter_uncharge_until(struct res_counter *counter,
> -				struct res_counter *top,
> -				unsigned long val)
> +u64 res_counter_uncharge_until(struct res_counter *counter,
> +			       struct res_counter *top,
> +			       unsigned long val)
>  {
>  	unsigned long flags;
>  	struct res_counter *c;
> +	u64 ret = 0;
>  
>  	local_irq_save(flags);
>  	for (c = counter; c != top; c = c->parent) {
> +		u64 r;
>  		spin_lock(&c->lock);
> -		res_counter_uncharge_locked(c, val);
> +		r = res_counter_uncharge_locked(c, val);
> +		if (c == counter)
> +			ret = r;
>  		spin_unlock(&c->lock);
>  	}
>  	local_irq_restore(flags);
> +	return ret;

As I have already mentioned in my previous feedback this is cetainly not
atomic as you the lock protects only one group in the hierarchy. How is
the return value from this function supposed to be used?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
