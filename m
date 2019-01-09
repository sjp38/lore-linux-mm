Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFDC8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 17:11:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so6231063pfj.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 14:11:22 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id s8si2795199plq.345.2019.01.09.14.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 14:11:21 -0800 (PST)
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
 <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
Date: Wed, 9 Jan 2019 14:09:20 -0800
MIME-Version: 1.0
In-Reply-To: <20190109212334.GA18978@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/9/19 1:23 PM, Johannes Weiner wrote:
> On Wed, Jan 09, 2019 at 12:36:11PM -0800, Yang Shi wrote:
>> As I mentioned above, if we know some page caches from some memcgs
>> are referenced one-off and unlikely shared, why just keep them
>> around to increase memory pressure?
> It's just not clear to me that your scenarios are generic enough to
> justify adding two interfaces that we have to maintain forever, and
> that they couldn't be solved with existing mechanisms.
>
> Please explain:
>
> - Unmapped clean page cache isn't expensive to reclaim, certainly
>    cheaper than the IO involved in new application startup. How could
>    recycling clean cache be a prohibitive part of workload warmup?

It is nothing about recycling. Those page caches might be referenced by 
memcg just once, then nobody touch them until memory pressure is hit. 
And, they might be not accessed again at any time soon.

>
> - Why you cannot temporarily raise the kswapd watermarks right before
>    an important application starts up (your answer was sorta handwavy)

It could, but kswapd watermark is global. Boosting kswapd watermark may 
cause kswapd reclaim some memory from some memcgs which we want to keep 
untouched. Although v2's low/min could provide some protection, it is 
still not prohibited generally. And, v1 doesn't have such protection at all.

force_empty or wipe_on_offline could be used to target to some specific 
memcgs which we may know exactly what they do or it is safe to reclaim 
memory from them. IMHO, this may make better isolation.

>
> - Why you cannot use madvise/fadvise when an application whose cache
>    you won't reuse exits

Sure we can. But, we can't guarantee all applications use them properly.

>
> - Why you couldn't set memory.high or memory.max to 0 after the
>    application quits and before you call rmdir on the cgroup

I recall I explained this in the review email for the first version. Set 
memory.high or memory.max to 0 would trigger direct reclaim which may 
stall the offline of memcg. But, we have "restarting the same name job" 
logic in our usecase (I'm not quite sure why they do so). Basically, it 
means to create memcg with the exact same name right after the old one 
is deleted, but may have different limit or other settings. The creation 
has to wait for rmdir is done.

>
> Adding a permanent kernel interface is a serious measure. I think you
> need to make a much better case for it, discuss why other options are
> not practical, and show that this will be a generally useful thing for
> cgroup users and not just a niche fix for very specific situations.

I do understand your concern and the maintenance cost for a permanent 
kernel interface. I'm not quite sure if this is generic enough, however, 
Michal Hocko did mention "It seems we have several people asking for 
something like that already.", so at least it sounds not like "a niche 
fix for very specific situations".

In my first submit, I did reuse force_empty interface to keep it less 
intrusive, at least not a new interface. Since we have several people 
asking for something like that already, Michal suggested a new knob 
instead of reusing force_empty.

Thanks,
Yang
