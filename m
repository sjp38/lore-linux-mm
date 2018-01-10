Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6A16B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 17:31:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so419215wmb.9
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:31:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x11si13225150wrg.146.2018.01.10.14.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 14:31:26 -0800 (PST)
Date: Wed, 10 Jan 2018 14:31:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-Id: <20180110143121.cf2a1c5497b31642c9b38b2a@linux-foundation.org>
In-Reply-To: <20180110124317.28887-1-aryabinin@virtuozzo.com>
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
	<20180110124317.28887-1-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On Wed, 10 Jan 2018 15:43:17 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

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

Is there any situation under which that mem_cgroup_resize_limit() can
get stuck semi-indefinitely in a livelockish state?  It isn't very
obvious that we're protected from this, so perhaps it would help to
have a comment which describes how loop termination is assured?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
