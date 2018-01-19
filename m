Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8C946B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 09:49:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b186so3423739wmf.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 06:49:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c191sor374885wma.46.2018.01.19.06.49.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 06:49:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119133510.GD6584@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-1-aryabinin@virtuozzo.com> <20180119132544.19569-2-aryabinin@virtuozzo.com>
 <20180119133510.GD6584@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 19 Jan 2018 06:49:29 -0800
Message-ID: <CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in mem_cgroup_resize_limit()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, Jan 19, 2018 at 5:35 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 19-01-18 16:25:44, Andrey Ryabinin wrote:
>> Currently mem_cgroup_resize_limit() retries to set limit after reclaiming
>> 32 pages. It makes more sense to reclaim needed amount of pages right away.
>>
>> This works noticeably faster, especially if 'usage - limit' big.
>> E.g. bringing down limit from 4G to 50M:
>>
>> Before:
>>  # perf stat echo 50M > memory.limit_in_bytes
>>
>>      Performance counter stats for 'echo 50M':
>>
>>             386.582382      task-clock (msec)         #    0.835 CPUs utilized
>>                  2,502      context-switches          #    0.006 M/sec
>>
>>            0.463244382 seconds time elapsed
>>
>> After:
>>  # perf stat echo 50M > memory.limit_in_bytes
>>
>>      Performance counter stats for 'echo 50M':
>>
>>             169.403906      task-clock (msec)         #    0.849 CPUs utilized
>>                     14      context-switches          #    0.083 K/sec
>>
>>            0.199536900 seconds time elapsed
>
> But I am not going ack this one. As already stated this has a risk
> of over-reclaim if there a lot of charges are freed along with this
> shrinking. This is more of a theoretical concern so I am _not_ going to

If you don't mind, can you explain why over-reclaim is a concern at
all? The only side effect of over reclaim I can think of is the job
might suffer a bit over (more swapins & pageins). Shouldn't this be
within the expectation of the user decreasing the limits?

> nack. If we ever see such a problem then reverting this patch should be
> pretty straghtforward.
>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

>> Cc: Shakeel Butt <shakeelb@google.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
>> ---
>>  mm/memcontrol.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9d987f3e79dc..09bac2df2f12 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2448,6 +2448,7 @@ static DEFINE_MUTEX(memcg_limit_mutex);
>>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>                                  unsigned long limit, bool memsw)
>>  {
>> +     unsigned long nr_pages;
>>       bool enlarge = false;
>>       int ret;
>>       bool limits_invariant;
>> @@ -2479,8 +2480,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>               if (!ret)
>>                       break;
>>
>> -             if (!try_to_free_mem_cgroup_pages(memcg, 1,
>> -                                     GFP_KERNEL, !memsw)) {
>> +             nr_pages = max_t(long, 1, page_counter_read(counter) - limit);
>> +             if (!try_to_free_mem_cgroup_pages(memcg, nr_pages,
>> +                                             GFP_KERNEL, !memsw)) {
>>                       ret = -EBUSY;
>>                       break;
>>               }
>> --
>> 2.13.6
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
