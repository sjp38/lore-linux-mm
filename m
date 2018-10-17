Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04DE06B027C
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:00:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e6-v6so19367046pge.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:00:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 72-v6si18057234pla.334.2018.10.17.02.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:00:22 -0700 (PDT)
Date: Wed, 17 Oct 2018 10:00:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181017090015.GI6931@suse.de>
References: <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
 <20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181016153715.b40478ff2eebe8d6cf1aead5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, Oct 16, 2018 at 03:37:15PM -0700, Andrew Morton wrote:
> On Tue, 16 Oct 2018 08:46:06 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > I consider this to be an unfortunate outcome. On the one hand, we have a
> > problem that three people can trivially reproduce with known test cases
> > and a patch shown to resolve the problem. Two of those three people work
> > on distributions that are exposed to a large number of users. On the
> > other, we have a problem that requires the system to be in a specific
> > state and an unknown workload that suffers badly from the remote access
> > penalties with a patch that has review concerns and has not been proven
> > to resolve the trivial cases. In the case of distributions, the first
> > patch addresses concerns with a common workload where on the other hand
> > we have an internal workload of a single company that is affected --
> > which indirectly affects many users admittedly but only one entity directly.
> > 
> > At the absolute minimum, a test case for the "system fragmentation incurs
> > access penalties for a workload" scenario that could both replicate the
> > fragmentation and demonstrate the problem should have been available before
> > the patch was rejected.  With the test case, there would be a chance that
> > others could analyse the problem and prototype some fixes. The test case
> > was requested in the thread and never produced so even if someone were to
> > prototype fixes, it would be dependant on a third party to test and produce
> > data which is a time-consuming loop. Instead, we are more or less in limbo.
> > 
> 
> OK, thanks.
> 
> But we're OK holding off for a few weeks, yes?  If we do that
> we'll still make it into 4.19.1.  Am reluctant to merge this while
> discussion, testing and possibly more development are ongoing.
> 

Without a test case that reproduces the Google case, we are a bit stuck.
Previous experience indicates that just fragmenting memory is not enough
to give a reliable case as unless the unmovable/reclaimable pages are
"sticky", the normal reclaim can handle it. Similarly, the access
pattern of the target workload is important as it would need to be
something larger than L3 cache to constantly hit the access penalty. We
do not know what the exact characteristics of the Google workload are
but we know that a fix for three cases is not equivalent for the Google
case.

The discussion has circled around wish-list items such as better
fragmentation control, node-aware compaction, improved compact deferred
logic and lower latencies with little in the way of actual specifics
of implementation or patches. Improving fragmentation control would
benefit from a workload that actually fragments so the extfrag events
can be monitored as well as maybe a dump of pageblocks with mixed pages.

On node-aware compaction, that was not implemented initially simply
because HighMem was common and that needs to be treated as a corner case
-- we cannot safely migrate pages from zone normal to highmem. That one
is relatively trivial to measure as it's a functional issue.

However, backing off compaction properly to maximise allocation success
rates while minimising allocation latency and access latency needs a live
workload that is representative. Trivial cases like the java workloads,
nas or usemem won't do as they either exhibit special locality or are
streaming readers/writers. Memcache might work but the driver in that
case is critical to ensure the access penalties are incurred. Again,
a modern example is missing.

As for why this took so long to discover, it is highly likely that it's
due to VM's being sized such as they typically fit in a NUMA node so
it would have avoided the worst case scenarios. Furthermore, a machine
dedicated to VM's has fewer concerns with respect to slab allocations
and unmovable allocations fragmenting memory long-term. Finally, the
worst case scenarios are encountered when there is a mix of different
workloads of variable duration which may be common in a Google-like setup
with different jobs being dispatched across a large network but less so
in other setups where a service tends to be persistent. We already know
that some of the worst performance problems take years to discover.

-- 
Mel Gorman
SUSE Labs
