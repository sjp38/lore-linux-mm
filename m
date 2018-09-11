Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6358E0002
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:43:06 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id w74-v6so11881784ybe.19
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:43:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133-v6sor3220592ybd.21.2018.09.11.05.43.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 05:43:02 -0700 (PDT)
Date: Tue, 11 Sep 2018 08:43:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911124303.GA19043@cmpxchg.org>
References: <20180910215622.4428-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180910215622.4428-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Sep 10, 2018 at 02:56:22PM -0700, Roman Gushchin wrote:
> The memcg OOM killer is never invoked due to a failed high-order
> allocation, however the MEMCG_OOM event can be easily raised.

Wasn't the same also true for kernel allocations until recently? We'd
signal MEMCG_OOM and then return -ENOMEM.

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

These seem to be more implementation details than anything else.

Personally, I'm confused by the difference between the "oom" and
"oom_kill" events, and I don't understand when you would be interested
in one and when in the other. The difference again seems to be mostly
implementation details.

But the definition of "oom"/MEMCG_OOM in cgroup-v2.rst applies to the
situation of failing higher-order allocations. I'm not per-se against
changing the semantics here, as I don't think they are great. But can
you please start out with rewriting the definition in a way that shows
the practical difference for users?

The original idea behind MEMCG_OOM was to signal when reclaim had
failed and we defer to the oom killer. The oom killer may or may not
kill anything, which is the case for higher order allocations, but
that doesn't change the out-of-memory situation that has occurred.

Konstantin added the OOM_KILL events to count actual kills. It seems
to me that this has much more practical applications than the more
theoretical OOM, since users care more about kills and not necessarily
about "reclaim failed (but i might have been able to handle it with
retries and fallback allocations, and so there isn't an actual issue".

Is there a good reason for keeping OOM now that we have OOM_KILL?
