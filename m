Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E32426B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 23:54:56 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C3soU4026661
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:54:50 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C3t8011179758
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:55:08 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C3soBP006328
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:54:50 +1100
Date: Thu, 12 Mar 2009 09:24:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] add softlimit to res_counter
Message-ID: <20090312035444.GC23583@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:56:12]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
> softlimit paramater itself is added to res_counter and 
>  res_counter_set_softlimit() and
>  res_counter_check_under_softlimit() is provided as an interface.
> 
> 
> Changelog v2->v3:
>  - softlimit is moved to res_counter

Good, this is very similar to the patch I have in my post as well. Please feel
free to add my signed-off-by on this patch, but please see below for
comments.

> Changelog v1->v2:
>  - For refactoring, divided a patch into 2 part and this patch just
>    involves memory.softlimit interface.
>  - Removed governor-detect routine, it was buggy in design.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/res_counter.h |    9 +++++++++
>  kernel/res_counter.c        |   29 +++++++++++++++++++++++++++++
>  mm/memcontrol.c             |   12 ++++++++++++
>  3 files changed, 50 insertions(+)
> 
> Index: mmotm-2.6.29-Mar10/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Mar10.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Mar10/mm/memcontrol.c
> @@ -2002,6 +2002,12 @@ static int mem_cgroup_write(struct cgrou
>  		else
>  			ret = mem_cgroup_resize_memsw_limit(memcg, val);
>  		break;
> +	case RES_SOFTLIMIT:
> +		ret = res_counter_memparse_write_strategy(buffer, &val);
> +		if (ret)
> +			break;
> +		ret = res_counter_set_softlimit(&memcg->res, val);
> +		break;
>  	default:
>  		ret = -EINVAL; /* should be BUG() ? */
>  		break;
> @@ -2251,6 +2257,12 @@ static struct cftype mem_cgroup_files[] 
>  		.read_u64 = mem_cgroup_read,
>  	},
>  	{
> +		.name = "softlimit_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEM, RES_SOFTLIMIT),
> +		.write_string = mem_cgroup_write,
> +		.read_u64 = mem_cgroup_read,
> +	},
> +	{
>  		.name = "failcnt",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
>  		.trigger = mem_cgroup_reset,
> Index: mmotm-2.6.29-Mar10/include/linux/res_counter.h
> ===================================================================
> --- mmotm-2.6.29-Mar10.orig/include/linux/res_counter.h
> +++ mmotm-2.6.29-Mar10/include/linux/res_counter.h
> @@ -39,6 +39,10 @@ struct res_counter {
>  	 */
>  	unsigned long long failcnt;
>  	/*
> +	 * the softlimit.
> +	 */
> +	unsigned long long softlimit;
> +	/*
>  	 * the lock to protect all of the above.
>  	 * the routines below consider this to be IRQ-safe
>  	 */
> @@ -85,6 +89,7 @@ enum {
>  	RES_MAX_USAGE,
>  	RES_LIMIT,
>  	RES_FAILCNT,
> +	RES_SOFTLIMIT,
>  };
> 
>  /*
> @@ -178,4 +183,8 @@ static inline int res_counter_set_limit(
>  	return ret;
>  }
> 
> +/* res_counter's softlimit check can handles hierarchy in proper way */
> +int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val);
> +bool res_counter_check_under_softlimit(struct res_counter *cnt);
> +
>  #endif
> Index: mmotm-2.6.29-Mar10/kernel/res_counter.c
> ===================================================================
> --- mmotm-2.6.29-Mar10.orig/kernel/res_counter.c
> +++ mmotm-2.6.29-Mar10/kernel/res_counter.c
> @@ -20,6 +20,7 @@ void res_counter_init(struct res_counter
>  	spin_lock_init(&counter->lock);
>  	counter->limit = (unsigned long long)LLONG_MAX;
>  	counter->parent = parent;
> +	counter->softlimit = (unsigned long long)LLONG_MAX;
>  }
> 
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> @@ -88,6 +89,32 @@ void res_counter_uncharge(struct res_cou
>  	local_irq_restore(flags);
>  }
> 
> +int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	cnt->softlimit = val;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return 0;
> +}
> +
> +bool res_counter_check_under_softlimit(struct res_counter *cnt)
> +{
> +	struct res_counter *c;
> +	unsigned long flags;
> +	bool ret = true;
> +
> +	local_irq_save(flags);
> +	for (c = cnt; ret && c != NULL; c = c->parent) {
> +		spin_lock(&c->lock);
> +		if (c->softlimit < c->usage)
> +			ret = false;

So if a child was under the soft limit and the parent is *not*, we
_override_ ret and return false?

> +		spin_unlock(&c->lock);
> +	}
> +	local_irq_restore(flags);
> +	return ret;
> +}

Why is the check_under_softlimit hierarchical? BTW, this patch is
buggy. See above.

> 
>  static inline unsigned long long *
>  res_counter_member(struct res_counter *counter, int member)
> @@ -101,6 +128,8 @@ res_counter_member(struct res_counter *c
>  		return &counter->limit;
>  	case RES_FAILCNT:
>  		return &counter->failcnt;
> +	case RES_SOFTLIMIT:
> +		return &counter->softlimit;
>  	};
> 
>  	BUG();
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
