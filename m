Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 716976B02A0
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:52:08 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id b190so3583749lfg.11
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:52:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g65sor150470ljb.64.2017.11.07.01.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 01:52:06 -0800 (PST)
Date: Tue, 7 Nov 2017 12:52:03 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/3] mm: memcontrol: fix excessive complexity in
 memory.stat reporting
Message-ID: <20171107095203.wmxs4z2qpms27t5b@esperanza>
References: <20171103153336.24044-1-hannes@cmpxchg.org>
 <20171103153336.24044-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103153336.24044-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 03, 2017 at 11:33:36AM -0400, Johannes Weiner wrote:
> We've seen memory.stat reads in top-level cgroups take up to fourteen
> seconds during a userspace bug that created tens of thousands of ghost
> cgroups pinned by lingering page cache.
> 
> Even with a more reasonable number of cgroups, aggregating memory.stat
> is unnecessarily heavy. The complexity is this:
> 
> 	nr_cgroups * nr_stat_items * nr_possible_cpus
> 
> where the stat items are ~70 at this point. With 128 cgroups and 128
> CPUs - decent, not enormous setups - reading the top-level memory.stat
> has to aggregate over a million per-cpu counters. This doesn't scale.
> 
> Instead of spreading the source of truth across all CPUs, use the
> per-cpu counters merely to batch updates to shared atomic counters.
> 
> This is the same as the per-cpu stocks we use for charging memory to
> the shared atomic page_counters, and also the way the global vmstat
> counters are implemented.
> 
> Vmstat has elaborate spilling thresholds that depend on the number of
> CPUs, amount of memory, and memory pressure - carefully balancing the
> cost of counter updates with the amount of per-cpu error. That's
> because the vmstat counters are system-wide, but also used for
> decisions inside the kernel (e.g. NR_FREE_PAGES in the
> allocator). Neither is true for the memory controller.
> 
> Use the same static batch size we already use for page_counter updates
> during charging. The per-cpu error in the stats will be 128k, which is
> an acceptable ratio of cores to memory accounting granularity.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |  96 +++++++++++++++++++++++++++---------------
>  mm/memcontrol.c            | 101 +++++++++++++++++++++++----------------------
>  2 files changed, 113 insertions(+), 84 deletions(-)

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
