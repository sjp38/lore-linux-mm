Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id B6AED6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:54:53 -0500 (EST)
Received: by mail-qk0-f175.google.com with SMTP id s68so3495917qkh.3
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 21:54:53 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id v83si2118191qkl.55.2016.02.09.21.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 21:54:52 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 9 Feb 2016 22:54:51 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id CA8C21FF0042
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 22:42:57 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1A5slRt20185122
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 22:54:47 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1A5slsQ020424
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 22:54:47 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/thp/migration: switch from flush_tlb_range to flush_pmd_tlb_range
Date: Wed, 10 Feb 2016 11:24:36 +0530
Message-Id: <1455083676-8685-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We remove one instace of flush_tlb_range here. That was added by
f714f4f20e59ea6eea264a86b9a51fd51b88fc54 ("mm: numa: call MMU notifiers
on THP migration"). But the pmdp_huge_clear_flush_notify should have
done the require flush for us. Hence remove the extra flush.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/migrate.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b1034f9c77e7..c079c115d038 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1767,7 +1767,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		put_page(new_page);
 		goto out_fail;
 	}
-
+	/*
+	 * We are not sure a pending tlb flush here is for a huge page
+	 * mapping or not. Hence use the tlb range variant
+	 */
 	if (mm_tlb_flush_pending(mm))
 		flush_tlb_range(vma, mmun_start, mmun_end);
 
@@ -1823,12 +1826,11 @@ fail_putback:
 	page_add_anon_rmap(new_page, vma, mmun_start, true);
 	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
-	flush_tlb_range(vma, mmun_start, mmun_end);
 	update_mmu_cache_pmd(vma, address, &entry);
 
 	if (page_count(page) != 2) {
 		set_pmd_at(mm, mmun_start, pmd, orig_entry);
-		flush_tlb_range(vma, mmun_start, mmun_end);
+		flush_pmd_tlb_range(vma, mmun_start, mmun_end);
 		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
 		page_remove_rmap(new_page, true);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
