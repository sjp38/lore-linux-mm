Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D134E6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 17:48:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so325919556pge.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:48:17 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id s22si1600634plk.156.2017.03.13.14.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 14:48:17 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id b129so70872203pgc.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:48:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170313195833.GA25454@cmpxchg.org>
References: <20170310194620.5021-1-shakeelb@google.com> <20170313195833.GA25454@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 13 Mar 2017 14:48:16 -0700
Message-ID: <CALvZod43N16hz-prYvshbZ26HdSzBx2j76ETb12cjKLqr4MGZw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix condition for throttle_direct_reclaim
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 13, 2017 at 12:58 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi Shakeel,
>
> On Fri, Mar 10, 2017 at 11:46:20AM -0800, Shakeel Butt wrote:
>> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
>> number of unsucessful iterations. Before going to sleep, kswapd thread
>> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
>> However the awoken threads will recheck the watermarks and wake the
>> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
>> of continuous back and forth between kswapd and direct reclaiming
>> threads if the kswapd keep failing and thus defeat the purpose of
>> adding backoff mechanism to kswapd. So, add kswapd_failures check
>> on the throttle_direct_reclaim condition.
>>
>> Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> You're right, the way it works right now is kind of lame. Did you
> observe continued kswapd spinning because of the wakeup ping-pong?
>

Yes, I did observe kswapd spinning for more than an hour.

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
>
> Instead of a second helper function, could you rename
> pfmemalloc_watermark_ok() and add the kswapd_failure check at the very
> beginning of that function?
>

Sure, Michal also suggested the same.

> Because that check fits nicely with the comment about kswapd having to
> be awake, too. We need kswapd operational when throttling reclaimers.
>
> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
