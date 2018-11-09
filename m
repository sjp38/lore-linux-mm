Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id A689A6B06F2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 07:13:24 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id f4-v6so153180lfa.17
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 04:13:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor1285430lfa.64.2018.11.09.04.13.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 04:13:22 -0800 (PST)
Date: Fri, 9 Nov 2018 15:13:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
> The basic idea as outlined by Mel Gorman in [2] is:
> 
> 1) On first fault in a sufficiently sized range, allocate a huge page
>    sized and aligned block of base pages.  Map the base page
>    corresponding to the fault address and hold the rest of the pages in
>    reserve.
> 2) On subsequent faults in the range, map the pages from the reservation.
> 3) When enough pages have been mapped, promote the mapped pages and
>    remaining pages in the reservation to a huge page.
> 4) When there is memory pressure, release the unused pages from their
>    reservations.

I haven't yet read the patch in details, but I'm skeptical about the
approach in general for few reasons:

- PTE page table retracting to replace it with huge PMD entry requires
  down_write(mmap_sem). It makes the approach not practical for many
  multi-threaded workloads.

  I don't see a way to avoid exclusive lock here. I will be glad to
  be proved otherwise.

- The promotion will also require TLB flush which might be prohibitively
  slow on big machines.

- Short living processes will fail to benefit from THP with the policy,
  even with plenty of free memory in the system: no time to promote to THP
  or, with synchronous promotion, cost will overweight the benefit.

The goal to reduce memory overhead of THP is admirable, but we need to be
careful not to kill THP benefit itself. The approach will reduce number of
THP mapped in the system and/or shift their allocation to later stage of
process lifetime.

The only way I see it can be useful is if it will be possible to apply the
policy on per-VMA basis. It will be very useful for malloc()
implementations, for instance. But as a global policy it's no-go to me.

Prove me wrong with performance data. :)

-- 
 Kirill A. Shutemov
