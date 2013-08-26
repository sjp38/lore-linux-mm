Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EC62D6B0039
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 04:46:35 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 18:32:55 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8411B357804E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:30 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q8ULL057540680
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:30:27 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7Q8kOtM025140
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:24 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 3/10] mm/hwpoison: fix race against poison thp
Date: Mon, 26 Aug 2013 16:46:07 +0800
Message-Id: <1377506774-5377-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
 * unpoison thp fail  

There is a race between hwpoison page and unpoison page, memory_failure
set the page hwpoison and increase num_poisoned_pages without hold page
lock, and one page count will be accounted against thp for num_poisoned_pages.
However, unpoison can occur before memory_failure hold page lock and
split transparent hugepage, unpoison will decrease num_poisoned_pages
by 1 << compound_order since memory_failure has not yet split transparent
hugepage with page lock held. That means we account one page for hwpoison
and 1 << compound_order for unpoison. This patch fix it by inserting a 
PageTransHuge check before doing TestClearPageHWPoison, unpoison failed 
without clearing PageHWPoison and decreasing num_poisoned_pages.


            A                                                 	B
    	memory_failue
        TestSetPageHWPoison(p);
        if (PageHuge(p))
            nr_pages = 1 << compound_order(hpage);
        else
            nr_pages = 1;
        atomic_long_add(nr_pages, &num_poisoned_pages);
															unpoison_memory
															nr_pages = 1<< compound_trans_order(page);
															if(TestClearPageHWPoison(p))
																atomic_long_sub(nr_pages, &num_poisoned_pages);
        lock page
        if (!PageHWPoison(p))
        	unlock page and return
        hwpoison_user_mappings
        if (PageTransHuge(hpage))
        	split_huge_page(hpage);


Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5a4f4d6..a6c4752 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1339,6 +1339,16 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
 
+	/*
+	 * unpoison_memory() can encounter thp only when the thp is being
+	 * worked by memory_failure() and the page lock is not held yet.
+	 * In such case, we yield to memory_failure() and make unpoison fail.
+	 */
+	if (PageTransHuge(page)) {
+		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
+			return 0;
+	}
+
 	nr_pages = 1 << compound_order(page);
 
 	if (!get_page_unless_zero(page)) {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
