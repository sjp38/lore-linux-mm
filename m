Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6C796B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 12:22:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l22so6115807wre.11
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 09:22:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j144sor3803188wmj.5.2018.01.09.09.22.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 09:22:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180109165815.8329-1-aryabinin@virtuozzo.com>
References: <20171220135329.GS4831@dhcp22.suse.cz> <20180109165815.8329-1-aryabinin@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 9 Jan 2018 09:22:53 -0800
Message-ID: <CALvZod4WCsrcx+Zrj9pNSoJFyhB7_5OZxBxT_kiy0unprKMdcA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/memcg: try harder to decrease [memory,memsw].limit_in_bytes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 9, 2018 at 8:58 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
> pages on each iteration. This makes practically impossible to decrease
> limit of memory cgroup. Tasks could easily allocate back 32 pages,
> so we can't reduce memory usage, and once retry_count reaches zero we return
> -EBUSY.
>
> Easy to reproduce the problem by running the following commands:
>
>   mkdir /sys/fs/cgroup/memory/test
>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
>   cat big_file > /dev/null &
>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>   -bash: echo: write error: Device or resource busy
>
> Instead of relying on retry_count, keep retrying the reclaim until
> the desired limit is reached or fail if the reclaim doesn't make
> any progress or a signal is pending.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
