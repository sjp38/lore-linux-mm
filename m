Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD406B003A
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:35:07 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so1377745eek.10
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:35:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si4061602eew.181.2014.01.09.06.35.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:35:06 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] x86: mm: Eliminate redundant page table walk during TLB range flushing
Date: Thu,  9 Jan 2014 14:34:56 +0000
Message-Id: <1389278098-27154-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-1-git-send-email-mgorman@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When choosing between doing an address space or ranged flush, the x86
implementation of flush_tlb_mm_range takes into account whether there are
any large pages in the range. A per-page flush typically requires fewer
entries than would covered by a single large page and the check is redundant.

There is one potential exception. THP migration flushes single THP entries
and it conceivably would benefit from flushing a single entry instead
of the mm. However, this flush is after a THP allocation, copy and page
table update potentially with any other threads serialised behind it. In
comparison to that, the flush is noise. It makes more sense to optimise
balancing to require fewer flushes than to optimise the flush itself.

This patch deletes the redundant huge page check.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/mm/tlb.c | 28 +---------------------------
 1 file changed, 1 insertion(+), 27 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 5176526..dd8dda1 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -158,32 +158,6 @@ void flush_tlb_current_task(void)
 	preempt_enable();
 }
 
-/*
- * It can find out the THP large page, or
- * HUGETLB page in tlb_flush when THP disabled
- */
-static inline unsigned long has_large_page(struct mm_struct *mm,
-				 unsigned long start, unsigned long end)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	unsigned long addr = ALIGN(start, HPAGE_SIZE);
-	for (; addr < end; addr += HPAGE_SIZE) {
-		pgd = pgd_offset(mm, addr);
-		if (likely(!pgd_none(*pgd))) {
-			pud = pud_offset(pgd, addr);
-			if (likely(!pud_none(*pud))) {
-				pmd = pmd_offset(pud, addr);
-				if (likely(!pmd_none(*pmd)))
-					if (pmd_large(*pmd))
-						return addr;
-			}
-		}
-	}
-	return 0;
-}
-
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
@@ -218,7 +192,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	nr_base_pages = (end - start) >> PAGE_SHIFT;
 
 	/* tlb_flushall_shift is on balance point, details in commit log */
-	if (nr_base_pages > act_entries || has_large_page(mm, start, end)) {
+	if (nr_base_pages > act_entries) {
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
