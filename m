Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id F217B6B025C
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:18:27 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n186so7564269wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:18:27 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id y14si1382953wmd.62.2016.03.11.00.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 00:18:26 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id l68so7815017wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:18:26 -0800 (PST)
Date: Fri, 11 Mar 2016 09:18:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim and OOM kill when shrinking
 memory.max below usage
Message-ID: <20160311081825.GC27701@dhcp22.suse.cz>
References: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 10-03-16 15:50:14, Johannes Weiner wrote:
> Setting the original memory.limit_in_bytes hardlimit is subject to a
> race condition when the desired value is below the current usage. The
> code tries a few times to first reclaim and then see if the usage has
> dropped to where we would like it to be, but there is no locking, and
> the workload is free to continue making new charges up to the old
> limit. Thus, attempting to shrink a workload relies on pure luck and
> hope that the workload happens to cooperate.

OK this would be indeed a problem when you want to stop a runaway load.

> To fix this in the cgroup2 memory.max knob, do it the other way round:
> set the limit first, then try enforcement. And if reclaim is not able
> to succeed, trigger OOM kills in the group. Keep going until the new
> limit is met, we run out of OOM victims and there's only unreclaimable
> memory left, or the task writing to memory.max is killed. This allows
> users to shrink groups reliably, and the behavior is consistent with
> what happens when new charges are attempted in excess of memory.max.

Here as well. I think this should go into 4.5 final or later to stable
so that we do not have different behavior of the knob.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

One nit below

[...]
> @@ -5037,9 +5040,36 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  	if (err)
>  		return err;
>  
> -	err = mem_cgroup_resize_limit(memcg, max);
> -	if (err)
> -		return err;
> +	xchg(&memcg->memory.limit, max);
> +
> +	for (;;) {
> +		unsigned long nr_pages = page_counter_read(&memcg->memory);
> +
> +		if (nr_pages <= max)
> +			break;
> +
> +		if (signal_pending(current)) {

Didn't you want fatal_signal_pending here? At least the changelog
suggests that.

> +			err = -EINTR;
> +			break;
> +		}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
