Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 127756B026F
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:57:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x8-v6so22753656qtc.15
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:57:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 56si1914796qvg.212.2018.10.15.15.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 15:57:45 -0700 (PDT)
Date: Mon, 15 Oct 2018 18:57:43 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181015225743.GB30832@redhat.com>
References: <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, Oct 15, 2018 at 03:30:17PM -0700, David Rientjes wrote:
> At the risk of beating a dead horse that has already been beaten, what are 
> the plans for this patch when the merge window opens?  It would be rather 
> unfortunate for us to start incurring a 14% increase in access latency and 
> 40% increase in fault latency.  Would it be possible to test with my 
> patch[*] that does not try reclaim to address the thrashing issue?  If 
> that is satisfactory, I don't have a strong preference if it is done with 
> a hardcoded pageblock_order and __GFP_NORETRY check or a new 
> __GFP_COMPACT_ONLY flag.

I don't like the pageblock size hardcoding inside the page
allocator. __GFP_COMPACT_ONLY is fully runtime equivalent, but it at
least let the caller choose the behavior, so it looks more flexible.

To fix your 40% fault latency concern in the short term we could use
__GFP_COMPACT_ONLY, but I think we should get rid of
__GFP_COMPACT_ONLY later: we need more statistical data in the zone
structure to track remote compaction failures triggering because the
zone is fully fragmented.

Once the zone is fully fragmented we need to do a special exponential
backoff on that zone when the zone is from a remote node.

Furthermore at the first remote NUMA node zone failure caused by full
fragmentation we need to interrupt compaction and stop trying with all
remote nodes.

As long as compaction returns COMPACT_SKIPPED it's ok to keep doing
reclaim and keep doing compaction, as long as compaction succeeds.

What is causing the higher latency is the fact we try all zones from
all remote nodes even if there's a failure caused by full
fragmentation of all remote zone, and we're unable to skip (skip with
exponential backoff) only those zones where compaction cannot succeed
because of fragmentation.

Once we achieve the above deleting __GFP_COMPACT_ONLY will be a
trivial patch.

> I think the second issue of faulting remote thp by removing __GFP_THISNODE 
> needs supporting evidence that shows some platforms benefit from this (and 
> not with numa=fake on the command line :).
> 
>  [*] https://marc.info/?l=linux-kernel&m=153903127717471

That is needed to compare the current one liner fix with
__GFP_COMPACT_ONLY, but I don't think it's needed to compare v4.18
with the current fix. The badness of v4.18 was too bad keep, getting
local PAGE_SIZEd memory or remote THPs is a secondary issue.

In fact the main reason for __GFP_COMPACT_ONLY is not anymore such
tradeoff, but not to spend too much CPU in compaction when all nodes
are fragmented to avoid increasing the allocation latency too much.

Thanks,
Andrea
