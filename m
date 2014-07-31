Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 64DDE6B0038
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:41:00 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so3689513pdb.17
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:40:59 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id j3si3200266pdd.56.2014.07.31.08.40.57
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 08:40:58 -0700 (PDT)
Subject: [PATCH 3/7] x86: mm: fix missed global TLB flush stat
From: Dave Hansen <dave@sr71.net>
Date: Thu, 31 Jul 2014 08:40:56 -0700
References: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
In-Reply-To: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Message-Id: <20140731154056.FF763B76@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, riel@redhat.com, mgorman@suse.de


From: Dave Hansen <dave.hansen@linux.intel.com>

If we take the

	if (end == TLB_FLUSH_ALL || vmflag & VM_HUGETLB) {
		local_flush_tlb();
		goto out;
	}

path out of flush_tlb_mm_range(), we will have flushed the tlb,
but not incremented NR_TLB_LOCAL_FLUSH_ALL.  This unifies the
way out of the function so that we always take a single path when
doing a full tlb flush.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---

 b/arch/x86/mm/tlb.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff -puN arch/x86/mm/tlb.c~fix-missed-global-flush-stat arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~fix-missed-global-flush-stat	2014-06-30 16:18:26.857507178 -0700
+++ b/arch/x86/mm/tlb.c	2014-06-30 16:18:26.864507497 -0700
@@ -164,8 +164,9 @@ unsigned long tlb_single_page_flush_ceil
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
-	int need_flush_others_all = 1;
 	unsigned long addr;
+	/* do a global flush by default */
+	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
 
 	preempt_disable();
 	if (current->active_mm != mm)
@@ -176,16 +177,14 @@ void flush_tlb_mm_range(struct mm_struct
 		goto out;
 	}
 
-	if (end == TLB_FLUSH_ALL || vmflag & VM_HUGETLB) {
-		local_flush_tlb();
-		goto out;
-	}
+	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
+		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
-	if ((end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
+	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
+		base_pages_to_flush = TLB_FLUSH_ALL;
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
-		need_flush_others_all = 0;
 		/* flush range by one by one 'invlpg' */
 		for (addr = start; addr < end;	addr += PAGE_SIZE) {
 			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
@@ -193,7 +192,7 @@ void flush_tlb_mm_range(struct mm_struct
 		}
 	}
 out:
-	if (need_flush_others_all) {
+	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
 		end = TLB_FLUSH_ALL;
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
