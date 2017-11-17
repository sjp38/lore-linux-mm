Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 761CA6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 12:41:33 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 72so3905960itl.1
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 09:41:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i93sor2004267ioo.204.2017.11.17.09.41.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 09:41:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod77t3FWgO+rNLHDGU9TZUH-_3qBpzt86BC6R8JJK2ZZ=g@mail.gmail.com>
References: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
 <20171117155509.GA920@castle> <CALOAHbAWvYKve4eB9+zissgi24cNKeFih1=avfSi_dH5upQVOg@mail.gmail.com>
 <20171117164531.GA23745@castle> <CALOAHbABr5gVL0f5LX5M2NstZ=FqzaFxrohu8B97uhrSo6Jp2Q@mail.gmail.com>
 <CALvZod77t3FWgO+rNLHDGU9TZUH-_3qBpzt86BC6R8JJK2ZZ=g@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 18 Nov 2017 01:41:31 +0800
Message-ID: <CALOAHbB6+uGNm_RdMiLNCzu+NwZLYcqYJmAZ0FcE8HZts8=JdA@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2017-11-18 1:35 GMT+08:00 Shakeel Butt <shakeelb@google.com>:
> On Fri, Nov 17, 2017 at 9:09 AM, Yafang Shao <laoar.shao@gmail.com> wrote:
>> 2017-11-18 0:45 GMT+08:00 Roman Gushchin <guro@fb.com>:
>>> On Sat, Nov 18, 2017 at 12:20:40AM +0800, Yafang Shao wrote:
>>>> 2017-11-17 23:55 GMT+08:00 Roman Gushchin <guro@fb.com>:
>>>> > On Thu, Nov 16, 2017 at 08:43:17PM -0800, Shakeel Butt wrote:
>>>> >> On Thu, Nov 16, 2017 at 7:09 PM, Yafang Shao <laoar.shao@gmail.com> wrote:
>>>> >> > Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
>>>> >> > without "-o size=XXX".
>>>> >> > When we mount tmpfs in a container(i.e. docker), it is also
>>>> >> > totalram_pages / 2 regardless of the memory limit on this container.
>>>> >> > That may easily cause OOM if tmpfs occupied too much memory when swap is
>>>> >> > off.
>>>> >> > So when we mount tmpfs in a memcg, the default size should be limited by
>>>> >> > the memcg memory.limit.
>>>> >> >
>>>> >>
>>>> >> The pages of the tmpfs files are charged to the memcg of allocators
>>>> >> which can be in memcg different from the memcg in which the mount
>>>> >> operation happened. So, tying the size of a tmpfs mount where it was
>>>> >> mounted does not make much sense.
>>>> >
>>>> > Also, memory limit is adjustable,
>>>>
>>>> Yes. But that's irrelevant.
>>>>
>>>> > and using a particular limit value
>>>> > at a moment of tmpfs mounting doesn't provide any warranties further.
>>>> >
>>>>
>>>> I can not agree.
>>>> The default size of tmpfs is totalram / 2, the reason we do this is to
>>>> provide any warranties further IMHO.
>>>>
>>>> > Is there a reason why the userspace app which is mounting tmpfs can't
>>>> > set the size based on memory.limit?
>>>>
>>>> That's because of misuse.
>>>> The application should set size with "-o size=" when mount tmpfs, but
>>>> not all applications do this.
>>>> As we can't guarantee that all applications will do this, we should
>>>> give them a proper default value.
>>>
>>> The value you're suggesting is proper only if an app which is mounting
>>> tmpfs resides in the same memcg
>>
>> Yes.
>> But maybe that's mostly used today?
>>
>>> and the memory limit will not be adjusted
>>> significantly later.
>>
>> There's a similar issue for physical memory adjusted by memory hotplug.
>> So what will happen if the physical memory adjusted significantly later ?
>>
>>> Otherwise you can end up with a default value, which
>>> is worse than totalram/2, for instance, if tmpfs is mounted by some helper,
>>> which is located in a separate and very limited memcg.
>>
>> That may happen.
>> Maybe we could improve the solution to handle this issue ?
>>
>>
>
> Let's backtrack, what is the actual concern? If a user/process inside
> a memcg is allocating pages for a file on a tmpfs mounted without size
> parameter, you want the OS to return ENOSPC (if allocation is done by
> write syscall) earlier to not cause the user/process's memcg to OOM.
> Is that right?
>

Right.

> First, there is no guarantee to not cause OOM by restricting tmpfs to
> half the size of memcg limit due to the presence of other memory
> charged to that memcg. The memcg can OOM even before the tmpfs hits
> its size.
>

Just guarantee that the OOM not caused by misuse of tmpfs.

> Second, the users who really care to avoid such scenario should just
> set the size parameter of tmpfs.

Of couse that is the best way.
But we can not ensue all applications will do it.
That's why I introduce a proper defalut value for them.


Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
