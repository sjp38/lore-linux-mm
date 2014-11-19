Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4316B0070
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 16:14:18 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so1442116ier.41
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 13:14:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b35si246307iod.72.2014.11.19.13.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 13:14:17 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.14 117/122] x86/mm: In the PTE swapout page reclaim case clear the accessed bit instead of flushing the TLB
Date: Wed, 19 Nov 2014 12:52:47 -0800
Message-Id: <20141119205212.727672767@linuxfoundation.org>
In-Reply-To: <20141119205208.812884198@linuxfoundation.org>
References: <20141119205208.812884198@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

3.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Shaohua Li <shli@kernel.org>

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/pgtable.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -399,13 +399,20 @@ int pmdp_test_and_clear_young(struct vm_
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
