Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE202806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:34:20 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j13so27268930qta.13
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:34:20 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id e58si9267591qta.179.2017.05.19.09.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 09:34:19 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id k74so10852127qke.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:34:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149520375057.74196.2843113275800730971.stgit@buzz>
References: <149520375057.74196.2843113275800730971.stgit@buzz>
From: Roman Guschin <guroan@gmail.com>
Date: Fri, 19 May 2017 17:34:18 +0100
Message-ID: <CALo0P1123MROxgveCdX6YFpWDwG4qrAyHu3Xd1F+ckaFBnF4dQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org

2017-05-19 15:22 GMT+01:00 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>:
> Show count of global oom killer invocations in /proc/vmstat and
> count of oom kills inside memory cgroup in knob "memory.events"
> (in memory.oom_control for v1 cgroup).
>
> Also describe difference between "oom" and "oom_kill" in memory
> cgroup documentation. Currently oom in memory cgroup kills tasks
> iff shortage has happened inside page fault.
>
> These counters helps in monitoring oom kills - for now
> the only way is grepping for magic words in kernel log.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  Documentation/cgroup-v2.txt   |   12 +++++++++++-
>  include/linux/memcontrol.h    |    1 +
>  include/linux/vm_event_item.h |    1 +
>  mm/memcontrol.c               |    2 ++
>  mm/oom_kill.c                 |    6 ++++++
>  mm/vmstat.c                   |    1 +
>  6 files changed, 22 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index dc5e2dcdbef4..a742008d76aa 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -830,9 +830,19 @@ PAGE_SIZE multiple when read back.
>
>           oom
>
> +               The number of time the cgroup's memory usage was
> +               reached the limit and allocation was about to fail.
> +               Result could be oom kill, -ENOMEM from any syscall or
> +               completely ignored in cases like disk readahead.
> +               For now oom in memory cgroup kills tasks iff shortage
> +               has happened inside page fault.

>From a user's point of view the difference between "oom" and "max"
becomes really vague here,
assuming that "max" is described almost in the same words:

"The number of times the cgroup's memory usage was
about to go over the max boundary.  If direct reclaim
fails to bring it down, the OOM killer is invoked."

I wonder, if it's better to fix the existing "oom" value  to show what
it has to show, according to docs,
rather than to introduce a new one?

> +
> +         oom_kill
> +
>                 The number of times the OOM killer has been invoked in
>                 the cgroup.  This may not exactly match the number of
> -               processes killed but should generally be close.
> +               processes killed but should generally be close: each
> +               invocation could kill several processes at once.
>
>    memory.stat
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
