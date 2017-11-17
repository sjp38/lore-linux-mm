Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B92A96B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 11:20:42 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x28so3632433ita.9
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 08:20:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o11sor3063768ito.73.2017.11.17.08.20.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 08:20:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171117155509.GA920@castle>
References: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com> <20171117155509.GA920@castle>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 18 Nov 2017 00:20:40 +0800
Message-ID: <CALOAHbAWvYKve4eB9+zissgi24cNKeFih1=avfSi_dH5upQVOg@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2017-11-17 23:55 GMT+08:00 Roman Gushchin <guro@fb.com>:
> On Thu, Nov 16, 2017 at 08:43:17PM -0800, Shakeel Butt wrote:
>> On Thu, Nov 16, 2017 at 7:09 PM, Yafang Shao <laoar.shao@gmail.com> wrote:
>> > Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
>> > without "-o size=XXX".
>> > When we mount tmpfs in a container(i.e. docker), it is also
>> > totalram_pages / 2 regardless of the memory limit on this container.
>> > That may easily cause OOM if tmpfs occupied too much memory when swap is
>> > off.
>> > So when we mount tmpfs in a memcg, the default size should be limited by
>> > the memcg memory.limit.
>> >
>>
>> The pages of the tmpfs files are charged to the memcg of allocators
>> which can be in memcg different from the memcg in which the mount
>> operation happened. So, tying the size of a tmpfs mount where it was
>> mounted does not make much sense.
>
> Also, memory limit is adjustable,

Yes. But that's irrelevant.

> and using a particular limit value
> at a moment of tmpfs mounting doesn't provide any warranties further.
>

I can not agree.
The default size of tmpfs is totalram / 2, the reason we do this is to
provide any warranties further IMHO.

> Is there a reason why the userspace app which is mounting tmpfs can't
> set the size based on memory.limit?

That's because of misuse.
The application should set size with "-o size=" when mount tmpfs, but
not all applications do this.
As we can't guarantee that all applications will do this, we should
give them a proper default value.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
