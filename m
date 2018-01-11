Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7626B0266
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:59:20 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n6so1928155pfg.19
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 03:59:20 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30132.outbound.protection.outlook.com. [40.107.3.132])
        by mx.google.com with ESMTPS id q3si3197046pgr.290.2018.01.11.03.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 03:59:18 -0800 (PST)
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180110143121.cf2a1c5497b31642c9b38b2a@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <47856d2b-1534-6198-c2e2-6d2356973bef@virtuozzo.com>
Date: Thu, 11 Jan 2018 14:59:23 +0300
MIME-Version: 1.0
In-Reply-To: <20180110143121.cf2a1c5497b31642c9b38b2a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On 01/11/2018 01:31 AM, Andrew Morton wrote:
> On Wed, 10 Jan 2018 15:43:17 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
>> pages on each iteration. This makes practically impossible to decrease
>> limit of memory cgroup. Tasks could easily allocate back 32 pages,
>> so we can't reduce memory usage, and once retry_count reaches zero we return
>> -EBUSY.
>>
>> Easy to reproduce the problem by running the following commands:
>>
>>   mkdir /sys/fs/cgroup/memory/test
>>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
>>   cat big_file > /dev/null &
>>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>>   -bash: echo: write error: Device or resource busy
>>
>> Instead of relying on retry_count, keep retrying the reclaim until
>> the desired limit is reached or fail if the reclaim doesn't make
>> any progress or a signal is pending.
>>
> 
> Is there any situation under which that mem_cgroup_resize_limit() can
> get stuck semi-indefinitely in a livelockish state?  It isn't very
> obvious that we're protected from this, so perhaps it would help to
> have a comment which describes how loop termination is assured?
> 

We are not protected from this. If tasks in cgroup *indefinitely* generate reclaimable memory at high rate
and user asks to set unreachable limit, like 'echo 4096 > memory.limit_in_bytes', than
try_to_free_mem_cgroup_pages() will return non-zero indefinitely.

Is that a big deal? At least loop can be interrupted by a signal, and we don't hold any locks here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
