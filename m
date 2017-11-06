Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 307596B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 15:21:53 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id s88so1301618ota.1
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 12:21:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v24si6581917otv.355.2017.11.06.12.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 12:21:52 -0800 (PST)
Date: Mon, 6 Nov 2017 21:21:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP
 migration
Message-ID: <20171106202148.GA26645@redhat.com>
References: <20171103075231.25416-1-ying.huang@intel.com>
 <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
 <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

Hello,

On Sun, Nov 05, 2017 at 11:01:05AM +0800, huang ying wrote:
> On Fri, Nov 3, 2017 at 11:00 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
> > On 3 Nov 2017, at 3:52, Huang, Ying wrote:
> >
> >> From: Huang Ying <ying.huang@intel.com>
> >>
> >> If THP migration is enabled, the following situation is possible,
> >>
> >> - A THP is mapped at source address
> >> - Migration is started to move the THP to another node
> >> - Page fault occurs
> >> - The PMD (migration entry) is copied to the destination address in mremap
> >>
> >
> > You mean the page fault path follows the source address and sees pmd_none() now
> > because mremap() clears it and remaps the page with dest address.
> > Otherwise, it seems not possible to get into handle_userfault(), since it is called in
> > pmd_none() branch inside do_huge_pmd_anonymous_page().
> >
> >
> >> That is, it is possible for handle_userfault() encounter a PMD entry
> >> which has been handled but !pmd_present().  In the current
> >> implementation, we will wait for such PMD entries, which may cause
> >> unnecessary waiting, and potential soft lockup.
> >
> > handle_userfault() should only see pmd_none() in the situation you describe,
> > whereas !pmd_present() (migration entry case) should lead to
> > pmd_migration_entry_wait().
> 
> Yes.  This is my understanding of the source code too.  And I
> described it in the original patch description too.  I just want to
> make sure whether it is possible that !pmd_none() and !pmd_present()
> for a PMD in userfaultfd_must_wait().  And, whether it is possible for

I don't see how mremap is relevant above. mremap runs with mmap_sem
for writing, so it can't race against userfaultfd_must_wait.

However the concern of set_pmd_migration_entry() being called with
only the mmap_sem for reading through TTU_MIGRATION in
__unmap_and_move and being interpreted as a "missing" THP page by
userfaultfd_must_wait seems valid.

Compaction won't normally compact pages that are already THP sized so
you cannot see this normally because VM don't normally get migrated
over SHM/hugetlbfs with hard bindings while userfaults are in
progress.

Overall your patch looks more correct than current code so it's good
idea to apply and it should avoid surprises with the above corner
case if CONFIG_ARCH_ENABLE_THP_MIGRATION is set.

Worst case the process would hang in handle_userfault(), but it will
still respond fine to sigkill, so it's not concerning, but it should
be fixed nevertheless.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

> us to implement PMD mapping copying in UFFDIO_COPY in the future?

That's definitely good idea to add too. We don't have an userland
model for THP yet in QEMU (so it wouldn't be making a difference right
now), we have it for the hugetlbfs-only case though. It'd be nice to
add a THP model and to have an option to do the faults at 2M
granularity also on anon and SHM memory (not just with hugetlbfs).

With userfaults the granularity of the fault is entirely decided by
userland. The kernel can then map a THP directly into the destination
if the granularity userland uses is 2M. The 8k user fault granularity
would also be feasible on x86, but it won't provide any TLB benefits,
while the 2M granularity will (after the kernel optimization you're
asking about). So it should be an ideal faetu.

I tried to defer the complexity to the point it could provide a
runtime payoff and until we tested userfaults at 2M granularity we
wouldn't know for sure how it would behave. Now we run userfaults on
hugetlbfs in production and so by now know the latency of those 2M
transfers over network is acceptable and the live migration runs
slightly faster overall. All goes as expected at runtime, so in
principle the THP model with anon/SHM THP should be a good tradeoff
too. Note that it will only work well with the fastest network
bandwidth available. Legacy gigabit likely wants to stay at current 4k
granularity so the default should probably stick to 4k userfault
granularity to avoid having to deal with unexpected higher latencies.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
