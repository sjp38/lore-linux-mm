Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 605B06B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 08:05:09 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id b80so14665576iob.23
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 05:05:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m67sor6967654ite.16.2017.11.20.05.05.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 05:05:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171120123933.fh5mnslggk4kys7d@dhcp22.suse.cz>
References: <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
 <20171117155509.GA920@castle> <CALOAHbAWvYKve4eB9+zissgi24cNKeFih1=avfSi_dH5upQVOg@mail.gmail.com>
 <20171117164531.GA23745@castle> <CALOAHbABr5gVL0f5LX5M2NstZ=FqzaFxrohu8B97uhrSo6Jp2Q@mail.gmail.com>
 <CALvZod77t3FWgO+rNLHDGU9TZUH-_3qBpzt86BC6R8JJK2ZZ=g@mail.gmail.com>
 <CALOAHbB6+uGNm_RdMiLNCzu+NwZLYcqYJmAZ0FcE8HZts8=JdA@mail.gmail.com>
 <CALvZod6=-dxhaeQMEBwJ5o6iyVhvQ_jdNck-yWncFVRvkb1YXQ@mail.gmail.com>
 <20171120120422.a6r4govoyxjbgp7w@dhcp22.suse.cz> <CALOAHbCRdPSQ8RNZxYY292fsgBTGf92PWPjvnXpbbVVv5LeL6A@mail.gmail.com>
 <20171120123933.fh5mnslggk4kys7d@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 20 Nov 2017 21:05:05 +0800
Message-ID: <CALOAHbBC6dGfGiz0hD5K8jX4ygHD1NOcoQ0X3tiBcY5eRXRX3Q@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2017-11-20 20:39 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Mon 20-11-17 20:16:15, Yafang Shao wrote:
>> 2017-11-20 20:04 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
>> > On Fri 17-11-17 09:49:54, Shakeel Butt wrote:
>> >> On Fri, Nov 17, 2017 at 9:41 AM, Yafang Shao <laoar.shao@gmail.com> wrote:
>> > [...]
>> >> > Of couse that is the best way.
>> >> > But we can not ensue all applications will do it.
>> >> > That's why I introduce a proper defalut value for them.
>> >> >
>> >>
>> >> I think we disagree on the how to get proper default value. Unless you
>> >> can restrict that all the memory allocated for a tmpfs mount will be
>> >> charged to a specific memcg, you should not just pick limit of the
>> >> memcg of the process mounting the tmpfs to set the default of tmpfs
>> >> mount. If you can restrict tmpfs charging to a specific memcg then the
>> >> limit of that memcg should be used to set the default of the tmpfs
>> >> mount. However this feature is not present in the upstream kernel at
>> >> the moment (We have this feature in our local kernel and I am planning
>> >> to upstream that).
>> >
>> > I think the whole problem is that containers pretend to be independent
>> > while they share a non-reclaimable resource. Fix this and you will not
>> > have a problem. I am afraid that the only real fix is to make tmpfs
>> > private per container instance and that is something you can easily
>> > achieve in the userspace.
>> >
>>
>> Agree with you.
>
> I suspect you misunderstood...
>
>> Introduce tmpfs stat in memory cgroup, something like
>> memory.tmpfs.limit
>> memory.tmpfs.usage
>>
>> IMHO this is the best solution.
>
> No, you misunderstood. I do not think that we want to split tmpfs out of
> the regular limit. We used to have something like that for user vs.
> kernel memory accounting  in v1 and that turned to be not working well.
>

understood.
That really doesn't work well.

> What you really want to do is to make a private mount per container to
> ensure that the resource is really _yours_
> --

That is what I'm doing it currently.
Then setting the default size depends on the container memory limit works well.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
