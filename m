Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC07900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:51:25 -0400 (EDT)
Date: Fri, 20 May 2011 14:51:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/8] memcg asyncrhouns reclaim workqueue
Message-Id: <20110520145115.d52f3693.akpm@linux-foundation.org>
In-Reply-To: <20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Fri, 20 May 2011 12:48:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> workqueue for memory cgroup asynchronous memory shrinker.
> 
> This patch implements the workqueue of async shrinker routine. each
> memcg has a work and only one work can be scheduled at the same time.
> 
> If shrinking memory doesn't goes well, delay will be added to the work.
> 

When this code explodes (as it surely will), users will see large
amounts of CPU consumption in the work queue thread.  We want to make
this as easy to debug as possible, so we should try to make the
workqueue's names mappable back onto their memcg's.  And anything else
we can think of to help?

>
> ...
>
> +static void mem_cgroup_async_shrink(struct work_struct *work)
> +{
> +	struct delayed_work *dw = to_delayed_work(work);
> +	struct mem_cgroup *mem = container_of(dw,
> +			struct mem_cgroup, async_work);
> +	bool congested = false;
> +	int delay = 0;
> +	unsigned long long required, usage, limit, shrink_to;

There's a convention which is favored by some (and ignored by the
clueless ;)) which says "one definition per line".

The reason I like one-definition-per-line is that it leaves a little
room on the right where the programmer can explain the role of the
local.

Another advantage is that one can initialise it.  eg:

	unsigned long limit = res_counter_read_u64(&mem->res, RES_LIMIT);

That conveys useful information: the reader can see what it's
initialised with and can infer its use.

A third advantage is that it can now be made const, which conveys very
useful informtation and can prevent bugs.

A fourth advantage is that it makes later patches to this function more
readable and easier to apply when there are conflicts.


> +	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> +	shrink_to = limit - MEMCG_ASYNC_MARGIN - PAGE_SIZE;
> +	usage = res_counter_read_u64(&mem->res, RES_USAGE);
> +	if (shrink_to <= usage) {
> +		required = usage - shrink_to;
> +		required = (required >> PAGE_SHIFT) + 1;
> +		/*
> +		 * This scans some number of pages and returns that memory
> +		 * reclaim was slow or now. If slow, we add a delay as
> +		 * congestion_wait() in vmscan.c
> +		 */
> +		congested = mem_cgroup_shrink_static_scan(mem, (long)required);
> +	}
> +	if (test_bit(ASYNC_NORESCHED, &mem->async_flags)
> +	    || mem_cgroup_async_should_stop(mem))
> +		goto finish_scan;
> +	/* If memory reclaim couldn't go well, add delay */
> +	if (congested)
> +		delay = HZ/10;

Another magic number.

If Moore's law holds, we need to reduce this number by 1.4 each year. 
Is this good?

> +	queue_delayed_work(memcg_async_shrinker, &mem->async_work, delay);
> +	return;
> +finish_scan:
> +	cgroup_release_and_wakeup_rmdir(&mem->css);
> +	clear_bit(ASYNC_RUNNING, &mem->async_flags);
> +	return;
> +}
> +
> +static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
> +{
> +	if (test_bit(ASYNC_NORESCHED, &mem->async_flags))
> +		return;

I can't work out what ASYNC_NORESCHED does.  Is its name well-chosen?

> +	if (test_and_set_bit(ASYNC_RUNNING, &mem->async_flags))
> +		return;
> +	cgroup_exclude_rmdir(&mem->css);
> +	/*
> +	 * start reclaim with small delay. This delay will allow us to do job
> +	 * in batch.

Explain more?

> +	 */
> +	if (!queue_delayed_work(memcg_async_shrinker, &mem->async_work, 1)) {
> +		cgroup_release_and_wakeup_rmdir(&mem->css);
> +		clear_bit(ASYNC_RUNNING, &mem->async_flags);
> +	}
> +	return;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
