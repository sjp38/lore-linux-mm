Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA3C8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:45:34 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id v71so3885801ybv.17
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:45:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h32sor16359366ybi.131.2019.01.09.08.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:45:30 -0800 (PST)
Date: Wed, 9 Jan 2019 11:45:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Message-ID: <20190109164528.GA13515@cmpxchg.org>
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, josef@toxicpanda.com, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, mhocko@suse.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 03:20:18PM +0300, Kirill Tkhai wrote:
> On nodes without memory overcommit, it's common a situation,
> when memcg exceeds its limit and pages from pagecache are
> shrinked on reclaim, while node has a lot of free memory.
> Further access to the pages requires real device IO, while
> IO causes time delays, worse powerusage, worse throughput
> for other users of the device, etc.
> 
> Cleancache is not a good solution for this problem, since
> it implies copying of page on every cleancache_put_page()
> and cleancache_get_page(). Also, it requires introduction
> of internal per-cleancache_ops data structures to manage
> cached pages and their inodes relationships, which again
> introduces overhead.
> 
> This patchset introduces another solution. It introduces
> a new scheme for evicting memcg pages:
> 
>   1)__remove_mapping() uncharges unmapped page memcg
>     and leaves page in pagecache on memcg reclaim;
> 
>   2)putback_lru_page() places page into root_mem_cgroup
>     list, since its memcg is NULL. Page may be evicted
>     on global reclaim (and this will be easily, as
>     page is not mapped, so shrinker will shrink it
>     with 100% probability of success);
> 
>   3)pagecache_get_page() charges page into memcg of
>     a task, which takes it first.
> 
> Below is small test, which shows profit of the patchset.
> 
> Create memcg with limit 20M (exact value does not matter much):
>   $ mkdir /sys/fs/cgroup/memory/ct
>   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
>   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
> 
> Then twice read 1GB file:
>   $ time cat file_1gb > /dev/null
> 
> Before (2 iterations):
>   1)0.01user 0.82system 0:11.16elapsed 7%CPU
>   2)0.01user 0.91system 0:11.16elapsed 8%CPU
> 
> After (2 iterations):
>   1)0.01user 0.57system 0:11.31elapsed 5%CPU
>   2)0.00user 0.28system 0:00.28elapsed 100%CPU
> 
> With the patch set applied, we have file pages are cached
> during the second read, so the result is 39 times faster.
> 
> This may be useful for slow disks, NFS, nodes without
> overcommit by memory, in case of two memcg access the same
> files, etc.

What you're implementing is work conservation: avoid causing IO work,
unless it's physically necessary, not when the memcg limit says so.

This is a great idea, but we already have that in the form of the
memory.low setting (or softlimit in cgroup v1).

Say you have a 100M system and two cgroups. Instead of setting the 20M
limit on group A as you did, you set 80M memory.low on group B. If B
is not using its share and there is no physical memory pressure, group
A can consume as much memory as it wants. If B starts and consumes its
80M, A will get pushed back to 20M. (And when B grows beyond 80M, they
compete fairly over the remaining 20M, just like they would if A had
the 20M limit setting).

At FB we use protection like this for most group allocations. ISTR
Google does too with a modified softlimit implementation in v1.

We do use hard limits for failsafes. I.e. "I don't care if we're not
using all available memory for this one workload, it's already 2x its
expected size, something is wrong with it anyway" -> apply reclaim
pressure and kill if necessary. So we actually do NOT want the work
conservation aspect in this case, because we don't want a likely buggy
workload to compete over memory with well-behaved jobs.
