Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDC76B0789
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 04:35:40 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id j5-v6so1327387ljg.1
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 01:35:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3-v6sor6175883ljk.33.2018.11.10.01.35.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 01:35:38 -0800 (PST)
Date: Sat, 10 Nov 2018 12:35:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181110093534.upaq6tfxxtoquq3p@kshutemo-mobl1>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109131128.GE23260@techsingularity.net>
 <EEBCAF4D-138C-4CF7-B4B7-C55F1192A026@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EEBCAF4D-138C-4CF7-B4B7-C55F1192A026@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Mel Gorman <mgorman@techsingularity.net>, Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Fri, Nov 09, 2018 at 10:34:07AM -0500, Zi Yan wrote:
> On 9 Nov 2018, at 8:11, Mel Gorman wrote:
> 
> > On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
> >> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
> >>> The basic idea as outlined by Mel Gorman in [2] is:
> >>>
> >>> 1) On first fault in a sufficiently sized range, allocate a huge page
> >>>    sized and aligned block of base pages.  Map the base page
> >>>    corresponding to the fault address and hold the rest of the pages in
> >>>    reserve.
> >>> 2) On subsequent faults in the range, map the pages from the reservation.
> >>> 3) When enough pages have been mapped, promote the mapped pages and
> >>>    remaining pages in the reservation to a huge page.
> >>> 4) When there is memory pressure, release the unused pages from their
> >>>    reservations.
> >>
> >> I haven't yet read the patch in details, but I'm skeptical about the
> >> approach in general for few reasons:
> >>
> >> - PTE page table retracting to replace it with huge PMD entry requires
> >>   down_write(mmap_sem). It makes the approach not practical for many
> >>   multi-threaded workloads.
> >>
> >>   I don't see a way to avoid exclusive lock here. I will be glad to
> >>   be proved otherwise.
> >>
> >
> > That problem is somewhat fundamental to the mmap_sem itself and
> > conceivably it could be alleviated by range-locking (if that gets
> > completed). The other thing to bear in mind is the timing. If the
> > promotion is in-place due to reservations, there isn't the allocation
> > overhead and the hold times *should* be short.
> >
> 
> Is it possible to convert all these PTEs to migration entries during
> the promotion and replace them with a huge PMD entry afterwards?
> AFAIK, migrating pages does not require holding a mmap_sem.
> Basically, it will act like migrating 512 base pages to a THP without
> actually doing the page copy.

You'll still need down_write(mmap_sem) to convert PTE page table full of
migration entires to PMD entry. It's required at least to protect against
parallel MADV_DONTNEED that can zap migration entries under you.

-- 
 Kirill A. Shutemov
