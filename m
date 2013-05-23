Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id F373B6B0033
	for <linux-mm@kvack.org>; Thu, 23 May 2013 04:43:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 23 May 2013 18:32:41 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4FFF33578050
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:43:03 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4N8SrP823265476
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:28:53 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4N8h1gY019107
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:43:01 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 4/4] mm/hugetlb: use already exist interface huge_page_shift
Date: Thu, 23 May 2013 16:42:48 +0800
Message-Id: <1369298568-20094-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v1 -> v2:
	* update alloc_bootmem_huge_page in powerpc 
	* add Michal reviewed-by 

Use already exist interface huge_page_shift instead of h->order + PAGE_SHIFT.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 2 +-
 mm/hugetlb.c                  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 237c8e5..cafec93 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -357,7 +357,7 @@ void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
 int alloc_bootmem_huge_page(struct hstate *hstate)
 {
 	struct huge_bootmem_page *m;
-	int idx = shift_to_mmu_psize(hstate->order + PAGE_SHIFT);
+	int idx = shift_to_mmu_psize(huge_page_shift(hstate));
 	int nr_gpages = gpage_freearray[idx].nr_gpages;
 
 	if (nr_gpages == 0)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f8feeec..b6ff0ee 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -319,7 +319,7 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 
 	hstate = hstate_vma(vma);
 
-	return 1UL << (hstate->order + PAGE_SHIFT);
+	return 1UL << huge_page_shift(hstate);
 }
 EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
