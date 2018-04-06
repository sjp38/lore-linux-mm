Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB59A6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 11:22:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b76so1029792wmg.9
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 08:22:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w40sor4916178wrc.79.2018.04.06.08.22.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 08:22:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <406e02a5-16d4-7cd3-de01-24bee60eab02@virtuozzo.com>
References: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
 <20180406135215.10057-1-aryabinin@virtuozzo.com> <CALvZod7bGjx-fUKZ15oVAkXkeneZjtoRFiUSpKSZ1U0DA_e1BA@mail.gmail.com>
 <406e02a5-16d4-7cd3-de01-24bee60eab02@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 6 Apr 2018 08:22:15 -0700
Message-ID: <CALvZod4jmJp26=TB1hXrKb59DVEKOeJV9moKas=6Dcuvkq9ZZQ@mail.gmail.com>
Subject: Re: [PATCH] mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2-fix
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>

On Fri, Apr 6, 2018 at 8:09 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 04/06/2018 05:37 PM, Shakeel Butt wrote:
>
>>>
>>> @@ -2482,7 +2494,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>>>  static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
>>>  {
>>>         return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
>>> -               (memcg && test_memcg_bit(PGDAT_CONGESTED, memcg));
>>> +               (memcg && memcg_congested(pgdat, memcg));
>>
>> I am wondering if we should check all ancestors for congestion as
>> well. Maybe a parallel memcg reclaimer might have set some ancestor of
>> this memcg to congested.
>>
>
> Why? If ancestor is congested but its child (the one we currently reclaim) is not,
> it could mean only 2 things:
>  - Either child use mostly anon and inactive file lru is small (file_lru >> priority == 0)
>    so it's not congested.
>  - Or the child was congested recently (at the time when ancestor scanned this group),
>    but not anymore. So the information from ancestor is simply outdated.
>

Oh yeah, you explained in the other email as well. Thanks.

I think Andrew will squash this patch with the previous one. Andrew,
please add following in the squashed patch.

Reviewed-by: Shakeel Butt <shakeelb@google.com>
