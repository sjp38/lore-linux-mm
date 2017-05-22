Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE1876B02B4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 18:30:19 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c71so175461956oig.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 15:30:19 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t51si52016otb.245.2017.05.22.15.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 15:30:19 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 01/11] x86/mm: Reimplement flush_tlb_page() using flush_tlb_mm_range()
Date: Mon, 22 May 2017 15:30:01 -0700
Message-Id: <3cc3847cf888d8907577569b8bac3f01992ef8f9.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
In-Reply-To: <cover.1495492063.git.luto@kernel.org>
References: <cover.1495492063.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

flush_tlb_page() was very similar to flush_tlb_mm_range() except that
it had a couple of issues:

 - It was missing an smp_mb() in the case where
   current->active_mm != mm.  (This is a longstanding bug reported by
   Nadav Amit.)

 - It was missing tracepoints and vm counter updates.

The only reason that I can see for keeping it at as a separate
function is that it could avoid a few branches that
flush_tlb_mm_range() needs to decide to flush just one page.  This
hardly seems worthwhile.  If we decide we want to get rid of those
branches again, a better way would be to introduce an
__flush_tlb_mm_range() helper and make both flush_tlb_page() and
flush_tlb_mm_range() use it.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h |  6 +++++-
 arch/x86/mm/tlb.c               | 27 ---------------------------
 2 files changed, 5 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6ed9ea469b48..b9db0f8fef55 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -307,11 +307,15 @@ static inline void flush_tlb_kernel_range(unsigned long start,
 		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)
 
 extern void flush_tlb_all(void);
-extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
+static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
+{
+	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, VM_NONE);
+}
+
 void native_flush_tlb_others(const struct cpumask *cpumask,
 				struct mm_struct *mm,
 				unsigned long start, unsigned long end);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 6e7bedf69af7..fe6471132ea3 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -354,33 +354,6 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	preempt_enable();
 }
 
-void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
-{
-	struct mm_struct *mm = vma->vm_mm;
-
-	preempt_disable();
-
-	if (current->active_mm == mm) {
-		if (current->mm) {
-			/*
-			 * Implicit full barrier (INVLPG) that synchronizes
-			 * with switch_mm.
-			 */
-			__flush_tlb_one(start);
-		} else {
-			leave_mm(smp_processor_id());
-
-			/* Synchronize with switch_mm. */
-			smp_mb();
-		}
-	}
-
-	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, start, start + PAGE_SIZE);
-
-	preempt_enable();
-}
-
 static void do_flush_tlb_all(void *info)
 {
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
