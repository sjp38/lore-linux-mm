Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 77B066B0044
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 19:54:37 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 05:15:52 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 37DB01258053
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:24:38 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8ENuZTn26148964
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:26:35 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8ENsWFJ004762
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:24:32 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [RESEND PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge page 
Date: Sun, 15 Sep 2013 07:53:57 +0800
Message-Id: <1379202839-23939-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 *v1 -> v2: reverse PageTransHuge(page) && !PageHuge(page) check 

PageTransHuge() can't guarantee the page is transparent huge page since it 
return true for both transparent huge and hugetlbfs pages. This patch fix 
it by check the page is also !hugetlbfs page.

Before patch:

[  121.571128] Injecting memory failure at pfn 23a200
[  121.571141] MCE 0x23a200: huge page recovery: Delayed
[  140.355100] MCE: Memory failure is now running on 0x23a200

After patch:

[   94.290793] Injecting memory failure at pfn 23a000
[   94.290800] MCE 0x23a000: huge page recovery: Delayed
[  105.722303] MCE: Software-unpoisoned page 0x23a000

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e28ee77..b114570 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1349,7 +1349,7 @@ int unpoison_memory(unsigned long pfn)
 	 * worked by memory_failure() and the page lock is not held yet.
 	 * In such case, we yield to memory_failure() and make unpoison fail.
 	 */
-	if (PageTransHuge(page)) {
+	if (!PageHuge(page) && PageTransHuge(page)) {
 		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
 			return 0;
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
