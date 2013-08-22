Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 8113C6B0073
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:48:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 19:35:14 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 327F92CE8057
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:41 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M9WVMX66191424
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:32:33 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7M9mcOP012739
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:38 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/6] mm/hwpoison: fix num_poisoned_pages error statistics for thp 
Date: Thu, 22 Aug 2013 17:48:24 +0800
Message-Id: <1377164907-24801-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

There is a race between hwpoison page and unpoison page, memory_failure 
set the page hwpoison and increase num_poisoned_pages without hold page 
lock, and one page count will be accounted against thp for num_poisoned_pages.
However, unpoison can occur before memory_failure hold page lock and 
split transparent hugepage, unpoison will decrease num_poisoned_pages 
by 1 << compound_order since memory_failure has not yet split transparent 
hugepage with page lock held. That means we account one page for hwpoison
and 1 << compound_order for unpoison. This patch fix it by decrease one 
account for num_poisoned_pages against no hugetlbfs pages case.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5092e06..6bfd51e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1350,7 +1350,7 @@ int unpoison_memory(unsigned long pfn)
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
-			atomic_long_sub(nr_pages, &num_poisoned_pages);
+			atomic_long_dec(&num_poisoned_pages);
 		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
 		return 0;
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
