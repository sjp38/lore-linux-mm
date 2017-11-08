Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3484403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 00:42:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 76so1381524pfr.3
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 21:42:27 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00050.outbound.protection.outlook.com. [40.107.0.50])
        by mx.google.com with ESMTPS id w19si3135997pfa.59.2017.11.07.21.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 21:42:21 -0800 (PST)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com>
Date: Wed, 8 Nov 2017 14:42:04 +0900
MIME-Version: 1.0
In-Reply-To: <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 03/11/2017 10:40 PM, Mel Gorman wrote:
> On Thu, Nov 02, 2017 at 07:21:09PM +0200, Tariq Toukan wrote:
>>
>>
>> On 18/09/2017 12:16 PM, Tariq Toukan wrote:
>>>
>>>
>>> On 15/09/2017 1:23 PM, Mel Gorman wrote:
>>>> On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
>>>>> Insights: Major degradation between #1 and #2, not getting any
>>>>> close to linerate! Degradation is fixed between #2 and #3. This is
>>>>> because page allocator cannot stand the higher allocation rate. In
>>>>> #2, we also see that the addition of rings (cores) reduces BW (!!),
>>>>> as result of increasing congestion over shared resources.
>>>>>
>>>>
>>>> Unfortunately, no surprises there.
>>>>
>>>>> Congestion in this case is very clear. When monitored in perf
>>>>> top: 85.58% [kernel] [k] queued_spin_lock_slowpath
>>>>>
>>>>
>>>> While it's not proven, the most likely candidate is the zone lock
>>>> and that should be confirmed using a call-graph profile. If so, then
>>>> the suggestion to tune to the size of the per-cpu allocator would
>>>> mitigate the problem.
>>>>
>>> Indeed, I tuned the per-cpu allocator and bottleneck is released.
>>>
>>
>> Hi all,
>>
>> After leaving this task for a while doing other tasks, I got back to it now
>> and see that the good behavior I observed earlier was not stable.
>>
>> Recall: I work with a modified driver that allocates a page (4K) per packet
>> (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
>> NICs.
>>
> 
> There is almost new in the data that hasn't been discussed before. The
> suggestion to free on a remote per-cpu list would be expensive as it would
> require per-cpu lists to have a lock for safe remote access.
That's right, but each such lock will be significantly less congested 
than the buddy allocator lock. In the flow in subject two cores need to 
synchronize (one allocates, one frees).
We also need to evaluate the cost of acquiring and releasing the lock in 
the case of no congestion at all.

>  However,
> I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
> ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's an
> unfinished prototype I worked on a few weeks ago. I was going to revisit
> in about a months time when 4.15-rc1 was out. I'd be interested in seeing
> if it has a postive gain in normal page allocations without destroying
> the performance of interrupt and softirq allocation contexts. The
> interrupt/softirq context testing is crucial as that is something that
> hurt us before when trying to improve page allocator performance.
> 
Yes, I will test that once I get back in office (after netdev conference 
and vacation).
Can you please elaborate in a few words about the idea behind the prototype?
Does it address page-allocator scalability issues, or only the rate of 
single core page allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
