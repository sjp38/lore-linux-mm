Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 185E46B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 07:57:46 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so1932083pdj.23
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 04:57:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.203])
        by mx.google.com with SMTP id fn9si20502302pab.188.2013.11.14.04.57.43
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 04:57:44 -0800 (PST)
Message-Id: <E1VgwTG-0005fr-5y@yggdrasil.ua.sandberg.pp.se>
From: Andreas Sandberg <andreas@sandberg.pp.se>
Date: Sun, 20 Oct 2013 11:20:59 +0200
Subject: [PATCH] mm: Call MMU notifiers when copying a hugetlb page range
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Steve Capper <steve.capper@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Andreas Sandberg <andreas@sandberg.pp.se>

When copy_hugetlb_page_range is called to copy a range of hugetlb
mappings, the secondary MMUs are not notified if there is a protection
downgrade, which breaks COW semantics in KVM.

This patch adds the necessary MMU notifier calls.

Signed-off-by: Andreas Sandberg <andreas@sandberg.pp.se>
Acked-by: Steve Capper <steve.capper@linaro.org>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
---
 mm/hugetlb.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0b7656e..f5c5002 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2372,16 +2372,26 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	int cow;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
+	int ret;
 
+	ret = 0;
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+	mmun_start = vma->vm_start;
+	mmun_end = vma->vm_end;
+	if (cow)
+		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
 		dst_pte = huge_pte_alloc(dst, addr, sz);
-		if (!dst_pte)
-			goto nomem;
+		if (!dst_pte) {
+			ret = -ENOMEM;
+			break;
+		}
 
 		/* If the pagetables are shared don't copy or take references */
 		if (dst_pte == src_pte)
@@ -2401,10 +2411,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		spin_unlock(&src->page_table_lock);
 		spin_unlock(&dst->page_table_lock);
 	}
-	return 0;
 
-nomem:
-	return -ENOMEM;
+	if (cow)
+		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+
+	return ret;
 }
 
 static int is_hugetlb_entry_migration(pte_t pte)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
