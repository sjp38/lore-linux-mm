Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0F306B0276
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:33:46 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z16-v6so2035926wrs.22
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:33:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z21-v6sor622384wma.48.2018.07.18.08.33.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 08:33:45 -0700 (PDT)
MIME-Version: 1.0
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <20180718144710.GI7193@dhcp22.suse.cz> <CAOm-9aqLopJouRFd6sQr95yYTJmuoE6y9=VoMEJeyr_OVfQxnw@mail.gmail.com>
In-Reply-To: <CAOm-9aqLopJouRFd6sQr95yYTJmuoE6y9=VoMEJeyr_OVfQxnw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 18 Jul 2018 08:33:33 -0700
Message-ID: <CALvZod5zCeXECsOeRzkqpKWsG1X4xM-vcv62kzXJTRouvqZgww@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bmerry@ska.ac.za
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Jul 18, 2018 at 8:27 AM Bruce Merry <bmerry@ska.ac.za> wrote:
>
> On 18 July 2018 at 16:47, Michal Hocko <mhocko@kernel.org> wrote:
> >> Thanks for looking into this. I'm not familiar with ftrace. Can you
> >> give me a specific command line to run? Based on "perf record cat
> >> /sys/fs/cgroup/memory/memory.stat"/"perf report", I see the following:
> >>
> >>   42.09%  cat      [kernel.kallsyms]  [k] memcg_stat_show
> >>   29.19%  cat      [kernel.kallsyms]  [k] memcg_sum_events.isra.22
> >>   12.41%  cat      [kernel.kallsyms]  [k] mem_cgroup_iter
> >>    5.42%  cat      [kernel.kallsyms]  [k] _find_next_bit
> >>    4.14%  cat      [kernel.kallsyms]  [k] css_next_descendant_pre
> >>    3.44%  cat      [kernel.kallsyms]  [k] find_next_bit
> >>    2.84%  cat      [kernel.kallsyms]  [k] mem_cgroup_node_nr_lru_pages
> >
> > I would just use perf record as you did. How long did the call take?
> > Also is the excessive time an outlier or a more consistent thing? If the
> > former does perf record show any difference?
>
> I didn't note the exact time for that particular run, but it's pretty
> consistently 372-377ms on the machine that has that perf report. The
> times differ between machines showing the symptom (anywhere from
> 200-500ms), but are consistent (within a few ms) in back-to-back runs
> on each machine.
>
> >> Ubuntu 16.04 with kernel 4.13.0-41-generic (so presumably includes
> >> some Ubuntu special sauce).
> >
> > Do you see the same whe running with the vanilla kernel?
>
> We don't currently have any boxes running vanilla kernels. While I
> could install a test box with a vanilla kernel, I don't know how to
> reproduce the problem, what piece of our production environment is
> triggering it, or even why some machines are unaffected, so if the
> problem didn't re-occur on the test box I wouldn't be able to conclude
> anything useful.
>
> Do you have suggestions on things I could try that might trigger this?
> e.g. are there cases where a cgroup no longer shows up in the
> filesystem but is still lingering while waiting for its refcount to
> hit zero? Does every child cgroup contribute to the stat_show cost of
> its parent or does it have to have some non-trivial variation from its
> parent?
>

The memcg tree does include all zombie memcgs and these zombies does
contribute to the memcg_stat_show cost.

Shakeel
