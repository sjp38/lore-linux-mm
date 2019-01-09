Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7268E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 15:40:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so6050254pfb.17
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 12:40:39 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id t4si71348885pfj.183.2019.01.09.12.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 12:40:38 -0800 (PST)
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
Date: Wed, 9 Jan 2019 12:36:11 -0800
MIME-Version: 1.0
In-Reply-To: <20190109193247.GA16319@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/9/19 11:32 AM, Johannes Weiner wrote:
> On Thu, Jan 10, 2019 at 03:14:40AM +0800, Yang Shi wrote:
>> We have some usecases which create and remove memcgs very frequently,
>> and the tasks in the memcg may just access the files which are unlikely
>> accessed by anyone else.  So, we prefer force_empty the memcg before
>> rmdir'ing it to reclaim the page cache so that they don't get
>> accumulated to incur unnecessary memory pressure.  Since the memory
>> pressure may incur direct reclaim to harm some latency sensitive
>> applications.
> We have kswapd for exactly this purpose. Can you lay out more details
> on why that is not good enough, especially in conjunction with tuning
> the watermark_scale_factor etc.?

watermark_scale_factor does help out for some workloads in general. 
However, memcgs might be created then do memory allocation faster than 
kswapd in some our workloads. And, the tune may work for one kind 
machine or workload, but may not work for others. But, we may have 
different kind workloads (for example, latency-sensitive and batch jobs) 
run on the same machine, so it is kind of hard for us to guarantee all 
the workloads work well together by relying on kswapd and 
watermark_scale_factor only.

And, we know the page cache access pattern would be one-off for some 
memcgs, and those page caches are unlikely shared by others, so why not 
just drop them when the memcg is offlined. Reclaiming those cold page 
caches earlier would also improve the efficiency of memcg creation for 
long run.

>
> We've been pretty adamant that users shouldn't use drop_caches for
> performance for example, and that the need to do this usually is
> indicative of a problem or suboptimal tuning in the VM subsystem.
>
> How is this different?

IMHO, that depends on the usecases and workloads. As I mentioned above, 
if we know some page caches from some memcgs are referenced one-off and 
unlikely shared, why just keep them around to increase memory pressure?

Thanks,
Yang
