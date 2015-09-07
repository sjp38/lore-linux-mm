Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF376B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 05:23:49 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so76552153wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 02:23:48 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id gk10si19684235wjb.110.2015.09.07.02.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 02:23:48 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so76917525wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 02:23:47 -0700 (PDT)
Date: Mon, 7 Sep 2015 11:23:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150907092346.GC6022@dhcp22.suse.cz>
References: <20150828220158.GD11089@htj.dyndns.org>
 <20150828220237.GE11089@htj.dyndns.org>
 <20150904210011.GH25329@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904210011.GH25329@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri 04-09-15 17:00:11, Tejun Heo wrote:
> Currently, try_charge() tries to reclaim memory synchronously when the
> high limit is breached; however, if the allocation doesn't have
> __GFP_WAIT, synchronous reclaim is skipped.  If a process performs
> only speculative allocations, it can blow way past the high limit.
> This is actually easily reproducible by simply doing "find /".
> slab/slub allocator tries speculative allocations first, so as long as
> there's memory which can be consumed without blocking, it can keep
> allocating memory regardless of the high limit.
> 
> This patch makes try_charge() always punt the over-high reclaim to the
> return-to-userland path.  If try_charge() detects that high limit is
> breached, it adds the overage to current->memcg_nr_pages_over_high and
> schedules execution of mem_cgroup_handle_over_high() which performs
> synchronous reclaim from the return-to-userland path.

This also means that a killed task will not reclaim before it dies. This
shouldn't be a big deal, though, because the task should uncharge its
memory which will most likely belong to the memcg. More on that below.

> As long as kernel doesn't have a run-away allocation spree, this
> should provide enough protection while making kmemcg behave more
> consistently.

I would also point out that this approach allows for a better reclaim
opportunities for GFP_NOFS charges which are quite common with kmem
enabled.

> v2: - Switched to reclaiming only the overage caused by current rather
>       than the difference between usage and high as suggested by
>       Michal.
>     - Don't record the memcg which went over high limit.  This makes
>       exit path handling unnecessary.  Dropped.

Hmm, this allows to leave a memcg in a high limit excess. I guess
you are right that this is not that likely to lose sleep over
it. Nevertheless, a nasty user could move away from within signal
handler context which runs before. This looks like a potential runaway
but the migration outside of the restricted hierarchy is a problem in
itself so I wouldn't consider this a problem.

>     - Drop mentions of avoiding high stack usage from description as
>       suggested by Vladimir.  max limit still triggers direct reclaim.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> +/*
> + * Scheduled by try_charge() to be executed from the userland return path
> + * and reclaims memory over the high limit.
> + */
> +void mem_cgroup_handle_over_high(void)
> +{
> +	unsigned int nr_pages = current->memcg_nr_pages_over_high;
> +	struct mem_cgroup *memcg, *pos;
> +
> +	if (likely(!nr_pages))
> +		return;

This is hooking into a hot path so I guess it would be better to make
this part inline and the rest can go via function call.

> +
> +	pos = memcg = get_mem_cgroup_from_mm(current->mm);
> +
> +	do {
> +		if (page_counter_read(&pos->memory) <= pos->high)
> +			continue;
> +		mem_cgroup_events(pos, MEMCG_HIGH, 1);

I was thinking about when to emit the event when I realized we haven't
specified the semantic anywhere. It sounds more logical to emit the
event when the limit is breached rather than when we reclaim for it.  On
the other hand we have been doing it only for reclaim and GFP_NOWAIT
where not accounted. So this mimics the previous behavior. Same for the
max limit when we skip the charge. So I guess this is OK as well.


> +		try_to_free_mem_cgroup_pages(pos, nr_pages, GFP_KERNEL, true);
> +	} while ((pos = parent_mem_cgroup(pos)));
> +
> +	css_put(&memcg->css);
> +	current->memcg_nr_pages_over_high = 0;
> +}
> +
>  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		      unsigned int nr_pages)
>  {
> @@ -2082,17 +2108,22 @@ done_restock:

JFYI you can get rid of labels in the patch format by
[diff "default"]
        xfuncname = "^[[:alpha:]$_].*[^:]$"

I found it really nice and easier to read.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
