Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A33B6B1E87
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 07:51:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 186-v6so952014pgc.12
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 04:51:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b62-v6si9312677pgc.491.2018.08.21.04.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 04:50:59 -0700 (PDT)
Date: Tue, 21 Aug 2018 13:50:57 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180821115057.GY29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820032204.9591-3-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Sun 19-08-18 23:22:04, Andrea Arcangeli wrote:
> qemu uses MADV_HUGEPAGE which allows direct compaction (i.e.
> __GFP_DIRECT_RECLAIM is set).
> 
> The problem is that direct compaction combined with the NUMA
> __GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
> hard the local node, instead of failing the allocation if there's no
> THP available in the local node.
> 
> Such logic was ok until __GFP_THISNODE was added to the THP allocation
> path even with MPOL_DEFAULT.
> 
> The idea behind the __GFP_THISNODE addition, is that it is better to
> provide local memory in PAGE_SIZE units than to use remote NUMA THP
> backed memory. That largely depends on the remote latency though, on
> threadrippers for example the overhead is relatively low in my
> experience.
> 
> The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
> extremely slow qemu startup with vfio, if the VM is larger than the
> size of one host NUMA node. This is because it will try very hard to
> unsuccessfully swapout get_user_pages pinned pages as result of the
> __GFP_THISNODE being set, instead of falling back to PAGE_SIZE
> allocations and instead of trying to allocate THP on other nodes (it
> would be even worse without vfio type1 GUP pins of course, except it'd
> be swapping heavily instead).
> 
> It's very easy to reproduce this by setting
> transparent_hugepage/defrag to "always", even with a simple memhog.
> 
> 1) This can be fixed by retaining the __GFP_THISNODE logic also for
>    __GFP_DIRECT_RELCAIM by allowing only one compaction run. Not even
>    COMPACT_SKIPPED (i.e. compaction failing because not enough free
>    memory in the zone) should be allowed to invoke reclaim.
> 
> 2) An alternative is not use __GFP_THISNODE if __GFP_DIRECT_RELCAIM
>    has been set by the caller (i.e. MADV_HUGEPAGE or
>    defrag="always"). That would keep the NUMA locality restriction
>    only when __GFP_DIRECT_RECLAIM is not set by the caller. So THP
>    will be provided from remote nodes if available before falling back
>    to PAGE_SIZE units in the local node, but an app using defrag =
>    always (or madvise with MADV_HUGEPAGE) supposedly prefers that.

So does reverting 5265047ac301 ("mm, thp: really limit transparent
hugepage allocation to local node") help?

I really detest a new gfp flag for one time semantic that is muddy as
hell.

> + * __GFP_ONLY_COMPACT: Only invoke compaction. Do not try to succeed
> + * the allocation by freeing memory. Never risk to free any
> + * "PAGE_SIZE" memory unit even if compaction failed specifically
> + * because of not enough free pages in the zone. This only makes sense
> + * only in combination with __GFP_THISNODE (enforced with a
> + * VM_WARN_ON), to restrict the THP allocation in the local node that
> + * triggered the page fault and fallback into PAGE_SIZE allocations in
> + * the same node. We don't want to invoke reclaim because there may be
> + * plenty of free memory already in the local node. More importantly
> + * there may be even plenty of free THP available in remote nodes so
> + * we should allocate those if something instead of reclaiming any
> + * memory in the local node. Implementation detail: set ___GFP_NORETRY
> + * too so that ___GFP_ONLY_COMPACT only needs to be checked in a slow
> + * path.

This is simply incomprehensible. How can anybody who is not deeply
familiar with the allocator/reclaim internals know when to use it.

If this is really a regression then we should start by pinpointing the
real culprit and go from there. If this is really 5265047ac301 then just
start by reverting it. I strongly suspect there is some mismatch in
expectations here. What others consider acceptable seems to be a problem
for others. I believe that was one of the reasons why we have changed
the default THP direct compaction behavior, no?
-- 
Michal Hocko
SUSE Labs
