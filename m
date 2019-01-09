Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4EB8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:49:37 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d35so7128832qtd.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 07:49:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19sor14464053qkl.109.2019.01.09.07.49.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 07:49:36 -0800 (PST)
Date: Wed, 9 Jan 2019 10:49:33 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Message-ID: <20190109154932.tpc27dk2hzeycqex@MacBook-Pro-91.local>
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, josef@toxicpanda.com, jack@suse.cz, hughd@google.com, darrick.wong@oracle.com, mhocko@suse.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
> 

This isn't going to work for us (Facebook).  The whole reason the hard limit
exists is to keep different groups from messing up other groups.  Page cache
reclaim is not free, most of our pain and most of the reason we use cgroups
is to limit the effect of flooding the machine with pagecache from different
groups.  Memory leaks happen few and far between, but chef doing a yum
update in the system container happens regularly.  If you talk about suddenly
orphaning these pages to the root container it still creates pressure on the
main workload, pressure that results in it having to take time from what it's
doing and free up memory instead.  Thanks,

Josef
