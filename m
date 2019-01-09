Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45CE48E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:38:06 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id h3so4270503ywc.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:38:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y127sor9806128ywf.195.2019.01.09.09.38.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 09:38:04 -0800 (PST)
MIME-Version: 1.0
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
In-Reply-To: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 9 Jan 2019 09:37:52 -0800
Message-ID: <CALvZod63z5_m-izxFh4XQvjcALqffkZ5G91-KsyOuAC4wvN3Wg@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, josef@toxicpanda.com, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Kirill,

On Wed, Jan 9, 2019 at 4:20 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
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

>From what I understand from the proposal, on memcg reclaim, the file
pages are uncharged but kept in the memory and if they are accessed
again (either through mmap or syscall), they will be charged again but
to the requesting memcg. Also it is assumed that the global reclaim of
such uncharged file pages is very fast and deterministic. Is that
right?

Shakeel

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
> ---
>
> Kirill Tkhai (3):
>       mm: Uncharge and keep page in pagecache on memcg reclaim
>       mm: Recharge page memcg on first get from pagecache
>       mm: Pass FGP_NOWAIT in generic_file_buffered_read and enable ext4
>
>
>  fs/ext4/inode.c         |    1 +
>  include/linux/pagemap.h |    1 +
>  mm/filemap.c            |   38 ++++++++++++++++++++++++++++++++++++--
>  mm/vmscan.c             |   22 ++++++++++++++++++----
>  4 files changed, 56 insertions(+), 6 deletions(-)
>
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
