Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA3756B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:16:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so16646987pgb.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:16:23 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0041.outbound.protection.outlook.com. [104.47.0.41])
        by mx.google.com with ESMTPS id x86si4182317pfk.293.2017.09.18.02.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 02:16:22 -0700 (PDT)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
Date: Mon, 18 Sep 2017 12:16:09 +0300
MIME-Version: 1.0
In-Reply-To: <20170915102320.zqceocmvvkyybekj@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>
Cc: David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>



On 15/09/2017 1:23 PM, Mel Gorman wrote:
> On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
>> Insights: Major degradation between #1 and #2, not getting any
>> close to linerate! Degradation is fixed between #2 and #3. This is
>> because page allocator cannot stand the higher allocation rate. In
>> #2, we also see that the addition of rings (cores) reduces BW (!!),
>> as result of increasing congestion over shared resources.
>> 
> 
> Unfortunately, no surprises there.
> 
>> Congestion in this case is very clear. When monitored in perf top: 
>> 85.58% [kernel] [k] queued_spin_lock_slowpath
>> 
> 
> While it's not proven, the most likely candidate is the zone lock
> and that should be confirmed using a call-graph profile. If so, then
> the suggestion to tune to the size of the per-cpu allocator would
> mitigate the problem.
> 
Indeed, I tuned the per-cpu allocator and bottleneck is released.

>> I think that page allocator issues should be discussed separately: 
>> 1) Rate: Increase the allocation rate on a single core. 2)
>> Scalability: Reduce congestion and sync overhead between cores.
>> 
>> This is clearly the current bottleneck in the network stack receive
>> flow.
>> 
>> I know about some efforts that were made in the past two years. For
>> example the ones from Jesper et al.: - Page-pool (not accepted
>> AFAIK).
> 
> Indeed not and it would also need driver conversion.
> 
>> - Page-allocation bulking.
> 
> Prototypes exist but it's pointless without the pool or driver 
> conversion so it's in the back burner for the moment.
> 

As I already mentioned in another reply (to Jesper), this would
perfectly fit with our Striding RQ feature, as we have large descriptors
that serve several packets, requiring the allocation of several pages at
once. I'd gladly move to using the bulking API.

>> - Optimize order-0 allocations in Per-Cpu-Pages.
>> 
> 
> This had a prototype that was reverted as it must be able to cope
> with both irq and noirq contexts.
Yeah, I remember that I tested and reported the issue.

Unfortunately I never found the time to
> revisit it but a split there to handle both would mitigate the
> problem. Probably not enough to actually reach line speed though so
> tuning of the per-cpu allocator sizes would still be needed. I don't
> know when I'll get the chance to revisit it. I'm travelling all next
> week and am mostly occupied with other work at the moment that is
> consuming all my concentration.
> 
>> I am not an mm expert, but wanted to raise the issue again, to
>> combine the efforts and hear from you guys about status and
>> possible directions.
> 
> The recent effort to reduce overhead from stats will help mitigate
> the problem.
I should get more familiar with these stats, check how costly they are, 
and whether they can be turned off in Kconfig.

> Finishing the page pool, the bulk allocator and converting drivers 
> would be the most likely successful path forward but it's currently
> stalled as everyone that was previously involved is too busy.
> 
I think we should consider changing the default allocation of PCP 
fraction as well, or implement some smart dynamic heuristic.
This turned on to have significant effect over networking performance.

Many thanks Mel!

Regards,
Tariq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
