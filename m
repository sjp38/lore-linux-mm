Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56CB16B027C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:37:45 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id 11-v6so1796176vko.21
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:37:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y43-v6sor150969uac.184.2018.07.18.08.37.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 08:37:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Wed, 18 Jul 2018 17:37:43 +0200
Message-ID: <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 18 July 2018 at 17:26, Shakeel Butt <shakeelb@google.com> wrote:
> On Wed, Jul 18, 2018 at 7:29 AM Bruce Merry <bmerry@ska.ac.za> wrote:
> It seems like you are using cgroup-v1. How many nodes are there in
> your memcg tree and also how many cpus does the system have?

>From my original email: "there are 106 memory.stat files in
/sys/fs/cgroup/memory." - is that what you mean by the number of
nodes?

The affected systems all have 8 CPU cores (hyperthreading is disabled).

> Please note that memcg_stat_show or reading memory.stat in cgroup-v1
> is not optimized as cgroup-v2. The function memcg_stat_show() in 4.13
> does ~17 tree walks and then for ~12 of those tree walks, it goes
> through all cpus for each node in the memcg tree. In 4.16,
> a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat
> reporting") optimizes aways the cpu traversal at the expense of some
> accuracy. Next optimization would be to do just one memcg tree
> traversal similar to cgroup-v2's memory_stat_show().

On most machines it is still fast (1-2ms), and there is no difference
in the number of CPUs and only very small differences in the number of
live memory cgroups, so presumably something else is going on.

> The memcg tree does include all zombie memcgs and these zombies does
> contribute to the memcg_stat_show cost.

That sounds promising. Is there any way to tell how many zombies there
are, and is there any way to deliberately create zombies? If I can
produce zombies that might give me a reliable way to reproduce the
problem, which could then sensibly be tested against newer kernel
versions.

Thanks
Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
