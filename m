Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEBD36B710D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 23:44:09 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c14-v6so6474303qtc.7
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 20:44:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4-v6si565305qkb.21.2018.09.04.20.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 20:44:08 -0700 (PDT)
Date: Tue, 4 Sep 2018 23:44:03 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180905034403.GN4762@redhat.com>
References: <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180830164057.GK2656@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Thu, Aug 30, 2018 at 06:40:57PM +0200, Michal Hocko wrote:
> On Thu 30-08-18 10:02:23, Zi Yan wrote:
> > On 30 Aug 2018, at 9:45, Michal Hocko wrote:
> > 
> > > On Thu 30-08-18 09:22:21, Zi Yan wrote:
> > >> On 30 Aug 2018, at 3:00, Michal Hocko wrote:
> > >>
> > >>> On Wed 29-08-18 18:54:23, Zi Yan wrote:
> > >>> [...]
> > >>>> I tested it against Linusa??s tree with a??memhog -r3 130ga?? in a two-socket machine with 128GB memory on
> > >>>> each node and got the results below. I expect this test should fill one node, then fall back to the other.
> > >>>>
> > >>>> 1. madvise(MADV_HUGEPAGE) + defrag = {always, madvise, defer+madvise}:
> > >>>> no swap, THPs are allocated in the fallback node.

no swap

> > >>>> 2. madvise(MADV_HUGEPAGE) + defrag = defer: pages got swapped to the
> > >>>> disk instead of being allocated in the fallback node.

swap

> > >>>> 3. no madvise, THP is on by default + defrag = {always, defer,
> > >>>> defer+madvise}: pages got swapped to the disk instead of being
> > >>>> allocated in the fallback node.

swap

> > >>>> 4. no madvise, THP is on by default + defrag = madvise: no swap, base
> > >>>> pages are allocated in the fallback node.

no swap

> > >>>> The result 2 and 3 seems unexpected, since pages should be allocated in the fallback node.

I agree it's not great for 2 and 3.

I don't see how the above can be considered a 100% "pass" to the test,
at best it's a 50% pass.

Let me clarify the setup to be sure:

1) There was no hard bind at all

2) Let's also ignore NUMA balancing which is all but restrictive at
   the start and it's meant to converge over time if current
   conditions don't allow immediate convergence. For simplicity let's
   assume NUMA balancing off.

So what the test exercised is the plain normal allocation of RAM with
THP main knob enabled to "always" on a NUMA system.

No matter the madvise used or not used, 2 cases over 4 decided to
swapout instead of allocating totally free THP or PAGE_SIZEd pages.

As opposed there would have been absolutely zero swapouts in the exact
same test if the main THP knob would have been disabled with:

     echo never >/sys/kernel/mm/transparent_hugepage/enabled

There is no way that enabling THP (no matter what other defrag
settings were and no matter if MADV_HUGEPAGE was used or not) should
cause heavy swap storms during page faults allocating memory, when
disabling THP doesn't swap even a single 4k page. That can't possibly
be right.

This is because there is no way the overhead of swapping can be
compensated by the THP improvement.

And with swapping I really mean "reclaim", just testing with the
swapout testcase is simpler and doesn't require an iommu pinning all
memory. So setting may_swap and may_unmap to zero won't move the
needle because my test showed just massive CPU consumption in trying
so hard to generate THP from the local node, but nothing got swapped
out because of the iommu pins.

That kind of swapping may only pay off in the very long long term,
which is what khugepaged is for. khugepaged already takes care of the
long term, so we could later argue and think if khugepaged should
swapout or not in such condition, but I don't think there's much to
argue about the page fault.

> Thanks for your and Stefan's testing. I will wait for some more
> feedback. I will be offline next few days and if there are no major
> objections I will repost with both tested-bys early next week.

I'm not so positive about 2 of the above tests if I understood the
test correctly.

Those results are totally fine if you used the non default memory
policy, but with MPOL_DEFAULT and in turn no hard bind of the memory,
I'm afraid it'll be even be harder to reproduce when things will go
wrong again in those two cases.

Thanks,
Andrea
