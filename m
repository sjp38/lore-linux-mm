Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C96018E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 13:20:25 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id e185so23978107oih.18
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 10:20:25 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t25si27325736oth.275.2019.01.03.10.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 10:20:24 -0800 (PST)
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force
 empty
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com>
 <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
 <CALvZod5cZ60VkrxuO8o9dnSOhGmNt21o+NoS5Qy1Mh3-k6suyw@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ce624a97-71b3-162b-5f61-8ee3c0bc2c77@linux.alibaba.com>
Date: Thu, 3 Jan 2019 10:19:23 -0800
MIME-Version: 1.0
In-Reply-To: <CALvZod5cZ60VkrxuO8o9dnSOhGmNt21o+NoS5Qy1Mh3-k6suyw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/3/19 9:03 AM, Shakeel Butt wrote:
> On Thu, Jan 3, 2019 at 8:57 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>
>>
>> On 1/2/19 1:45 PM, Shakeel Butt wrote:
>>> On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>>> The typical usecase of force empty is to try to reclaim as much as
>>>> possible memory before offlining a memcg.  Since there should be no
>>>> attached tasks to offlining memcg, the tasks anonymous pages would have
>>>> already been freed or uncharged.
>>> Anon pages can come from tmpfs files as well.
>> Yes, but they are charged to swap space as regular anon pages.
>>
> The point was the lifetime of tmpfs anon pages are not tied to any
> task. Even though there aren't any task attached to a memcg, the tmpfs
> anon pages will remain charged. Other than that, the old anon pages of
> a task which have migrated away might still be charged to the old
> memcg (if move_charge_at_immigrate is not set).

Yes, my understanding is even though they are swapped out but they are 
still charged to memsw for cgroupv1. force_empty is supposed to reclaim 
as much as possible memory, here I'm supposed "reclaim" also means 
"uncharge".

Even though the anon pages are still charged to the old memcg, it will 
be moved the new memcg when the old one is deleted, or the pages will be 
just released if the task is killed.

So, IMHO, I don't see the point why swapping anon pages when doing 
force_empty.

Thanks,
Yang

>>>> Even though anonymous pages get
>>>> swapped out, but they still get charged to swap space.  So, it sounds
>>>> pointless to do swap for force empty.
>>>>
>>> I understand that force_empty is typically used before rmdir'ing a
>>> memcg but it might be used differently by some users. We use this
>>> interface to test memory reclaim behavior (anon and file).
>> Thanks for sharing your usecase. So, you uses this for test only?
>>
> Yes.
>
> Shakeel
