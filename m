Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC52D6B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:47:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o60-v6so1165337edd.13
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:47:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12-v6si3229492edr.216.2018.07.18.07.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 07:47:11 -0700 (PDT)
Date: Wed, 18 Jul 2018 16:47:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some
 machines
Message-ID: <20180718144710.GI7193@dhcp22.suse.cz>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz>
 <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruce Merry <bmerry@ska.ac.za>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 18-07-18 16:29:20, Bruce Merry wrote:
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

I would just use perf record as you did. How long did the call take?
Also is the excessive time an outlier or a more consistent thing? If the
former does perf record show any difference?

> > memory_stat_show should only scale with the depth of the cgroup
> > hierarchy for memory.stat to get cumulative numbers. All the rest should
> > be simply reads of gathered counters. There is no locking involved in
> > the current kernel. What is the kernel version you are using, btw?
> 
> Ubuntu 16.04 with kernel 4.13.0-41-generic (so presumably includes
> some Ubuntu special sauce).

Do you see the same whe running with the vanilla kernel?
-- 
Michal Hocko
SUSE Labs
