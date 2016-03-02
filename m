Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8372F6B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 13:47:37 -0500 (EST)
Received: by mail-qk0-f179.google.com with SMTP id x1so86137191qkc.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 10:47:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f189si37224227qhc.12.2016.03.02.10.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 10:47:36 -0800 (PST)
Date: Wed, 2 Mar 2016 19:47:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160302184732.GC4946@redhat.com>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160226103253.GA22450@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160226103253.GA22450@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Feb 26, 2016 at 01:32:53PM +0300, Kirill A. Shutemov wrote:
> Could you elaborate on problems with rmap? I have looked into this deeply
> yet.
> 
> Do you see anything what would prevent following basic scheme:
> 
>  - Identify series of small pages as candidate for collapsing into
>    a compound page. Not sure how difficult it would be. I guess it can be
>    done by looking for adjacent pages which belong to the same anon_vma.

Just like if there was no other process sharing them yes.

>  - Setup migration entries for pte which maps these pages.
>
> 
>  - Collapse small pages into compound page. IIUC, it only will be possible
>    if these pages are not pinned.
> 
>  - Replace migration entries with ptes which point to subpages of the new
>    compound page.
> 
>  - Scan over all vmas mapping this compound page, looking for VMA suitable
>    for huge page. We cannot collapse it right away due lock inversion of
>    anon_vma->rwsem vs. mmap_sem.
> 
>  - For found VMAs, collapse page table into PMD one VMA a time under
>    down_write(mmap_sem).
> 
> Even if would fail to create any PMDs, we would reduce LRU pressure by
> collapsing small pages into compound one.

I see how your new refcounting simplifies things as we don't have to
do create hugepmds immediately, but we still have to modify all ptes
of all sharers, not just those belonging to the vma we collapsed (or
we'd be effectively copying-on-collapse in turn losing the
sharing).

If we'd defer it and leave temporarily new THP and old 4k pages both
allocated and independently mapped, a process running in the old ptes
could gup_fast and a process in the new ptes could gup_fast too and
we'd up with double memory usage, so we'd need a way to redirect
gup_fast in the old pte to the new THP, so the future pins goes to the
new THP always. Some new linkage between old ptes and new ptes would
also be needed to keep walking it slowly and it shall be invalidated
during COWs.

Doing it incrementally and not updating all ptes at once wouldn't be
straightforward. Doing it not incrementally would mean paying the cost
of updating (in the worst case) up to hundred thousand ptes at full
CPU usage for a later gain we're not sure about. Said that I think
it's worthy goal to achieve, especially if we remove compaction from
direct reclaim.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
