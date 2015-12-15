Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC666B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 22:13:20 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so114397318pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 19:13:19 -0800 (PST)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id dz4si14222895pab.235.2015.12.14.19.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 19:13:19 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 0EB0DAC0136
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:13:13 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <566F8528.9060205@jp.fujitsu.com>
Date: Tue, 15 Dec 2015 12:12:40 +0900
MIME-Version: 1.0
In-Reply-To: <20151214153037.GB4339@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/15 0:30, Michal Hocko wrote:
> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
>> In the legacy hierarchy we charge memsw, which is dubious, because:
>>
>>   - memsw.limit must be >= memory.limit, so it is impossible to limit
>>     swap usage less than memory usage. Taking into account the fact that
>>     the primary limiting mechanism in the unified hierarchy is
>>     memory.high while memory.limit is either left unset or set to a very
>>     large value, moving memsw.limit knob to the unified hierarchy would
>>     effectively make it impossible to limit swap usage according to the
>>     user preference.
>>
>>   - memsw.usage != memory.usage + swap.usage, because a page occupying
>>     both swap entry and a swap cache page is charged only once to memsw
>>     counter. As a result, it is possible to effectively eat up to
>>     memory.limit of memory pages *and* memsw.limit of swap entries, which
>>     looks unexpected.
>>
>> That said, we should provide a different swap limiting mechanism for
>> cgroup2.
>> This patch adds mem_cgroup->swap counter, which charges the actual
>> number of swap entries used by a cgroup. It is only charged in the
>> unified hierarchy, while the legacy hierarchy memsw logic is left
>> intact.
>
> I agree that the previous semantic was awkward. The problem I can see
> with this approach is that once the swap limit is reached the anon
> memory pressure might spill over to other and unrelated memcgs during
> the global memory pressure. I guess this is what Kame referred to as
> anon would become mlocked basically. This would be even more of an issue
> with resource delegation to sub-hierarchies because nobody will prevent
> setting the swap amount to a small value and use that as an anon memory
> protection.
>
> I guess this was the reason why this approach hasn't been chosen before

Yes. At that age, "never break global VM" was the policy. And "mlock" can be
used for attacking system.

> but I think we can come up with a way to stop the run away consumption
> even when the swap is accounted separately. All of them are quite nasty
> but let me try.
>
> We could allow charges to fail even for the high limit if the excess is
> way above the amount of reclaimable memory in the given memcg/hierarchy.
> A runaway load would be stopped before it can cause a considerable
> damage outside of its hierarchy this way even when the swap limit
> is configured small.
> Now that goes against the high limit semantic which should only throttle
> the consumer and shouldn't cause any functional failures but maybe this
> is acceptable for the overall system stability. An alternative would
> be to throttle in the high limit reclaim context proportionally to
> the excess. This is normally done by the reclaim itself but with no
> reclaimable memory this wouldn't work that way.
>
This seems hard to use for users who want to control resource precisely
even if stability is good.

> Another option would be to ignore the swap limit during the global
> reclaim. This wouldn't stop the runaway loads but they would at least
> see their fair share of the reclaim. The swap excess could be then used
> as a "handicap" for a more aggressive throttling during high limit reclaim
> or to trigger hard limit sooner.
>
This seems to work. But users need to understand swap-limit can be exceeded.

> Or we could teach the global OOM killer to select abusive anon memory
> users with restricted swap. That would require to iterate through all
> memcgs and checks whether their anon consumption is in a large excess to
> their swap limit and fallback to the memcg OOM victim selection if that
> is the case. This adds more complexity to the OOM killer path so I am
> not sure this is generally acceptable, though.
>

I think this is not acceptable.

> My question now is. Is the knob usable/useful even without additional
> heuristics? Do we want to protect swap space so rigidly that a swap
> limited memcg can cause bigger problems than without the swap limit
> globally?
>

swap requires some limit. If not, an application can eat up all swap
and it will not be never freed until the application access it or
swapoff runs.

Thanks,
-Kame

>> The swap usage can be monitored using new memory.swap.current file and
>> limited using memory.swap.max.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
>> ---
>>   include/linux/memcontrol.h |   1 +
>>   include/linux/swap.h       |   5 ++
>>   mm/memcontrol.c            | 123 +++++++++++++++++++++++++++++++++++++++++----
>>   mm/shmem.c                 |   4 ++
>>   mm/swap_state.c            |   5 ++
>>   5 files changed, 129 insertions(+), 9 deletions(-)
>
> [...]
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
