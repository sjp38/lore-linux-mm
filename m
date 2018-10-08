Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2D176B0010
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 05:22:19 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id h38-v6so251614ywk.20
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 02:22:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8-v6sor1994387ywe.45.2018.10.08.02.22.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 02:22:14 -0700 (PDT)
Date: Mon, 8 Oct 2018 05:22:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20181008092211.GA7515@cmpxchg.org>
References: <20181004214050.7417-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004214050.7417-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu, Oct 04, 2018 at 09:41:09PM +0000, Roman Gushchin wrote:
> I was reported that on some of our machines containers were restarted
> with OOM symptoms without an obvious reason. Despite there were almost
> no memory pressure and plenty of page cache, MEMCG_OOM event was
> raised occasionally, causing the container management software to
> think, that OOM has happened. However, no tasks have been killed.
> 
> The following investigation showed that the problem is caused by
> a failing attempt to charge a high-order page. In such case, the
> OOM killer is never invoked. As shown below, it can happen under
> conditions, which are very far from a real OOM: e.g. there is plenty
> of clean page cache and no memory pressure.
> 
> There is no sense in raising an OOM event in this case, as it might
> confuse a user and lead to wrong and excessive actions (e.g. restart
> the workload, as in my case).
> 
> Let's look at the charging path in try_charge(). If the memory usage
> is about memory.max, which is absolutely natural for most memory cgroups,
> we try to reclaim some pages. Even if we were able to reclaim
> enough memory for the allocation, the following check can fail due to
> a race with another concurrent allocation:
> 
>     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>         goto retry;
> 
> For regular pages the following condition will save us from triggering
> the OOM:
> 
>    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
>        goto retry;
> 
> But for high-order allocation this condition will intentionally fail.
> The reason behind is that we'll likely fall to regular pages anyway,
> so it's ok and even preferred to return ENOMEM.
> 
> In this case the idea of raising MEMCG_OOM looks dubious.
> 
> Fix this by moving MEMCG_OOM raising to mem_cgroup_oom() after
> allocation order check, so that the event won't be raised for high
> order allocations. This change doesn't affect regular pages allocation
> and charging.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
