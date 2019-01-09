Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5868E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:08:15 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p86-v6so1952885lja.2
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:08:15 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s129-v6si61573625lja.72.2019.01.09.08.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:08:13 -0800 (PST)
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <20190109154932.tpc27dk2hzeycqex@MacBook-Pro-91.local>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e7dc9a15-9438-cc15-c898-36eca325118a@virtuozzo.com>
Date: Wed, 9 Jan 2019 19:08:09 +0300
MIME-Version: 1.0
In-Reply-To: <20190109154932.tpc27dk2hzeycqex@MacBook-Pro-91.local>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, mhocko@suse.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, Josef,

On 09.01.2019 18:49, Josef Bacik wrote:
> On Wed, Jan 09, 2019 at 03:20:18PM +0300, Kirill Tkhai wrote:
>> On nodes without memory overcommit, it's common a situation,
>> when memcg exceeds its limit and pages from pagecache are
>> shrinked on reclaim, while node has a lot of free memory.
>> Further access to the pages requires real device IO, while
>> IO causes time delays, worse powerusage, worse throughput
>> for other users of the device, etc.
>>
>> Cleancache is not a good solution for this problem, since
>> it implies copying of page on every cleancache_put_page()
>> and cleancache_get_page(). Also, it requires introduction
>> of internal per-cleancache_ops data structures to manage
>> cached pages and their inodes relationships, which again
>> introduces overhead.
>>
>> This patchset introduces another solution. It introduces
>> a new scheme for evicting memcg pages:
>>
>>   1)__remove_mapping() uncharges unmapped page memcg
>>     and leaves page in pagecache on memcg reclaim;
>>
>>   2)putback_lru_page() places page into root_mem_cgroup
>>     list, since its memcg is NULL. Page may be evicted
>>     on global reclaim (and this will be easily, as
>>     page is not mapped, so shrinker will shrink it
>>     with 100% probability of success);
>>
>>   3)pagecache_get_page() charges page into memcg of
>>     a task, which takes it first.
>>
>> Below is small test, which shows profit of the patchset.
>>
>> Create memcg with limit 20M (exact value does not matter much):
>>   $ mkdir /sys/fs/cgroup/memory/ct
>>   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
>>   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
>>
>> Then twice read 1GB file:
>>   $ time cat file_1gb > /dev/null
>>
>> Before (2 iterations):
>>   1)0.01user 0.82system 0:11.16elapsed 7%CPU
>>   2)0.01user 0.91system 0:11.16elapsed 8%CPU
>>
>> After (2 iterations):
>>   1)0.01user 0.57system 0:11.31elapsed 5%CPU
>>   2)0.00user 0.28system 0:00.28elapsed 100%CPU
>>
>> With the patch set applied, we have file pages are cached
>> during the second read, so the result is 39 times faster.
>>
>> This may be useful for slow disks, NFS, nodes without
>> overcommit by memory, in case of two memcg access the same
>> files, etc.
>>
> 
> This isn't going to work for us (Facebook).  The whole reason the hard limit
> exists is to keep different groups from messing up other groups.  Page cache
> reclaim is not free, most of our pain and most of the reason we use cgroups
> is to limit the effect of flooding the machine with pagecache from different
> groups.

I understand the problem.

> Memory leaks happen few and far between, but chef doing a yum
> update in the system container happens regularly.  If you talk about suddenly
> orphaning these pages to the root container it still creates pressure on the
> main workload, pressure that results in it having to take time from what it's
> doing and free up memory instead.

Could you please to clarify additional pressure, which introduces the patchset?
The number of actions, which are needed to evict a pagecache page, remain almost
the same: we just delay __delete_from_page_cache() to global reclaim. Global
reclaim should not introduce much pressure, since it's the iteration on a single
memcg (we should not dive into hell of children memcg, since root memcg reclaim
should be successful and free enough pages, should't we?).

Also, what is about implementing this as static key option? What about linking
orphaned pagecache pages into separate list, which is easy-to-iterate?

Thanks,
Kirill
