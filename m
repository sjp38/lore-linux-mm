Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A0480828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:50 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so16322106pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id d3si21159548pas.116.2016.01.08.15.15.49
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:49 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 10/13] x86/mm: Factor out remote TLB flushing
Date: Fri,  8 Jan 2016 15:15:28 -0800
Message-Id: <357b13bf9d6d04e585894ff5dcf40fa14ea1d3a7.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

There are three call sites that propagate TLB flushes, and they all
do exactly the same thing.  Factor the code out into a helper.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 8f4cc3dfac32..b208a33571b0 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -154,6 +154,14 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 	smp_call_function_many(cpumask, flush_tlb_func, &info, 1);
 }
 
+static void propagate_tlb_flush(unsigned int this_cpu,
+				struct mm_struct *mm, unsigned long start,
+				unsigned long end)
+{
+	if (cpumask_any_but(mm_cpumask(mm), this_cpu) < nr_cpu_ids)
+		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
+}
+
 void flush_tlb_current_task(void)
 {
 	struct mm_struct *mm = current->mm;
@@ -166,8 +174,7 @@ void flush_tlb_current_task(void)
 	local_flush_tlb();
 
 	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
-	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
+	propagate_tlb_flush(smp_processor_id(), mm, 0UL, TLB_FLUSH_ALL);
 	preempt_enable();
 }
 
@@ -231,8 +238,7 @@ out:
 		start = 0UL;
 		end = TLB_FLUSH_ALL;
 	}
-	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, start, end);
+	propagate_tlb_flush(smp_processor_id(), mm, start, end);
 	preempt_enable();
 }
 
@@ -257,8 +263,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 		}
 	}
 
-	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, start, 0UL);
+	propagate_tlb_flush(smp_processor_id(), mm, start, 0UL);
 
 	preempt_enable();
 }
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
