Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3F9F6B6DCF
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:45:43 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id m16so8605190pgd.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:45:43 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id z136si15432121pgz.28.2018.12.04.00.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 00:45:42 -0800 (PST)
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH 2/3] mm/vmscan: Enable kswapd to reclaim low-protected
 memory
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-2-xlpang@linux.alibaba.com>
 <20181203115646.GP31738@dhcp22.suse.cz>
 <54a3f0a6-6e7d-c620-97f2-ac567c057bc2@linux.alibaba.com>
 <20181203172007.GG31738@dhcp22.suse.cz>
 <a77ed2a6-ed9b-4c1b-e2e9-fb9a5108c1f9@linux.alibaba.com>
 <20181204072508.GU31738@dhcp22.suse.cz>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <4e06fac2-7269-23a7-e4f5-18928998ece2@linux.alibaba.com>
Date: Tue, 4 Dec 2018 16:44:40 +0800
MIME-Version: 1.0
In-Reply-To: <20181204072508.GU31738@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/12/4 PM 3:25, Michal Hocko wrote:
> On Tue 04-12-18 10:40:29, Xunlei Pang wrote:
>> On 2018/12/4 AM 1:22, Michal Hocko wrote:
>>> On Mon 03-12-18 23:20:31, Xunlei Pang wrote:
>>>> On 2018/12/3 下午7:56, Michal Hocko wrote:
>>>>> On Mon 03-12-18 16:01:18, Xunlei Pang wrote:
>>>>>> There may be cgroup memory overcommitment, it will become
>>>>>> even common in the future.
>>>>>>
>>>>>> Let's enable kswapd to reclaim low-protected memory in case
>>>>>> of memory pressure, to mitigate the global direct reclaim
>>>>>> pressures which could cause jitters to the response time of
>>>>>> lantency-sensitive groups.
>>>>>
>>>>> Please be more descriptive about the problem you are trying to handle
>>>>> here. I haven't actually read the patch but let me emphasise that the
>>>>> low limit protection is important isolation tool. And allowing kswapd to
>>>>> reclaim protected memcgs is going to break the semantic as it has been
>>>>> introduced and designed.
>>>>
>>>> We have two types of memcgs: online groups(important business)
>>>> and offline groups(unimportant business). Online groups are
>>>> all configured with MAX low protection, while offline groups
>>>> are not at all protected(with default 0 low).
>>>>
>>>> When offline groups are overcommitted, the global memory pressure
>>>> suffers. This will cause the memory allocations from online groups
>>>> constantly go to the slow global direct reclaim in order to reclaim
>>>> online's page caches, as kswap is not able to reclaim low-protection
>>>> memory. low is not hard limit, it's reasonable to be reclaimed by
>>>> kswapd if there's no other reclaimable memory.
>>>
>>> I am sorry I still do not follow. What role do offline cgroups play.
>>> Those are certainly not low mem protected because mem_cgroup_css_offline
>>> will reset them to 0.
>>>
>>
>> Oh, I meant "offline groups" to be "offline-business groups", memcgs
>> refered to here are all "online state" from kernel's perspective.
> 
> What is offline-business group? Please try to explain the actual problem
> in much more details and do not let us guess.
> 

Maybe I choosed the wrong word, let me rephase it, and
here is an example.

                root 200GB
           /                  \
important(100GB)  unimportant(100GB+DYNAMIC)
  /     |      \         /          \
docker0 docker1...  normal(100GB) oversold(DYNAMIC)
                      /  |  \      / |  \
                     j0 j1 ...    w0 w1 ...

"DYNAMIC" is controlled by the cluster job scheduler dynamically,
it periodically samples the available system memory(/proc/meminfo
"MemAvailable"), and use part of that to launch oversold jobs
under some special conditions. When "oversold" is active, the
whole system is put under heavy global memory pressure although
memcgs are not.

IOW "DYNAMIC" is primarily borrowed from "dockers" temporarily,
oversold workers will be killed in a timely fashion if "dockers"
needs their memory back suddenly which is rare.

If kswapd doesn't reclaim low-protected memory configured among
"important" dockers, memory allocations from dockers will trap
into global direct reclaim constantly which harms their performance
and response time. The inactive caches from dockers are allowed
to be reclaimed although they are under low-protected(we used a
simple MAX setting), we allow the inactive low-protected memory
to be reclaimed immediately and asynchronously as long as there's
no unprotected reclaimable memory. Its's also friendly to disk IO.

For really latency-sensitive docker, memory.min is supposed to be
used to guarantee its memory QoS.

Thanks
