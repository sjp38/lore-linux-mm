Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBA088E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:11:19 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 123so39594657itv.6
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:11:19 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 142si3966728itk.34.2019.01.03.11.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:11:18 -0800 (PST)
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190103101215.GH31793@dhcp22.suse.cz>
 <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
 <20190103181329.GW31793@dhcp22.suse.cz>
 <6f43e926-3bb5-20d1-2e39-1d30bf7ad375@linux.alibaba.com>
 <20190103185333.GX31793@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d610c665-890f-3bf0-1e2a-437150b6ddfb@linux.alibaba.com>
Date: Thu, 3 Jan 2019 11:10:00 -0800
MIME-Version: 1.0
In-Reply-To: <20190103185333.GX31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/3/19 10:53 AM, Michal Hocko wrote:
> On Thu 03-01-19 10:40:54, Yang Shi wrote:
>>
>> On 1/3/19 10:13 AM, Michal Hocko wrote:
>>> On Thu 03-01-19 09:33:14, Yang Shi wrote:
>>>> On 1/3/19 2:12 AM, Michal Hocko wrote:
>>>>> On Thu 03-01-19 04:05:30, Yang Shi wrote:
>>>>>> Currently, force empty reclaims memory synchronously when writing to
>>>>>> memory.force_empty.  It may take some time to return and the afterwards
>>>>>> operations are blocked by it.  Although it can be interrupted by signal,
>>>>>> it still seems suboptimal.
>>>>> Why it is suboptimal? We are doing that operation on behalf of the
>>>>> process requesting it. What should anybody else pay for it? In other
>>>>> words why should we hide the overhead?
>>>> Please see the below explanation.
>>>>
>>>>>> Now css offline is handled by worker, and the typical usecase of force
>>>>>> empty is before memcg offline.  So, handling force empty in css offline
>>>>>> sounds reasonable.
>>>>> Hmm, so I guess you are talking about
>>>>> echo 1 > $MEMCG/force_empty
>>>>> rmdir $MEMCG
>>>>>
>>>>> and you are complaining that the operation takes too long. Right? Why do
>>>>> you care actually?
>>>> We have some usecases which create and remove memcgs very frequently, and
>>>> the tasks in the memcg may just access the files which are unlikely accessed
>>>> by anyone else. So, we prefer force_empty the memcg before rmdir'ing it to
>>>> reclaim the page cache so that they don't get accumulated to incur
>>>> unnecessary memory pressure. Since the memory pressure may incur direct
>>>> reclaim to harm some latency sensitive applications.
>>> Yes, this makes sense to me.
>>>
>>>> And, the create/remove might be run in a script sequentially (there might be
>>>> a lot scripts or applications are run in parallel to do this), i.e.
>>>> mkdir cg1
>>>> do something
>>>> echo 0 > cg1/memory.force_empty
>>>> rmdir cg1
>>>>
>>>> mkdir cg2
>>>> ...
>>>>
>>>> The creation of the afterwards memcg might be blocked by the force_empty for
>>>> long time if there are a lot page caches, so the overall throughput of the
>>>> system may get hurt.
>>> Is there any reason for your scripts to be strictly sequential here? In
>>> other words why cannot you offload those expensive operations to a
>>> detached context in _userspace_?
>> I would say it has not to be strictly sequential. The above script is just
>> an example to illustrate the pattern. But, sometimes it may hit such pattern
>> due to the complicated cluster scheduling and container scheduling in the
>> production environment, for example the creation process might be scheduled
>> to the same CPU which is doing force_empty. I have to say I don't know too
>> much about the internals of the container scheduling.
> In that case I do not see a strong reason to implement the offloding
> into the kernel. It is an additional code and semantic to maintain.

Yes, it does introduce some additional code and semantic, but IMHO, it 
is quite simple and very straight forward, isn't it? Just utilize the 
existing css offline worker. And, that a couple of lines of code do 
improve some throughput issues for some real usecases.

>
> I think it is more important to discuss whether we want to introduce
> force_empty in cgroup v2.

We would prefer have it in v2 as well.

Thanks,
Yang
