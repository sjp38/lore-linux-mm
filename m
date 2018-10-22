Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5F496B000A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:04:36 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c28-v6so27794190pfe.4
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 14:04:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 97-v6sor10925719plm.39.2018.10.22.14.04.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 14:04:35 -0700 (PDT)
Date: Mon, 22 Oct 2018 14:04:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181016074606.GH6931@suse.de>
Message-ID: <alpine.DEB.2.21.1810221355050.120157@chino.kir.corp.google.com>
References: <20181005232155.GA2298@redhat.com> <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <20181009122745.GN8528@dhcp22.suse.cz> <20181009130034.GD6931@suse.de> <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com> <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com> <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com> <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, 16 Oct 2018, Mel Gorman wrote:

> I consider this to be an unfortunate outcome. On the one hand, we have a
> problem that three people can trivially reproduce with known test cases
> and a patch shown to resolve the problem. Two of those three people work
> on distributions that are exposed to a large number of users. On the
> other, we have a problem that requires the system to be in a specific
> state and an unknown workload that suffers badly from the remote access
> penalties with a patch that has review concerns and has not been proven
> to resolve the trivial cases.

The specific state is that remote memory is fragmented as well, this is 
not atypical.  Removing __GFP_THISNODE to avoid thrashing a zone will only 
be beneficial when you can allocate remotely instead.  When you cannot 
allocate remotely instead, you've made the problem much worse for 
something that should be __GFP_NORETRY in the first place (and was for 
years) and should never thrash.

I'm not interested in patches that require remote nodes to have an 
abundance of free or unfragmented memory to avoid regressing.

> In the case of distributions, the first
> patch addresses concerns with a common workload where on the other hand
> we have an internal workload of a single company that is affected --
> which indirectly affects many users admittedly but only one entity directly.
> 

The alternative, which is my patch, hasn't been tested or shown why it 
cannot work.  We continue to talk about order >= pageblock_order vs
__GFP_COMPACTONLY.

I'd like to know, specifically:

 - what measurable affect my patch has that is better solved with removing
   __GFP_THISNODE on systems where remote memory is also fragmented?

 - what platforms benefit from remote access to hugepages vs accessing
   local small pages (I've asked this maybe 4 or 5 times now)?

 - how is reclaiming (and possibly thrashing) memory helpful if compaction
   fails to free an entire pageblock due to slab fragmentation due to low
   on memory conditions and the page allocator preference to return node-
   local memory?

 - how is reclaiming (and possibly thrashing) memory helpful if compaction
   cannot access the memory reclaimed because the freeing scanner has 
   already passed by it, or the migration scanner has passed by it, since
   this reclaim is not targeted to pages it can find?

 - what metrics can be introduced to the page allocator so that we can
   determine that reclaiming (and possibly thrashing) memory will result 
   in a hugepage being allocated?

Until we have answers, especially for the last, there is no reason why thp 
allocations should not be __GFP_NORETRY including for MADV_HUGEPAGE 
regions.  The implementation of memory compaction simply cannot guarantee 
that the cost is worthwhile.
