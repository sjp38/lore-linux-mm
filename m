Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C96AD6B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 21:11:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n781BgVL022158
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 8 Aug 2009 10:11:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BBF045DE58
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 10:11:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D40B145DE4E
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 10:11:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A42821DB8043
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 10:11:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 393C41DB803E
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 10:11:41 +0900 (JST)
Message-ID: <39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090807221238.GJ9686@balbir.in.ibm.com>
References: <20090807221238.GJ9686@balbir.in.ibm.com>
Date: Sat, 8 Aug 2009 10:11:40 +0900 (JST)
Subject: Re: Help Resource Counters Scale Better (v2)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Enhancement: For scalability move the resource counter to a percpu counter
>
> Changelog v2->v1
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> 1. Updated Documentation (cgroups.txt and resource_counters.txt)
> 2. Added the notion of tolerance to resource counter initialization
>
looks better ..but a few concerns/nitpicks.


> I tested this patch on my x86_64 box with a regular test for hard
> limits and a page fault program. I also enabled lockdep and lock_stat
> clearly shows that the contention on counter->lock is down quite
> significantly. I tested these patches against an older mmotm, but
> this should apply cleanly to the 6th August mmotm as well.
>
It's always helpful if the numbers are shown.


> diff --git a/Documentation/cgroups/memory.txt
> b/Documentation/cgroups/memory.txt
> index b871f25..8f86537 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -13,6 +13,9 @@ c. Provides *zero overhead* for non memory controller
> users
>  d. Provides a double LRU: global memory pressure causes reclaim from the
>     global LRU; a cgroup on hitting a limit, reclaims from the per
>     cgroup LRU
> +   NOTE: One can no longer rely on the exact limit. Since we've moved
> +   to using percpu_counters for resource counters, there is always going
> +   to be a fuzziness factor depending on the batch value.
>
This text is just from our view.
Please explain to people who reads memcg for the first time.


>  Benefits and Purpose of the memory controller
>
> diff --git a/Documentation/cgroups/resource_counter.txt
> b/Documentation/cgroups/resource_counter.txt
> index 95b24d7..d3b276b 100644
> --- a/Documentation/cgroups/resource_counter.txt
> +++ b/Documentation/cgroups/resource_counter.txt
> @@ -12,12 +12,15 @@ to work with it.
>
>  1. Crucial parts of the res_counter structure
>
> - a. unsigned long long usage
> + a. percpu_counter usage
>
>   	The usage value shows the amount of a resource that is consumed
>  	by a group at a given time. The units of measurement should be
>  	determined by the controller that uses this counter. E.g. it can
>  	be bytes, items or any other unit the controller operates on.
> +	NOTE: being a percpu_counter, the way to read the correct value
> +	at all times makes it unscalable and reading it scalably makes
> +	the value a little unreliable :)
>
ditto.

>   b. unsigned long long max_usage
>
> @@ -48,7 +51,8 @@ to work with it.
>  2. Basic accounting routines
>
>   a. void res_counter_init(struct res_counter *rc,
> -				struct res_counter *rc_parent)
> +				struct res_counter *rc_parent,
> +				unsigned long tolerance)
>
>   	Initializes the resource counter. As usual, should be the first
>  	routine called for a new counter.
> @@ -57,6 +61,9 @@ to work with it.
>  	child -> parent relationship directly in the res_counter structure,
>  	NULL can be used to define no relationship.
>
> +	The tolerance is used to control the batching behaviour of percpu
> +	counters
> +
This description is ambiguous.
What is the system's total tolerance ?
    tolerance ?
    nr_online_cpus * tolerance ?
    MAX_CPUS * tolerance ?


>   c. int res_counter_charge(struct res_counter *rc, unsigned long val,
>  				struct res_counter **limit_fail_at)
>
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 731af71..2d412d7 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -14,6 +14,7 @@
>   */
>
>  #include <linux/cgroup.h>
> +#include <linux/percpu_counter.h>
>
>  /*
>   * The core object. the cgroup that wishes to account for some
> @@ -23,10 +24,6 @@
>
>  struct res_counter {
>  	/*
> -	 * the current resource consumption level
> -	 */
> -	unsigned long long usage;
> -	/*
>  	 * the maximal value of the usage from the counter creation
>  	 */
>  	unsigned long long max_usage;
> @@ -48,6 +45,14 @@ struct res_counter {
>  	 */
>  	spinlock_t lock;
>  	/*
> +	 * the current resource consumption level
> +	 */
> +	struct percpu_counter usage;
> +	/*
> +	 * Tolerance for the percpu_counter (usage) above
> +	 */
> +	unsigned long usage_tolerance;
> +	/*
>  	 * Parent counter, used for hierarchial resource accounting
>  	 */
>  	struct res_counter *parent;
> @@ -98,7 +103,8 @@ enum {
>   * helpers for accounting
>   */
>
> -void res_counter_init(struct res_counter *counter, struct res_counter
> *parent);
> +void res_counter_init(struct res_counter *counter, struct res_counter
> *parent,
> +			unsigned long usage_tolerance);
>
>  /*
>   * charge - try to consume more resource.
> @@ -133,7 +139,8 @@ void res_counter_uncharge(struct res_counter *counter,
> unsigned long val,
>
>  static inline bool res_counter_limit_check_locked(struct res_counter
> *cnt)
>  {
> -	if (cnt->usage < cnt->limit)
> +	unsigned long long usage = percpu_counter_read_positive(&cnt->usage);
> +	if (usage < cnt->limit)
>  		return true;
>
Hmm. In memcg, this function is not used for busy pass but used for
important pass to check usage under limit (and continue reclaim)

Can't we add res_clounter_check_locked_exact(), which use
percpu_counter_sum() later ?

>  	return false;
> @@ -141,7 +148,8 @@ static inline bool
> res_counter_limit_check_locked(struct res_counter *cnt)
>
>  static inline bool res_counter_soft_limit_check_locked(struct res_counter
> *cnt)
>  {
> -	if (cnt->usage < cnt->soft_limit)
> +	unsigned long long usage = percpu_counter_read_positive(&cnt->usage);
> +	if (usage < cnt->soft_limit)
>  		return true;
>
>  	return false;
> @@ -157,15 +165,15 @@ static inline bool
> res_counter_soft_limit_check_locked(struct res_counter *cnt)
>  static inline unsigned long long
>  res_counter_soft_limit_excess(struct res_counter *cnt)
>  {
> -	unsigned long long excess;
> -	unsigned long flags;
> +	unsigned long long excess, usage;
>
> -	spin_lock_irqsave(&cnt->lock, flags);
> -	if (cnt->usage <= cnt->soft_limit)
> +	usage = percpu_counter_read_positive(&cnt->usage);
> +	preempt_disable();
> +	if (usage <= cnt->soft_limit)
>  		excess = 0;
>  	else
> -		excess = cnt->usage - cnt->soft_limit;
> -	spin_unlock_irqrestore(&cnt->lock, flags);
> +		excess = usage - cnt->soft_limit;
> +	preempt_enable();
>  	return excess;
>  }
It's not clear why this part uses preempt_disable() instead of
irqsave(). Could you add comment ?
(*AND* it seems the caller disable irq....)


>
> @@ -178,9 +186,9 @@ static inline bool
> res_counter_check_under_limit(struct res_counter *cnt)
>  	bool ret;
>  	unsigned long flags;
>
> -	spin_lock_irqsave(&cnt->lock, flags);
> +	local_irq_save(flags);
>  	ret = res_counter_limit_check_locked(cnt);
> -	spin_unlock_irqrestore(&cnt->lock, flags);
> +	local_irq_restore(flags);
>  	return ret;
>  }
>
> @@ -189,18 +197,19 @@ static inline bool
> res_counter_check_under_soft_limit(struct res_counter *cnt)
>  	bool ret;
>  	unsigned long flags;
>
> -	spin_lock_irqsave(&cnt->lock, flags);
> +	local_irq_save(flags);
>  	ret = res_counter_soft_limit_check_locked(cnt);
> -	spin_unlock_irqrestore(&cnt->lock, flags);
> +	local_irq_restore(flags);
>  	return ret;
>  }
>
>  static inline void res_counter_reset_max(struct res_counter *cnt)
>  {
>  	unsigned long flags;
> +	unsigned long long usage = percpu_counter_read_positive(&cnt->usage);
>
>  	spin_lock_irqsave(&cnt->lock, flags);
> -	cnt->max_usage = cnt->usage;
> +	cnt->max_usage = usage;
>  	spin_unlock_irqrestore(&cnt->lock, flags);
>  }
>
> @@ -217,10 +226,11 @@ static inline int res_counter_set_limit(struct
> res_counter *cnt,
>  		unsigned long long limit)
>  {
>  	unsigned long flags;
> +	unsigned long long usage = percpu_counter_read_positive(&cnt->usage);
>  	int ret = -EBUSY;
>
>  	spin_lock_irqsave(&cnt->lock, flags);
> -	if (cnt->usage <= limit) {
> +	if (usage <= limit) {
>  		cnt->limit = limit;
>  		ret = 0;
>  	}

For the same reason to check_limit, I want correct number here.
percpu_counter_sum() is better.


> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 88faec2..ae83168 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -15,24 +15,34 @@
>  #include <linux/uaccess.h>
>  #include <linux/mm.h>
>
> -void res_counter_init(struct res_counter *counter, struct res_counter
> *parent)
> +void res_counter_init(struct res_counter *counter, struct res_counter
> *parent,
> +			unsigned long usage_tolerance)
>  {
>  	spin_lock_init(&counter->lock);
> +	percpu_counter_init(&counter->usage, 0);
>  	counter->limit = RESOURCE_MAX;
>  	counter->soft_limit = RESOURCE_MAX;
>  	counter->parent = parent;
> +	counter->usage_tolerance = usage_tolerance;
>  }
>
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long
> val)
>  {
> -	if (counter->usage + val > counter->limit) {
> +	unsigned long long usage;
> +
> +	usage = percpu_counter_read_positive(&counter->usage);
> +	if (usage + val > counter->limit) {
>  		counter->failcnt++;
>  		return -ENOMEM;
>  	}
>
> -	counter->usage += val;
> -	if (counter->usage > counter->max_usage)
> -		counter->max_usage = counter->usage;
> +	__percpu_counter_add(&counter->usage, val, nr_cpu_ids *
> +				counter->usage_tolerance);
> +	if (usage + val > counter->max_usage) {
> +		spin_lock(&counter->lock);
> +		counter->max_usage = (usage + val);
> +		spin_unlock(&counter->lock);
> +	}
Hmm...irq is already off here ?


>  	return 0;
>  }
>
> @@ -49,7 +59,6 @@ int res_counter_charge(struct res_counter *counter,
> unsigned long val,
>  		*soft_limit_fail_at = NULL;
>  	local_irq_save(flags);
>  	for (c = counter; c != NULL; c = c->parent) {
> -		spin_lock(&c->lock);
>  		ret = res_counter_charge_locked(c, val);
>  		/*
>  		 * With soft limits, we return the highest ancestor
> @@ -58,7 +67,6 @@ int res_counter_charge(struct res_counter *counter,
> unsigned long val,
>  		if (soft_limit_fail_at &&
>  			!res_counter_soft_limit_check_locked(c))
>  			*soft_limit_fail_at = c;
> -		spin_unlock(&c->lock);
>  		if (ret < 0) {
>  			*limit_fail_at = c;
>  			goto undo;
> @@ -68,9 +76,7 @@ int res_counter_charge(struct res_counter *counter,
> unsigned long val,
>  	goto done;
>  undo:
>  	for (u = counter; u != c; u = u->parent) {
> -		spin_lock(&u->lock);
>  		res_counter_uncharge_locked(u, val);
> -		spin_unlock(&u->lock);
>  	}
>  done:

When using hierarchy, tolerance to root node will be bigger.
Please write this attention to the document.


>  	local_irq_restore(flags);
> @@ -79,10 +85,13 @@ done:
>
>  void res_counter_uncharge_locked(struct res_counter *counter, unsigned
> long val)
>  {
> -	if (WARN_ON(counter->usage < val))
> -		val = counter->usage;
> +	unsigned long long usage;
> +
> +	usage = percpu_counter_read_positive(&counter->usage);
> +	if (WARN_ON((usage + counter->usage_tolerance * nr_cpu_ids) < val))
> +		val = usage;
Is this correct ? (or do we need this WARN_ON ?)
Hmm. percpu_counter is cpu-hotplug aware. Then,
nr_cpu_ids is not correct. but nr_onlie_cpus() is heavy..hmm.


>
> -	counter->usage -= val;
> +	percpu_counter_sub(&counter->usage, val);
>  }
>
>  void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> @@ -93,12 +102,10 @@ void res_counter_uncharge(struct res_counter
> *counter, unsigned long val,
>
>  	local_irq_save(flags);
>  	for (c = counter; c != NULL; c = c->parent) {
> -		spin_lock(&c->lock);
>  		if (was_soft_limit_excess)
>  			*was_soft_limit_excess =
>  				!res_counter_soft_limit_check_locked(c);
>  		res_counter_uncharge_locked(c, val);
> -		spin_unlock(&c->lock);
>  	}
>  	local_irq_restore(flags);
>  }
> @@ -108,8 +115,6 @@ static inline unsigned long long *
>  res_counter_member(struct res_counter *counter, int member)
>  {
>  	switch (member) {
> -	case RES_USAGE:
> -		return &counter->usage;
>  	case RES_MAX_USAGE:
>  		return &counter->max_usage;
>  	case RES_LIMIT:
> @@ -128,11 +133,15 @@ ssize_t res_counter_read(struct res_counter
> *counter, int member,
>  		const char __user *userbuf, size_t nbytes, loff_t *pos,
>  		int (*read_strategy)(unsigned long long val, char *st_buf))
>  {
> -	unsigned long long *val;
> +	unsigned long long *val, usage_val;
>  	char buf[64], *s;
>
>  	s = buf;
> -	val = res_counter_member(counter, member);
> +	if (member == RES_USAGE) {
> +		usage_val = percpu_counter_read_positive(&counter->usage);
> +		val = &usage_val;
> +	} else
> +		val = res_counter_member(counter, member);
>  	if (read_strategy)
>  		s += read_strategy(*val, s);


>  	else
> @@ -143,7 +152,10 @@ ssize_t res_counter_read(struct res_counter *counter,
> int member,
>
>  u64 res_counter_read_u64(struct res_counter *counter, int member)
>  {
> -	return *res_counter_member(counter, member);
> +	if (member == RES_USAGE)
> +		return percpu_counter_read_positive(&counter->usage);
> +	else
> +		return *res_counter_member(counter, member);
>  }

>
>  int res_counter_memparse_write_strategy(const char *buf,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 48a38e1..17d305d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -58,6 +58,19 @@ static DEFINE_MUTEX(memcg_tasklist);	/* can be hold
> under cgroup_mutex */
>  #define SOFTLIMIT_EVENTS_THRESH (1000)
>
>  /*
> + * To help resource counters scale, we take a step back
> + * and allow the counters to be scalable and set a
> + * batch value such that every addition does not cause
> + * global synchronization. The side-effect will be visible
> + * on limit enforcement, where due to this fuzziness,
> + * we will lose out on inforcing a limit when the usage
> + * exceeds the limit. The plan however in the long run
> + * is to allow this value to be controlled. We will
> + * probably add a new control file for it.
> + */
> +#define MEM_CGROUP_RES_ERR_TOLERANCE (4 * PAGE_SIZE)

Considering percpu counter's extra overhead. This number is too small, IMO.

> +
> +/*
>   * Statistics for memory cgroup.
>   */
>  enum mem_cgroup_stat_index {
> @@ -2340,7 +2353,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup
> *mem, bool free_all)
>  	if (free_all)
>  		goto try_to_free;
>  move_account:
> -	while (mem->res.usage > 0) {
> +	while (res_counter_read_u64(&mem->res, RES_USAGE) > 0) {
>  		ret = -EBUSY;
>  		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>  			goto out;
> @@ -2383,7 +2396,7 @@ try_to_free:
>  	lru_add_drain_all();
>  	/* try to free all pages in this cgroup */
>  	shrink = 1;
> -	while (nr_retries && mem->res.usage > 0) {
> +	while (nr_retries && res_counter_read_u64(&mem->res, RES_USAGE) > 0) {
>  		int progress;
>
>  		if (signal_pending(current)) {
> @@ -2401,7 +2414,7 @@ try_to_free:
>  	}
>  	lru_add_drain();
>  	/* try move_account...there may be some *locked* pages. */
> -	if (mem->res.usage)
> +	if (res_counter_read_u64(&mem->res, RES_USAGE))
>  		goto move_account;
>  	ret = 0;
>  	goto out;
> @@ -3019,8 +3032,10 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct
> cgroup *cont)
>  	}
>
>  	if (parent && parent->use_hierarchy) {
> -		res_counter_init(&mem->res, &parent->res);
> -		res_counter_init(&mem->memsw, &parent->memsw);
> +		res_counter_init(&mem->res, &parent->res,
> +			MEM_CGROUP_RES_ERR_TOLERANCE);
> +		res_counter_init(&mem->memsw, &parent->memsw,
> +			MEM_CGROUP_RES_ERR_TOLERANCE);
>  		/*
>  		 * We increment refcnt of the parent to ensure that we can
>  		 * safely access it on res_counter_charge/uncharge.
> @@ -3029,8 +3044,10 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct
> cgroup *cont)
>  		 */
>  		mem_cgroup_get(parent);
>  	} else {
> -		res_counter_init(&mem->res, NULL);
> -		res_counter_init(&mem->memsw, NULL);
> +		res_counter_init(&mem->res, NULL,
> +			MEM_CGROUP_RES_ERR_TOLERANCE);
> +		res_counter_init(&mem->memsw, NULL,
> +			MEM_CGROUP_RES_ERR_TOLERANCE);
>  	}
>  	mem->last_scanned_child = 0;
>  	spin_lock_init(&mem->reclaim_param_lock);
>

Thanks,
-Kame

>
> --
> 	Balbir
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
