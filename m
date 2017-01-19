Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92A196B02A6
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 09:18:14 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so8860988wjy.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:18:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l45si4625789wrc.12.2017.01.19.06.18.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 06:18:12 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
References: <20161230131412.GI13301@dhcp22.suse.cz>
 <20161230140651.nud2ozpmvmziqyx4@suse.de>
 <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
 <20170113070331.GA7874@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bfbc31ec-7400-6174-62c3-94d82667320d@suse.cz>
Date: Thu, 19 Jan 2017 15:18:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170113070331.GA7874@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 01/13/2017 08:03 AM, Joonsoo Kim wrote:
>>>> So what is the problem? The demand for high order pages is growing and
>>>> that seems to be the general trend. The problem is that while they can
>>>> bring performance benefit they can get be really expensive to allocate
>>>> especially when we enter the direct compaction. So we really want to
>>>> prevent from expensive path and defer as much as possible to the
>>>> background. A huge step forward was kcompactd introduced by Vlastimil.
>>>> We are still not there yet though, because it might be already quite
>>>> late when we wakeup_kcompactd(). The memory might be already fragmented
>>>> when we hit there.
>>
>> Right.
> 
> Before we talk about pro-active compaction, I'd like to know the
> usecase that really needs pro-active compaction. For THP, IMHO, it's
> better not to do pro-active compaction, because high-order page made
> by pro-active compaction could be broken before it is used. And,

I agree that THP should be given lower priority, but wouldn't rule it
out completely.

> THP page can be setup lately by THP daemon. Benefit of pro-active
> compaction would not compensate overhead of it in this case.

khugepaged can only help in the longer term, but we can still help
shorter-lived processes

> I guess
> that almost cases that have a fallback would hit this category.

Yes, ideally we can derive this info from the GFP flags and prioritize
accordingly.

> For the order lower than costly order, system would have such a
> freepage usually. So, my question is pro-active compaction is really
> needed even if it's cost is really high? Reason I ask this question is
> that I tested some patches to do pro-active compaction and found that
> cost looks too much high. I heard that someone want this feature but
> I'm not sure they will use it with this high cost. Anyway, I will post
> some patches for pro-active compaction, soon.

David Rientjes mentioned their workloads benefit from background
compaction in the discussion about THP's "defrag" setting.

[...]

>> Parameters
>> - wake up period for kcompactd
>> - target per-order goals for kcompactd
>> - lowest efficiency where it's still considered worth to compact?
>>
>> An important question: how to evaluate this? Metrics should be feasible
>> (improved success rate, % of compaction that was handled by kcompactd
>> and not direct compaction...), but what are the good testcases?
> 
> Usecase should be defined first? Anyway, I hope that new testcase would
> be finished in short time. stress-highalloc test takes too much time
> to test various ideas.

Yeah, that too. But mainly it's too artificial.

>>
>> Ideally I would also revisit the topic of compaction mechanism (migrate
>> and free scanners) itself. It's been shown that they usually meet in the
> 
> +1
> 
>> 1/3 or 1/2 of zone, which means the rest of the zone is only
>> defragmented by "plugging free holes" by migrated pages, although it
>> might actually contain pageblocks more suitable for migrating from, than
>> the first part of the zone. It's also expensive for the free scanner to
>> actually find free pages, according to the stats.
> 
> Scalable approach would be [3] since it finds freepage by O(1) unlike
> others that are O(N).

There's however the issue that we need to skip (or potentially isolate
on a private list) freepages that lie in the area we are migrating from,
which is potentially O(N) where N is NR_FREE. This gets worse with
multiple compactors so we might have to e.g. reuse the pageblock skip
bits to indicate to others to go away, and rely on too_many_isolated()
or something similar to limit the number of concurrent compactors.

>>
>> Some approaches were proposed in recent years, but never got far as it's
>> always some kind of a trade-off (this partially goes back to the problem
>> of evaluation, often limited to stress-highalloc from mmtests):
>>
>> - "pivot" based approach where scanners' starting point changes and
>> isn't always zone boundaries [1]
>> - both scanners scan whole zone moving in the same direction, just
>> making sure they don't operate on the same pageblock at the same time [2]
>> - replacing free scanner by directly taking free pages from freelist
>>
>> However, the problem with this subtopic is that it might be too much
>> specialized for the full MM room.
> 
> Right. :)
> 
> Thanks.
> 
>>
>> [1] https://lkml.org/lkml/2015/1/19/158
>> [2] https://lkml.org/lkml/2015/6/24/706
>> [3] https://lkml.org/lkml/2015/12/3/63
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
