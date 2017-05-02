Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C978E6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:36:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g12so14299106wrg.15
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:36:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6si19067560wrc.122.2017.05.02.07.36.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 07:36:12 -0700 (PDT)
Date: Tue, 2 May 2017 16:36:08 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170502143608.GM14593@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Wed 19-04-17 17:52:38, Balbir Singh wrote:
> This is a request for comments on the discussed approaches
> for coherent memory at mm-summit (some of the details are at
> https://lwn.net/Articles/717601/). The latest posted patch
> series is at https://lwn.net/Articles/713035/. I am reposting
> this as RFC, Michal Hocko suggested using HMM for CDM, but
> we believe there are stronger reasons to use the NUMA approach.
> The earlier patches for Coherent Device memory were implemented
> and designed by Anshuman Khandual.
> 
> Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
> The patches do a great deal to enable CDM with HMM, but we
> still believe that HMM with CDM is not a natural way to
> represent coherent device memory and the mm will need
> to be audited and enhanced for it to even work.
> 
> With HMM we'll see ZONE_DEVICE pages mapped into
> user space and that would mean a thorough audit of all code
> paths to make sure we are ready for such a use case and enabling
> those use cases, like with HMM CDM patch 1, which changes
> move_pages() and migration paths. I've done a quick
> evaluation to check for features and found limitationd around
> features like migration (page cache
> migration), fault handling to the right location
> (direct page cache allocation in the coherent memory), mlock
> handling, RSS accounting, memcg enforcement for pages not on LRU, etc.

Are those problems not viable to solve?

[...]
> Introduction
> 
> CDM device memory is cache coherent with system memory and we would like
> this to show up as a NUMA node, however there are certain algorithms
> that might not be currently suitable for N_COHERENT_MEMORY
> 
> 1. AutoNUMA balancing

OK, I can see a reason for that but theoretically the same applies to
cpu less numa nodes in general, no?

> 2. kswapd reclaim

How is the memory reclaim handled then? How are users expected to handle
OOM situation?

> The reason for exposing this device memory as NUMA is to simplify
> the programming model, where memory allocation via malloc() or
> mmap() for example would seamlessly work across both kinds of
> memory. Since we expect the size of device memory to be smaller
> than system RAM, we would like to control the allocation of such
> memory. The proposed mechanism reuses nodemasks and explicit
> specification of the coherent node in the nodemask for allocation
> from device memory. This implementation also allows for kernel
> level allocation via __GFP_THISNODE and existing techniques
> such as page migration to work.

so it basically resembles isol_cpus except for memory, right. I believe
scheduler people are more than unhappy about this interface...

Anyway, I consider CPUless nodes a dirty hack (especially when I see
them mostly used with poorly configured LPARs where no CPUs are left for
a particular memory).  Now this is trying to extend this concept even
further to a memory which is not reclaimable by the kernel and requires
an explicit and cooperative memory reclaim from userspace. How is this
going to work? The memory also has a different reliability properties
from RAM which user space doesn't have any clue about from the NUMA
properties exported. Or am I misunderstanding it? That all sounds quite
scary to me.

I very much agree with the last email from Mel and I would really like
to see how would a real application benefit from these nodes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
