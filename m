Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5946B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:24:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k13so1427002wrd.7
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:24:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v29sor1585111wra.78.2018.01.19.07.24.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 07:24:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119151118.GE6584@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-1-aryabinin@virtuozzo.com> <20180119132544.19569-2-aryabinin@virtuozzo.com>
 <20180119133510.GD6584@dhcp22.suse.cz> <CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
 <20180119151118.GE6584@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 19 Jan 2018 07:24:08 -0800
Message-ID: <CALvZod6q8ExRW-EkG_eMyJeGhhMcbSQZMQEqmHEHj7PhRYwJ1w@mail.gmail.com>
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in mem_cgroup_resize_limit()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, Jan 19, 2018 at 7:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 19-01-18 06:49:29, Shakeel Butt wrote:
>> On Fri, Jan 19, 2018 at 5:35 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Fri 19-01-18 16:25:44, Andrey Ryabinin wrote:
>> >> Currently mem_cgroup_resize_limit() retries to set limit after reclaiming
>> >> 32 pages. It makes more sense to reclaim needed amount of pages right away.
>> >>
>> >> This works noticeably faster, especially if 'usage - limit' big.
>> >> E.g. bringing down limit from 4G to 50M:
>> >>
>> >> Before:
>> >>  # perf stat echo 50M > memory.limit_in_bytes
>> >>
>> >>      Performance counter stats for 'echo 50M':
>> >>
>> >>             386.582382      task-clock (msec)         #    0.835 CPUs utilized
>> >>                  2,502      context-switches          #    0.006 M/sec
>> >>
>> >>            0.463244382 seconds time elapsed
>> >>
>> >> After:
>> >>  # perf stat echo 50M > memory.limit_in_bytes
>> >>
>> >>      Performance counter stats for 'echo 50M':
>> >>
>> >>             169.403906      task-clock (msec)         #    0.849 CPUs utilized
>> >>                     14      context-switches          #    0.083 K/sec
>> >>
>> >>            0.199536900 seconds time elapsed
>> >
>> > But I am not going ack this one. As already stated this has a risk
>> > of over-reclaim if there a lot of charges are freed along with this
>> > shrinking. This is more of a theoretical concern so I am _not_ going to
>>
>> If you don't mind, can you explain why over-reclaim is a concern at
>> all? The only side effect of over reclaim I can think of is the job
>> might suffer a bit over (more swapins & pageins). Shouldn't this be
>> within the expectation of the user decreasing the limits?
>
> It is not a disaster. But it is an unexpected side effect of the
> implementation. If you have limit 1GB and want to reduce it 500MB
> then it would be quite surprising to land at 200M just because somebody
> was freeing 300MB in parallel. Is this likely? Probably not but the more
> is the limit touched and the larger are the differences the more likely
> it is. Keep retrying in the smaller amounts and you will not see the
> above happening.
>
> And to be honest, I do not really see why keeping retrying from
> mem_cgroup_resize_limit should be so much faster than keep retrying from
> the direct reclaim path. We are doing SWAP_CLUSTER_MAX batches anyway.
> mem_cgroup_resize_limit loop adds _some_ overhead but I am not really
> sure why it should be that large.
>

Thanks for the explanation. Another query, we do not call
drain_all_stock() in mem_cgroup_resize_limit() but memory_max_write()
does call drain_all_stock(). Was this intentional or missed
accidentally?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
