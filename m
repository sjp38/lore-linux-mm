Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C83C6B034F
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 17:45:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s141-v6so4160369pgs.23
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 14:45:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7-v6sor13318398pga.38.2018.10.28.14.45.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Oct 2018 14:45:07 -0700 (PDT)
Date: Sun, 28 Oct 2018 14:45:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <0BA54BDA-D457-4BD8-AC49-1DD7CD032C7F@cs.rutgers.edu>
Message-ID: <alpine.DEB.2.21.1810281426260.129745@chino.kir.corp.google.com>
References: <20181005232155.GA2298@redhat.com> <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <20181009122745.GN8528@dhcp22.suse.cz> <20181009130034.GD6931@suse.de> <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com> <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com> <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com> <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org> <20181016074606.GH6931@suse.de>
 <alpine.DEB.2.21.1810221355050.120157@chino.kir.corp.google.com> <0BA54BDA-D457-4BD8-AC49-1DD7CD032C7F@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, 22 Oct 2018, Zi Yan wrote:

> Hi David,
> 

Hi!

> On 22 Oct 2018, at 17:04, David Rientjes wrote:
> 
> > On Tue, 16 Oct 2018, Mel Gorman wrote:
> > 
> > > I consider this to be an unfortunate outcome. On the one hand, we have a
> > > problem that three people can trivially reproduce with known test cases
> > > and a patch shown to resolve the problem. Two of those three people work
> > > on distributions that are exposed to a large number of users. On the
> > > other, we have a problem that requires the system to be in a specific
> > > state and an unknown workload that suffers badly from the remote access
> > > penalties with a patch that has review concerns and has not been proven
> > > to resolve the trivial cases.
> > 
> > The specific state is that remote memory is fragmented as well, this is
> > not atypical.  Removing __GFP_THISNODE to avoid thrashing a zone will only
> > be beneficial when you can allocate remotely instead.  When you cannot
> > allocate remotely instead, you've made the problem much worse for
> > something that should be __GFP_NORETRY in the first place (and was for
> > years) and should never thrash.
> > 
> > I'm not interested in patches that require remote nodes to have an
> > abundance of free or unfragmented memory to avoid regressing.
> 
> I just wonder what is the page allocation priority list in your environment,
> assuming all memory nodes are so fragmented that no huge pages can be
> obtained without compaction or reclaim.
> 
> Here is my version of that list, please let me know if it makes sense to you:
> 
> 1. local huge pages: with compaction and/or page reclaim, you are willing
> to pay the penalty of getting huge pages;
> 
> 2. local base pages: since, in your system, remote data accesses have much
> higher penalty than the extra TLB misses incurred by the base page size;
> 
> 3. remote huge pages: at least it is better than remote base pages;
> 
> 4. remote base pages: it performs worst in terms of locality and TLBs.
> 

I have a ton of different platforms available.  Consider a very basic 
access latency evaluation on Broadwell on a running production system: 
remote hugepage vs remote PAGE_SIZE pages had about 5% better access 
latency.  Remote PAGE_SIZE pages vs local pages is a 12% degradation.  On 
Naples, remote hugepage vs remote PAGE_SIZE had 2% better access latency 
intrasocket, no better access latency intersocket.  Remote PAGE_SIZE pages 
vs local is a 16% degradation intrasocket and 38% degradation intersocket.

My list removes (3) from your list, but is otherwise unchanged.  I remove 
(3) because 2-5% better access latency is nice, but we'd much rather fault 
local base pages and then let khugepaged collapse it into a local hugepage 
when fragmentation is improved or we have freed memory.  That is where we 
can get a much better result, 41% better access latency on Broadwell and 
52% better access latncy on Naples.  I wouldn't trade that for 2-5% 
immediate remote hugepages.

It just so happens that prior to this patch, the implementation of the 
page allocator matches this preference.

> In addition, to prioritize local base pages over remote pages,
> the original huge page allocation has to fail, then kernel can
> fall back to base page allocations. And you will never get remote
> huge pages any more if the local base page allocation fails,
> because there is no way back to huge page allocation after the fallback.
> 

That is exactly what we want, we want khugepaged to collapse memory into 
local hugepages for the big improvement rather than persistently access a 
hugepage remotely; the win of the remote hugepage just isn't substantial 
enough, and the win of the local hugepage is just too great.

> > I'd like to know, specifically:
> > 
> >  - what measurable affect my patch has that is better solved with removing
> >    __GFP_THISNODE on systems where remote memory is also fragmented?
> > 
> >  - what platforms benefit from remote access to hugepages vs accessing
> >    local small pages (I've asked this maybe 4 or 5 times now)?
> > 
> >  - how is reclaiming (and possibly thrashing) memory helpful if compaction
> >    fails to free an entire pageblock due to slab fragmentation due to low
> >    on memory conditions and the page allocator preference to return node-
> >    local memory?
> > 
> >  - how is reclaiming (and possibly thrashing) memory helpful if compaction
> >    cannot access the memory reclaimed because the freeing scanner has
> >    already passed by it, or the migration scanner has passed by it, since
> >    this reclaim is not targeted to pages it can find?
> > 
> >  - what metrics can be introduced to the page allocator so that we can
> >    determine that reclaiming (and possibly thrashing) memory will result
> >    in a hugepage being allocated?
> 
> The slab fragmentation and whether reclaim/compaction can help form
> huge pages seem to orthogonal to this patch, which tries to decide
> the priority between locality and huge pages.
> 

It's not orthogonal to the problem being reported which requires local 
memory pressure.  If there is no memory pressure, compaction often can 
succeed without reclaim because the freeing scanner can find target 
memory and the migration scanner can make a pageblock free.  Under memory 
pressure, however, where Andrea is experiencing the thrashing of the local 
node, by this time it can be inferred that slab pages have already fallen 
bcak to MIGRATE_MOVABLE pageblocks.  There is nothing preventing it under 
memory pressure because of the preference to return local memory over 
fragmenting pageblocks.

So the point of slab fragmentation, which typically exists locally when 
there is memory pressure, is that we cannot ascertain whether memory 
compaction even with reclaim will be successful.  Not only because the 
freeing scanner cannot access reclaimed memory, but also because we have 
no feedback from compaction to determine whether the work will be useful.  
Thrashing the local node, migrating COMPACT_CLUSTER_MAX pages, finding one 
slab page sitting in the pageblock, and continuing is not a good use of 
the allocator's time.  This is true of both MADV_HUGEPAGE and 
non-MADV_HUGEPAGE regions.

For reclaim to be considered, we should ensure that work is useful to 
compaction.  That ability is non-existant.  The worst case scenario is you 
thrash the local node and still cannot allocate a hugepage.
