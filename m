Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 531C98E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:12:50 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a3so4982926otl.9
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 15:12:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a28sor2879276otk.13.2019.01.13.15.12.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 Jan 2019 15:12:49 -0800 (PST)
MIME-Version: 1.0
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
 <20190111135938.GG14956@dhcp22.suse.cz> <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
From: Baptiste Lepers <baptiste.lepers@gmail.com>
Date: Mon, 14 Jan 2019 10:12:37 +1100
Message-ID: <CABdVr8T4ccrnRfboehOBfMVG4kHbWwq=ijDOtq3dEbGSXLkyUg@mail.gmail.com>
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, mgorman@techsingularity.net, akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org, hannes@cmpxchg.org

On Sat, Jan 12, 2019 at 4:53 AM Daniel Jordan
<daniel.m.jordan@oracle.com> wrote:
>
> On Fri, Jan 11, 2019 at 02:59:38PM +0100, Michal Hocko wrote:
> > On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> > > Hello,
> > >
> > > We have a performance issue with the page cache. One of our workload
> > > spends more than 50% of it's time in the lru_locks called by
> > > shrink_inactive_list in mm/vmscan.c.
> >
> > Who does contend on the lock? Are there direct reclaimers or is it
> > solely kswapd with paths that are faulting the new page cache in?
>
> Yes, and could you please post your performance data showing the time in
> lru_lock?  Whatever you have is fine, but using perf with -g would give
> callstacks and help answer Michal's question about who's contending.

Thanks for the quick answer.

The time spent in the lru_lock is mainly due to direct reclaimers
(reading an mmaped page that causes some readahead to happen). We have
tried to play with readahead values, but it doesn't change performance
a lot. We have disabled swap on the machine, so kwapd doesn't run.

Our programs run in memory cgroups, but I don't think that the issue
directly comes from cgroups (I might be wrong though).

Here is the callchain that I have using perf report --no-children;
(Paste here https://pastebin.com/151x4QhR )

    44.30%  swapper      [kernel.vmlinux]  [k] intel_idle
    # The machine is idle mainly because it waits in that lru_locks,
which is the 2nd function in the report:
    10.98%  testradix    [kernel.vmlinux]  [k] native_queued_spin_lock_slowpath
               |--10.33%--_raw_spin_lock_irq
               |          |
               |           --10.12%--shrink_inactive_list
               |                     shrink_node_memcg
               |                     shrink_node
               |                     do_try_to_free_pages
               |                     try_to_free_mem_cgroup_pages
               |                     try_charge
               |                     mem_cgroup_try_charge
               |                     __add_to_page_cache_locked
               |                     add_to_page_cache_lru
               |                     |
               |                     |--5.39%--ext4_mpage_readpages
               |                     |          ext4_readpages
               |                     |          __do_page_cache_readahead
               |                     |          |
               |                     |           --5.37%--ondemand_readahead
               |                     |
page_cache_async_readahead
               |                     |                     filemap_fault
               |                     |                     ext4_filemap_fault
               |                     |                     __do_fault
               |                     |                     handle_pte_fault
               |                     |                     __handle_mm_fault
               |                     |                     handle_mm_fault
               |                     |                     __do_page_fault
               |                     |                     do_page_fault
               |                     |                     page_fault
               |                     |                     |
               |                     |                     |--4.23%-- <our app>


Thanks,

Baptiste.






>
> Happy to help profile and debug offline.
