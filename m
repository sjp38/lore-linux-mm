Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED5498E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 02:44:43 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so8591928edr.21
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 23:44:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw4-v6si1922668ejb.52.2019.01.13.23.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 23:44:42 -0800 (PST)
Date: Mon, 14 Jan 2019 08:44:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
Message-ID: <20190114074405.GD21345@dhcp22.suse.cz>
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
 <20190111135938.GG14956@dhcp22.suse.cz>
 <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
 <CABdVr8T4ccrnRfboehOBfMVG4kHbWwq=ijDOtq3dEbGSXLkyUg@mail.gmail.com>
 <20190114070600.GC21345@dhcp22.suse.cz>
 <CABdVr8QT_FS+dFrhDjKu3hfP8TzFXS83DxhX=nTtuLNg3kVckg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABdVr8QT_FS+dFrhDjKu3hfP8TzFXS83DxhX=nTtuLNg3kVckg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baptiste Lepers <baptiste.lepers@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, mgorman@techsingularity.net, akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org, hannes@cmpxchg.org

On Mon 14-01-19 18:25:45, Baptiste Lepers wrote:
> On Mon, Jan 14, 2019 at 6:06 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 14-01-19 10:12:37, Baptiste Lepers wrote:
> > > On Sat, Jan 12, 2019 at 4:53 AM Daniel Jordan
> > > <daniel.m.jordan@oracle.com> wrote:
> > > >
> > > > On Fri, Jan 11, 2019 at 02:59:38PM +0100, Michal Hocko wrote:
> > > > > On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> > > > > > Hello,
> > > > > >
> > > > > > We have a performance issue with the page cache. One of our workload
> > > > > > spends more than 50% of it's time in the lru_locks called by
> > > > > > shrink_inactive_list in mm/vmscan.c.
> > > > >
> > > > > Who does contend on the lock? Are there direct reclaimers or is it
> > > > > solely kswapd with paths that are faulting the new page cache in?
> > > >
> > > > Yes, and could you please post your performance data showing the time in
> > > > lru_lock?  Whatever you have is fine, but using perf with -g would give
> > > > callstacks and help answer Michal's question about who's contending.
> > >
> > > Thanks for the quick answer.
> > >
> > > The time spent in the lru_lock is mainly due to direct reclaimers
> > > (reading an mmaped page that causes some readahead to happen). We have
> > > tried to play with readahead values, but it doesn't change performance
> > > a lot. We have disabled swap on the machine, so kwapd doesn't run.
> >
> > kswapd runs even without swap storage.
> >
> > > Our programs run in memory cgroups, but I don't think that the issue
> > > directly comes from cgroups (I might be wrong though).
> >
> > Do you use hard/high limit on those cgroups. Because those would be a
> > source of the reclaim.
> >
> > > Here is the callchain that I have using perf report --no-children;
> > > (Paste here https://pastebin.com/151x4QhR )
> > >
> > >     44.30%  swapper      [kernel.vmlinux]  [k] intel_idle
> > >     # The machine is idle mainly because it waits in that lru_locks,
> > > which is the 2nd function in the report:
> > >     10.98%  testradix    [kernel.vmlinux]  [k] native_queued_spin_lock_slowpath
> > >                |--10.33%--_raw_spin_lock_irq
> > >                |          |
> > >                |           --10.12%--shrink_inactive_list
> > >                |                     shrink_node_memcg
> > >                |                     shrink_node
> > >                |                     do_try_to_free_pages
> > >                |                     try_to_free_mem_cgroup_pages
> > >                |                     try_charge
> > >                |                     mem_cgroup_try_charge
> >
> > And here it shows this is indeed the case. You are hitting the hard
> > limit and that causes direct reclaim to shrink the memcg.
> >
> > If you do not really need a strong isolation between cgroups then I
> > would suggest to not set the hard limit and rely on the global memory
> > reclaim to do the background reclaim which is less aggressive and more
> > pro-active.
> 
> Thanks for the suggestion.
> We actually need the hard limit in that case, but the problem occurs
> even without cgroups (we mmap a 1TB file and we only have 64GB of
> RAM). Basically the page cache fills up quickly and then reading the
> mmaped file becomes "slow" (400-500MB/s instead of the initial
> 2.6GB/s). I'm just wondering if there is a way to make page
> reclamation a bit faster, especially given that our workload is read
> only.

Well, the clean page cache should be the most simple reclaim scenario so
I would be curious about a performance profile of this run.

> shrink_inactive_list only seem to reclaim 32 pages with the default
> setting and takes lru_lock twice to do that, so that's a lock of
> locking per KB. Increasing the SWAP_CLUSTER_MAX value helped a bit,
> but this is still quite slow.

Yes, SWAP_CLUSTER_MAX is a bit arbitrary but it is hard to guess what is
the bottle neck without some more data. Please note that this batching
controls how many pages are isolated from the LRU at once and that is
where we take the lock. So the larger the number the more pages we
isolate. This might indeed have a possitive effect on performance but
another side is that we do not want to isolate way too much for various
reasons (e.g. over reclaim).

Also getting back to your specific usecase. You've said you have played
with MADV_DONTNEED but it didn't help much. I am really curious on
details. Have you called madvice too late? What is the actual resident
portion of the file that you really need?

-- 
Michal Hocko
SUSE Labs
