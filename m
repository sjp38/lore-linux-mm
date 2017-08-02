Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 668816B0549
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:18:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p20so38767097pfj.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:18:45 -0700 (PDT)
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id 67si4838020pfv.603.2017.08.02.00.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:18:44 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 2/7] mm: migrate: fix barriers around tlb_flush_pending
Date: Tue, 1 Aug 2017 17:08:13 -0700
Message-ID: <20170802000818.4760-3-namit@vmware.com>
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@suse.de>

Reading tlb_flush_pending while the page-table lock is taken does not
require a barrier, since the lock/unlock already acts as a barrier.
Removing the barrier in mm_tlb_flush_pending() to address this issue.

However, migrate_misplaced_transhuge_page() calls mm_tlb_flush_pending()
while the page-table lock is already released, which may present a
problem on architectures with weak memory model (PPC). To deal with this
case, a new parameter is added to mm_tlb_flush_pending() to indicate
if it is read without the page-table lock taken, and calling
smp_mb__after_unlock_lock() in this case.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>

Signed-off-by: Nadav Amit <namit@vmware.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_types.h | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f5263dd0f1bc..2956513619a7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -522,12 +522,12 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
  * the page table locks, outside of which no page table modifications happen.
- * The barriers below prevent the compiler from re-ordering the instructions
- * around the memory barriers that are already present in the code.
+ * The barriers are used to ensure the order between tlb_flush_pending updates,
+ * which happen while the lock is not taken, and the PTE updates, which happen
+ * while the lock is taken, are serialized.
  */
 static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
 {
-	barrier();
 	return atomic_read(&mm->tlb_flush_pending) > 0;
 }
 
@@ -550,7 +550,13 @@ static inline void inc_tlb_flush_pending(struct mm_struct *mm)
 /* Clearing is done after a TLB flush, which also provides a barrier. */
 static inline void dec_tlb_flush_pending(struct mm_struct *mm)
 {
-	barrier();
+	/*
+	 * Guarantee that the tlb_flush_pending does not not leak into the
+	 * critical section, since we must order the PTE change and changes to
+	 * the pending TLB flush indication. We could have relied on TLB flush
+	 * as a memory barrier, but this behavior is not clearly documented.
+	 */
+	smp_mb__before_atomic();
 	atomic_dec(&mm->tlb_flush_pending);
 }
 #else
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
