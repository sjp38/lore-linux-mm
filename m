Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C11EF440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 00:07:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p87so4250596pfj.21
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 21:07:10 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0054.outbound.protection.outlook.com. [104.47.0.54])
        by mx.google.com with ESMTPS id m8si5319212pgt.327.2017.11.08.21.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 21:07:09 -0800 (PST)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
 <b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com>
 <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <a803dbd4-da87-f6b9-5b8d-02651bbf236e@mellanox.com>
Date: Thu, 9 Nov 2017 14:06:33 +0900
MIME-Version: 1.0
In-Reply-To: <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 08/11/2017 6:35 PM, Mel Gorman wrote:
> On Wed, Nov 08, 2017 at 02:42:04PM +0900, Tariq Toukan wrote:
>>>> Hi all,
>>>>
>>>> After leaving this task for a while doing other tasks, I got back to it now
>>>> and see that the good behavior I observed earlier was not stable.
>>>>
>>>> Recall: I work with a modified driver that allocates a page (4K) per packet
>>>> (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
>>>> NICs.
>>>>
>>>
>>> There is almost new in the data that hasn't been discussed before. The
>>> suggestion to free on a remote per-cpu list would be expensive as it would
>>> require per-cpu lists to have a lock for safe remote access.
>>
>> That's right, but each such lock will be significantly less congested than
>> the buddy allocator lock.
> 
> That is not necessarily true if all the allocations and frees always happen
> on the same CPUs. The contention will be equivalent to the zone lock.
> Your point will only hold true if there are also heavy allocation streams
> from other CPUs that are unrelated.

That's exactly the case.
I saw no issues when working with a single core allocating pages (and 
many others consuming the SKBs), this does not stress the buddy 
allocator enough to expose the problem.
On my server, problem becomes visible when working with >= 4 allocator 
cores (RX rings).
So "distributing" the locks between the different PCPs and doing 
remote-free (instead of using the centralized buddy allocator lock), 
would give a huge performance under high load (although it might cause a 
slight degradation when load is low).

> 
>> In the flow in subject two cores need to
>> synchronize (one allocates, one frees).
>> We also need to evaluate the cost of acquiring and releasing the lock in the
>> case of no congestion at all.
>>
> 
> If the per-cpu structures have a lock, there will be a light amount of
> overhead. Nothing too severe, but it shouldn't be done lightly either.
> 
If the trade-off is a huge gain under load, it might be worth it.

>>>   However,
>>> I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
>>> ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's an
>>> unfinished prototype I worked on a few weeks ago. I was going to revisit
>>> in about a months time when 4.15-rc1 was out. I'd be interested in seeing
>>> if it has a postive gain in normal page allocations without destroying
>>> the performance of interrupt and softirq allocation contexts. The
>>> interrupt/softirq context testing is crucial as that is something that
>>> hurt us before when trying to improve page allocator performance.
>>>
>> Yes, I will test that once I get back in office (after netdev conference and
>> vacation).
> 
> Thanks.
> 
>> Can you please elaborate in a few words about the idea behind the prototype?
>> Does it address page-allocator scalability issues, or only the rate of
>> single core page allocations?
> 
> Short answer -- maybe. All scalability issues or rates of allocation are
> context and workload dependant so the question is impossible to answer
> for the general case.
> 
> Broadly speaking, the patch reintroduces the per-cpu lists being for !irq
> context allocations again. The last time we did this, hard and soft IRQ
> allocations went through the buddy allocator which couldn't scale and
> the patch was reverted. With this patch, it goes through a very large
> pagevec-like structure that is protected by a lock but the fast paths
> for alloc/free are extremely simple operations so the lock hold times are
> very small. Potentially, a development path is that the current per-cpu
> allocator is replaced with pagevec-like structures that are dynamically
> allocated which would also allow pages to be freed to remote CPU lists
> (if we could detect when that is appropriate which is unclear). We could
> also drain remote lists without using IPIs. The downside is that the memory
> footprint of the allocator would be higher and the size could no longer
> be tuned so there would need to be excellent justification for such a move.
> 
> I haven't posted the patches properly yet because mmotm is carrying too
> many patches as it is and this patch indirectly depends on the contents. I
> also didn't write memory hot-remove support which would be a requirement
> before merging. I hadn't intended to put further effort into it until I
> had some evidence the approach had promise. My own testing indicated it
> worked but the drivers I was using for network tests did not allocate
> intensely enough to show any major gain/loss.
> 
Thanks for the description. This sounds intriguing.
Once I'll get to testing it, I'll magnify the effect by stressing the 
page-allocator the same way I did earlier to simulate a load of 200Gbps.

Regards,
Tariq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
