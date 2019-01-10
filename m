Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5963A8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 20:48:59 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so6571041pfk.12
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:48:59 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id y188si9074136pfb.59.2019.01.09.17.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 17:48:58 -0800 (PST)
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
 <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org>
 <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
 <20190109225143.GA22252@cmpxchg.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <99843dad-608d-10cc-c28f-e5e63a793361@linux.alibaba.com>
Date: Wed, 9 Jan 2019 17:47:41 -0800
MIME-Version: 1.0
In-Reply-To: <20190109225143.GA22252@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/9/19 2:51 PM, Johannes Weiner wrote:
> On Wed, Jan 09, 2019 at 02:09:20PM -0800, Yang Shi wrote:
>> On 1/9/19 1:23 PM, Johannes Weiner wrote:
>>> On Wed, Jan 09, 2019 at 12:36:11PM -0800, Yang Shi wrote:
>>>> As I mentioned above, if we know some page caches from some memcgs
>>>> are referenced one-off and unlikely shared, why just keep them
>>>> around to increase memory pressure?
>>> It's just not clear to me that your scenarios are generic enough to
>>> justify adding two interfaces that we have to maintain forever, and
>>> that they couldn't be solved with existing mechanisms.
>>>
>>> Please explain:
>>>
>>> - Unmapped clean page cache isn't expensive to reclaim, certainly
>>>     cheaper than the IO involved in new application startup. How could
>>>     recycling clean cache be a prohibitive part of workload warmup?
>> It is nothing about recycling. Those page caches might be referenced by
>> memcg just once, then nobody touch them until memory pressure is hit. And,
>> they might be not accessed again at any time soon.
> I meant recycling the page frames, not the cache in them. So the new
> workload as it starts up needs to take those pages from the LRU list
> instead of just the allocator freelist. While that's obviously not the
> same cost, it's not clear why the difference would be prohibitive to
> application startup especially since app startup tends to be dominated
> by things like IO to fault in executables etc.

I'm a little bit confused here. Even though those page frames are not 
reclaimed by force_empty, they would be reclaimed by kswapd later when 
memory pressure is hit. For some usecases, they may prefer get recycled 
before kswapd kick them out LRU, but for some usecases avoiding memory 
pressure might outpace page frame recycling.

>
>>> - Why you couldn't set memory.high or memory.max to 0 after the
>>>     application quits and before you call rmdir on the cgroup
>> I recall I explained this in the review email for the first version. Set
>> memory.high or memory.max to 0 would trigger direct reclaim which may stall
>> the offline of memcg. But, we have "restarting the same name job" logic in
>> our usecase (I'm not quite sure why they do so). Basically, it means to
>> create memcg with the exact same name right after the old one is deleted,
>> but may have different limit or other settings. The creation has to wait for
>> rmdir is done.
> This really needs a fix on your end. We cannot add new cgroup control
> files because you cannot handle a delayed release in the cgroupfs
> namespace while you're reclaiming associated memory. A simple serial
> number would fix this.
>
> Whether others have asked for this knob or not, these patches should
> come with a solid case in the cover letter and changelogs that explain
> why this ABI is necessary to solve a generic cgroup usecase. But it
> sounds to me that setting the limit to 0 once the group is empty would
> meet the functional requirement (use fork() if you don't want to wait)
> of what you are trying to do.

Do you mean do something like the below:

echo 0 > cg1/memory.max &
rmdir cg1 &
mkdir cg1 &

But, the latency is still there, even though memcg creation (mkdir) can 
be done very fast by using fork(), the latency would delay afterwards 
operations, i.e. attaching tasks (echo PID > cg1/cgroup.procs). When we 
calculating the time consumption of the container deployment, we would 
count from mkdir to the job is actually launched.

So, without delaying force_empty to offline kworker, we still suffer 
from the latency.

Am I missing anything?

Thanks,
Yang

>
> I don't think the new interface bar is met here.
