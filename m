Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 19C496B0256
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 07:38:41 -0400 (EDT)
Received: by lanb10 with SMTP id b10so49967473lan.3
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:38:40 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p3si492336lap.36.2015.09.07.04.38.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 04:38:39 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:38:22 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v2 3/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150907113822.GB31800@esperanza>
References: <20150828220158.GD11089@htj.dyndns.org>
 <20150828220237.GE11089@htj.dyndns.org>
 <20150904210011.GH25329@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150904210011.GH25329@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Sep 04, 2015 at 05:00:11PM -0400, Tejun Heo wrote:
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
> 
> As long as kernel doesn't have a run-away allocation spree, this
> should provide enough protection while making kmemcg behave more
> consistently.

Another good thing about such an approach is that it copes with prio
inversion. Currently, a task with small memory.high might issue
memory.high reclaim on kmem charge with a bunch of various locks held.
If a task with a big value of memory.high needs any of these locks,
it'll have to wait until the low prio task finishes reclaim and releases
the locks. By handing over reclaim to task_work whenever possible we
might avoid this issue and improve overall performance.

> 
> v2: - Switched to reclaiming only the overage caused by current rather
>       than the difference between usage and high as suggested by
>       Michal.
>     - Don't record the memcg which went over high limit.  This makes
>       exit path handling unnecessary.  Dropped.
>     - Drop mentions of avoiding high stack usage from description as
>       suggested by Vladimir.  max limit still triggers direct reclaim.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
