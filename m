Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 964A66B0038
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:55:14 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so171266eaj.35
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 03:55:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s42si23315819eew.203.2013.12.12.03.55.13
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 03:55:13 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] x86: mm: Account for the of CPUs that must be flushed during a TLB range flush
Date: Thu, 12 Dec 2013 11:55:09 +0000
Message-Id: <1386849309-22584-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386849309-22584-1-git-send-email-mgorman@suse.de>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

X86 TLB range flushing uses a balance point to decide if a single global TLB
flush or multiple single page flushes would perform best.  This patch takes into
account how many CPUs must be flushed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/mm/tlb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 09b8cb8..0cababa 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -217,6 +217,9 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	act_entries = mm->total_vm > act_entries ? act_entries : mm->total_vm;
 	nr_base_pages = (end - start) >> PAGE_SHIFT;
 
+	/* Take the number of CPUs to range flush into account */
+	nr_base_pages *= cpumask_weight(mm_cpumask(mm));
+
 	/* tlb_flushall_shift is on balance point, details in commit log */
 	if (nr_base_pages > act_entries || has_large_page(mm, start, end)) {
 		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
