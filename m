Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 696126B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:07:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so302752007pgh.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:07:17 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id m2si11655647pgn.334.2017.03.13.08.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:07:16 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id 25so64715000pgy.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:07:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170313090206.GC31518@dhcp22.suse.cz>
References: <20170310194620.5021-1-shakeelb@google.com> <20170313090206.GC31518@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 13 Mar 2017 08:07:15 -0700
Message-ID: <CALvZod4sxxhj4f8pmg1s+07c2pJfHwD2T7wh7vP9sD5PRcme-A@mail.gmail.com>
Subject: Re: [PATCH] mm: fix condition for throttle_direct_reclaim
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 13, 2017 at 2:02 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 10-03-17 11:46:20, Shakeel Butt wrote:
>> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
>> number of unsucessful iterations. Before going to sleep, kswapd thread
>> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
>> However the awoken threads will recheck the watermarks and wake the
>> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
>> of continuous back and forth between kswapd and direct reclaiming
>> threads if the kswapd keep failing and thus defeat the purpose of
>> adding backoff mechanism to kswapd. So, add kswapd_failures check
>> on the throttle_direct_reclaim condition.
>
> I have to say I really do not like this. kswapd_failures shouldn't
> really be checked outside of the kswapd context. The
> pfmemalloc_watermark_ok/throttle_direct_reclaim is quite complex even
> without putting another variable into it. I wish we rather replace this
> throttling by something else. Johannes had an idea to throttle by the
> number of reclaimers.
>
Do you suspect race in accessing kswapd_failures in non-kswapd
context? Please do let me know more about replacing this throttling.

> Anyway, I am wondering whether we can hit this issue in
> practice? Have you seen it happening or is this a result of the code
> review? I would assume that that !zone_reclaimable_pages check in
> pfmemalloc_watermark_ok should help to some degree.
>
Yes, I have seen this issue going on for more than one hour on my
test. It was a simple test where the number of processes, in the
presence of swap, try to allocate memory more than RAM. The number of
processes are equal to the number of cores and are pinned to each
individual core. I am suspecting that !zone_reclaimable_pages() check
did not help.

>> Signed-off-by: Shakeel Butt <shakeelb@google.com>
>> ---
>>  mm/vmscan.c | 12 +++++++++---
>>  1 file changed, 9 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index bae698484e8e..b2d24cc7a161 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2819,6 +2819,12 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>>       return wmark_ok;
>>  }
>>
>> +static bool should_throttle_direct_reclaim(pg_data_t *pgdat)
>> +{
>> +     return (pgdat->kswapd_failures < MAX_RECLAIM_RETRIES &&
>> +             !pfmemalloc_watermark_ok(pgdat));
>> +}
>> +
>>  /*
>>   * Throttle direct reclaimers if backing storage is backed by the network
>>   * and the PFMEMALLOC reserve for the preferred node is getting dangerously
>> @@ -2873,7 +2879,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>>
>>               /* Throttle based on the first usable node */
>>               pgdat = zone->zone_pgdat;
>> -             if (pfmemalloc_watermark_ok(pgdat))
>> +             if (!should_throttle_direct_reclaim(pgdat))
>>                       goto out;
>>               break;
>>       }
>> @@ -2895,14 +2901,14 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
>>        */
>>       if (!(gfp_mask & __GFP_FS)) {
>>               wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
>> -                     pfmemalloc_watermark_ok(pgdat), HZ);
>> +                     !should_throttle_direct_reclaim(pgdat), HZ);
>>
>>               goto check_pending;
>>       }
>>
>>       /* Throttle until kswapd wakes the process */
>>       wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
>> -             pfmemalloc_watermark_ok(pgdat));
>> +             !should_throttle_direct_reclaim(pgdat));
>>
>>  check_pending:
>>       if (fatal_signal_pending(current))
>> --
>> 2.12.0.246.ga2ecc84866-goog
>>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
