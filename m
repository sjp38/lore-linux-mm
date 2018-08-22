Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFD606B2385
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:02:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id q29-v6so657224edd.0
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:02:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31-v6si1375215edd.265.2018.08.22.02.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 02:02:16 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:02:14 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180822090214.GF29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821214049.GG13047@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 21-08-18 17:40:49, Andrea Arcangeli wrote:
> On Tue, Aug 21, 2018 at 01:50:57PM +0200, Michal Hocko wrote:
[...]
> > I really detest a new gfp flag for one time semantic that is muddy as
> > hell.
> 
> Well there's no way to fix this other than to prevent reclaim to run,
> if you still want to give a chance to page faults to obtain THP under
> MADV_HUGEPAGE in the page fault without waiting minutes or hours for
> khugpaged to catch up with it.

I do not get that part. Why should caller even care about reclaim vs.
compaction. How can you even make an educated guess what makes more
sense? This should be fully controlled by the allocator path. The caller
should only care about how hard to try. It's been some time since I've
looked but we used to have a gfp flags to tell that for THP allocations
as well.

> > This is simply incomprehensible. How can anybody who is not deeply
> > familiar with the allocator/reclaim internals know when to use it.
> 
> Nobody should use this in drivers, it's a __GFP flag.

Like other __GFP flags (e.g. __GFP_NOWARN, __GFP_COMP, __GFP_ZERO and
many others)?

> Note:
> 
> 	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
> 
> #define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> 	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
> 
> Only THP is ever affected by the BUG so nothing else will ever need to
> call __GFP_COMPACT_ONLY. It is a VM internal flag, I wish there was a
> way to make the build fail if a driver would use it but there isn't
> right now.

My experience tells me that there is nothing like an internal gfp flag
and abusing them is quite common and really hard to get rid of. Having a
THP specific gfp flag has also turned out to be a bad idea (e.g. GFP_THISNODE).

> > If this is really a regression then we should start by pinpointing the
> 
> You can check yourself, create a 2 node vnuma guest or pick any host
> with more than one node. Set defrag=always and run "memhog -r11111111
> 18g" if host has 16g per node. Add some swap and notice the swap storm
> while all ram is left free in the other node.

I am not disputing the bug itself. How hard should defrag=allways really
try is good question and I would say different people would have
different ideas but a swapping storm sounds like genuinely unwanted
behavior. I would expect that to be handled in the reclaim/compaction.
GFP_TRANSHUGE doesn't have ___GFP_RETRY_MAYFAIL so it shouldn't really
try too hard to reclaim.

> > real culprit and go from there. If this is really 5265047ac301 then just
> 
> In my view there's no single culprit, but it was easy to identify the
> last drop that made the MADV_HUGEPAGE glass overflow, and it's that
> commit that adds __GFP_THISNODE. The combination of the previous code
> that prioritized NUMA over THP and then the MADV_HUGEPAGE logic that
> still uses compaction (and in turn reclaim if compaction fails with
> COMPACT_SKIPPED because there's no 4k page in the local node) just
> falls apart with __GFP_THISNODE set as well on top of it and it
> doesn't do the expected thing either without it (i.e. THP gets
> priority over NUMA locality without such flag).
> 
> __GFP_THISNODE and the logic there, only works ok when
> __GFP_DIRECT_RECLAIM is not set, i.e. MADV_HUGEPAGE not set.

I still have to digest the __GFP_THISNODE thing but I _think_ that the
alloc_pages_vma code is just trying to be overly clever and
__GFP_THISNODE is not a good fit for it. 

-- 
Michal Hocko
SUSE Labs
