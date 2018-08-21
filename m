Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6824F6B2101
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 18:18:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q26-v6so6405534qtj.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:18:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k8-v6si67917qtg.106.2018.08.21.15.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 15:18:47 -0700 (PDT)
Date: Tue, 21 Aug 2018 18:18:43 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180821221843.GI13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <20180820151905.GB13047@redhat.com>
 <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
 <alpine.DEB.2.21.1808211021110.258924@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808211021110.258924@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>

On Tue, Aug 21, 2018 at 10:26:54AM -0700, David Rientjes wrote:
> MADV_HUGEPAGE (or defrag == "always") would now become a combination of 
> "try to compact locally" and "allocate remotely if necesary" without the 
> ability to avoid the latter absent a mempolicy that affects all memory 

I don't follow why compaction should run only on the local node in
such case (i.e. __GFP_THISNODE removed when __GFP_DIRECT_RECLAIM is
set).

The zonelist will simply span all nodes so compaction & reclaim should
both run on all for MADV_HUGEPAGE with option 2).

The only mess there is in the allocator right now is that compaction
runs per zone and reclaim runs per node but that's another issue and
won't hurt for this case.

> allocations.  I think the complete solution would be a MPOL_F_HUGEPAGE 
> flag that defines mempolicies for hugepage allocations.  In my experience 
> thp falling back to remote nodes for intrasocket latency is a win but 
> intersocket or two-hop intersocket latency is a no go.

Yes, that's my expectation too.

So what you suggest is to add a new hard binding, that allows altering
the default behavior for THP, that sure sounds fine.

We've still to pick the actual default and decide if a single default
is ok or it should be tunable or even change the default depending on
the NUMA topology.

I suspect it's a bit overkill to have different defaults depending on
NUMA topology. There have been defaults for obscure things like
numa_zonelist_order that changed behavior depending on number of nodes
and they happened to hurt on some system. I ended up tuning them to
the current default (until the runtime tuning was removed).

It's a bit hard to just pick the best just based on arbitrary things
like number of numa nodes or distance, especially when what is better
also depends on the actual application.

I think options are sane behaviors with some pros and cons, and option
2) is simpler and will likely perform better on smaller systems,
option 1) is less risky in larger systems.

In any case the watermark optimization to set __GFP_THISNODE only if
there's plenty of PAGE_SIZEd memory in the local node, remains a valid
optimization for later for the default "defrag" value (i.e. no
MADV_HUGEPAGE) not setting __GFP_DIRECT_RECLAIM. If there's no RAM
free in the local node we can totally try to pick the THP from the
other nodes and not doing so only has the benefit of saving the
watermark check itself.

Thanks,
Andrea
