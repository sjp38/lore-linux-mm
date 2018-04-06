Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6376B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 07:43:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so687341plm.12
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 04:43:25 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00107.outbound.protection.outlook.com. [40.107.0.107])
        by mx.google.com with ESMTPS id n11-v6si10392455plp.636.2018.04.06.04.43.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 04:43:23 -0700 (PDT)
Subject: Re: [PATCH v2 4/4] mm/vmscan: Don't mess with pgdat->flags in memcg
 reclaim.
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180323152029.11084-5-aryabinin@virtuozzo.com>
 <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <72db1bfb-aa79-3764-54fd-2c7ddbd07bea@virtuozzo.com>
Date: Fri, 6 Apr 2018 14:44:09 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>

On 04/06/2018 05:13 AM, Shakeel Butt wrote:
> On Fri, Mar 23, 2018 at 8:20 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> memcg reclaim may alter pgdat->flags based on the state of LRU lists
>> in cgroup and its children. PGDAT_WRITEBACK may force kswapd to sleep
>> congested_wait(), PGDAT_DIRTY may force kswapd to writeback filesystem
>> pages. But the worst here is PGDAT_CONGESTED, since it may force all
>> direct reclaims to stall in wait_iff_congested(). Note that only kswapd
>> have powers to clear any of these bits. This might just never happen if
>> cgroup limits configured that way. So all direct reclaims will stall
>> as long as we have some congested bdi in the system.
>>
>> Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
>> pgdat, only kswapd can clear pgdat->flags once node is balance, thus
>> it's reasonable to leave all decisions about node state to kswapd.
> 
> What about global reclaimers? Is the assumption that when global
> reclaimers hit such condition, kswapd will be running and correctly
> set PGDAT_CONGESTED?
> 

The reason I moved this under if(current_is_kswapd()) is because only kswapd
can clear these flags. I'm less worried about the case when PGDAT_CONGESTED falsely
not set, and more worried about the case when it falsely set. If direct reclaimer sets
PGDAT_CONGESTED, do we have guarantee that, after congestion problem is sorted, kswapd 
ill be woken up and clear the flag? It seems like there is no such guarantee.
E.g. direct reclaimers may eventually balance pgdat and kswapd simply won't wake up
(see wakeup_kswapd()).



>>  static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
>>  {
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 4525b4404a9e..44422e1d3def 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -190,6 +190,8 @@ struct mem_cgroup {
>>         /* vmpressure notifications */
>>         struct vmpressure vmpressure;
>>
>> +       unsigned long flags;
>> +
> 
> nit(you can ignore it): The name 'flags' is too general IMO. Something
> more specific would be helpful.
> 
> Question: Does this 'flags' has any hierarchical meaning? Does
> congested parent means all descendents are congested?

It's the same as with pgdat->flags. Cgroup (or pgdat) is congested if at least one cgroup
in the hierarchy (in pgdat) is congested and the rest are all either also congested or don't have
any file pages to reclaim (nr_file_taken == 0).

> Question: Should this 'flags' be per-node? Is it ok for a congested
> memcg to call wait_iff_congested for all nodes?
> 

Yes, it should be per-node. I'll try to replace ->flags with 'bool congested'
in struct mem_cgroup_per_node.
