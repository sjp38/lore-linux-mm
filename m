Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4328A6B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 11:09:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d6-v6so1107586plo.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 08:09:07 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00091.outbound.protection.outlook.com. [40.107.0.91])
        by mx.google.com with ESMTPS id x14-v6si8375989pln.728.2018.04.06.08.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 08:09:06 -0700 (PDT)
Subject: Re: [PATCH]
 mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2-fix
References: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
 <20180406135215.10057-1-aryabinin@virtuozzo.com>
 <CALvZod7bGjx-fUKZ15oVAkXkeneZjtoRFiUSpKSZ1U0DA_e1BA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <406e02a5-16d4-7cd3-de01-24bee60eab02@virtuozzo.com>
Date: Fri, 6 Apr 2018 18:09:54 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod7bGjx-fUKZ15oVAkXkeneZjtoRFiUSpKSZ1U0DA_e1BA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>



On 04/06/2018 05:37 PM, Shakeel Butt wrote:

>>
>> @@ -2482,7 +2494,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
>>  static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
>>  {
>>         return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
>> -               (memcg && test_memcg_bit(PGDAT_CONGESTED, memcg));
>> +               (memcg && memcg_congested(pgdat, memcg));
> 
> I am wondering if we should check all ancestors for congestion as
> well. Maybe a parallel memcg reclaimer might have set some ancestor of
> this memcg to congested.
> 

Why? If ancestor is congested but its child (the one we currently reclaim) is not,
it could mean only 2 things:
 - Either child use mostly anon and inactive file lru is small (file_lru >> priority == 0)
   so it's not congested.
 - Or the child was congested recently (at the time when ancestor scanned this group),
   but not anymore. So the information from ancestor is simply outdated.
