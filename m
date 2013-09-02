Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3C0D36B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 08:34:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 2 Sep 2013 22:22:38 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BC05E3578056
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 22:33:58 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82CXiAU64225356
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 22:33:47 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r82CXs53009036
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 22:33:55 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/4] mm/hwpoison: fix miss catch transparent huge page 
Date: Mon,  2 Sep 2013 20:33:42 +0800
Message-Id: <1378125224-12794-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
+	if (PageTransHuge(page) && !PageHuge(page)) {
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
