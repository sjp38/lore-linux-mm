Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9D86B24E2
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:45:22 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g36-v6so1077801plb.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:45:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d68-v6si2099009pfj.311.2018.08.22.07.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 07:45:21 -0700 (PDT)
Date: Wed, 22 Aug 2018 16:45:17 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180822144517.GP29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822110737.GK29735@dhcp22.suse.cz>
 <20180822142446.GL13047@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822142446.GL13047@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 22-08-18 10:24:46, Andrea Arcangeli wrote:
> On Wed, Aug 22, 2018 at 01:07:37PM +0200, Michal Hocko wrote:
> > On Wed 22-08-18 11:02:14, Michal Hocko wrote:
> > > On Tue 21-08-18 17:40:49, Andrea Arcangeli wrote:
> > > > On Tue, Aug 21, 2018 at 01:50:57PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > I really detest a new gfp flag for one time semantic that is muddy as
> > > > > hell.
> > > > 
> > > > Well there's no way to fix this other than to prevent reclaim to run,
> > > > if you still want to give a chance to page faults to obtain THP under
> > > > MADV_HUGEPAGE in the page fault without waiting minutes or hours for
> > > > khugpaged to catch up with it.
> > > 
> > > I do not get that part. Why should caller even care about reclaim vs.
> > > compaction. How can you even make an educated guess what makes more
> > > sense? This should be fully controlled by the allocator path. The caller
> > > should only care about how hard to try. It's been some time since I've
> > > looked but we used to have a gfp flags to tell that for THP allocations
> > > as well.
> > 
> > In other words, why do we even try to swap out when allocating costly
> > high order page for requests which do not insist to try really hard?
> 
> Note that the testcase with vfio swaps nothing and writes nothing to
> disk. No memory at all is being swapped or freed because 100% of the
> node is pinned with GUP pins, so I'm dubious this could possible move
> the needle for the reproducer that I used for the benchmark.

Now I am confused. How can compaction help at all then? I mean  if the
node is full of GUP pins then you can hardly do anything but fallback to
other node. Or how come your new GFP flag makes any difference?

> The swap storm I suggested to you as reproducer, because it's another
> way the bug would see the light of the day and it's easier to
> reproduce without requiring device assignment, but the badness is the
> fact reclaim is called when it shouldn't be and whatever fix must
> cover vfio too. The below I can't imagine how it could possibly have
> an effect on vfio, and even for the swap storm case you're converting
> a swap storm into a CPU waste, it'll still run just extremely slow
> allocations like with vfio.

It would still try to reclaim easy target as compaction requires. If you
do not reclaim at all you can make the current implementation of the
compaction noop due to its own watermark checks IIRC.

> The effect of the below should be evaluated regardless of the issue
> we've been discussing in this thread and it's a new corner case for
> order > PAGE_ALLOC_COSTLY_ORDER. I don't like very much order >
> PAGE_ALLOC_COSTLY_ORDER checks, those are arbitrary numbers, the more
> checks are needed in various places for that, the more it's a sign the
> VM is bad and arbitrary and with one more corner case required to hide
> some badness. But again this will have effects unrelated to what we're
> discussing here and it will just convert I/O into CPU waste and have
> no effect on vfio.

yeah, I agree about PAGE_ALLOC_COSTLY_ORDER being an arbitrary limit for
a different behavior. But we already do handle those specially so it
kind of makes sense to me to expand on that.
-- 
Michal Hocko
SUSE Labs
