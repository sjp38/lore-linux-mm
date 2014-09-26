Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 42BE06B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 05:55:36 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so2440053lbi.27
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 02:55:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ee12si6370545lbd.126.2014.09.26.02.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 02:55:34 -0700 (PDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [patch added to the 3.12 stable tree] x86/mm: In the PTE swapout page reclaim case clear the accessed bit instead of flushing the TLB
Date: Fri, 26 Sep 2014 11:54:55 +0200
Message-Id: <1411725331-4427-60-git-send-email-jslaby@suse.cz>
In-Reply-To: <1411725331-4427-1-git-send-email-jslaby@suse.cz>
References: <1411725331-4427-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: Shaohua Li <shli@kernel.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

From: Shaohua Li <shli@kernel.org>

This patch has been added to the 3.12 stable tree. If you have any
objections, please let us know.

===============

commit b13b1d2d8692b437203de7a404c6b809d2cc4d99 upstream.

We use the accessed bit to age a page at page reclaim time,
and currently we also flush the TLB when doing so.

But in some workloads TLB flush overhead is very heavy. In my
simple multithreaded app with a lot of swap to several pcie
SSDs, removing the tlb flush gives about 20% ~ 30% swapout
speedup.

Fortunately just removing the TLB flush is a valid optimization:
on x86 CPUs, clearing the accessed bit without a TLB flush
doesn't cause data corruption.

It could cause incorrect page aging and the (mistaken) reclaim of
hot pages, but the chance of that should be relatively low.

So as a performance optimization don't flush the TLB when
clearing the accessed bit, it will eventually be flushed by
a context switch or a VM operation anyway. [ In the rare
event of it not getting flushed for a long time the delay
shouldn't really matter because there's no real memory
pressure for swapout to react to. ]

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fusionio.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Link: http://lkml.kernel.org/r/20140408075809.GA1764@kernel.org
[ Rewrote the changelog and the code comments. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 arch/x86/mm/pgtable.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index dfa537a03be1..5da29d04de2f 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -386,13 +386,20 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
-	int young;
-
-	young = ptep_test_and_clear_young(vma, address, ptep);
-	if (young)
-		flush_tlb_page(vma, address);
-
-	return young;
+	/*
+	 * On x86 CPUs, clearing the accessed bit without a TLB flush
+	 * doesn't cause data corruption. [ It could cause incorrect
+	 * page aging and the (mistaken) reclaim of hot pages, but the
+	 * chance of that should be relatively low. ]
+	 *
+	 * So as a performance optimization don't flush the TLB when
+	 * clearing the accessed bit, it will eventually be flushed by
+	 * a context switch or a VM operation anyway. [ In the rare
+	 * event of it not getting flushed for a long time the delay
+	 * shouldn't really matter because there's no real memory
+	 * pressure for swapout to react to. ]
+	 */
+	return ptep_test_and_clear_young(vma, address, ptep);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
