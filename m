Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 970BD6B0037
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:40:58 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so3853286pad.37
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:40:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id j3si3200266pdd.56.2014.07.31.08.40.55
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 08:40:55 -0700 (PDT)
Subject: [PATCH 1/7] x86: mm: clean up tlb flushing code
From: Dave Hansen <dave@sr71.net>
Date: Thu, 31 Jul 2014 08:40:54 -0700
References: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
In-Reply-To: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Message-Id: <20140731154054.44F1CDDC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, riel@redhat.com, mgorman@suse.de


From: Dave Hansen <dave.hansen@linux.intel.com>

The

	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)

line of code is not exactly the easiest to audit, especially when
it ends up at two different indentation levels.  This eliminates
one of the the copy-n-paste versions.  It also gives us a unified
exit point for each path through this function.  We need this in
a minute for our tracepoint.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---

 b/arch/x86/mm/tlb.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff -puN arch/x86/mm/tlb.c~simplify-tlb-code arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~simplify-tlb-code	2014-06-30 16:18:05.525535882 -0700
+++ b/arch/x86/mm/tlb.c	2014-06-30 16:18:05.535536335 -0700
@@ -161,23 +161,24 @@ void flush_tlb_current_task(void)
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
+	bool need_flush_others_all = true;
 	unsigned long addr;
 	unsigned act_entries, tlb_entries = 0;
 	unsigned long nr_base_pages;
 
 	preempt_disable();
 	if (current->active_mm != mm)
-		goto flush_all;
+		goto out;
 
 	if (!current->mm) {
 		leave_mm(smp_processor_id());
-		goto flush_all;
+		goto out;
 	}
 
 	if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1
 					|| vmflag & VM_HUGETLB) {
 		local_flush_tlb();
-		goto flush_all;
+		goto out;
 	}
 
 	/* In modern CPU, last level tlb used for both data/ins */
@@ -196,22 +197,20 @@ void flush_tlb_mm_range(struct mm_struct
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
+		need_flush_others_all = false;
 		/* flush range by one by one 'invlpg' */
 		for (addr = start; addr < end;	addr += PAGE_SIZE) {
 			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 			__flush_tlb_single(addr);
 		}
-
-		if (cpumask_any_but(mm_cpumask(mm),
-				smp_processor_id()) < nr_cpu_ids)
-			flush_tlb_others(mm_cpumask(mm), mm, start, end);
-		preempt_enable();
-		return;
 	}
-
-flush_all:
+out:
+	if (need_flush_others_all) {
+		start = 0UL;
+		end = TLB_FLUSH_ALL;
+	}
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
-		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
+		flush_tlb_others(mm_cpumask(mm), mm, start, end);
 	preempt_enable();
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
