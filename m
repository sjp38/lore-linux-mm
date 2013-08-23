Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 795CF6B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 06:31:06 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 20:17:32 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A0A362BB0058
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:57 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7NAUhRo9568596
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:46 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7NAUrpX031936
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:53 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 2/7] mm/hwpoison: don't need to hold compound lock for hugetlbfs page
Date: Fri, 23 Aug 2013 18:30:36 +0800
Message-Id: <1377253841-17620-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
	* drop compound_trans_order completely

compound lock is introduced by commit e9da73d67("thp: compound_lock."),
it is used to serialize put_page against __split_huge_page_refcount().
In addition, transparent hugepages will be splitted in hwpoison handler
and just one subpage will be poisoned. There is unnecessary to hold
compound lock for hugetlbfs page. This patch replace compound_trans_order
by compond_order in the place where the page is hugetlbfs page.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/mm.h  |   14 --------------
 mm/memory-failure.c |   12 ++++++------
 2 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..1745a2a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -489,20 +489,6 @@ static inline int compound_order(struct page *page)
 	return (unsigned long)page[1].lru.prev;
 }
 
-static inline int compound_trans_order(struct page *page)
-{
-	int order;
-	unsigned long flags;
-
-	if (!PageHead(page))
-		return 0;
-
-	flags = compound_lock_irqsave(page);
-	order = compound_order(page);
-	compound_unlock_irqrestore(page, flags);
-	return order;
-}
-
 static inline void set_compound_order(struct page *page, unsigned long order)
 {
 	page[1].lru.prev = (void *)order;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2c13aa7..efa6bd7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -206,7 +206,7 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 #ifdef __ARCH_SI_TRAPNO
 	si.si_trapno = trapno;
 #endif
-	si.si_addr_lsb = compound_trans_order(compound_head(page)) + PAGE_SHIFT;
+	si.si_addr_lsb = compound_order(compound_head(page)) + PAGE_SHIFT;
 
 	if ((flags & MF_ACTION_REQUIRED) && t == current) {
 		si.si_code = BUS_MCEERR_AR;
@@ -983,7 +983,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 static void set_page_hwpoison_huge_page(struct page *hpage)
 {
 	int i;
-	int nr_pages = 1 << compound_trans_order(hpage);
+	int nr_pages = 1 << compound_order(hpage);
 	for (i = 0; i < nr_pages; i++)
 		SetPageHWPoison(hpage + i);
 }
@@ -991,7 +991,7 @@ static void set_page_hwpoison_huge_page(struct page *hpage)
 static void clear_page_hwpoison_huge_page(struct page *hpage)
 {
 	int i;
-	int nr_pages = 1 << compound_trans_order(hpage);
+	int nr_pages = 1 << compound_order(hpage);
 	for (i = 0; i < nr_pages; i++)
 		ClearPageHWPoison(hpage + i);
 }
@@ -1336,7 +1336,7 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
 
-	nr_pages = 1 << compound_trans_order(page);
+	nr_pages = 1 << compound_order(page);
 
 	if (!get_page_unless_zero(page)) {
 		/*
@@ -1491,7 +1491,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	} else {
 		set_page_hwpoison_huge_page(hpage);
 		dequeue_hwpoisoned_huge_page(hpage);
-		atomic_long_add(1 << compound_trans_order(hpage),
+		atomic_long_add(1 << compound_order(hpage),
 				&num_poisoned_pages);
 	}
 	return ret;
@@ -1551,7 +1551,7 @@ int soft_offline_page(struct page *page, int flags)
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
 			dequeue_hwpoisoned_huge_page(hpage);
-			atomic_long_add(1 << compound_trans_order(hpage),
+			atomic_long_add(1 << compound_order(hpage),
 					&num_poisoned_pages);
 		} else {
 			SetPageHWPoison(page);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
