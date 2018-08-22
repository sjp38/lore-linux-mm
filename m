Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 323216B24CB
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:24:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y46-v6so1656211qth.9
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:24:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z3-v6si1827366qth.129.2018.08.22.07.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 07:24:55 -0700 (PDT)
Date: Wed, 22 Aug 2018 10:24:46 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180822142446.GL13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822110737.GK29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822110737.GK29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Aug 22, 2018 at 01:07:37PM +0200, Michal Hocko wrote:
> On Wed 22-08-18 11:02:14, Michal Hocko wrote:
> > On Tue 21-08-18 17:40:49, Andrea Arcangeli wrote:
> > > On Tue, Aug 21, 2018 at 01:50:57PM +0200, Michal Hocko wrote:
> > [...]
> > > > I really detest a new gfp flag for one time semantic that is muddy as
> > > > hell.
> > > 
> > > Well there's no way to fix this other than to prevent reclaim to run,
> > > if you still want to give a chance to page faults to obtain THP under
> > > MADV_HUGEPAGE in the page fault without waiting minutes or hours for
> > > khugpaged to catch up with it.
> > 
> > I do not get that part. Why should caller even care about reclaim vs.
> > compaction. How can you even make an educated guess what makes more
> > sense? This should be fully controlled by the allocator path. The caller
> > should only care about how hard to try. It's been some time since I've
> > looked but we used to have a gfp flags to tell that for THP allocations
> > as well.
> 
> In other words, why do we even try to swap out when allocating costly
> high order page for requests which do not insist to try really hard?

Note that the testcase with vfio swaps nothing and writes nothing to
disk. No memory at all is being swapped or freed because 100% of the
node is pinned with GUP pins, so I'm dubious this could possible move
the needle for the reproducer that I used for the benchmark.

The swap storm I suggested to you as reproducer, because it's another
way the bug would see the light of the day and it's easier to
reproduce without requiring device assignment, but the badness is the
fact reclaim is called when it shouldn't be and whatever fix must
cover vfio too. The below I can't imagine how it could possibly have
an effect on vfio, and even for the swap storm case you're converting
a swap storm into a CPU waste, it'll still run just extremely slow
allocations like with vfio.

The effect of the below should be evaluated regardless of the issue
we've been discussing in this thread and it's a new corner case for
order > PAGE_ALLOC_COSTLY_ORDER. I don't like very much order >
PAGE_ALLOC_COSTLY_ORDER checks, those are arbitrary numbers, the more
checks are needed in various places for that, the more it's a sign the
VM is bad and arbitrary and with one more corner case required to hide
some badness. But again this will have effects unrelated to what we're
discussing here and it will just convert I/O into CPU waste and have
no effect on vfio.

> 
> I mean why don't we do something like this?
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 03822f86f288..41005d3d4c2d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3071,6 +3071,14 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>  		return 1;
>  
> +	/*
> +	 * If we are allocating a costly order and do not insist on trying really
> +	 * hard then we should keep the reclaim impact at minimum. So only
> +	 * focus on easily reclaimable memory.
> +	 */
> +	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> +		sc.may_swap = sc.may_unmap = 0;
> +
>  	trace_mm_vmscan_direct_reclaim_begin(order,
>  				sc.may_writepage,
>  				sc.gfp_mask,
> -- 
> Michal Hocko
> SUSE Labs
> 
