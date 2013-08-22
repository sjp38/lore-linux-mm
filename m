Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 6C2216B0037
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:48:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 19:35:12 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 04B052BB0056
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:41 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M9WTow9896220
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:32:33 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7M9mZsj016962
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:36 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/6] mm/hwpoison: don't need to hold compound lock for hugetlbfs page 
Date: Thu, 22 Aug 2013 17:48:23 +0800
Message-Id: <1377164907-24801-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

compound lock is introduced by commit e9da73d67("thp: compound_lock."), 
it is used to serialize put_page against __split_huge_page_refcount(). 
In addition, transparent hugepages will be splitted in hwpoison handler 
and just one subpage will be poisoned. There is unnecessary to hold 
compound lock for hugetlbfs page. This patch replace compound_trans_order 
by compond_order in the place where the page is hugetlbfs page.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2c13aa7..5092e06 100644
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
