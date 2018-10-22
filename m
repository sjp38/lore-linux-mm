Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCFF6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:54:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w15-v6so30551475pge.2
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:54:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j32-v6sor21621709pgj.16.2018.10.22.13.54.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 13:54:35 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:54:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181015231953.GC30832@redhat.com>
Message-ID: <alpine.DEB.2.21.1810221346130.120157@chino.kir.corp.google.com>
References: <20181005232155.GA2298@redhat.com> <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <20181009122745.GN8528@dhcp22.suse.cz> <20181009130034.GD6931@suse.de> <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com> <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com> <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com> <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181015231953.GC30832@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, 15 Oct 2018, Andrea Arcangeli wrote:

> > On Mon, 15 Oct 2018 15:30:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > >  Would it be possible to test with my 
> > > patch[*] that does not try reclaim to address the thrashing issue?
> > 
> > Yes please.
> 
> It'd also be great if a testcase reproducing the 40% higher access
> latency (with the one liner original fix) was available.
> 

I never said 40% higher access latency, I said 40% higher fault latency.  

The higher access latency is 13.9% as measured on Haswell.

The test case is rather trivial: fragment all memory with order-4 memory 
to replicate a fragmented local zone, use sched_setaffinity() to bind to 
that node, and fault a reasonable number of hugepages (128MB, 256, 
whatever).  The cost of faulting remotely in this case was measured to be 
40% higher than falling back to local small pages.  This occurs quite 
obviously because you are thrashing the remote node trying to allocate 
thp.

> We don't have a testcase for David's 40% latency increase problem, but
> that's likely to only happen when the system is somewhat low on memory
> globally.

Well, yes, but that's most of our systems.  We can't keep around gigabytes 
of memory free just to work around this patch.  Removing __GFP_THISNODE to 
avoid thrashing the local node obviously will incur a substantial 
performance degradation if you thrash the remote node as well.  This 
should be rather straight forward.

> When there's 75% or more of the RAM free (not even allocated as easily
> reclaimable pagecache) globally, you don't expect to hit heavy
> swapping.
> 

I agree there is no regression introduced by your patch when 75% of memory 
is free.

> The 40% THP allocation latency increase if you use MADV_HUGEPAGE in
> such window where all remote zones are fully fragmented is somehow
> lesser of a concern in my view (plus there's the compact deferred
> logic that should mitigate that scenario). Furthermore it is only a
> concern for page faults in MADV_HUGEPAGE ranges. If MADV_HUGEPAGE is
> set the userland allocation is long lived, so such higher allocation
> latency won't risk to hit short lived allocations that don't set
> MADV_HUGEPAGE (unless madvise=always, but that's not the default
> precisely because not all allocations are long lived).
> 
> If the MADV_HUGEPAGE using library was freely available it'd also be
> nice.
> 

You scan your mappings for .text segments, map a hugepage-aligned region 
sufficient in size, mremap() to that region, and do MADV_HUGEPAGE.
