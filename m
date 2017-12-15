Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE3906B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:00:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 96so4715369wrk.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:00:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w21sor3851898edl.48.2017.12.15.02.00.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 02:00:26 -0800 (PST)
Date: Fri, 15 Dec 2017 13:00:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
Message-ID: <20171215100024.gxuijdovjhkugarz@node.shutemov.name>
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On Thu, Dec 14, 2017 at 05:28:52PM -0800, Nitin Gupta wrote:
> Currently, if the THP enabled policy is "always", or the mode
> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
> is allocated on a page fault if the pud or pmd is empty.  This
> yields the best VA translation performance, but increases memory
> consumption if some small page ranges within the huge page are
> never accessed.
> 
> An alternate behavior for such page faults is to install a
> hugepage only when a region is actually found to be (almost)
> fully mapped and active.  This is a compromise between
> translation performance and memory consumption.  Currently there
> is no way for an application to choose this compromise for the
> page fault conditions above.
> 
> With this change, when an application issues MADV_DONTNEED on a
> memory region, the region is marked as "space-efficient". For
> such regions, a hugepage is not immediately allocated on first
> write.  Instead, it is left to the khugepaged thread to do
> delayed hugepage promotion depending on whether the region is
> actually mapped and active. When application issues
> MADV_HUGEPAGE, the region is marked again as non-space-efficient
> wherein hugepage is allocated on first touch.

I think this would be NAK. At least in this form.

What performance testing have you done? Any numbers?

Making whole vma "space_efficient" just because somebody freed one page
from it is just wrong. And there's no way back after this.

> 
> Orabug: 26910556

Wat?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
