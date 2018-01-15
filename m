Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28EAF6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:05:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a6so7324598wrh.10
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:05:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c9sor41595wrg.66.2018.01.15.09.05.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 09:05:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <e5e92227-0931-dfc1-841e-c036131e66a8@virtuozzo.com>
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com> <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com> <20180111124629.GA1732@dhcp22.suse.cz>
 <ce885a69-67af-5f4c-1116-9f6803fb45ee@virtuozzo.com> <20180111162947.GG1732@dhcp22.suse.cz>
 <560a77b5-02d7-cbae-35f3-0b20a1c384c2@virtuozzo.com> <20180112122405.GK1732@dhcp22.suse.cz>
 <CALvZod6y8EfQt02+rNOP_JXgzpJJHjuVzd++T3E=NEMwwBv_CQ@mail.gmail.com> <e5e92227-0931-dfc1-841e-c036131e66a8@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 15 Jan 2018 09:04:58 -0800
Message-ID: <CALvZod6k-pwbVRFis0QyGeQbAdmBHx2V0suD_7r-0OTfdxJhGA@mail.gmail.com>
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease [memory,memsw].limit_in_bytes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 15, 2018 at 4:29 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 01/13/2018 01:57 AM, Shakeel Butt wrote:
>> On Fri, Jan 12, 2018 at 4:24 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>> On Fri 12-01-18 00:59:38, Andrey Ryabinin wrote:
>>>> On 01/11/2018 07:29 PM, Michal Hocko wrote:
>>> [...]
>>>>> I do not think so. Consider that this reclaim races with other
>>>>> reclaimers. Now you are reclaiming a large chunk so you might end up
>>>>> reclaiming more than necessary. SWAP_CLUSTER_MAX would reduce the over
>>>>> reclaim to be negligible.
>>>>>
>>>>
>>>> I did consider this. And I think, I already explained that sort of race in previous email.
>>>> Whether "Task B" is really a task in cgroup or it's actually a bunch of reclaimers,
>>>> doesn't matter. That doesn't change anything.
>>>
>>> I would _really_ prefer two patches here. The first one removing the
>>> hard coded reclaim count. That thing is just dubious at best. If you
>>> _really_ think that the higher reclaim target is meaningfull then make
>>> it a separate patch. I am not conviced but I will not nack it it either.
>>> But it will make our life much easier if my over reclaim concern is
>>> right and we will need to revert it. Conceptually those two changes are
>>> independent anywa.
>>>
>>
>> Personally I feel that the cgroup-v2 semantics are much cleaner for
>> setting limit. There is no race with the allocators in the memcg,
>> though oom-killer can be triggered. For cgroup-v1, the user does not
>> expect OOM killer and EBUSY is expected on unsuccessful reclaim. How
>> about we do something similar here and make sure oom killer can not be
>> triggered for the given memcg?
>>
>> // pseudo code
>> disable_oom(memcg)
>> old = xchg(&memcg->memory.limit, requested_limit)
>>
>> reclaim memory until usage gets below new limit or retries are exhausted
>>
>> if (unsuccessful) {
>>   reset_limit(memcg, old)
>>   ret = EBUSY
>> } else
>>   ret = 0;
>> enable_oom(memcg)
>>
>> This way there is no race with the allocators and oom killer will not
>> be triggered. The processes in the memcg can suffer but that should be
>> within the expectation of the user. One disclaimer though, disabling
>> oom for memcg needs more thought.
>
> That's might be worse. If limit is too low, all allocations (except __GFP_NOFAIL of course) will start
> failing. And the kernel not always careful enough in -ENOMEM handling.
> Also, it's not much different from oom killing everything, the end result is almost the same -
> nothing will work in that cgroup.
>

By disabling memcg oom, I meant to treat all allocations from that
memcg as __GFP_NOFAIL until the oom is disabled. I will see if I can
convert this into an actual code.

>
>> Shakeel
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
