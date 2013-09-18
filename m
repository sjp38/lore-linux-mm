Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7592F6B0034
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:39:12 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so6307697pbc.9
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:39:12 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Sep 2013 06:09:06 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5CD55394004E
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:08:51 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8I0fBN436569204
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:11:11 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8I0d3be032151
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:04 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 2/4] mm/hwpoison: fix miss catch transparent huge page
Date: Wed, 18 Sep 2013 08:38:55 +0800
Message-Id: <1379464737-23592-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
Acked-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e28ee77..ed41c63 100644
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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
