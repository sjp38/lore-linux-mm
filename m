Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCC26B026C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:26:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w21-v6so1154791wmc.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:26:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor1799072wrv.61.2018.07.18.08.26.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 08:26:57 -0700 (PDT)
MIME-Version: 1.0
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
In-Reply-To: <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 18 Jul 2018 08:26:45 -0700
Message-ID: <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bmerry@ska.ac.za
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Jul 18, 2018 at 7:29 AM Bruce Merry <bmerry@ska.ac.za> wrote:
>
> On 18 July 2018 at 12:42, Michal Hocko <mhocko@kernel.org> wrote:
> > [CC some more people]
> >
> > On Tue 17-07-18 21:23:07, Andrew Morton wrote:
> >> (cc linux-mm)
> >>
> >> On Tue, 3 Jul 2018 08:43:23 +0200 Bruce Merry <bmerry@ska.ac.za> wrote:
> >>
> >> > Hi
> >> >
> >> > I've run into an odd performance issue in the kernel, and not being a
> >> > kernel dev or knowing terribly much about cgroups, am looking for
> >> > advice on diagnosing the problem further (I discovered this while
> >> > trying to pin down high CPU load in cadvisor).
> >> >
> >> > On some machines in our production system, cat
> >> > /sys/fs/cgroup/memory/memory.stat is extremely slow (500ms on one
> >> > machine), while on other nominally identical machines it is fast
> >> > (2ms).
> >
> > Could you try to use ftrace to see where the time is spent?
>
> Thanks for looking into this. I'm not familiar with ftrace. Can you
> give me a specific command line to run? Based on "perf record cat
> /sys/fs/cgroup/memory/memory.stat"/"perf report", I see the following:
>
>   42.09%  cat      [kernel.kallsyms]  [k] memcg_stat_show
>   29.19%  cat      [kernel.kallsyms]  [k] memcg_sum_events.isra.22
>   12.41%  cat      [kernel.kallsyms]  [k] mem_cgroup_iter
>    5.42%  cat      [kernel.kallsyms]  [k] _find_next_bit
>    4.14%  cat      [kernel.kallsyms]  [k] css_next_descendant_pre
>    3.44%  cat      [kernel.kallsyms]  [k] find_next_bit
>    2.84%  cat      [kernel.kallsyms]  [k] mem_cgroup_node_nr_lru_pages
>

It seems like you are using cgroup-v1. How many nodes are there in
your memcg tree and also how many cpus does the system have?

Please note that memcg_stat_show or reading memory.stat in cgroup-v1
is not optimized as cgroup-v2. The function memcg_stat_show() in 4.13
does ~17 tree walks and then for ~12 of those tree walks, it goes
through all cpus for each node in the memcg tree. In 4.16,
a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat
reporting") optimizes aways the cpu traversal at the expense of some
accuracy. Next optimization would be to do just one memcg tree
traversal similar to cgroup-v2's memory_stat_show().

Anyways, is it possible for you to try 4.16 kernel?

Shakeel
