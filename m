Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0438E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:40:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so11881211pff.17
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:40:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n62-v6sor2527531pgn.145.2018.09.10.17.40.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 17:40:22 -0700 (PDT)
Date: Mon, 10 Sep 2018 17:40:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
In-Reply-To: <20180910215622.4428-1-guro@fb.com>
Message-ID: <alpine.DEB.2.21.1809101740080.256423@chino.kir.corp.google.com>
References: <20180910215622.4428-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, 10 Sep 2018, Roman Gushchin wrote:

> The memcg OOM killer is never invoked due to a failed high-order
> allocation, however the MEMCG_OOM event can be easily raised.
> 
> Under some memory pressure it can happen easily because of a
> concurrent allocation. Let's look at try_charge(). Even if we were
> able to reclaim enough memory, this check can fail due to a race
> with another allocation:
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
> In this case the idea of raising the MEMCG_OOM event looks dubious.
> 
> Fix this by moving MEMCG_OOM raising to  mem_cgroup_oom() after
> allocation order check, so that the event won't be raised for high
> order allocations.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>
