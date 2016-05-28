Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8446A6B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:58:57 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id q18so119563045igr.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:58:57 -0700 (PDT)
Received: from smtp-outbound-2.vmware.com (smtp-outbound-2.vmware.com. [208.91.2.13])
        by mx.google.com with ESMTPS id rd13si16227232pac.120.2016.06.06.12.58.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 12:58:57 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH] x86/mm: Change barriers before TLB flushes to smp_mb__after_atomic
Date: Fri, 27 May 2016 20:16:51 -0700
Message-Id: <1464405413-7209-1-git-send-email-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: nadav.amit@gmail.com, Nadav Amit <namit@vmware.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

When (current->active_mm != mm), flush_tlb_page() does not perform a
memory barrier. In practice, this memory barrier is not needed since in
the existing call-sites the PTE is modified using atomic-operations.
This patch therefore modifies the existing smp_mb in flush_tlb_page to
smp_mb__after_atomic and adds the missing one, while documenting the new
assumption of flush_tlb_page.

In addition smp_mb__after_atomic is also added to
set_tlb_ubc_flush_pending, since it makes a similar implicit assumption
and omits the memory barrier.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/mm/tlb.c | 9 ++++++++-
 mm/rmap.c         | 3 +++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index fe9b9f7..2534333 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -242,6 +242,10 @@ out:
 	preempt_enable();
 }
 
+/*
+ * Calls to flush_tlb_page must be preceded by atomic PTE change or
+ * explicit memory-barrier.
+ */
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -259,8 +263,11 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 			leave_mm(smp_processor_id());
 
 			/* Synchronize with switch_mm. */
-			smp_mb();
+			smp_mb__after_atomic();
 		}
+	} else {
+		/* Synchronize with switch_mm. */
+		smp_mb__after_atomic();
 	}
 
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
diff --git a/mm/rmap.c b/mm/rmap.c
index 307b555..60ab0fe 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -613,6 +613,9 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
 {
 	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
 
+	/* Synchronize with switch_mm. */
+	smp_mb__after_atomic();
+
 	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
 	tlb_ubc->flush_required = true;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
