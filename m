Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D434C6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:21:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 17so57646wma.1
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:21:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z5si1479313wmd.88.2018.01.11.16.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 16:21:37 -0800 (PST)
Date: Thu, 11 Jan 2018 16:21:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-Id: <20180111162134.53aa5a44c59689ec0399db57@linux-foundation.org>
In-Reply-To: <47856d2b-1534-6198-c2e2-6d2356973bef@virtuozzo.com>
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
	<20180110124317.28887-1-aryabinin@virtuozzo.com>
	<20180110143121.cf2a1c5497b31642c9b38b2a@linux-foundation.org>
	<47856d2b-1534-6198-c2e2-6d2356973bef@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On Thu, 11 Jan 2018 14:59:23 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> On 01/11/2018 01:31 AM, Andrew Morton wrote:
> > On Wed, 10 Jan 2018 15:43:17 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > 
> >> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
> >> pages on each iteration. This makes practically impossible to decrease
> >> limit of memory cgroup. Tasks could easily allocate back 32 pages,
> >> so we can't reduce memory usage, and once retry_count reaches zero we return
> >> -EBUSY.
> >>
> >> Easy to reproduce the problem by running the following commands:
> >>
> >>   mkdir /sys/fs/cgroup/memory/test
> >>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
> >>   cat big_file > /dev/null &
> >>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
> >>   -bash: echo: write error: Device or resource busy
> >>
> >> Instead of relying on retry_count, keep retrying the reclaim until
> >> the desired limit is reached or fail if the reclaim doesn't make
> >> any progress or a signal is pending.
> >>
> > 
> > Is there any situation under which that mem_cgroup_resize_limit() can
> > get stuck semi-indefinitely in a livelockish state?  It isn't very
> > obvious that we're protected from this, so perhaps it would help to
> > have a comment which describes how loop termination is assured?
> > 
> 
> We are not protected from this. If tasks in cgroup *indefinitely* generate reclaimable memory at high rate
> and user asks to set unreachable limit, like 'echo 4096 > memory.limit_in_bytes', than
> try_to_free_mem_cgroup_pages() will return non-zero indefinitely.
> 
> Is that a big deal? At least loop can be interrupted by a signal, and we don't hold any locks here.

It may be better to detect this condition, give up and return an error?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
