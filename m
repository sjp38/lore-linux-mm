Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61BB06B027A
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 22:16:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t15so1796846wmh.3
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 19:16:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor4724948wru.40.2017.12.08.19.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 19:16:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1712081259520.47087@chino.kir.corp.google.com>
References: <20171208012305.83134-1-surenb@google.com> <alpine.DEB.2.10.1712081259520.47087@chino.kir.corp.google.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 8 Dec 2017 19:16:28 -0800
Message-ID: <CAJuCfpEvzo1BAAj5AHLFqZnjbQg+s2njkzGBycEWJe1ZHuwO5w@mail.gmail.com>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Fri, Dec 8, 2017 at 1:02 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 7 Dec 2017, Suren Baghdasaryan wrote:
>
>> Slab shrinkers can be quite time consuming and when signal
>> is pending they can delay handling of the signal. If fatal
>> signal is pending there is no point in shrinking that process
>> since it will be killed anyway. This change checks for pending
>> fatal signals inside shrink_slab loop and if one is detected
>> terminates this loop early.
>>
>
> I've proposed a similar patch in the past, but for a check on TIF_MEMDIE,
> which would today be a tsk_is_oom_victim(current), since we had observed
> lengthy stalls in reclaim that would have been prevented if the oom victim
> had exited out, returned back to the page allocator, allocated with
> ALLOC_NO_WATERMARKS, and proceeded to quickly exit.
>
> I'm not sure that all fatal_signal_pending() tasks should get the same
> treatment, but I understand the point that the task is killed and should
> free memory when it fully exits.  How much memory is unknown.
>

Thanks for the input. For my particular use case TIF_MEMDIE check
would not help because I'm trying to kill a process before OOM kicks
in, however the approach is interesting and provides food for thought.

>  > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
>>
>> ---
>> V2:
>> Sergey Senozhatsky:
>>   - Fix missing parentheses
>> ---
>>  mm/vmscan.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c02c850ea349..28e4bdc72c16 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>                       .memcg = memcg,
>>               };
>>
>> +             /*
>> +              * We are about to die and free our memory.
>> +              * Stop shrinking which might delay signal handling.
>> +              */
>> +             if (unlikely(fatal_signal_pending(current)))
>> +                     break;
>> +
>>               /*
>>                * If kernel memory accounting is disabled, we ignore
>>                * SHRINKER_MEMCG_AWARE flag and call all shrinkers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
