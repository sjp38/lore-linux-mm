Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89CF06B0289
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:27 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id j80-v6so2756883vke.22
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:26:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o188-v6sor4988240vkg.36.2018.07.25.04.26.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 04:26:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180724224635.143944-1-shakeelb@google.com>
References: <20180724224635.143944-1-shakeelb@google.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Wed, 25 Jul 2018 13:26:25 +0200
Message-ID: <CAOm-9arFu63A9YJ6yVtm6_LdtbRKZg1Q3dz8WugdkBBQfoOWYw@mail.gmail.com>
Subject: Re: [PATCH] memcg: reduce memcg tree traversals for stats collection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 25 July 2018 at 00:46, Shakeel Butt <shakeelb@google.com> wrote:
> I ran a simple benchmark which reads the root_mem_cgroup's stat file
> 1000 times in the presense of 2500 memcgs on cgroup-v1. The results are:
>
> Without the patch:
> $ time ./read-root-stat-1000-times
>
> real    0m1.663s
> user    0m0.000s
> sys     0m1.660s
>
> With the patch:
> $ time ./read-root-stat-1000-times
>
> real    0m0.468s
> user    0m0.000s
> sys     0m0.467s

Thanks for cc'ing me. I've tried this patch using my test case and the
results are interesting. With the patch applied, running my script
only generates about 8000 new cgroups, compared to 40,000 before -
presumably because the optimisation has altered the timing.

On the other hand, if I run the script 5 times to generate 40000
zombie cgroups, the time to get stats for the root cgroup (cgroup-v1)
is almost unchanged at around 18ms (was 20ms, but there were slightly
more cgroups as well), compared to the almost 4x speedup you're seeing
in your test.

Regards
Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
