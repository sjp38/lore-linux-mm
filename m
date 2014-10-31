Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2FDAE280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:22:19 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so6488273pdj.14
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 21:22:18 -0700 (PDT)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id cd13si8207990pdb.188.2014.10.30.21.22.16
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 21:22:18 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: [RFC patch] mm: hugetlb: fix __unmap_hugepage_range
Date: Fri, 31 Oct 2014 12:22:12 +0800
Message-ID: <028701cff4c2$3e9e2ca0$bbda85e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

First, after flushing TLB, we have no need to scan pte from start again.
Second, before bail out loop, the address is forwarded one step.

Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---

--- a/mm/hugetlb.c	Fri Oct 31 11:47:25 2014
+++ b/mm/hugetlb.c	Fri Oct 31 11:52:42 2014
@@ -2641,8 +2641,9 @@ void __unmap_hugepage_range(struct mmu_g
 
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	address = start;
 again:
-	for (address = start; address < end; address += sz) {
+	for (; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
@@ -2689,6 +2690,7 @@ again:
 		page_remove_rmap(page);
 		force_flush = !__tlb_remove_page(tlb, page);
 		if (force_flush) {
+			address += sz;
 			spin_unlock(ptl);
 			break;
 		}
--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
