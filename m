Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 590FB6B0617
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 08:11:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so1123052edc.17
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 05:11:32 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id w9-v6si1894696edc.162.2018.11.09.05.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 05:11:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 4BB851C31D2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 13:11:30 +0000 (GMT)
Date: Fri, 9 Nov 2018 13:11:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181109131128.GE23260@techsingularity.net>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
> > The basic idea as outlined by Mel Gorman in [2] is:
> > 
> > 1) On first fault in a sufficiently sized range, allocate a huge page
> >    sized and aligned block of base pages.  Map the base page
> >    corresponding to the fault address and hold the rest of the pages in
> >    reserve.
> > 2) On subsequent faults in the range, map the pages from the reservation.
> > 3) When enough pages have been mapped, promote the mapped pages and
> >    remaining pages in the reservation to a huge page.
> > 4) When there is memory pressure, release the unused pages from their
> >    reservations.
> 
> I haven't yet read the patch in details, but I'm skeptical about the
> approach in general for few reasons:
> 
> - PTE page table retracting to replace it with huge PMD entry requires
>   down_write(mmap_sem). It makes the approach not practical for many
>   multi-threaded workloads.
> 
>   I don't see a way to avoid exclusive lock here. I will be glad to
>   be proved otherwise.
> 

That problem is somewhat fundamental to the mmap_sem itself and
conceivably it could be alleviated by range-locking (if that gets
completed). The other thing to bear in mind is the timing. If the
promotion is in-place due to reservations, there isn't the allocation
overhead and the hold times *should* be short.

> - The promotion will also require TLB flush which might be prohibitively
>   slow on big machines.
> 

Which may be offset by either a) setting the threshold to 1 in cases
where the promtotion should always be immediate or b) offset by reduced
memory consumption potentially avoiding premature reclaim in others.

> - Short living processes will fail to benefit from THP with the policy,
>   even with plenty of free memory in the system: no time to promote to THP
>   or, with synchronous promotion, cost will overweight the benefit.
> 

Short-lived processes are also not going to be dominated by the TLB
refill cost so I think that's somewhat unfair. Potential means of
mediating this include per-task promotion thresholds via either prctl or
a task-wide policy inherited across exec

> The goal to reduce memory overhead of THP is admirable, but we need to be
> careful not to kill THP benefit itself. The approach will reduce number of
> THP mapped in the system and/or shift their allocation to later stage of
> process lifetime.
> 

While I agree with you, I also had suggested in review that the
threshold initially be set to 1 so it can be experiemented with by
people who are more concerned about memory consumption than reduced TLB
misses. While the general idea is not free of problems, I believe they
are fixable rather than fundamental.

> Prove me wrong with performance data. :)
> 

Agreed that this should be accompanied by performance data but I think I
laid out a reasonable approach here. If the default is a threshold of 1
and that is shown to be performance-neutral then incremental progress
can be made as opposed to an "all or nothing" approach.

-- 
Mel Gorman
SUSE Labs
