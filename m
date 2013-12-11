Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D4A426B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:21:13 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so2865143eek.15
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:21:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l2si19016368een.125.2013.12.11.05.21.12
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 05:21:12 -0800 (PST)
Date: Wed, 11 Dec 2013 13:21:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Guarantee that tlb_flush_pending updates are
 visible before page table updates
Message-ID: <20131211132109.GB24125@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

According to documentation on barriers, stores issued before a LOCK can
complete after the lock implying that it's possible tlb_flush_pending can
be visible after a page table update. As per revised documentation, this patch
adds a smp_mb__before_spinlock to guarantee the correct ordering.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c122bb1..a12f2ab 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -482,7 +482,12 @@ static inline bool tlb_flush_pending(struct mm_struct *mm)
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
 {
 	mm->tlb_flush_pending = true;
-	barrier();
+
+	/*
+	 * Guarantee that the tlb_flush_pending store does not leak into the
+	 * critical section updating the page tables
+	 */
+	smp_mb__before_spinlock();
 }
 /* Clearing is done after a TLB flush, which also provides a barrier. */
 static inline void clear_tlb_flush_pending(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
