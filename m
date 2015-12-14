Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C9C4B6B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:31:17 -0500 (EST)
Received: by wmnn186 with SMTP id n186so125889087wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:31:17 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id hb7si46516508wjc.71.2015.12.14.07.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:30:48 -0800 (PST)
Received: by mail-wm0-f42.google.com with SMTP id n186so123514926wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:30:47 -0800 (PST)
Date: Mon, 14 Dec 2015 16:30:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151214153037.GB4339@dhcp22.suse.cz>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
> In the legacy hierarchy we charge memsw, which is dubious, because:
> 
>  - memsw.limit must be >= memory.limit, so it is impossible to limit
>    swap usage less than memory usage. Taking into account the fact that
>    the primary limiting mechanism in the unified hierarchy is
>    memory.high while memory.limit is either left unset or set to a very
>    large value, moving memsw.limit knob to the unified hierarchy would
>    effectively make it impossible to limit swap usage according to the
>    user preference.
> 
>  - memsw.usage != memory.usage + swap.usage, because a page occupying
>    both swap entry and a swap cache page is charged only once to memsw
>    counter. As a result, it is possible to effectively eat up to
>    memory.limit of memory pages *and* memsw.limit of swap entries, which
>    looks unexpected.
> 
> That said, we should provide a different swap limiting mechanism for
> cgroup2.
> This patch adds mem_cgroup->swap counter, which charges the actual
> number of swap entries used by a cgroup. It is only charged in the
> unified hierarchy, while the legacy hierarchy memsw logic is left
> intact.

I agree that the previous semantic was awkward. The problem I can see
with this approach is that once the swap limit is reached the anon
memory pressure might spill over to other and unrelated memcgs during
the global memory pressure. I guess this is what Kame referred to as
anon would become mlocked basically. This would be even more of an issue
with resource delegation to sub-hierarchies because nobody will prevent
setting the swap amount to a small value and use that as an anon memory
protection.

I guess this was the reason why this approach hasn't been chosen before
but I think we can come up with a way to stop the run away consumption
even when the swap is accounted separately. All of them are quite nasty
but let me try.

We could allow charges to fail even for the high limit if the excess is
way above the amount of reclaimable memory in the given memcg/hierarchy.
A runaway load would be stopped before it can cause a considerable
damage outside of its hierarchy this way even when the swap limit
is configured small.
Now that goes against the high limit semantic which should only throttle
the consumer and shouldn't cause any functional failures but maybe this
is acceptable for the overall system stability. An alternative would
be to throttle in the high limit reclaim context proportionally to
the excess. This is normally done by the reclaim itself but with no
reclaimable memory this wouldn't work that way.

Another option would be to ignore the swap limit during the global
reclaim. This wouldn't stop the runaway loads but they would at least
see their fair share of the reclaim. The swap excess could be then used
as a "handicap" for a more aggressive throttling during high limit reclaim
or to trigger hard limit sooner.

Or we could teach the global OOM killer to select abusive anon memory
users with restricted swap. That would require to iterate through all
memcgs and checks whether their anon consumption is in a large excess to
their swap limit and fallback to the memcg OOM victim selection if that
is the case. This adds more complexity to the OOM killer path so I am
not sure this is generally acceptable, though.

My question now is. Is the knob usable/useful even without additional
heuristics? Do we want to protect swap space so rigidly that a swap
limited memcg can cause bigger problems than without the swap limit
globally?

> The swap usage can be monitored using new memory.swap.current file and
> limited using memory.swap.max.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |   1 +
>  include/linux/swap.h       |   5 ++
>  mm/memcontrol.c            | 123 +++++++++++++++++++++++++++++++++++++++++----
>  mm/shmem.c                 |   4 ++
>  mm/swap_state.c            |   5 ++
>  5 files changed, 129 insertions(+), 9 deletions(-)

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
