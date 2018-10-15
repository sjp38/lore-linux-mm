Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 474036B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 19:19:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v198-v6so21738505qka.16
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:19:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r23-v6si3315155qte.383.2018.10.15.16.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 16:19:55 -0700 (PDT)
Date: Mon, 15 Oct 2018 19:19:53 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181015231953.GC30832@redhat.com>
References: <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

Hello Andrew,

On Mon, Oct 15, 2018 at 03:44:59PM -0700, Andrew Morton wrote:
> On Mon, 15 Oct 2018 15:30:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> >  Would it be possible to test with my 
> > patch[*] that does not try reclaim to address the thrashing issue?
> 
> Yes please.

It'd also be great if a testcase reproducing the 40% higher access
latency (with the one liner original fix) was available.

We don't have a testcase for David's 40% latency increase problem, but
that's likely to only happen when the system is somewhat low on memory
globally. So the measurement must be done when compaction starts
failing globally on all zones, but before the system starts
swapping. The more global fragmentation the larger will be the window
between "compaction fails because all zones are too fragmented" and
"there is still free PAGE_SIZEd memory available to reclaim without
swapping it out". If I understood correctly, that is precisely the
window where the 40% higher latency should materialize.

The workload that shows the badness in the upstream code is fairly
trivial. Mel and Zi reproduced it too and I have two testcases that
can reproduce it, one with device assignment and the other is just
memhog. That's a massively larger window than the one where the 40%
higher latency materializes.

When there's 75% or more of the RAM free (not even allocated as easily
reclaimable pagecache) globally, you don't expect to hit heavy
swapping.

The 40% THP allocation latency increase if you use MADV_HUGEPAGE in
such window where all remote zones are fully fragmented is somehow
lesser of a concern in my view (plus there's the compact deferred
logic that should mitigate that scenario). Furthermore it is only a
concern for page faults in MADV_HUGEPAGE ranges. If MADV_HUGEPAGE is
set the userland allocation is long lived, so such higher allocation
latency won't risk to hit short lived allocations that don't set
MADV_HUGEPAGE (unless madvise=always, but that's not the default
precisely because not all allocations are long lived).

If the MADV_HUGEPAGE using library was freely available it'd also be
nice.
