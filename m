Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 842EA6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 18:12:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t187so147733535pfb.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:12:17 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id x69si7317990pfj.283.2017.07.26.15.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 15:12:16 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 2/2] mm: migrate: fix barriers around tlb_flush_pending
Date: Wed, 26 Jul 2017 08:02:14 -0700
Message-ID: <20170726150214.11320-3-namit@vmware.com>
In-Reply-To: <20170726150214.11320-1-namit@vmware.com>
References: <20170726150214.11320-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>

Reading tlb_flush_pending while the page-table lock is taken does not
require a barrier, since the lock/unlock already acts as a barrier.
Removing the barrier in mm_tlb_flush_pending() to address this issue.

However, migrate_misplaced_transhuge_page() calls mm_tlb_flush_pending()
while the page-table lock is already released, which may present a
problem on architectures with weak memory model (PPC). Use
smp_mb__after_unlock_lock() in that case.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/mm_types.h | 18 ++++++++++++------
 mm/migrate.c             |  9 +++++++++
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 36f4ec589544..312eec5690d4 100644
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
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
@@ -535,15 +535,21 @@ static inline void set_tlb_flush_pending(struct mm_struct *mm)
 	atomic_inc(&mm->tlb_flush_pending);
 
 	/*
-	 * Guarantee that the tlb_flush_pending store does not leak into the
+	 * Guarantee that the tlb_flush_pending increase does not leak into the
 	 * critical section updating the page tables
 	 */
 	smp_mb__before_spinlock();
 }
-/* Clearing is done after a TLB flush, which also provides a barrier. */
+
 static inline void clear_tlb_flush_pending(struct mm_struct *mm)
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
diff --git a/mm/migrate.c b/mm/migrate.c
index 89a0a1707f4c..85c7134d70cc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1935,6 +1935,15 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		put_page(new_page);
 		goto out_fail;
 	}
+
+	/*
+	 * mm_tlb_flush_pending() is safe if it is executed while the page-table
+	 * lock is taken. But here, it is executed while the page-table lock is
+	 * already released. This requires a full memory barrier on
+	 * architectures with weak memory models.
+	 */
+	smp_mb__after_unlock_lock();
+
 	/*
 	 * We are not sure a pending tlb flush here is for a huge page
 	 * mapping or not. Hence use the tlb range variant
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
