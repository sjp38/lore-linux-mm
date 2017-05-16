Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A86F6B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:10:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i63so131408260pgd.15
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:10:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si13140965pgk.81.2017.05.16.02.10.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 02:10:27 -0700 (PDT)
Date: Tue, 16 May 2017 11:10:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/4 v2] mm: give __GFP_REPEAT a better semantic
Message-ID: <20170516091022.GD2481@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307154843.32516-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

So, is there some interest in this? I am not going to push this if there
is a general consensus that we do not need to do anything about the
current situation or need a different approach.

On Tue 07-03-17 16:48:39, Michal Hocko wrote:
> Hi,
> this is a follow up for __GFP_REPEAT clean up merged in 4.7. The previous
> version of this patch series was posted as an RFC
> http://lkml.kernel.org/r/1465212736-14637-1-git-send-email-mhocko@kernel.org
> Since then I have reconsidered the semantic and made it a counterpart
> to the __GFP_NORETRY and made it the other extreme end of the retry
> logic. Both are not invoking the OOM killer so they are suitable
> for allocation paths with a fallback. Also a new potential user has
> emerged (kvmalloc - see patch 4). I have also renamed the flag from
> __GFP_RETRY_HARD to __GFP_RETRY_MAY_FAIL as this should be more clear.
> 
> I have kept the RFC status because of the semantic change. The patch 1
> is an exception because it should be merge regardless of the rest.
> 
> The main motivation for the change is that the current implementation of
> __GFP_REPEAT is not very much useful.
> 
> The documentation says:
>  * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
>  *   _might_ fail.  This depends upon the particular VM implementation.
> 
> It just fails to mention that this is true only for large (costly) high
> order which has been the case since the flag was introduced. A similar
> semantic would be really helpful for smal orders as well, though,
> because we have places where a failure with a specific fallback error
> handling is preferred to a potential endless loop inside the page
> allocator.
> 
> The earlier cleanup dropped __GFP_REPEAT usage for low (!costly) order
> users so only those which might use larger orders have stayed. One user
> which slipped through cracks is addressed in patch 1.
> 
> Let's rename the flag to something more verbose and use it for existing
> users. Semantic for those will not change. Then implement low (!costly)
> orders failure path which is hit after the page allocator is about to
> invoke the oom killer. Now we have a good counterpart for __GFP_NORETRY
> and finally can tell try as hard as possible without the OOM killer.
> 
> Xfs code already has an existing annotation for allocations which are
> allowed to fail and we can trivially map them to the new gfp flag
> because it will provide the semantic KM_MAYFAIL wants.
> 
> kvmalloc will allow also !costly high order allocations to retry hard
> before falling back to the vmalloc.
> 
> The patchset is based on the current linux-next.
> 
> Shortlog
> Michal Hocko (4):
>       s390: get rid of superfluous __GFP_REPEAT
>       mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_MAYFAIL with more useful semantic
>       xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
>       mm: kvmalloc support __GFP_RETRY_MAYFAIL for all sizes
> 
> Diffstat
>  Documentation/DMA-ISA-LPC.txt                |  2 +-
>  arch/powerpc/include/asm/book3s/64/pgalloc.h |  2 +-
>  arch/powerpc/kvm/book3s_64_mmu_hv.c          |  2 +-
>  arch/s390/mm/pgalloc.c                       |  2 +-
>  drivers/mmc/host/wbsd.c                      |  2 +-
>  drivers/s390/char/vmcp.c                     |  2 +-
>  drivers/target/target_core_transport.c       |  2 +-
>  drivers/vhost/net.c                          |  2 +-
>  drivers/vhost/scsi.c                         |  2 +-
>  drivers/vhost/vsock.c                        |  2 +-
>  fs/btrfs/check-integrity.c                   |  2 +-
>  fs/btrfs/raid56.c                            |  2 +-
>  fs/xfs/kmem.h                                | 10 +++++++++
>  include/linux/gfp.h                          | 32 +++++++++++++++++++---------
>  include/linux/slab.h                         |  3 ++-
>  include/trace/events/mmflags.h               |  2 +-
>  mm/hugetlb.c                                 |  4 ++--
>  mm/internal.h                                |  2 +-
>  mm/page_alloc.c                              | 14 +++++++++---
>  mm/sparse-vmemmap.c                          |  4 ++--
>  mm/util.c                                    | 14 ++++--------
>  mm/vmalloc.c                                 |  2 +-
>  mm/vmscan.c                                  |  8 +++----
>  net/core/dev.c                               |  6 +++---
>  net/core/skbuff.c                            |  2 +-
>  net/sched/sch_fq.c                           |  2 +-
>  tools/perf/builtin-kmem.c                    |  2 +-
>  27 files changed, 78 insertions(+), 53 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
