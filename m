Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 815CD8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:20:12 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id w9so6046496ybe.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:20:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor9930376ywe.27.2019.01.10.11.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 11:20:10 -0800 (PST)
MIME-Version: 1.0
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <CALvZod63z5_m-izxFh4XQvjcALqffkZ5G91-KsyOuAC4wvN3Wg@mail.gmail.com> <a1dbe366-43bd-e3ee-6133-f6179b2f2278@virtuozzo.com>
In-Reply-To: <a1dbe366-43bd-e3ee-6133-f6179b2f2278@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 10 Jan 2019 11:19:58 -0800
Message-ID: <CALvZod62A+EpGF6UVGjBhuDfwPd2b7c0M9mR86jP-3GGGT1T6g@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 10, 2019 at 1:46 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> Hi, Shakeel,
>
> On 09.01.2019 20:37, Shakeel Butt wrote:
> > Hi Kirill,
> >
> > On Wed, Jan 9, 2019 at 4:20 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>
> >> On nodes without memory overcommit, it's common a situation,
> >> when memcg exceeds its limit and pages from pagecache are
> >> shrinked on reclaim, while node has a lot of free memory.
> >> Further access to the pages requires real device IO, while
> >> IO causes time delays, worse powerusage, worse throughput
> >> for other users of the device, etc.
> >>
> >> Cleancache is not a good solution for this problem, since
> >> it implies copying of page on every cleancache_put_page()
> >> and cleancache_get_page(). Also, it requires introduction
> >> of internal per-cleancache_ops data structures to manage
> >> cached pages and their inodes relationships, which again
> >> introduces overhead.
> >>
> >> This patchset introduces another solution. It introduces
> >> a new scheme for evicting memcg pages:
> >>
> >>   1)__remove_mapping() uncharges unmapped page memcg
> >>     and leaves page in pagecache on memcg reclaim;
> >>
> >>   2)putback_lru_page() places page into root_mem_cgroup
> >>     list, since its memcg is NULL. Page may be evicted
> >>     on global reclaim (and this will be easily, as
> >>     page is not mapped, so shrinker will shrink it
> >>     with 100% probability of success);
> >>
> >>   3)pagecache_get_page() charges page into memcg of
> >>     a task, which takes it first.
> >>
> >
> > From what I understand from the proposal, on memcg reclaim, the file
> > pages are uncharged but kept in the memory and if they are accessed
> > again (either through mmap or syscall), they will be charged again but
> > to the requesting memcg. Also it is assumed that the global reclaim of
> > such uncharged file pages is very fast and deterministic. Is that
> > right?
>
> Yes, this was my assumption. But Michal, Josef and Johannes pointed a diving
> into reclaim in general is not fast. So, maybe we need some more creativity
> here to minimize the effect of this diving..
>

I kind of disagree that this patchset is breaking the API semantics as
the charged memory of a memcg will never go over max/limit_in_bytes.
However the concern I have is the performance isolation. The
performance of a pagecache heavy job with a private mount can be
impacted by other jobs running on the system. This might be fine for
some customers but not for Google. One use-case I can tell is the
auto-tuner which adjusts the limits of the jobs based on their
performance and history. So, to make the auto-tuning deterministic we
have to disable the proposed optimization for the jobs with
auto-tuning enabled. Beside that there are internal non-auto-tuned
customers who prefer deterministic performance.

Also I am a bit skeptical that the allocation from the pool of such
(clean unmapped uncharged) file pages can be made as efficient as
fastpath of page allocator. Even if these pages are stored in a
separate list instead of root's LRU, on allocation, the pages need to
be unlinked from their mapping and has to be cleared.

BTW does this optimization have any impact on workingset mechanism?

thanks,
Shakeel
