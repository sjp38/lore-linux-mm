Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B58D56B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 10:15:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f137so948005wme.5
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 07:15:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t142sor2723168wmt.5.2018.04.06.07.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 07:15:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <72db1bfb-aa79-3764-54fd-2c7ddbd07bea@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180323152029.11084-5-aryabinin@virtuozzo.com> <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
 <72db1bfb-aa79-3764-54fd-2c7ddbd07bea@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 6 Apr 2018 07:15:40 -0700
Message-ID: <CALvZod4YCvz4bvjcrQxi_=HeZ49pZcA2xvres6_jMKwvOdhqcg@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] mm/vmscan: Don't mess with pgdat->flags in memcg reclaim.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>

On Fri, Apr 6, 2018 at 4:44 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 04/06/2018 05:13 AM, Shakeel Butt wrote:
>> On Fri, Mar 23, 2018 at 8:20 AM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>> memcg reclaim may alter pgdat->flags based on the state of LRU lists
>>> in cgroup and its children. PGDAT_WRITEBACK may force kswapd to sleep
>>> congested_wait(), PGDAT_DIRTY may force kswapd to writeback filesystem
>>> pages. But the worst here is PGDAT_CONGESTED, since it may force all
>>> direct reclaims to stall in wait_iff_congested(). Note that only kswapd
>>> have powers to clear any of these bits. This might just never happen if
>>> cgroup limits configured that way. So all direct reclaims will stall
>>> as long as we have some congested bdi in the system.
>>>
>>> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
>>> pgdat, only kswapd can clear pgdat->flags once node is balance, thus
>>> it's reasonable to leave all decisions about node state to kswapd.
>>
>> What about global reclaimers? Is the assumption that when global
>> reclaimers hit such condition, kswapd will be running and correctly
>> set PGDAT_CONGESTED?
>>
>
> The reason I moved this under if(current_is_kswapd()) is because only kswapd
> can clear these flags. I'm less worried about the case when PGDAT_CONGESTED falsely
> not set, and more worried about the case when it falsely set. If direct reclaimer sets
> PGDAT_CONGESTED, do we have guarantee that, after congestion problem is sorted, kswapd
> ill be woken up and clear the flag? It seems like there is no such guarantee.
> E.g. direct reclaimers may eventually balance pgdat and kswapd simply won't wake up
> (see wakeup_kswapd()).
>
>
Thanks for the explanation, I think it should be in the commit message.
