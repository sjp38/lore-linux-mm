Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 656BE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:20:26 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v187so4446200ywv.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:20:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195sor9815655ywh.176.2019.01.09.11.20.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 11:20:24 -0800 (PST)
Date: Wed, 9 Jan 2019 14:20:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Message-ID: <20190109192022.GA16027@cmpxchg.org>
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <20190109164528.GA13515@cmpxchg.org>
 <CALvZod6P12gUq-xTZ1V4ZBeFXGE6dGAfA5uiw6iN1w14eP9j2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6P12gUq-xTZ1V4ZBeFXGE6dGAfA5uiw6iN1w14eP9j2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, josef@toxicpanda.com, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 09, 2019 at 09:44:28AM -0800, Shakeel Butt wrote:
> Hi Johannes,
> 
> On Wed, Jan 9, 2019 at 8:45 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > On Wed, Jan 09, 2019 at 03:20:18PM +0300, Kirill Tkhai wrote:
> > > On nodes without memory overcommit, it's common a situation,
> > > when memcg exceeds its limit and pages from pagecache are
> > > shrinked on reclaim, while node has a lot of free memory.
> > > Further access to the pages requires real device IO, while
> > > IO causes time delays, worse powerusage, worse throughput
> > > for other users of the device, etc.
> > >
> > > Cleancache is not a good solution for this problem, since
> > > it implies copying of page on every cleancache_put_page()
> > > and cleancache_get_page(). Also, it requires introduction
> > > of internal per-cleancache_ops data structures to manage
> > > cached pages and their inodes relationships, which again
> > > introduces overhead.
> > >
> > > This patchset introduces another solution. It introduces
> > > a new scheme for evicting memcg pages:
> > >
> > >   1)__remove_mapping() uncharges unmapped page memcg
> > >     and leaves page in pagecache on memcg reclaim;
> > >
> > >   2)putback_lru_page() places page into root_mem_cgroup
> > >     list, since its memcg is NULL. Page may be evicted
> > >     on global reclaim (and this will be easily, as
> > >     page is not mapped, so shrinker will shrink it
> > >     with 100% probability of success);
> > >
> > >   3)pagecache_get_page() charges page into memcg of
> > >     a task, which takes it first.
> > >
> > > Below is small test, which shows profit of the patchset.
> > >
> > > Create memcg with limit 20M (exact value does not matter much):
> > >   $ mkdir /sys/fs/cgroup/memory/ct
> > >   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
> > >   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
> > >
> > > Then twice read 1GB file:
> > >   $ time cat file_1gb > /dev/null
> > >
> > > Before (2 iterations):
> > >   1)0.01user 0.82system 0:11.16elapsed 7%CPU
> > >   2)0.01user 0.91system 0:11.16elapsed 8%CPU
> > >
> > > After (2 iterations):
> > >   1)0.01user 0.57system 0:11.31elapsed 5%CPU
> > >   2)0.00user 0.28system 0:00.28elapsed 100%CPU
> > >
> > > With the patch set applied, we have file pages are cached
> > > during the second read, so the result is 39 times faster.
> > >
> > > This may be useful for slow disks, NFS, nodes without
> > > overcommit by memory, in case of two memcg access the same
> > > files, etc.
> >
> > What you're implementing is work conservation: avoid causing IO work,
> > unless it's physically necessary, not when the memcg limit says so.
> >
> > This is a great idea, but we already have that in the form of the
> > memory.low setting (or softlimit in cgroup v1).
> >
> > Say you have a 100M system and two cgroups. Instead of setting the 20M
> > limit on group A as you did, you set 80M memory.low on group B. If B
> > is not using its share and there is no physical memory pressure, group
> > A can consume as much memory as it wants. If B starts and consumes its
> > 80M, A will get pushed back to 20M. (And when B grows beyond 80M, they
> > compete fairly over the remaining 20M, just like they would if A had
> > the 20M limit setting).
> 
> There is one difference between the example you give and the proposal.
> In your example when B starts and consumes its 80M and pushes back A
> to 20M, the direct reclaim can be very expensive and
> non-deterministic. While in the proposal, the B's direct reclaim will
> be very fast and deterministic (assuming no overcommit on hard limits)
> as it will always first reclaim unmapped clean pages which were
> charged to A.

That struck me more as a side-effect of the implementation having to
unmap the pages to be able to change their page->mem_cgroup.

But regardless, we cannot fundamentally change the memory isolation
semantics of the hard limit like these patches propose, so it's a moot
point. A scheme to prepare likely reclaim candidates in advance for a
low-latency workload startup would have to come in a different form.
