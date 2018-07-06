Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3815C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 13:10:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d25-v6so11522513qtp.10
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 10:10:27 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n79-v6si7248371qkh.309.2018.07.06.10.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 10:10:25 -0700 (PDT)
Date: Fri, 6 Jul 2018 13:10:19 -0400
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH] Revert "mm: always flush VMA ranges affected by
 zap_page_range"
Message-ID: <20180706131019.51e3a5f0@imladris.surriel.com>
In-Reply-To: <1530896635.5350.25.camel@surriel.com>
References: <1530896635.5350.25.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team <kernel-team@fb.com>

There was a bug in Linux that could cause madvise (and mprotect?)
system calls to return to userspace without the TLB having been
flushed for all the pages involved.

This could happen when multiple threads of a process made simultaneous
madvise and/or mprotect calls.

This was noticed in the summer of 2017, at which time two solutions
were created:
56236a59556c ("mm: refactor TLB gathering API")
99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
and
4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")

We need only one of these solutions, and the former appears to be
a little more efficient than the latter, so revert that one.

This reverts commit 4647706ebeee6e50f7b9f922b095f4ec94d581c3.
---
 mm/memory.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..9d472e00fc2d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1603,20 +1603,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, NULL);
-
-		/*
-		 * zap_page_range does not specify whether mmap_sem should be
-		 * held for read or write. That allows parallel zap_page_range
-		 * operations to unmap a PTE and defer a flush meaning that
-		 * this call observes pte_none and fails to flush the TLB.
-		 * Rather than adding a complex API, ensure that no stale
-		 * TLB entries exist when this call returns.
-		 */
-		flush_tlb_range(vma, start, end);
-	}
-
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }
-- 
2.14.4
