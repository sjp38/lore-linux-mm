Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC2B6B0007
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:44:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o28so5315647pgn.6
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 11:44:50 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0131.outbound.protection.outlook.com. [104.47.1.131])
        by mx.google.com with ESMTPS id i72si5057351pfe.310.2018.01.25.11.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 11:44:48 -0800 (PST)
Subject: Re: [PATCH v5 1/2] mm/memcontrol.c: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-1-aryabinin@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5741fb29-a343-1f20-8957-bcd3647f2111@virtuozzo.com>
Date: Thu, 25 Jan 2018 22:44:16 +0300
MIME-Version: 1.0
In-Reply-To: <20180119132544.19569-1-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 01/19/2018 04:25 PM, Andrey Ryabinin wrote:
> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
> pages on each iteration.  This makes it practically impossible to decrease
> limit of memory cgroup.  Tasks could easily allocate back 32 pages, so we
> can't reduce memory usage, and once retry_count reaches zero we return
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
> Instead of relying on retry_count, keep retrying the reclaim until the
> desired limit is reached or fail if the reclaim doesn't make any progress
> or a signal is pending.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>


Andrew, are you ok to pick up the patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
