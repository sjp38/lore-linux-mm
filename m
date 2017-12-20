Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5906B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:16:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o16so2979293wmf.4
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:16:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z193sor1394577wmc.27.2017.12.20.10.15.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 10:15:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171220113404.GN4831@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20171220103337.GL4831@dhcp22.suse.cz> <6e9ee949-c203-621d-890f-25a432bd4bb3@virtuozzo.com>
 <20171220113404.GN4831@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 20 Dec 2017 10:15:57 -0800
Message-ID: <CALvZod7ED3qaqekGTd-2PHmbTjY+D_NcFP1bE5_AgP8OF=jXJw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/memcg: try harder to decrease [memory,memsw].limit_in_bytes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 20, 2017 at 3:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 20-12-17 14:32:19, Andrey Ryabinin wrote:
>> On 12/20/2017 01:33 PM, Michal Hocko wrote:
>> > On Wed 20-12-17 13:24:28, Andrey Ryabinin wrote:
>> >> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
>> >> pages on each iteration. This makes practically impossible to decrease
>> >> limit of memory cgroup. Tasks could easily allocate back 32 pages,
>> >> so we can't reduce memory usage, and once retry_count reaches zero we return
>> >> -EBUSY.
>> >>
>> >> It's easy to reproduce the problem by running the following commands:
>> >>
>> >>   mkdir /sys/fs/cgroup/memory/test
>> >>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
>> >>   cat big_file > /dev/null &
>> >>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>> >>   -bash: echo: write error: Device or resource busy
>> >>
>> >> Instead of trying to free small amount of pages, it's much more
>> >> reasonable to free 'usage - limit' pages.
>> >
>> > But that only makes the issue less probable. It doesn't fix it because
>> >             if (curusage >= oldusage)
>> >                     retry_count--;
>> > can still be true because allocator might be faster than the reclaimer.
>> > Wouldn't it be more reasonable to simply remove the retry count and keep
>> > trying until interrupted or we manage to update the limit.
>>
>> But does it makes sense to continue reclaiming even if reclaimer can't
>> make any progress? I'd say no. "Allocator is faster than reclaimer"
>> may be not the only reason for failed reclaim. E.g. we could try to
>> set limit lower than amount of mlock()ed memory in cgroup, retrying
>> reclaim would be just a waste of machine's resources.  Or we simply
>> don't have any swap, and anon > new_limit. Should be burn the cpu in
>> that case?
>
> We can check the number of reclaimed pages and go EBUSY if it is 0.
>
>> > Another option would be to commit the new limit and allow temporal overcommit
>> > of the hard limit. New allocations and the limit update paths would
>> > reclaim to the hard limit.
>> >
>>
>> It sounds a bit fragile and tricky to me. I wouldn't go that way
>> without unless we have a very good reason for this.
>
> I haven't explored this, to be honest, so there may be dragons that way.
> I've just mentioned that option for completness.
>

We already do this for cgroup-v2's memory.max. So, I don't think it is
fragile or tricky.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
