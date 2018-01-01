Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D12D6B0253
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:28:33 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id g12so24880995wra.2
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:28:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d12si18053187wrf.65.2018.01.01.06.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:28:32 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 27/63] x86/mm: Reimplement flush_tlb_page() using flush_tlb_mm_range()
Date: Mon,  1 Jan 2018 15:24:45 +0100
Message-Id: <20180101140047.136596660@linuxfoundation.org>
In-Reply-To: <20180101140042.456380281@linuxfoundation.org>
References: <20180101140042.456380281@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav Amit <namit@vmware.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit ca6c99c0794875c6d1db6e22f246699691ab7e6b upstream.

flush_tlb_page() was very similar to flush_tlb_mm_range() except that
it had a couple of issues:

 - It was missing an smp_mb() in the case where
   current->active_mm != mm.  (This is a longstanding bug reported by Nadav Amit)

 - It was missing tracepoints and vm counter updates.

The only reason that I can see for keeping it at as a separate
function is that it could avoid a few branches that
flush_tlb_mm_range() needs to decide to flush just one page.  This
hardly seems worthwhile.  If we decide we want to get rid of those
branches again, a better way would be to introduce an
__flush_tlb_mm_range() helper and make both flush_tlb_page() and
flush_tlb_mm_range() use it.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Acked-by: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/3cc3847cf888d8907577569b8bac3f01992ef8f9.1495492063.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |    6 +++++-
 arch/x86/mm/tlb.c               |   27 ---------------------------
 2 files changed, 5 insertions(+), 28 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -296,11 +296,15 @@ static inline void flush_tlb_kernel_rang
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
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -339,33 +339,6 @@ out:
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
