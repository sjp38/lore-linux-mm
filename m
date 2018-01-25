Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0562E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 16:13:14 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 31so5292163wru.0
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 13:13:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si4188922wre.530.2018.01.25.13.13.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 13:13:12 -0800 (PST)
Date: Thu, 25 Jan 2018 21:13:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180125211303.rbfeg7ultwr6hpd3@suse.de>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
 <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, J?r?me Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 25, 2018 at 11:41:03AM -0800, Nitin Gupta wrote:
> >> It's not really about memory scarcity but a more efficient use of it.
> >> Applications may want hugepage benefits without requiring any changes to
> >> app code which is what THP is supposed to provide, while still avoiding
> >> memory bloat.
> >>
> > I read these links and find that there are mainly two complains:
> > 1. THP causes latency spikes, because direction compaction slows down THP allocation,
> > 2. THP bloats memory footprint when jemalloc uses MADV_DONTNEED to return memory ranges smaller than
> >    THP size and fails because of THP.
> >
> > The first complain is not related to this patch.
> 
> I'm trying to address many different THP issues and memory bloat is
> first among them.

Expecting userspace to get this right is probably going to go sideways.
It'll be screwed up and be sub-optimal or have odd semantics for existing
madvise flags. The fact is that an application may not even know if it's
going to be sparsely using memory in advance if it's a computation load
modelling from unknown input data.

I suggest you read the old Talluri paper "Superpassing the TLB Performance
of Superpages with Less Operating System Support" and pay attention to
Section 4. There it discusses a page reservation scheme whereby on fault
a naturally aligned set of base pages are reserved and only one correctly
placed base page is inserted into the faulting address. It was tied into
a hypothetical piece of hardware that doesn't exist to give best-effort
support for superpages so it does not directly help you but the initial
idea is sound. There are holes in the paper from todays perspective but
it was written in the 90's.

>From there, read "Transparent operating system support for superpages"
by Navarro, particularly chapter 4 paying attention to the parts where
it talks about opportunism and promotion threshold.

Superficially, it goes like this

1. On fault, reserve a THP in the allocator and use one base page that
   is correctly-aligned for the faulting addresses. By correctly-aligned,
   I mean that you use base page whose offset would be naturally contiguous
   if it ever was part of a huge page.
2. On subsequent faults, attempt to use a base page that is naturally
   aligned to be a THP
3. When a "threshold" of base pages are inserted, allocate the remaining
   pages and promote it to a THP
4. If there is memory pressure, spill "reserved" pages into the main
   allocation pool and lose the opportunity to promote (which will need
   khugepaged to recover)

By definition, a promotion threshold of 1 would be the existing scheme
of allocation a THP on the first fault and some users will want that. It
also should be the default to avoid unexpected overhead.  For workloads
where memory is being sparsely addressed and the increased overhead of
THP is unwelcome then the threshold should be tuned higher with a maximum
possible value of HPAGE_PMD_NR.

It's non-trivial to do this because at minimum a page fault has to check
if there is a potential promotion candidate by checking the PTEs around
the faulting address searching for a correctly-aligned base page that is
already inserted. If there is, then check if the correctly aligned base
page for the current faulting address is free and if so use it. It'll
also then need to check the remaining PTEs to see if both the promotion
threshold has been reached and if so, promote it to a THP (or else teach
khugepaged to do an in-place promotion if possible). In other words,
implementing the promotion threshold is both hard and it's not free.

However, if it did exist then the only tunable would be the "promotion
threshold" and applications would not need any special awareness of their
address space.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
