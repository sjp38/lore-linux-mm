Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AADB74405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 11:42:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 189so163823518pfu.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 08:42:25 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50060.outbound.protection.outlook.com. [40.107.5.60])
        by mx.google.com with ESMTPS id q10si4232298plk.101.2017.02.15.08.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 08:42:24 -0800 (PST)
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
References: <20170213195858.5215-1-edumazet@google.com>
 <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com>
 <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
 <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S3530_2DYU-3VRmvRYZ3n05OqJZpJ3x02vXQd6Q7FUJQvw@mail.gmail.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <ccc4cb9e-9863-02e1-2789-4869aea3c661@mellanox.com>
Date: Wed, 15 Feb 2017 18:42:14 +0200
MIME-Version: 1.0
In-Reply-To: <CALx6S3530_2DYU-3VRmvRYZ3n05OqJZpJ3x02vXQd6Q7FUJQvw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, "David S .
 Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>



On 14/02/2017 7:29 PM, Tom Herbert wrote:
> On Tue, Feb 14, 2017 at 7:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2017-02-14 at 16:56 +0200, Tariq Toukan wrote:
>>
>>> As the previous series caused hangs, we must run functional regression
>>> tests over this series as well.
>>> Run has already started, and results will be available tomorrow morning.
>>>
>>> In general, I really like this series. The re-factorization looks more
>>> elegant and more correct, functionally.
>>>
>>> However, performance wise: we fear that the numbers will be drastically
>>> lower with this transition to order-0 pages,
>>> because of the (becoming critical) page allocator and dma operations
>>> bottlenecks, especially on systems with costly
>>> dma operations, such as ARM, iommu=on, etc...
>>>
>> So, again, performance after this patch series his higher,
>> once you have sensible RX queues parameters, for the expected workload.
>>
>> Only in pathological cases, you might have some regression.
>>
>> The old schem was _maybe_ better _when_ memory is not fragmented.
>>
>> When you run hosts for months, memory _is_ fragmented.
>>
>> You never see that on benchmarks, unless you force memory being
>> fragmented.
>>
>>
>>
>>> We already have this exact issue in mlx5, where we moved to order-0
>>> allocations with a fixed size cache, but that was not enough.
>>> Customers of mlx5 have already complained about the performance
>>> degradation, and currently this is hurting our business.
>>> We get a clear nack from our performance regression team regarding doing
>>> the same in mlx4.
>>> So, the question is, can we live with this degradation until those
>>> bottleneck challenges are addressed?
>> Again, there is no degradation.
>>
>> We have been using order-0 pages for years at Google.
>>
>> Only when we made the mistake to rebase from the upstream driver and
>> order-3 pages we got horrible regressions, causing production outages.
>>
>> I was silly to believe that mm layer got better.
>>
>>> Following our perf experts feedback, I cannot just simply Ack. We need
>>> to have a clear plan to close the perf gap or reduce the impact.
>> Your perf experts need to talk to me, or any experts at Google and
>> Facebook, really.
>>
> I agree with this 100%! To be blunt, power users like this are testing
> your drivers far beyond what Mellanox is doing and understand how
> performance gains in benchmarks translate to possible gains in real
> production way more than your perf experts can. Listen to Eric!
>
> Tom
>
>
>> Anything _relying_ on order-3 pages being available to impress
>> friends/customers is a lie.

Isn't it the same principle in page_frag_alloc() ?
It is called form __netdev_alloc_skb()/__napi_alloc_skb().

Why is it ok to have order-3 pages (PAGE_FRAG_CACHE_MAX_ORDER) there?
By using netdev/napi_alloc_skb, you'll get that the SKB's linear data is 
a frag of a huge page,
and it is not going to be freed before the other non-linear frags.
Cannot this cause the same threats (memory pinning and so...)?

Currently, mlx4 doesn't use this generic API, while most other drivers do.

Similar claims are true for TX:
https://github.com/torvalds/linux/commit/5640f7685831e088fe6c2e1f863a6805962f8e81

>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
