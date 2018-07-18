Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE5CC6B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:29:22 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id u26-v6so1581615uan.23
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:29:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q16-v6sor1448996uaq.127.2018.07.18.07.29.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 07:29:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180718104230.GC1431@dhcp22.suse.cz>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org> <20180718104230.GC1431@dhcp22.suse.cz>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Wed, 18 Jul 2018 16:29:20 +0200
Message-ID: <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 18 July 2018 at 12:42, Michal Hocko <mhocko@kernel.org> wrote:
> [CC some more people]
>
> On Tue 17-07-18 21:23:07, Andrew Morton wrote:
>> (cc linux-mm)
>>
>> On Tue, 3 Jul 2018 08:43:23 +0200 Bruce Merry <bmerry@ska.ac.za> wrote:
>>
>> > Hi
>> >
>> > I've run into an odd performance issue in the kernel, and not being a
>> > kernel dev or knowing terribly much about cgroups, am looking for
>> > advice on diagnosing the problem further (I discovered this while
>> > trying to pin down high CPU load in cadvisor).
>> >
>> > On some machines in our production system, cat
>> > /sys/fs/cgroup/memory/memory.stat is extremely slow (500ms on one
>> > machine), while on other nominally identical machines it is fast
>> > (2ms).
>
> Could you try to use ftrace to see where the time is spent?

Thanks for looking into this. I'm not familiar with ftrace. Can you
give me a specific command line to run? Based on "perf record cat
/sys/fs/cgroup/memory/memory.stat"/"perf report", I see the following:

  42.09%  cat      [kernel.kallsyms]  [k] memcg_stat_show
  29.19%  cat      [kernel.kallsyms]  [k] memcg_sum_events.isra.22
  12.41%  cat      [kernel.kallsyms]  [k] mem_cgroup_iter
   5.42%  cat      [kernel.kallsyms]  [k] _find_next_bit
   4.14%  cat      [kernel.kallsyms]  [k] css_next_descendant_pre
   3.44%  cat      [kernel.kallsyms]  [k] find_next_bit
   2.84%  cat      [kernel.kallsyms]  [k] mem_cgroup_node_nr_lru_pages

> memory_stat_show should only scale with the depth of the cgroup
> hierarchy for memory.stat to get cumulative numbers. All the rest should
> be simply reads of gathered counters. There is no locking involved in
> the current kernel. What is the kernel version you are using, btw?

Ubuntu 16.04 with kernel 4.13.0-41-generic (so presumably includes
some Ubuntu special sauce).

Some new information: when this occurred on another machine I ran
"echo 2 > /proc/sys/vm/drop_caches" to drop the dentry cache, and
performance immediately improved. Unfortunately, I've not been able to
deliberately reproduce the issue. I've tried doing the following 10^7
times in a loop and while it inflates the dentry cache, it doesn't
cause any significant slowdown:
1. Create a temporary cgroup: mkdir /sys/fs/cgroup/memory/<name>.
2. stat /sys/fs/cgroup/memory/<name>/memory.stat
3. rmdir /sys/fs/cgroup/memory/<name>

I've also tried inflating the dentry cache just by stat-ing millions
of non-existent files, and again, no slowdown. So I'm not sure exactly
how dentry cache is related.

Regards
Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
